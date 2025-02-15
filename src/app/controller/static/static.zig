const std = @import("std");
const builtin = @import("builtin");
const mem = std.mem;

const httpz = @import("httpz");
const zmpl = @import("zmpl");

const lib = @import("say-lib");
const App = lib.global.App;
const config = lib.global.config;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const static_res = try matchPublicContent(app, req);
    if (static_res) |static_data| {
        res.status = 200;
        res.body = static_data.content;
        res.header("content-type", static_data.mime_type);
        return;
    }

    res.status = 404;
    res.body = "Not Found";
}

const StaticResource = struct {
    content: []const u8,
    mime_type: []const u8 = "application/octet-stream",
};

fn matchPublicContent(app: *App, request: *httpz.Request) !?StaticResource {
    if (request.url.path.len <= 1) return null;
    if (request.method != .GET) return null;

    const sep = "/static/";
    const public_file_path = mem.trimLeft(u8, request.url.path, sep);

    var iterable_dir = std.fs.cwd().openDir(
        config.app.public_path,
        .{ .iterate = true, .no_follow = true },
    ) catch |err| {
        switch (err) {
            error.FileNotFound => return null,
            else => return err,
        }
    };
    defer iterable_dir.close();

    var walker = try iterable_dir.walk(request.arena);
    defer walker.deinit();

    var path_buffer: [256]u8 = undefined;
    while (try walker.next()) |file| {
        if (file.kind != .file) continue;
        const file_path = if (builtin.os.tag == .windows) blk: {
            _ = std.mem.replace(u8, file.path, std.fs.path.sep_str_windows, std.fs.path.sep_str_posix, &path_buffer);
            break :blk path_buffer[0..file.path.len];
        } else file.path;

        if (std.mem.eql(u8, file_path, public_file_path[0..])) {
            const content = try iterable_dir.readFileAlloc(
                request.arena,
                file_path,
                config.app.max_bytes_public_content,
            );

            const extension = std.fs.path.extension(file_path);
            const mime_type = if (app.mime_map.get(extension)) |mime| mime else "application/octet-stream";
            
            return .{
                .content = content,
                .mime_type = mime_type,
            };
        }
    }

    return null;
}

