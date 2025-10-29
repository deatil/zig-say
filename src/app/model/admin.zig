const std = @import("std");
const Allocator = std.mem.Allocator;

const myzql = @import("myzql");
const Conn = myzql.conn.Conn;
const OkPacket = myzql.protocol.generic_response.OkPacket;
const ResultSet = myzql.result.ResultSet;
const PreparedStatement = myzql.result.PreparedStatement;
const BinaryResultRow = myzql.result.BinaryResultRow;

pub const Admin = struct {
    id: u32 = 0,
    username: []const u8 = "",
    password: []const u8 = "",
    add_time: u32 = 0,
};

pub fn getInfoByUsername(alloc: Allocator, conn: *Conn, username: []const u8) !Admin {
    const query =
        \\SELECT id, username, password, add_time
        \\FROM say_admin
        \\WHERE username = ?
        \\LIMIT 1
    ;
    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const query_res = try conn.executeRows(alloc, &prep_stmt, .{username});
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

    const first_info = try rows.first();
    if (first_info) |val| {
        var admin: Admin = undefined;
        try val.scan(&admin);

        return admin;
    }

    return .{};
}

pub fn getInfoById(alloc: Allocator, conn: *Conn, id: u32) !Admin {
    const query =
        \\SELECT id, username, password, add_time
        \\FROM say_admin
        \\WHERE id = ?
        \\LIMIT 1
    ;
    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const query_res = try conn.executeRows(alloc, &prep_stmt, .{id});
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

    const first_info = try rows.first();
    if (first_info) |val| {
        var admin: Admin = undefined;
        try val.scan(&admin);

        return admin;
    }

    return .{};
}

pub fn updatePassword(alloc: Allocator, conn: *Conn, id: u32, password: []const u8) !bool {
    const query =
        \\UPDATE say_admin
        \\SET password = ?
        \\WHERE id = ?
    ;

    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const exe_res = try conn.execute(&prep_stmt, .{ password, id });

    const ok: OkPacket = try exe_res.expect(.ok);
    const affected_rows: u64 = ok.affected_rows;
    if (affected_rows == 0) {
        return false;
    }

    return true;
}
