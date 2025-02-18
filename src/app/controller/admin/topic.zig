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
const topic_model = model.topic;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    var data = views.datas(res.arena);

    try views.view(res, "admin/topic/index", &data);
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

    const where = topic_model.QueryWhere{
        .offset = (new_page - 1) * 10,
        .limit = new_limit,
        .keywords = keywords,
        .status = new_status,
    };

    var topic_list = std.ArrayList(topic_model.TopicUser).init(res.arena);
    defer topic_list.deinit();

    const lists = try topic_model.getList(res.arena, app.db, where);

    const rows_iter = lists.iter();
    while (try rows_iter.next()) |row| {
        {
            var topic: topic_model.TopicUser = undefined;
            try row.scan(&topic);

            try topic_list.append(topic);
        }
    }

    const topics = try topic_list.toOwnedSlice();
    const count = try topic_model.getCount(res.arena, app.db, where);

    try res.json(.{
        .code = 0,
        .msg = "login success",
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
        try views.errorAdminView(res, "id error", "");
        return;
    }

    const topic_info = topic_model.getInfoById(res.arena, app.db, new_id) catch topic_model.TopicUser{};
    if (topic_info.id == 0) {
        try views.errorAdminView(res, "id error", "");
        return;
    }

    var data = views.datas(res.arena);

    var body = try data.object();
    try body.put("data", topic_info);

    try views.view(res, "admin/topic/edit", &data);
}

pub fn editSave(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const query = try req.query();
    const id = query.get("id") orelse "";
    const new_id = std.fmt.parseInt(u32, id, 10) catch 0;
    if (new_id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "id error",
        }, .{});
        return;
    }

    var topic_info = topic_model.getInfoById(res.arena, app.db, new_id) catch topic_model.TopicUser{};
    if (topic_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "id error",
        }, .{});
        return;
    }
    
    if (req.body() == null) {
        try res.json(.{
            .code = 1,
            .msg = "update data empty",
        }, .{});
        return;
    }

    const fd = try http.parseFormData(res.arena, req.body().?);

    const title = fd.get("title") orelse "";
    const content = fd.get("content") orelse "";
    const views_data = fd.get("views") orelse "0";
    const status = fd.get("status") orelse "0";

    if (title.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "title empty",
        }, .{});
        return;
    }
    if (content.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "content empty",
        }, .{});
        return;
    }

    topic_info.title = title;
    topic_info.content = content;
    topic_info.views = std.fmt.parseInt(u64, views_data, 10) catch 0;
    topic_info.status = std.fmt.parseInt(u16, status, 10) catch 0;

    const ok: bool = topic_model.updateInfoById(res.arena, app.db, new_id, .{
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
            .msg = "update topic fail",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "update topic success",
    }, .{});
}

pub fn del(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const query = try req.query();
    const id = query.get("id") orelse "";
    const new_id = std.fmt.parseInt(u32, id, 10) catch 0;
    if (new_id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "id error",
        }, .{});
        return;
    }

    const topic_info = topic_model.getInfoById(res.arena, app.db, new_id) catch topic_model.TopicUser{};
    if (topic_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "topic not exists",
        }, .{});
        return;
    }

    const ok = topic_model.deleteInfo(res.arena, app.db, new_id) catch false;
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "delete topic fail",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "delete topic success",
    }, .{});
}
