const std = @import("std");

const mimeTypes = @import("src/mimeTypes.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_mod.addImport("say-lib", lib_mod);

    const lib = b.addLibrary(.{
        .name = "zig-say",
        .root_module = lib_mod,
    });
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "zig-say",
        .root_module = exe_mod,
    });
    const templates_paths = try templatesPaths(
        b.allocator,
        &.{
            .{ .prefix = "views", .path = &.{ "resources", "views" } },
        },
    );
    const zmpl = b.dependency(
        "zmpl",
        .{
            .target = target,
            .optimize = optimize,
            .zmpl_templates_paths = templates_paths,
            .zmpl_auto_build = false,
            .zmpl_markdown_fragments = try generateMarkdownFragments(b),
            .zmpl_constants = try addTemplateConstants(b, struct {
                say_view: []const u8,
            }),
        },
    );
    exe.root_module.addImport("zmpl", zmpl.module("zmpl"));
    lib_mod.addImport("zmpl", zmpl.module("zmpl"));

    const httpz = b.dependency("httpz", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("httpz", httpz.module("httpz"));
    lib_mod.addImport("httpz", httpz.module("httpz"));

    const myzql_dep = b.dependency("myzql", .{});
    exe.root_module.addImport("myzql", myzql_dep.module("myzql"));
    lib_mod.addImport("myzql", myzql_dep.module("myzql"));

    const mime_module = try mimeTypes.generateMimeModule(b);
    exe.root_module.addImport("mime_types", mime_module);
    lib_mod.addImport("mime_types", mime_module);

    const zig_time_dep = b.dependency("zigtime", .{});
    exe.root_module.addImport("zig-time", zig_time_dep.module("zig-time"));
    lib_mod.addImport("zig-time", zig_time_dep.module("zig-time"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

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
    const source = try file.readToEndAllocOptions(b.allocator, @intCast(stat.size), null, .@"1", 0);
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
                const node_index: std.zig.Ast.Node.Index = @enumFromInt(index);
                const decl = ast.simpleVarDecl(node_index);
                const identifier = ast.tokenSlice(decl.ast.mut_token + 1);
                if (std.mem.eql(u8, identifier, "markdown_fragments")) {
                    return ast.getNodeSource(node_index);
                }
            },
            else => continue,
        }
    }

    return null;
}

const TemplatesPath = struct {
    prefix: []const u8,
    path: []const []const u8,
};

fn templatesPaths(allocator: std.mem.Allocator, paths: []const TemplatesPath) ![]const []const u8 {
    var buf = std.array_list.Managed([]const u8).init(allocator);
    for (paths) |path| {
        const joined = try std.fs.path.join(allocator, path.path);
        defer allocator.free(joined);

        const absolute_path = if (std.fs.path.isAbsolute(joined))
            try allocator.dupe(u8, joined)
        else
            std.fs.cwd().realpathAlloc(allocator, joined) catch |err|
                switch (err) {
                    error.FileNotFound => "_",
                    else => return err,
                };

        try buf.append(
            try std.mem.concat(allocator, u8, &.{ "prefix=", path.prefix, ",path=", absolute_path }),
        );
    }

    return buf.toOwnedSlice();
}

fn addTemplateConstants(b: *std.Build, comptime constants: type) ![]const u8 {
    const fields = switch (@typeInfo(constants)) {
        .@"struct" => |info| info.fields,
        else => @panic("Expected struct, found: " ++ @typeName(constants)),
    };
    var array: [fields.len][]const u8 = undefined;

    inline for (fields, 0..) |field, index| {
        array[index] = std.fmt.comptimePrint(
            "{s}#{s}",
            .{ field.name, @typeName(field.type) },
        );
    }

    return std.mem.join(b.allocator, "|", &array);
}
