const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-lib");
const App = lib.global.App;
const views = lib.views;
const time = lib.utils.time.time;

const model = @import("./../../model/lib.zig");
const topic_model = model.topic;
const comment_model = model.comment;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;

    const admin_login = req.header("admin_login") orelse "";

    var data = views.datas(res.arena);

    var body = try data.object();
    try body.put("admin_login", data.string(admin_login));

    try views.view(res, "admin/index/index", &data);
}

pub fn console(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = req;

    const topic_count = try topic_model.getCount(res.arena, app.db, .{});
    const comment_count = try comment_model.getCount(res.arena, app.db, .{});

    var data = views.datas(res.arena);

    var body = try data.object();
    try body.put("topic_count", data.integer(topic_count));
    try body.put("comment_count", data.integer(comment_count));

    var new_topics = try data.array();

    const lists = try topic_model.getList(res.arena, app.db, .{.order = "id DESC"});
    const rows_iter = lists.iter();
    while (try rows_iter.next()) |row| {
        {
            var topic: topic_model.TopicUser = undefined;
            try row.scan(&topic);

            try new_topics.append(.{ 
                .title = topic.title,
                .add_time = try time.Time.fromTimestamp(@as(i64, @intCast(topic.add_time))).formatAlloc(res.arena, "YYYY-MM-DD HH:mm:ss"),
            });
        }
    }

    try body.put("new_topics", new_topics);

    try views.view(res, "admin/index/console", &data);
}

