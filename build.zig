const std = @import("std");

const zmpl_build = @import("zmpl");
const mimeTypes = @import("src/mimeTypes.zig");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // This creates a "module", which represents a collection of source files alongside
    // some compilation options, such as optimization mode and linked system libraries.
    // Every executable or library we compile will be based on one or more modules.
    const lib_mod = b.createModule(.{
        // `root_source_file` is the Zig "entry point" of the module. If a module
        // only contains e.g. external object files, you can make this `null`.
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // We will also create a module for our other entry point, 'main.zig'.
    const exe_mod = b.createModule(.{
        // `root_source_file` is the Zig "entry point" of the module. If a module
        // only contains e.g. external object files, you can make this `null`.
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Modules can depend on one another using the `std.Build.Module.addImport` function.
    // This is what allows Zig source code to use `@import("foo")` where 'foo' is not a
    // file path. In this case, we set up `exe_mod` to import `lib_mod`.
    exe_mod.addImport("say-lib", lib_mod);

    // Now, we will create a static library based on the module we created above.
    // This creates a `std.Build.Step.Compile`, which is the build step responsible
    // for actually invoking the compiler.
    const lib = b.addStaticLibrary(.{
        .name = "zig-say",
        .root_module = lib_mod,
    });

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    // This creates another `std.Build.Step.Compile`, but this one builds an executable
    // rather than a static library.
    const exe = b.addExecutable(.{
        .name = "zig-say",
        .root_module = exe_mod,
    });

    // zmpl
    const templates_paths = try zmpl_build.templatesPaths(
        b.allocator,
        &.{
            .{ .prefix = "views", .path = &.{ "resources", "views" } },
        },
    );
    const zmpl = b.dependency("zmpl", .{
            .target = target,
            .optimize = optimize,
            .zmpl_templates_paths = templates_paths,
            .zmpl_auto_build = false,
            .zmpl_markdown_fragments = try generateMarkdownFragments(b),
            .zmpl_constants = try zmpl_build.addTemplateConstants(b, struct {
                say_view: []const u8,
            }),
        },
    );
    exe.root_module.addImport("zmpl", zmpl.module("zmpl"));
    lib_mod.addImport("zmpl", zmpl.module("zmpl"));

    // httpz
    const httpz = b.dependency("httpz", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("httpz", httpz.module("httpz"));
    lib_mod.addImport("httpz", httpz.module("httpz"));

    // myzql
    const myzql_dep = b.dependency("myzql", .{});
    exe.root_module.addImport("myzql", myzql_dep.module("myzql"));
    lib_mod.addImport("myzql", myzql_dep.module("myzql"));

    // mimeTypes
    const mime_module = try mimeTypes.generateMimeModule(b);
    exe.root_module.addImport("mime_types", mime_module);
    lib_mod.addImport("mime_types", mime_module);

    // zig-time
    const zig_time_dep = b.dependency("zig-time", .{});
    exe.root_module.addImport("zig-time", zig_time_dep.module("zig-time"));
    lib_mod.addImport("zig-time", zig_time_dep.module("zig-time"));

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}

fn generateMarkdownFragments(b: *std.Build) ![]const u8 {
    const file = std.fs.cwd().openFile(b.pathJoin(&.{ "src", "main.zig" }), .{}) catch |err| {
        switch (err) {
            error.FileNotFound => return "",
            else => return err,
        }
    };
    const stat = try file.stat();
    const source = try file.readToEndAllocOptions(b.allocator, @intCast(stat.size), null, @alignOf(u8), 0);
    if (try getMarkdownFragmentsSource(b.allocator, source)) |markdown_fragments_source| {
        return try std.fmt.allocPrint(b.allocator,
            \\const std = @import("std");
            \\const zmd = @import("zmd");
            \\
            \\{s};
            \\
        , .{markdown_fragments_source});
    } else {
        return "";
    }
}

fn getMarkdownFragmentsSource(allocator: std.mem.Allocator, source: [:0]const u8) !?[]const u8 {
    var ast = try std.zig.Ast.parse(allocator, source, .zig);
    defer ast.deinit(allocator);

    for (ast.nodes.items(.tag), 0..) |tag, index| {
        switch (tag) {
            .simple_var_decl => {
                const decl = ast.simpleVarDecl(@intCast(index));
                const identifier = ast.tokenSlice(decl.ast.mut_token + 1);
                if (std.mem.eql(u8, identifier, "markdown_fragments")) {
                    return ast.getNodeSource(@intCast(index));
                }
            },
            else => continue,
        }
    }

    return null;
}


