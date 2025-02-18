const std = @import("std");
const Allocator = std.mem.Allocator;

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

pub const SettingList = std.ArrayList(Setting);
pub const SettingHashMap = std.StringHashMap([]const u8);

pub const Setting = struct {
    name: []const u8 = "",
    value: []const u8 = "",
    remark: []const u8 = "",
};

pub fn getList(alloc: Allocator, conn: *Conn) !ResultSet(BinaryResultRow) {
    const query =
        \\SELECT name, value, remark
        \\FROM say_setting
    ;
    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const query_res = try conn.executeRows(&prep_stmt, .{}); 
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

    return rows;
}

pub fn getInfoByName(alloc: Allocator, conn: *Conn, name: []const u8) !Setting {
    const query =
        \\SELECT name, value, remark
        \\FROM say_setting
        \\WHERE name = ?
        \\LIMIT 1
    ;
    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const query_res = try conn.executeRows(&prep_stmt, .{name}); 
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

    const first_info = try rows.first();
    if (first_info) |val| {
        var setting: Setting = undefined;
        try val.scan(&setting);

        return setting;
    }

    return .{};
}

pub fn updateInfo(alloc: Allocator, conn: *Conn, name: []const u8, value: []const u8) !bool {
    const query =
        \\UPDATE say_setting
        \\SET value = ?
        \\WHERE name = ?
    ;

    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const exe_res = try conn.execute(&prep_stmt, .{ value, name });

    const ok: OkPacket = try exe_res.expect(.ok); 
    const affected_rows: u64 = ok.affected_rows;
    if (affected_rows == 0) {
        return false;
    }

    return true;
}
