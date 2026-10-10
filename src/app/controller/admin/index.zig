const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-pkg");
const App = lib.global.App;
const views = lib.views;
const time = lib.utils.time.time;

const model = lib.app.model;
const topic_model = model.topic;
const comment_model = model.comment;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const admin_login = req.header("admin_login") orelse "";

    const data = try views.datas(res.arena, .{
        .admin_login = admin_login,
    });

    try views.view(app, res, "admin/index/index", data);
}

pub fn console(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = req;

    const topic_count = try topic_model.getCount(res.arena, app.io, app.db, .{});
    const comment_count = try comment_model.getCount(res.arena, app.io, app.db, .{});

    var new_topics = try std.ArrayList(struct {
        title: []const u8,
        add_time: []const u8,
    }).initCapacity(res.arena, 0);
    defer new_topics.deinit(res.arena);

    const lists = try topic_model.getList(res.arena, app.io, app.db, .{ .order = "id DESC" });
    const rows_iter = lists.iter();
    while (try rows_iter.next(app.io)) |row| {
        var topic: topic_model.TopicUser = undefined;
        try row.scan(&topic);

        const t = try res.arena.dupe(u8, topic.title);

        try new_topics.append(res.arena, .{
            .title = t,
            .add_time = try time.Time.fromTimestamp(@as(i64, @intCast(topic.add_time))).formatAlloc(res.arena, "YYYY-MM-DD HH:mm:ss"),
        });
    }

    const data = try views.datas(res.arena, .{
        .topic_count = topic_count,
        .comment_count = comment_count,
        .new_topics = try new_topics.toOwnedSlice(res.arena),
    });

    try views.view(app, res, "admin/index/console", data);
}
