const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-pkg");
const App = lib.global.App;
const views = lib.views;

const topic_model = lib.app.model.topic;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = req;

    const data = try views.datas(res.arena, .{});

    try views.view(app, res, "admin/topic/index", data);
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

    const TopicUserData = struct {
        id: u32 = 0,
        title: []const u8 = "",
        views: u64 = 0,
        status: u16 = 0,
        add_time: u32 = 0,
        username: ?[]const u8 = "",
    };

    const where = topic_model.QueryWhere{
        .offset = (new_page - 1) * 10,
        .limit = new_limit,
        .keywords = keywords,
        .status = new_status,
    };

    var topic_list = std.array_list.Managed(TopicUserData).init(res.arena);
    defer topic_list.deinit();

    const lists = try topic_model.getList(res.arena, app.io, app.db, where);

    const rows_iter = lists.iter();
    while (try rows_iter.next(app.io)) |row| {
        var topic: topic_model.TopicUser = undefined;
        try row.scan(&topic);

        const t = try res.arena.dupe(u8, topic.title);
        const u = try res.arena.dupe(u8, topic.username orelse "[empty]");

        try topic_list.append(.{
            .id = topic.id,
            .title = t,
            .views = topic.views,
            .status = topic.status,
            .add_time = topic.add_time,
            .username = u,
        });
    }

    const topics = try topic_list.toOwnedSlice();
    const count = try topic_model.getCount(res.arena, app.io, app.db, where);

    try res.json(.{
        .code = 0,
        .msg = "获取成功",
        .data = .{
            .list = topics,
            .count = count,
        },
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

    const topic_info = topic_model.getInfoById(res.arena, app.io, app.db, new_id) catch topic_model.TopicUser{};
    if (topic_info.id == 0) {
        try views.errorAdminView(app, res, "id 错误", "");
        return;
    }

    const data = try views.datas(res.arena, .{
        .data = topic_info,
    });

    try views.view(app, res, "admin/topic/edit", data);
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

    var topic_info = topic_model.getInfoById(res.arena, app.io, app.db, new_id) catch topic_model.TopicUser{};
    if (topic_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "话题数据不存在",
        }, .{});
        return;
    }

    const fd = try req.formData();

    const title = fd.get("title") orelse "";
    const content = fd.get("content") orelse "";
    const views_data = fd.get("views") orelse "0";
    const status = fd.get("status") orelse "0";

    if (title.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "标题不能为空",
        }, .{});
        return;
    }
    if (content.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "内容不能为空",
        }, .{});
        return;
    }

    topic_info.title = title;
    topic_info.content = content;
    topic_info.views = std.fmt.parseInt(u64, views_data, 10) catch 0;
    topic_info.status = std.fmt.parseInt(u16, status, 10) catch 0;

    const ok: bool = topic_model.updateInfoById(res.arena, app.io, app.db, new_id, .{
        .user_id = topic_info.user_id,
        .title = topic_info.title,
        .content = topic_info.content,
        .views = topic_info.views,
        .status = topic_info.status,
        .add_time = topic_info.add_time,
        .add_ip = topic_info.add_ip,
    }) catch false;
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "更改话题失败",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "更改话题成功",
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

    const topic_info = topic_model.getInfoById(res.arena, app.io, app.db, new_id) catch topic_model.TopicUser{};
    if (topic_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "话题数据不存在",
        }, .{});
        return;
    }

    const ok = topic_model.deleteInfo(res.arena, app.io, app.db, new_id) catch false;
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "删除话题失败",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "删除话题成功",
    }, .{});
}
