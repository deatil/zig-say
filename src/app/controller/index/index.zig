const std = @import("std");

const vin = @import("zig-vin");
const httpz = @import("httpz");

const lib = @import("say-pkg");
const App = lib.global.App;
const views = lib.views;
const time = lib.utils.time.time;

const topic_model = lib.app.model.topic;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const query = try req.query();

    const page = query.get("page") orelse "1";
    var new_page = std.fmt.parseInt(u32, page, 10) catch 1;
    new_page = @max(1, new_page);

    const lists = try topic_model.getNewList(res.arena, app.io, app.db, .{
        .offset = (new_page - 1) * 10,
        .limit = 10,
        .status = 1,
    });

    var map: vin.value.Namespace = .{};

    const TopicData = struct {
        id: u32,
        title: []const u8,
        username: []const u8,
        views: u64,
        add_time: []const u8,
    };

    var topics = std.array_list.Managed(TopicData).init(res.arena);
    defer topics.deinit();

    const rows_iter = lists.iter();
    while (try rows_iter.next(app.io)) |row| {
        var topic: topic_model.TopicUser = undefined;
        try row.scan(&topic);

        const t = try res.arena.dupe(u8, topic.title);
        const u = try res.arena.dupe(u8, topic.username orelse "[empty]");

        try topics.append(.{
            .id = topic.id,
            .title = t,
            .username = u,
            .views = topic.views,
            .add_time = try time.Time.fromTimestamp(@intCast(topic.add_time)).formatAlloc(res.arena, "YYYY-MM-DD HH:mm:ss"),
        });
    }

    const topic_list = try topics.toOwnedSlice();

    try map.set(res.arena, "topics", try vin.valueFrom(res.arena, topic_list));

    const topic_count = try topic_model.getCount(res.arena, app.io, app.db, .{
        .status = 1,
        .order = "id DESC",
    });

    try map.set(res.arena, "page", .fromInt(@intCast(new_page)));

    const pages = try std.math.divCeil(u64, topic_count, 10);
    try map.set(res.arena, "pages", .fromInt(@intCast(pages)));

    if (new_page > 1 and pages > 1) {
        try map.set(res.arena, "comment_page1", .fromInt(@intCast(new_page - 1)));
    }
    if (new_page < pages and pages > 1) {
        try map.set(res.arena, "comment_page2", .fromInt(@intCast(new_page + 1)));
    }

    var cookies = req.cookies();
    const loginid = cookies.get("loginid") orelse "";
    try map.set(res.arena, "loginid", .fromString(loginid));

    const data: vin.Value = .fromNamespace(&map);

    try views.view(app, res, "index/index/index", data);
}
