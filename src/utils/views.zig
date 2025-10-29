const std = @import("std");
const zmpl = @import("zmpl");
const httpz = @import("httpz");
const Allocator = std.mem.Allocator;

pub fn datas(allocator: Allocator) zmpl.Data {
    return zmpl.Data.init(allocator);
}

pub fn view(resp: *httpz.Response, tpl: []const u8, data: *zmpl.Data) !void {
    const Context = struct { webname: []const u8 = "zig-say" };
    const context = Context{ .webname = "Zig-say" };

    try data.addConst("say_view", data.string("test"));

    if (zmpl.find(tpl)) |template| {
        const output = try template.render(data, Context, context, &.{}, .{});
        resp.status = 200;
        resp.header("content-type", "text/html");
        resp.body = output;
    } else {
        resp.status = 200;
        resp.header("content-type", "text/html");
        resp.body = "View Not Found";
    }
}

pub fn errorAdminView(res: *httpz.Response, msg: []const u8, url: []const u8) !void {
    var data = datas(res.arena);

    var body = try data.object();
    try body.put("message", data.string(msg));
    try body.put("url", data.string(url));

    try view(res, "admin/error/index", &data);
}

pub fn errorView(res: *httpz.Response, msg: []const u8, url: []const u8) !void {
    var data = datas(res.arena);

    var body = try data.object();
    try body.put("message", data.string(msg));
    try body.put("url", data.string(url));

    try view(res, "index/error/index", &data);
}
