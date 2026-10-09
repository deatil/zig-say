const std = @import("std");

const httpz = @import("httpz");
const vin = @import("zig-vin");
const zig_time = @import("zig-time");

const lib = @import("say-pkg");
const App = lib.global.App;
const views = lib.views;
const http = lib.utils.http;

const model = lib.app.model;
const topic_model = model.topic;
const comment_model = model.comment;
const user_model = model.user;

pub fn view(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const id = req.param("id") orelse "0";
    const new_id = std.fmt.parseInt(u32, id, 10) catch 0;
    if (new_id == 0) {
        try views.errorView(app, res, "页面不存在", "");
        return;
    }

    var map: vin.value.Namespace = .{};

    const topic_info = topic_model.getInfoById(res.arena, app.io, app.db, new_id) catch topic_model.TopicUser{};
    if (topic_info.id == 0) {
        try views.errorView(app, res, "话题不存在", "");
        return;
    }

    const tt = try res.arena.dupe(u8, topic_info.title);
    const co = try res.arena.dupe(u8, topic_info.content);
    const un = try res.arena.dupe(u8, topic_info.username orelse "[empty]");

    const topic = .{
        .id = topic_info.id,
        .title = tt,
        .username = un,
        .content = co,
    };

    try map.set(res.arena, "topic", try vin.valueFrom(res.arena, topic));

    const query = try req.query();

    const page = query.get("page") orelse "1";
    var new_page = std.fmt.parseInt(u32, page, 10) catch 1;
    new_page = @max(1, new_page);

    const lists = try comment_model.getListByTopicId(res.arena, app.io, app.db, new_id, .{
        .offset = (new_page - 1) * 10,
        .limit = 10,
        .status = 1,
    });

    const CommentsData = struct {
        content: []const u8,
        username: []const u8,
        add_time: []const u8,
    };

    var comments = std.array_list.Managed(CommentsData).init(res.arena);
    defer comments.deinit();

    const rows_iter = lists.iter();
    while (try rows_iter.next(app.io)) |row| {
        var comment: comment_model.CommentUser = undefined;
        try row.scan(&comment);

        const c = try res.arena.dupe(u8, comment.content);
        const u = try res.arena.dupe(u8, comment.username orelse "[empty]");

        try comments.append(.{
            .content = c,
            .username = u,
            .add_time = try zig_time.Time.fromTimestamp(@as(i64, @intCast(comment.add_time))).formatAlloc(res.arena, "YYYY-MM-DD HH:mm:ss"),
        });
    }

    const comment_list = try comments.toOwnedSlice();

    try map.set(res.arena, "comments", try vin.valueFrom(res.arena, comment_list));

    const topic_time = try zig_time.Time.fromTimestamp(@as(i64, @intCast(topic_info.add_time))).formatAlloc(res.arena, "YYYY-MM-DD HH:mm:ss");
    try map.set(res.arena, "topic_time", .fromString(topic_time));

    const comment_count = try comment_model.getCountByTopicId(res.arena, app.io, app.db, new_id);
    const comment_pages = try std.math.divCeil(u64, comment_count, 10);

    try map.set(res.arena, "comment_page", .fromInt(new_page));
    try map.set(res.arena, "comment_pages", .fromInt(@intCast(comment_pages)));
    try map.set(res.arena, "comment_count", .fromInt(@intCast(comment_count)));

    if (new_page > 1 and comment_pages > 1) {
        try map.set(res.arena, "comment_page1", .fromInt(new_page - 1));
    }
    if (new_page < comment_pages and comment_pages > 1) {
        try map.set(res.arena, "comment_page2", .fromInt(new_page + 1));
    }

    var cookies = req.cookies();
    const loginid = cookies.get("loginid") orelse "";
    try map.set(res.arena, "loginid", .fromString(loginid));

    const data: vin.Value = .fromNamespace(&map);

    try views.view(app, res, "index/topic/view", data);
}

pub fn create(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    var cookies = req.cookies();
    const loginid = cookies.get("loginid") orelse "";

    const data = try views.datas(res.arena, .{
        .loginid = loginid,
    });

    try views.view(app, res, "index/topic/create", data);
}

pub fn createSave(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    if (req.body() == null) {
        try res.json(.{
            .code = 1,
            .msg = "发表评论失败",
        }, .{});
        return;
    }

    const fd = try http.parseFormData(res.arena, req.body().?);

    const title = fd.get("title") orelse "";
    const content = fd.get("content") orelse "";

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

    var cookies = req.cookies();
    const loginid = cookies.get("loginid") orelse "";

    const user_info = user_model.getInfoByCookie(res.arena, app.io, app.db, loginid) catch user_model.User{};
    if (user_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "请先登录",
        }, .{});
        return;
    }

    const add_time = zig_time.now(app.io).unix();

    const ok: bool = topic_model.addInfo(res.arena, app.io, app.db, .{
        .user_id = user_info.id,
        .title = title,
        .content = content,
        .views = 0,
        .status = 1,
        .add_time = @as(u32, @intCast(add_time)),
        .add_ip = "",
    }) catch false;
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "发表话题失败",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "发表话题成功",
    }, .{});
}

pub fn addComment(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    if (req.body() == null) {
        try res.json(.{
            .code = 1,
            .msg = "回复话题失败",
        }, .{});
        return;
    }

    const fd = try http.parseFormData(res.arena, req.body().?);

    const topic_id = fd.get("topic_id") orelse "";
    const content = fd.get("content") orelse "";

    if (topic_id.len == 0) {
        try res.json(.{
            .code = 1,
            .msg = "回复话题失败",
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

    const new_topic_id = std.fmt.parseInt(u32, topic_id, 10) catch 0;
    if (new_topic_id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "回复话题失败",
        }, .{});
        return;
    }

    var cookies = req.cookies();
    const loginid = cookies.get("loginid") orelse "";

    const user_info = user_model.getInfoByCookie(res.arena, app.io, app.db, loginid) catch user_model.User{};
    if (user_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "请先登录",
        }, .{});
        return;
    }

    const add_time = zig_time.now(app.io).unix();

    const ok: bool = comment_model.addInfo(res.arena, app.io, app.db, .{
        .user_id = user_info.id,
        .topic_id = new_topic_id,
        .content = content,
        .status = 1,
        .add_time = @as(u32, @intCast(add_time)),
        .add_ip = "",
    }) catch false;
    if (!ok) {
        try res.json(.{
            .code = 1,
            .msg = "回复话题失败",
        }, .{});
        return;
    }

    try res.json(.{
        .code = 0,
        .msg = "回复话题成功",
    }, .{});
}
