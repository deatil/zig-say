const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-lib");
const App = lib.global.App;
const config = lib.global.config;
const views = lib.views;
const auth = lib.utils.auth;

const model = @import("./../../model/lib.zig");
const admin_model = model.admin;

pub fn login(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    var data = views.datas(res.arena);
    defer data.deinit();

    try views.view(res, "admin/auth/login", &data);
}

pub fn loginSave(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const fd = try req.formData();

    var it = fd.iterator();
    while (it.next()) |kv| {
        std.debug.print("{s}: {s} \n", .{kv.key, kv.value});
    }

    if (fd.get("username") == null) {
        try res.json(.{
            .code = 1,
            .msg = "username empty",
        }, .{});
        return;
    }
    if (fd.get("password") == null) {
        try res.json(.{
            .code = 1,
            .msg = "password empty",
        }, .{});
        return;
    }

    const username = fd.get("username").?;
    const password = fd.get("password").?;

    const admin_info = admin_model.getInfoByUsername(res.arena, app, username) catch {
        try res.json(.{
            .code = 1,
            .msg = "user or pass not exists",
        }, .{});
        return;
    };
    if (admin_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "user or pass not exists",
        }, .{});
        return;
    }

    if (!auth.checkPasswordHash(password, admin_info.password)) {
        try res.json(.{
            .code = 1,
            .msg = "user or pass not exists",
        }, .{});
        return;
    }

    const username_encoded = auth.encrypt(res.arena, admin_info.username, config.auth.key, config.auth.iv) catch {
        try res.json(.{
            .code = 1,
            .msg = "user or pass not exists",
        }, .{});
        return;
    };

    try res.setCookie("admin_login", username_encoded, .{
        .path = "/",
        .max_age = 1_000_000_000,
        .http_only = true,
        .partitioned = true,
        .same_site = .none,  // or .none, or .strict (or null to leave out)
    });

    try res.json(.{
        .code = 0,
        .msg = "login success",
    }, .{});
}

