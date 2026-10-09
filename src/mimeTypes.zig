const std = @import("std");

const JsonMimeType = struct {
    name: []const u8,
    fileTypes: [][]const u8,
};

pub fn generateMimeModule(build: *std.Build) !*std.Build.Module {
    const io = build.graph.io;
    const mime_path = try std.Io.Dir.cwd().realPathFileAlloc(io, "./resources/mime/mimeData.json", build.allocator);

    const file = try std.Io.Dir.openFileAbsolute(io, mime_path, .{});
    const stat = try file.stat(io);

    const json = try build.allocator.alloc(u8, @intCast(stat.size));
    defer build.allocator.free(json);
    
    _ = try file.readPositionalAll(io, json, 0);

    const parsed_mime_types = try std.json.parseFromSlice(
        []JsonMimeType,
        build.allocator,
        json,
        .{ .ignore_unknown_fields = true },
    );

    var buf = std.array_list.Managed(u8).init(build.allocator);
    defer buf.deinit();

    try buf.appendSlice("pub const MimeType = struct { name: []const u8, file_type: []const u8 };");
    try buf.appendSlice("pub const mime_types = [_]MimeType{\n");
    for (parsed_mime_types.value) |mime_type| {
        for (mime_type.fileTypes) |file_type| {
            const entry = try build.allocator.print(
                \\.{{ .name = "{s}", .file_type = "{s}" }},
                \\
            ,
                .{ mime_type.name, file_type },
            );
            try buf.appendSlice(entry);
        }
    }
    try buf.appendSlice("};\n");

    const write_files = build.addWriteFiles();
    const generated_file = write_files.add("mime_types.zig", buf.items);
    return build.createModule(.{ .root_source_file = generated_file });
}
