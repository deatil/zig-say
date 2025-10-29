const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-lib");
const App = lib.global.App;
const views = lib.views;
const http = lib.utils.http;

const model = @import("./../../model/lib.zig");
const comment_model = model.comment;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    var data = views.datas(res.arena);

    try views.view(res, "admin/comment/index", &data);
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

    const where = comment_model.QueryWhere{
        .offset = (new_page - 1) * 10,
        .limit = new_limit,
        .keywords = keywords,
        .status = new_status,
    };

    var comment_list = std.array_list.Managed(comment_model.CommentUser).init(res.arena);
    defer comment_list.deinit();

    const lists = try comment_model.getList(res.arena, app.db, where);

    const rows_iter = lists.iter();
    while (try rows_iter.next()) |row| {
        {
            var comment: comment_model.CommentUser = undefined;
            try row.scan(&comment);

            try comment_list.append(comment);
        }
    }

    const comments = try comment_list.toOwnedSlice();
    const count = try comment_model.getCount(res.arena, app.db, where);

    try res.json(.{
        .code = 0,
        .msg = "获取成功",
        .data = .{
            .list = comments,
            .count = count,
        },
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

    const comment_info = comment_model.getInfoById(res.arena, app.db, new_id) catch comment_model.CommentUser{};
    if (comment_info.id == 0) {
        try views.errorAdminView(res, "评论数据不存在", "");
        return;
    }

    var data = views.datas(res.arena);

    var body = try data.object();
    try body.put("data", comment_info);

    try views.view(res, "admin/comment/edit", &data);
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

    var comment_info = comment_model.getInfoById(res.arena, app.db, new_id) catch comment_model.CommentUser{};
    if (comment_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "评论数据不存在",
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

    const content = fd.get("content") orelse "";
    const status = fd.get("status") orelse "0";

    if (content.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "内容不能为空",
        }, .{});
        return;
    }

    comment_info.content = content;
    comment_info.status = std.fmt.parseInt(u16, status, 10) catch 0;

    const ok: bool = comment_model.updateInfoById(res.arena, app.db, new_id, .{
        .user_id = comment_info.user_id,
        .topic_id = comment_info.topic_id,
        .content = comment_info.content,
        .status = comment_info.status,
        .add_time = comment_info.add_time,
        .add_ip = comment_info.add_ip,
    }) catch false;
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "更新评论失败",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "更新评论成功",
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

    const comment_info = comment_model.getInfoById(res.arena, app.db, new_id) catch comment_model.CommentUser{};
    if (comment_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "评论数据不存在",
        }, .{});
        return;
    }

    const ok = comment_model.deleteInfo(res.arena, app.db, new_id) catch false;
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "删除评论失败",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "删除评论成功",
    }, .{});
}
