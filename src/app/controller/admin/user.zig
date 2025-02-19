const std = @import("std");
const httpz = @import("httpz");
const zig_time = @import("zig-time");

const lib = @import("say-lib");
const App = lib.global.App;
const config = lib.global.config;
const views = lib.views;
const auth = lib.utils.auth;
const http = lib.utils.http;

const model = @import("./../../model/lib.zig");
const user_model = model.user;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    var data = views.datas(res.arena);

    try views.view(res, "admin/user/index", &data);
}

pub fn list(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const query = try req.query();

    const page = query.get("page") orelse "1";
    var new_page = std.fmt.parseInt(u32, page, 10) catch 1;
    new_page = @max(1, new_page);

    const limit = query.get("limit") orelse "10";
    var new_limit = std.fmt.parseInt(u32, limit, 10) catch 10;
    new_limit = @max(1, new_limit);

    const keywords = query.get("keywords") orelse "";

    const status = query.get("status") orelse "-1";
    var new_status: ?u16 = null;
    if (!std.mem.eql(u8, status, "1") and !std.mem.eql(u8, status, "0")) {
        new_status = null;
    }
    new_status = std.fmt.parseInt(u16, status, 10) catch null;

    const where = user_model.QueryWhere{
        .offset = (new_page - 1) * 10,
        .limit = new_limit,
        .keywords = keywords,
        .status = new_status,
    };

    var user_list = std.ArrayList(user_model.User).init(res.arena);
    defer user_list.deinit();

    const lists = try user_model.getList(res.arena, app.db, where);

    const rows_iter = lists.iter();
    while (try rows_iter.next()) |row| {
        {
            var user: user_model.User = undefined;
            try row.scan(&user);

            try user_list.append(user);
        }
    }

    const users = try user_list.toOwnedSlice();
    const count = try user_model.getCount(res.arena, app.db, where);

    try res.json(.{
        .code = 0,
        .msg = "获取成功",
        .data = .{
            .list = users,
            .count = count,
        },
    }, .{});

}

pub fn add(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    var data = views.datas(res.arena);

    try views.view(res, "admin/user/add", &data);
}

pub fn addSave(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    if (req.body() == null) {
        try res.json(.{
            .code = 1,
            .msg = "提交数据不能为空",
        }, .{});
        return;
    }

    const fd = try http.parseFormData(res.arena, req.body().?);

    const cookie = fd.get("cookie") orelse "";
    if (cookie.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "账号不能为空",
        }, .{});
        return;
    }

    const add_time = zig_time.now().unix();

    const ok: bool = user_model.addInfo(res.arena, app.db, .{
        .username = cookie,
        .cookie = cookie,
        .sign = "",
        .status = 1,
        .add_time = @as(u32, @intCast(add_time)),
        .add_ip = "",
    }) catch false;
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "添加账号失败",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "添加账号成功",
    }, .{});
}

pub fn edit(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const query = try req.query();
    const id = query.get("id") orelse "";
    const new_id = std.fmt.parseInt(u32, id, 10) catch 0;
    if (new_id == 0) {
        try views.errorAdminView(res, "id 错误", "");
        return;
    }

    const user_info = user_model.getInfoById(res.arena, app.db, new_id) catch user_model.User{};
    if (user_info.id == 0) {
        try views.errorAdminView(res, "id 错误", "");
        return;
    }

    var data = views.datas(res.arena);

    var body = try data.object();
    try body.put("data", user_info);

    try views.view(res, "admin/user/edit", &data);
}

pub fn editSave(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const query = try req.query();
    const id = query.get("id") orelse "";
    const new_id = std.fmt.parseInt(u32, id, 10) catch 0;
    if (new_id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "id 错误",
        }, .{});
        return;
    }

    var user_info = user_model.getInfoById(res.arena, app.db, new_id) catch user_model.User{};
    if (user_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "账号数据不存在",
        }, .{});
        return;
    }
    
    if (req.body() == null) {
        try res.json(.{
            .code = 1,
            .msg = "提交数据不能为空",
        }, .{});
        return;
    }

    const fd = try http.parseFormData(res.arena, req.body().?);

    const username = fd.get("username") orelse "";
    const cookie = fd.get("cookie") orelse "";
    const sign = fd.get("sign") orelse "";
    const status = fd.get("status") orelse "0";

    if (username.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "账号不能为空",
        }, .{});
        return;
    }
    if (cookie.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "Cookie不能为空",
        }, .{});
        return;
    }

    user_info.username = username;
    user_info.cookie = cookie;
    user_info.sign = sign;
    user_info.status = std.fmt.parseInt(u16, status, 10) catch 0;

    const ok: bool = user_model.updateInfoById(res.arena, app.db, new_id, user_info) catch false;
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "更改账号失败",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "更改账号成功",
    }, .{});
}

pub fn del(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const query = try req.query();
    const id = query.get("id") orelse "";
    const new_id = std.fmt.parseInt(u32, id, 10) catch 0;
    if (new_id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "id 错误",
        }, .{});
        return;
    }

    const user_info = user_model.getInfoById(res.arena, app.db, new_id) catch user_model.User{};
    if (user_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "账号数据不存在",
        }, .{});
        return;
    }

    const ok = user_model.deleteUser(res.arena, app.db, new_id) catch false;
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "删除账号失败",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "删除账号成功",
    }, .{});
}
