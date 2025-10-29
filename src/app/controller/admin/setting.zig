const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-lib");
const App = lib.global.App;
const views = lib.views;
const http = lib.utils.http;

const model = @import("./../../model/lib.zig");
const setting_model = model.setting;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = req;

    var data = views.datas(res.arena);
    var root = try data.object();
    var setting_data = try root.put("data", .object);

    // Load all settings from database
    const settings = try setting_model.getList(res.arena, app.db);
    const rows_iter = settings.iter();
    while (try rows_iter.next()) |row| {
        var setting: setting_model.Setting = undefined;
        try row.scan(&setting);
        try setting_data.put(setting.name, data.string(setting.value));
    }

    try views.view(res, "admin/setting/index", &data);
}

pub fn save(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    // Validate request body
    if (req.body() == null) {
        try res.json(.{
            .code = 1,
            .msg = "提交数据不能为空",
        }, .{});
        return;
    }

    // Parse form data and update each setting
    const form_data = try http.parseFormData(res.arena, req.body().?);
    var iterator = form_data.iterator();
    while (iterator.next()) |entry| {
        _ = try setting_model.updateInfo(res.arena, app.db, entry.key_ptr.*, entry.value_ptr.*);
    }

    try res.json(.{
        .code = 0,
        .msg = "设置更改成功",
    }, .{});
}
