const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-lib");
const App = lib.global.App;
const views = lib.views;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    var data = views.datas(res.arena);
    defer data.deinit();

    try views.view(res, "admin/index/index", &data);
}


