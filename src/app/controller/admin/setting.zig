const std = @import("std");

const vin = @import("zig-vin");
const httpz = @import("httpz");

const lib = @import("say-pkg");
const App = lib.global.App;
const views = lib.views;
const http = lib.utils.http;

const setting_model = lib.app.model.setting;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = req;

    var map: vin.value.Namespace = .{};

    // Load all settings from database
    const settings = try setting_model.getList(res.arena, app.io, app.db);
    const rows_iter = settings.iter();
    while (try rows_iter.next(app.io)) |row| {
        var setting: setting_model.Setting = undefined;
        try row.scan(&setting);

        const k = try res.arena.dupe(u8, setting.name);
        const v = try res.arena.dupe(u8, setting.value);
        try map.set(res.arena, k, .fromString(v));
    }

    const data: vin.Value = .fromNamespace(&map);

    try views.view(app, res, "admin/setting/index", data);
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
        _ = try setting_model.updateInfo(res.arena, app.io, app.db, entry.key_ptr.*, entry.value_ptr.*);
    }

    try res.json(.{
        .code = 0,
        .msg = "设置更改成功",
    }, .{});
}
