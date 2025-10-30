const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-lib");
const App = lib.global.App;

pub fn notFound(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    res.status = 404;
    res.header("content-type", "text/plain");
    res.body = "Not Found";
}
