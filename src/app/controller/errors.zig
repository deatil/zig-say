const std = @import("std");
const httpz = @import("httpz");

const say = @import("say");
const App = say.global.App;

pub fn notFound(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    res.status = 404;
    res.header("content-type", "text/plain");
    res.body = "Not Found";
}


