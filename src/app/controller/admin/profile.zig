const std = @import("std");
const httpz = @import("httpz");

const say = @import("say");
const config = say.global.config;
const views = say.views;
const auth = say.utils.auth;
const App = say.global.App;

const admin_model = say.app.model.admin;

pub fn password(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = req;

    const data = try views.datas(res.arena, .{});

    try views.view(app, res, "admin/profile/password", data);
}

pub fn passwordSave(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const fd = try req.formData();

    const oldpassword = fd.get("oldpassword") orelse "";
    const newpassword = fd.get("newpassword") orelse "";
    const newpassword2 = fd.get("newpassword2") orelse "";

    if (oldpassword.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "旧密码不能为空",
        }, .{});
        return;
    }
    if (newpassword.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "新密码不能为空",
        }, .{});
        return;
    }
    if (!std.mem.eql(u8, newpassword, newpassword2)) {
        try res.json(.{
            .code = 1,
            .msg = "确认密码不一致",
        }, .{});
        return;
    }

    const admin_login = req.header("admin_login") orelse "";

    const admin_info = admin_model.getInfoByUsername(res.arena, app.io, app.db, admin_login) catch {
        try res.json(.{
            .code = 1,
            .msg = "更改密码失败",
        }, .{});
        return;
    };

    if (!auth.checkPasswordHash(oldpassword, admin_info.password)) {
        try res.json(.{
            .code = 1,
            .msg = "旧密码不匹配",
        }, .{});
        return;
    }

    const new_pass = try auth.passwordHash(res.arena, app.io, newpassword);

    const ok = try admin_model.updatePassword(res.arena, app.io, app.db, admin_info.id, new_pass);
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "更改密码失败",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "更改密码成功",
    }, .{});
}
