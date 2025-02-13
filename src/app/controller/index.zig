const httpz = @import("httpz");
const zmpl = @import("zmpl");

const lib = @import("say-lib");

const App = lib.global.App;

pub fn getUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    res.status = 200;
    try res.json(.{.id = req.param("id").?, .name = "Teg"}, .{});
}

pub fn showHtml(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    var data = zmpl.Data.init(res.arena);
    defer data.deinit();

    var body = try data.object();
    var user = try data.object();

    try user.put("email", data.string("user@example.com"));

    try body.put("user", user);
    try data.addConst("say_view", data.string("test"));

    const Context = struct { foo: []const u8 = "default" };
    const context = Context { .foo = "bar" };

    if (zmpl.find("showhtml")) |template| {
        const output = try template.render(&data, Context, context, .{});
        defer res.arena.free(output);

        res.status = 200;
        res.body = output;
    } else {
        res.status = 200;
        try res.json(.{.err = "html not exists"}, .{});
    }
}


