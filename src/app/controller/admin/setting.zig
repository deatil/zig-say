const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-lib");
const App = lib.global.App;
const config = lib.global.config;
const views = lib.views;
const auth = lib.utils.auth;
const http = lib.utils.http;

const model = @import("./../../model/lib.zig");
const setting_model = model.setting;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = req;

    var data = views.datas(res.arena);

    var body = try data.object();

    var setting_data = try data.object();

    const settings = try setting_model.getList(res.arena, app.db);

    const rows_iter = settings.iter();
    while (try rows_iter.next()) |row| {
        {
            var setting: setting_model.Setting = undefined;
            try row.scan(&setting);

            try setting_data.put(setting.name, try http.formatBuf(res.arena, setting.value[0..]));
        }
    }

    try body.put("data", setting_data);

    try views.view(res, "admin/setting/index", &data);
}

pub fn save(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    if (req.body() == null) {
        try res.json(.{
            .code = 1,
            .msg = "update data empty",
        }, .{});
        return;
    }

    const fd = try http.parseFormData(res.arena, req.body().?);

    var it = fd.iterator();
    while (it.next()) |kv| {
        _ = try setting_model.updateInfo(res.arena, app.db, kv.key_ptr.*, kv.value_ptr.*);
    }    

    try res.json(.{
        .code = 0,
        .msg = "update setting success",
    }, .{});
}

