const std = @import("std");
const Allocator = std.mem.Allocator;

const httpz = @import("httpz");
const vin = @import("zig-vin");

const App = @import("say-pkg").global.App;

pub fn datas(alloc: Allocator, val: anytype) !vin.Value {
    const ctx = try vin.valueFrom(alloc, val);
    return ctx;
}

pub fn view(app: *App, resp: *httpz.Response, tpl: []const u8, data: anytype) !void {
    const ctx = try vin.valueFrom(resp.arena, .{
        .data = data,
        .context = .{
            .webname = "Zig-say",
        },
    });

    const output = app.view.renderTemplateAlloc(resp.arena, tpl, ctx, null) catch |err| {
        std.debug.print("error: {any} \n", .{err});

        resp.status = 200;
        resp.header("content-type", "text/html");
        resp.body = "View Not Found";

        return;
    };

    resp.status = 200;
    resp.header("content-type", "text/html");
    resp.body = output;
}

pub fn errorAdminView(app: *App, res: *httpz.Response, msg: []const u8, url: []const u8) !void {
    const data = try datas(res.arena, .{
        .message = msg,
        .url = url,
    });

    try view(app, res, "admin/error/index", data);
}

pub fn errorView(app: *App, res: *httpz.Response, msg: []const u8, url: []const u8) !void {
    const data = try datas(res.arena, .{
        .message = msg,
        .url = url,
    });

    try view(app, res, "index/error/index", data);
}
