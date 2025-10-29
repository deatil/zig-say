const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-lib");
const App = lib.global.App;
const config = lib.global.config;
const views = lib.views;
const auth = lib.utils.auth;
const http = lib.utils.http;

const model = @import("./../../model/lib.zig");
const admin_model = model.admin;

pub fn login(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;

    var cookies = req.cookies();
    const login_data = cookies.get("admin_login") orelse "";
    if (login_data.len > 0) {
        const login_username = auth.decrypt(res.arena, login_data, config.auth.key, config.auth.iv) catch "";
        if (login_username.len > 0) {
            res.status = 303;
            res.header("Location", "/admin/index");
            return;
        } else {
            try http.delCookie(res, "admin_login");
        }
    }

    var data = views.datas(res.arena);
    try views.view(res, "admin/auth/login", &data);
}

pub fn loginSave(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    var cookies = req.cookies();
    const login_data = cookies.get("admin_login") orelse "";

    const login_username = auth.decrypt(res.arena, login_data, config.auth.key, config.auth.iv) catch "";
    if (login_username.len > 0) {
        try res.json(.{
            .code = 1,
            .msg = "你已经登录了",
        }, .{});
    }

    if (req.body() == null) {
        try res.json(.{
            .code = 1,
            .msg = "账号不能为空",
        }, .{});
        return;
    }

    const fd = try http.parseFormData(res.arena, req.body().?);

    const username = fd.get("username") orelse "";
    const password = fd.get("password") orelse "";

    if (username.len == 0 or password.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "账号或者密码不能为空",
        }, .{});
        return;
    }

    const admin_info = admin_model.getInfoByUsername(res.arena, app.db, username) catch {
        try res.json(.{
            .code = 1,
            .msg = "账号或者密码错误",
        }, .{});
        return;
    };
    if (admin_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "账号或者密码错误",
        }, .{});
        return;
    }

    if (!auth.checkPasswordHash(password, admin_info.password)) {
        try res.json(.{
            .code = 1,
            .msg = "账号或者密码错误",
        }, .{});
        return;
    }

    const username_encoded = auth.encrypt(res.arena, admin_info.username, config.auth.key, config.auth.iv) catch {
        try res.json(.{
            .code = 1,
            .msg = "账号或者密码错误",
        }, .{});
        return;
    };

    try http.setCookie(res, "admin_login", username_encoded);

    try res.json(.{
        .code = 0,
        .msg = "登录成功",
    }, .{});
}

pub fn logout(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;

    var cookies = req.cookies();
    const login_data = cookies.get("admin_login") orelse "";

    const login_username = auth.decrypt(res.arena, login_data, config.auth.key, config.auth.iv) catch "";
    if (login_username.len > 0) {
        try http.delCookie(res, "admin_login");
    }

    res.status = 303;
    res.header("Location", "/admin/auth/login");
}
