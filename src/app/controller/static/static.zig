const std = @import("std");
const Allocator = std.mem.Allocator;

const httpz = @import("httpz");
const zmpl = @import("zmpl");

const lib = @import("say-lib");
const App = lib.global.App;
const config = lib.global.config;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const static_res = try matchPublicContent(res.arena, app, req);
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

fn matchPublicContent(alloc: Allocator, app: *App, request: *httpz.Request) !?StaticResource {
    if (request.url.path.len <= 1) return null;
    if (request.method != .GET) return null;

    const sep = "/static/";
    const public_file_path = request.url.path[sep.len..];

    const joined = try std.fs.path.join(alloc, &.{ config.app.public_path, public_file_path });
    defer alloc.free(joined);

    const absolute_path = if (std.fs.path.isAbsolute(joined))
        try alloc.dupe(u8, joined)
    else
        std.fs.cwd().realpathAlloc(alloc, joined) catch {
            return null;
        };

    var open_file = std.fs.cwd().openFile(absolute_path, .{ .mode = .read_only }) catch {
       return null;
    };
    defer open_file.close();

    const extension = std.fs.path.extension(public_file_path);
    const mime_type = if (app.mime_map.get(extension)) |mime| mime else "application/octet-stream";

    const file_length = (try open_file.metadata()).size();
    const content = try open_file.readToEndAlloc(alloc, file_length);

    return .{
        .content = content,
        .mime_type = mime_type,
    };
}

