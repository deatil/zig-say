const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-pkg");
const App = lib.global.App;
const views = lib.views;

const comment_model = lib.app.model.comment;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = req;

    const data = try views.datas(res.arena, .{});

    try views.view(app, res, "admin/comment/index", data);
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

    const CommentUserData = struct {
        id: u32 = 0,
        content: []const u8 = "",
        status: u16 = 0,
        add_time: u32 = 0,
        username: ?[]const u8 = "",
    };

    var comment_list = std.array_list.Managed(CommentUserData).init(res.arena);
    defer comment_list.deinit();

    const lists = try comment_model.getList(res.arena, app.io, app.db, where);

    const rows_iter = lists.iter();
    while (try rows_iter.next(app.io)) |row| {
        var comment: comment_model.CommentUser = undefined;
        try row.scan(&comment);

        const c = try res.arena.dupe(u8, comment.content);
        const u = try res.arena.dupe(u8, comment.username orelse "[empty]");

        try comment_list.append(.{
            .id = comment.id,
            .content = c,
            .status = comment.status,
            .add_time = comment.add_time,
            .username = u,
        });
    }

    const comments = try comment_list.toOwnedSlice();
    const count = try comment_model.getCount(res.arena, app.io, app.db, where);

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
        try views.errorAdminView(app, res, "id 错误", "");
        return;
    }

    const comment_info = comment_model.getInfoById(res.arena, app.io, app.db, new_id) catch comment_model.CommentUser{};
    if (comment_info.id == 0) {
        try views.errorAdminView(app, res, "评论数据不存在", "");
        return;
    }

    const data = try views.datas(res.arena, .{
        .data = comment_info,
    });

    try views.view(app, res, "admin/comment/edit", data);
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

    var comment_info = comment_model.getInfoById(res.arena, app.io, app.db, new_id) catch comment_model.CommentUser{};
    if (comment_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "评论数据不存在",
        }, .{});
        return;
    }

    const fd = try req.formData();

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

    if (comment_info.add_ip.len > 0) {
        comment_info.add_ip = try res.arena.dupe(u8, comment_info.add_ip);
    } else {
        comment_info.add_ip = try res.arena.dupe(u8, "0.0.0.0");
    }

    const ok: bool = comment_model.updateInfoById(res.arena, app.io, app.db, new_id, .{
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

    const comment_info = comment_model.getInfoById(res.arena, app.io, app.db, new_id) catch comment_model.CommentUser{};
    if (comment_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "评论数据不存在",
        }, .{});
        return;
    }

    const ok = comment_model.deleteInfo(res.arena, app.io, app.db, new_id) catch false;
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
