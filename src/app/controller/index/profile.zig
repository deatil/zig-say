const std = @import("std");
const httpz = @import("httpz");

const say = @import("say");
const views = say.views;
const App = say.global.App;

const user_model = say.app.model.user;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const loginid = req.header("loginid") orelse "";
    const user_info = user_model.getInfoByCookie(res.arena, app.io, app.db, loginid) catch user_model.User{};

    const data = try views.datas(res.arena, .{
        .loginid = loginid,
        .user = .{
            .username = user_info.username,
            .cookie = user_info.cookie,
            .sign = user_info.sign,
        },
    });

    try views.view(app, res, "index/profile/index", data);
}

pub fn save(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const fd = try req.formData();

    const username = fd.get("username") orelse "";
    const sign = fd.get("sign") orelse "";

    if (username.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "标题不能为空",
        }, .{});
        return;
    }

    const loginid = req.header("loginid") orelse "";

    var user_info = user_model.getInfoByCookie(res.arena, app.io, app.db, loginid) catch user_model.User{};
    if (user_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "请先登录",
        }, .{});
        return;
    }

    user_info.username = try res.arena.dupe(u8, username);
    user_info.cookie = try res.arena.dupe(u8, user_info.cookie);
    user_info.sign = try res.arena.dupe(u8, sign);

    const upres = user_model.updateInfoById(res.arena, app.io, app.db, user_info.id, user_info);

    var ok: bool = true;
    if (upres) |_| {} else |_| {
        ok = false;
    }

    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "更改失败",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "更改成功",
    }, .{});
}

