const std = @import("std");

const httpz = @import("httpz");
const zig_time = @import("zig-time");

const lib = @import("say-pkg");
const App = lib.global.App;
const views = lib.views;
const auth = lib.utils.auth;
const http = lib.utils.http;

const user_model = lib.app.model.user;

pub fn login(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = req;

    const data = try views.datas(res.arena, .{});

    try views.view(app, res, "index/auth/login", data);
}

pub fn loginSave(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    var cookies = req.cookies();
    const loginid = cookies.get("loginid") orelse "";
    if (loginid.len > 0) {
        try res.json(.{
            .code = 1,
            .msg = "你已经登录",
        }, .{});
        return;
    }

    var s: []u8 = try res.arena.alloc(u8, 12);
    app.io.random(s[0..]);

    defer res.arena.free(s);

    const str_encoded = try auth.bytesToHex(res.arena, s, .lower);

    const add_time = zig_time.now(app.io).unix();

    const ok: bool = user_model.addInfo(res.arena, app.io, app.db, .{
        .username = str_encoded,
        .cookie = str_encoded,
        .sign = "",
        .status = 1,
        .add_time = @intCast(add_time),
        .add_ip = "",
    }) catch false;
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "登录失败",
        }, .{});
        return;
    }

    try http.setCookie(res, "loginid", str_encoded);

    try res.json(.{
        .code = 0,
        .msg = "登录成功",
    }, .{});
}

pub fn logout(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    try http.delCookie(res, "loginid");

    res.status = 303;
    res.header("Location", "/auth/login");
}
