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

pub fn password(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    var data = views.datas(res.arena);

    try views.view(res, "admin/profile/password", &data);
}

pub fn passwordSave(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    if (req.body() == null) {
        try res.json(.{
            .code = 1,
            .msg = "update data empty",
        }, .{});
        return;
    }

    const fd = try http.parseFormData(res.arena, req.body().?);

    const oldpassword = fd.get("oldpassword") orelse "";
    const newpassword = fd.get("newpassword") orelse "";
    const newpassword2 = fd.get("newpassword2") orelse "";

    if (oldpassword.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "old password not empty",
        }, .{});
        return;
    }
    if (newpassword.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "new password not empty",
        }, .{});
        return;
    }
    if (!std.mem.eql(u8, newpassword, newpassword2)) {
        try res.json(.{
            .code = 1,
            .msg = "newpassword2 not eq newpassword",
        }, .{});
        return;
    }

    const admin_login = req.header("admin_login") orelse "";

    const admin_info = admin_model.getInfoByUsername(res.arena, app.db, admin_login) catch {
        try res.json(.{
            .code = 1,
            .msg = "update pass fail",
        }, .{});
        return;
    };
    
    if (!auth.checkPasswordHash(oldpassword, admin_info.password)) {
        try res.json(.{
            .code = 1,
            .msg = "oldpassword error",
        }, .{});
        return;
    }

    const new_pass = try auth.passwordHash(res.arena, newpassword);

    const ok = try admin_model.updatePassword(res.arena, app.db, admin_info.id, new_pass);
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "update password fail",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "update password success",
    }, .{});
}

