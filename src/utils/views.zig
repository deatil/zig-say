const std = @import("std");
const Allocator = std.mem.Allocator;

const httpz = @import("httpz");
const vin = @import("zig-vin");

const say = @import("say");
const App = say.global.App;
const time = say.utils.time.time;
const config = say.config;

pub fn datas(alloc: Allocator, val: anytype) !vin.Value {
    const ctx = try vin.valueFrom(alloc, val);
    return ctx;
}

pub fn view(app: *App, resp: *httpz.Response, tpl: []const u8, data: anytype) !void {
    const ctx = try vin.valueFrom(resp.arena, .{
        .data = data,
        .context = .{
            .webname = config.app.name,
        },
    });

    var diag: vin.Diagnostic = undefined;

    const output = app.view.renderTemplateAlloc(tpl, ctx, &diag) catch |err| {
        var msg = try resp.arena.dupe(u8, "View Not Found");

        const debug = config.app.debug;
        if (debug) {
            if (diag.len > 0 and diag.len <= 512) {
                msg = try resp.arena.print("[View]{s}: {f}", .{tpl, diag});
            } else {
                msg = try resp.arena.print("[View]{s}: {s}", .{tpl, @errorName(err)});
            }
        }

        resp.status = 200;
        resp.header("content-type", "text/html");
        resp.body = msg;

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

pub fn fFormatTime(ctx: *vin.FilterCtx, args: vin.FilterArgs) vin.FilterError!vin.Value {
    const time_v = args.get(0, "time") orelse return error.BadArgument;
    const fmt_v = args.get(1, "fmt") orelse vin.Value.empty_string;

    const fmt = ctx.toStr(fmt_v) catch "YYYY-MM-DD HH:mm:ss";
    _ = fmt;

    if (time_v != .integer) return error.BadArgument;
    if (time_v.integer < 0) return error.BadArgument;
    const time_int: i64 = @intCast(time_v.integer);

    const time_str = time.Time.fromTimestamp(time_int).formatAlloc(ctx.arena, "YYYY-MM-DD HH:mm:ss") catch return error.BadArgument;

    return .{ .string = .{ .bytes = time_str, .safe = false } };
}
