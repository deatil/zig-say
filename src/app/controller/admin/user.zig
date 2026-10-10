const std = @import("std");
const httpz = @import("httpz");
const zig_time = @import("zig-time");

const lib = @import("say-pkg");
const App = lib.global.App;
const views = lib.views;

const user_model = lib.app.model.user;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = req;

    const data = try views.datas(res.arena, .{});

    try views.view(app, res, "admin/user/index", data);
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

    const UserModel = struct {
        id: u32,
        username: []const u8,
        status: u16,
        add_time: u32,
    };

    var user_list = std.array_list.Managed(UserModel).init(res.arena);
    defer user_list.deinit();

    const lists = try user_model.getList(res.arena, app.io, app.db, where);

    const rows_iter = lists.iter();
    while (try rows_iter.next(app.io)) |row| {
        var user: user_model.User = undefined;
        try row.scan(&user);

        const u = try res.arena.dupe(u8, user.username);

        try user_list.append(.{
            .id = user.id,
            .username = u,
            .status = user.status,
            .add_time = user.add_time,
        });
    }

    const users = try user_list.toOwnedSlice();
    const count = try user_model.getCount(res.arena, app.io, app.db, where);

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
    _ = req;

    const data = try views.datas(res.arena, .{});

    try views.view(app, res, "admin/user/add", data);
}

pub fn addSave(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const fd = try req.formData();

    const cookie = fd.get("cookie") orelse "";
    if (cookie.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "账号不能为空",
        }, .{});
        return;
    }

    const add_time = zig_time.now(app.io).unix();

    const ok: bool = user_model.addInfo(res.arena, app.io, app.db, .{
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
        try views.errorAdminView(app, res, "id 错误", "");
        return;
    }

    const user_info = user_model.getInfoById(res.arena, app.io, app.db, new_id) catch user_model.User{};
    if (user_info.id == 0) {
        try views.errorAdminView(app, res, "id 错误", "");
        return;
    }

    const data = try views.datas(res.arena, .{
        .data = user_info,
    });

    try views.view(app, res, "admin/user/edit", data);
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

    var user_info = user_model.getInfoById(res.arena, app.io, app.db, new_id) catch user_model.User{};
    if (user_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "账号数据不存在",
        }, .{});
        return;
    }

    const fd = try req.formData();

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

    const ok: bool = user_model.updateInfoById(res.arena, app.io, app.db, new_id, user_info) catch false;
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

    const user_info = user_model.getInfoById(res.arena, app.io, app.db, new_id) catch user_model.User{};
    if (user_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "账号数据不存在",
        }, .{});
        return;
    }

    const ok = user_model.deleteUser(res.arena, app.io, app.db, new_id) catch false;
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
