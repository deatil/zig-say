const std = @import("std");
const Allocator = std.mem.Allocator;

const lib = @import("say-lib");
const App = lib.global.App;

const myzql = @import("myzql");
const Conn = myzql.conn.Conn;
const DateTime = myzql.temporal.DateTime;
const Duration = myzql.temporal.Duration;
const OkPacket = myzql.protocol.generic_response.OkPacket;
const ResultSet = myzql.result.ResultSet;
const TextResultRow = myzql.result.TextResultRow;
const ResultRowIter = myzql.result.ResultRowIter;
const TextElemIter = myzql.result.TextElemIter;
const TextElems = myzql.result.TextElems;
const PreparedStatement = myzql.result.PreparedStatement;
const BinaryResultRow = myzql.result.BinaryResultRow;

pub const Admin = struct {
    id: i16 = 0,
    username: []const u8 = "",
    password: []const u8 = "",
    add_time: i16 = 0,
};

pub fn getInfoByUsername(alloc: Allocator, app: *App, username: []const u8) !Admin {
    const query =
        \\SELECT id, username, password, add_time
        \\FROM say_admin
        \\WHERE username = ?
        \\LIMIT 1
    ;
    const prep_res = try app.db.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const query_res = try app.db.executeRows(&prep_stmt, .{username}); 
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

    const first_info = try rows.first();
    if (first_info) |val| {
        var admin: Admin = undefined;
        try val.scan(&admin);

        return admin;
    }

    return .{};
}

pub fn getInfoById(alloc: Allocator, app: *App, id: i16) !Admin {
    const query =
        \\SELECT id, username, password, add_time
        \\FROM say_admin
        \\WHERE id = ?
        \\LIMIT 1
    ;
    const prep_res = try app.db.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const query_res = try app.db.executeRows(&prep_stmt, .{id}); 
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

    const first_info = try rows.first();
    if (first_info) |val| {
        var admin: Admin = undefined;
        try val.scan(&admin);

        return admin;
    }

    return .{};
}

pub fn updatePassword(alloc: Allocator, app: *App, id: i16, password: []const u8) !bool {
    const query =
        \\UPDATE say_admin
        \\SET password = ?
        \\WHERE id = ?
    ;

    const prep_res = try app.db.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const exe_res = try app.db.execute(&prep_stmt, .{ password, id });

    const ok: OkPacket = try exe_res.expect(.ok); 
    const affected_rows: u64 = ok.affected_rows;
    if (affected_rows == 0) {
        return false;
    }

    return true;
}
