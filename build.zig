const std = @import("std");
const Io = std.Io;

const mimeTypes = @import("src/mimeTypes.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_mod.addImport("say-pkg", lib_mod);

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_mod.addImport("say-pkg", lib_mod);

    const lib = b.addLibrary(.{
        .name = "zig-say",
        .root_module = lib_mod,
    });
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "zig-say",
        .root_module = exe_mod,
    });

    const io = b.graph.io;
    const path = &.{ "resources", "views" };
    const tmp_path = try templatesPaths(b.allocator, io, path);

    const opts = b.addOptions();
    opts.addOption([]const u8, "tmp_path", tmp_path);
    exe.root_module.addImport("say-opts", opts.createModule());
    lib_mod.addImport("say-opts", opts.createModule());

    const zig_vin_dep = b.dependency("zig-vin", .{});
    exe.root_module.addImport("zig-vin", zig_vin_dep.module("zig-vin"));
    lib_mod.addImport("zig-vin", zig_vin_dep.module("zig-vin"));

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

fn templatesPaths(allocator: std.mem.Allocator, io: Io, paths: []const []const u8) ![]const u8 {
    const joined = try std.fs.path.join(allocator, paths);
    defer allocator.free(joined);

    const absolute_path = if (std.fs.path.isAbsolute(joined))
        try allocator.dupe(u8, joined)
    else
        std.Io.Dir.cwd().realPathFileAlloc(io, joined, allocator) catch |err|
            switch (err) {
                error.FileNotFound => "_",
                else => return err,
            };

    return absolute_path;
}

