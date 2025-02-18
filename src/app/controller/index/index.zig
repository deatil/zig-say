const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-lib");
const App = lib.global.App;
const views = lib.views;
const time = lib.utils.time.time;

const model = @import("./../../model/lib.zig");
const topic_model = model.topic;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const query = try req.query();

    const page = query.get("page") orelse "1";
    var new_page = std.fmt.parseInt(u32, page, 10) catch 1;
    new_page = @max(1, new_page);

    const lists = try topic_model.getList(res.arena, app.db, .{
        .offset = (new_page - 1) * 10,
        .limit = 10,
        .status = 1,
        .order = "id DESC", 
    });

    var data = views.datas(res.arena);
    var body = try data.object();

    var topics = try data.array();

    const rows_iter = lists.iter();
    while (try rows_iter.next()) |row| {
        {
            var topic: topic_model.TopicUser = undefined;
            try row.scan(&topic);

            try topics.append(.{ 
                .id = topic.id,
                .title = topic.title,
                .username = topic.username,
                .views = topic.views,
                .add_time = try time.Time.fromTimestamp(@as(i64, @intCast(topic.add_time))).formatAlloc(res.arena, "YYYY-MM-DD HH:mm:ss"),
           });
        }
    }

    try body.put("topics", topics);

    const topic_count = try topic_model.getCount(res.arena, app.db, .{
        .status = 1,
        .order = "id DESC", 
    });

    try body.put("page", data.integer(new_page));
    try body.put("pages", data.integer(@divTrunc(topic_count, 10)));

    var cookies = req.cookies();
    const loginid = cookies.get("loginid") orelse "";
    try body.put("loginid", data.string(loginid));

    try views.view(res, "index/index/index", &data);
}


