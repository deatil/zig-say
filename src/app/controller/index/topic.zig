const std = @import("std");
const httpz = @import("httpz");
const zig_time = @import("zig-time");

const lib = @import("say-lib");
const App = lib.global.App;
const views = lib.views;
const http = lib.utils.http;

const model = @import("./../../model/lib.zig");
const topic_model = model.topic;
const comment_model = model.comment;
const user_model = model.user;

pub fn view(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const id = req.param("id") orelse "0";
    const new_id = std.fmt.parseInt(u32, id, 10) catch 0;
    if (new_id == 0) {
        try views.errorView(res, "页面不存在", "");
        return;
    }

    var data = views.datas(res.arena);

    var body = try data.object();

    const topic_info = topic_model.getInfoById(res.arena, app.db, new_id) catch topic_model.TopicUser{};
    if (topic_info.id == 0) {
        try views.errorView(res, "话题不存在", "");
        return;
    }

    var topic = try data.object();
    try topic.put("id", data.integer(topic_info.id));
    try topic.put("title", data.string(topic_info.title));
    try topic.put("username", data.string(topic_info.username orelse "[empty]"));
    try topic.put("content", data.string(topic_info.content));

    try body.put("topic", topic);

    const query = try req.query();

    const page = query.get("page") orelse "1";
    var new_page = std.fmt.parseInt(u32, page, 10) catch 1;
    new_page = @max(1, new_page);

    const lists = try comment_model.getListByTopicId(res.arena, app.db, new_id, .{
        .offset = (new_page - 1) * 10,
        .limit = 10,
        .status = 1,
    });

    var comments = try data.array();

    const rows_iter = lists.iter();
    while (try rows_iter.next()) |row| {
        {
            var comment: comment_model.CommentUser = undefined;
            try row.scan(&comment);

            try comments.append(.{ 
                .content = comment.content,
                .username = comment.username orelse "[empty]",
                .add_time = try zig_time.Time.fromTimestamp(@as(i64, @intCast(comment.add_time))).formatAlloc(res.arena, "YYYY-MM-DD HH:mm:ss"),
           });
        }
    }

    try body.put("comments", comments);

    const topic_time = try zig_time.Time.fromTimestamp(@as(i64, @intCast(topic_info.add_time))).formatAlloc(res.arena, "YYYY-MM-DD HH:mm:ss");
    try body.put("topic_time", data.string(topic_time));

    const comment_count = try comment_model.getCountByTopicId(res.arena, app.db, new_id);
    const comment_pages = try std.math.divCeil(u64, comment_count, 10);

    try body.put("comment_page", data.integer(new_page));
    try body.put("comment_pages", data.integer(comment_pages));
    try body.put("comment_count", data.integer(comment_count));

    if (new_page > 1 and comment_pages > 1) {
        try body.put("comment_page1", data.integer(new_page - 1));
    }
    if (new_page < comment_pages and comment_pages > 1) {
        try body.put("comment_page2", data.integer(new_page + 1));
    }

    var cookies = req.cookies();
    const loginid = cookies.get("loginid") orelse "";
    try body.put("loginid", data.string(loginid));

    try views.view(res, "index/topic/view", &data);
}

pub fn create(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;

    var data = views.datas(res.arena);
    var body = try data.object();

    var cookies = req.cookies();
    const loginid = cookies.get("loginid") orelse "";
    try body.put("loginid", data.string(loginid));

    try views.view(res, "index/topic/create", &data);
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

    const user_info = user_model.getInfoByCookie(res.arena, app.db, loginid) catch user_model.User{};
    if (user_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "请先登录",
        }, .{});
        return;
    }

    const add_time = zig_time.now().unix();

    const ok: bool = topic_model.addInfo(res.arena, app.db, .{
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

    const user_info = user_model.getInfoByCookie(res.arena, app.db, loginid) catch user_model.User{};
    if (user_info.id == 0) {
        try res.json(.{
            .code = 1,
            .msg = "请先登录",
        }, .{});
        return;
    }

    const add_time = zig_time.now().unix();

    const ok: bool = comment_model.addInfo(res.arena, app.db, .{
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

