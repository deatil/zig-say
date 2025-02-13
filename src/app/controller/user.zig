const std = @import("std");

const httpz = @import("httpz");
const zmpl = @import("zmpl");

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

const lib = @import("say-lib");
const App = lib.global.App;

pub fn getUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const Person = struct {
        name: []const u8,
        cookie: []const u8,
    };

    _ = req;

    const allocator = res.arena;

    const query =
        \\SELECT username, cookie
        \\FROM say_user
    ;
    const prep_res = try app.db.prepare(allocator, query);
    defer prep_res.deinit(allocator);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    var user_list = std.ArrayList(Person).init(allocator);
    defer user_list.deinit();

    const query_res = try app.db.executeRows(&prep_stmt, .{}); 
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);
    const rows_iter = rows.iter();
    while (try rows_iter.next()) |row| {
        {
            var person: Person = undefined;
            try row.scan(&person);

            try user_list.append(person);
        }
    }

    const users = try user_list.toOwnedSlice();

    res.status = 200;
    try res.json(.{.users = users}, .{});
}

pub fn getUserInfo(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const Person = struct {
        name: []const u8,
        cookie: []const u8,
    };

    if (req.param("id") == null) {
        res.status = 200;
        try res.json(.{.msg = "id error"}, .{});
        return;
    } 

    const id = req.param("id").?;

    const allocator = res.arena;

    const query =
        \\SELECT username, cookie
        \\FROM say_user
        \\WHERE id = ?
        \\LIMIT 1
    ;
    const prep_res = try app.db.prepare(allocator, query);
    defer prep_res.deinit(allocator);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    var user: Person = undefined;

    const query_res = try app.db.executeRows(&prep_stmt, .{id}); 
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);
    const rows_iter = rows.iter();
    while (try rows_iter.next()) |row| {
        {
            var person: Person = undefined;
            try row.scan(&person);

            user = person;

            break;
        }
    }

    res.status = 200;
    try res.json(.{.user = user}, .{});
}

pub fn addUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const allocator = res.arena;

    _ = req;

    const prep_res = try app.db.prepare(allocator, "INSERT INTO say_user (username, cookie) VALUES (?, ?)");
    defer prep_res.deinit(allocator);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);
    const params = .{
        .{ "John", "cookie1" },
        .{ "Sam", "cookie2" },
    };

    inline for (params) |param| {
        const exe_res = try app.db.execute(&prep_stmt, param);
        const ok: OkPacket = try exe_res.expect(.ok); 
        const affected_rows: u64 = ok.affected_rows;

        if (affected_rows == 0) {
            res.status = 200;
            try res.json(.{.msg = "add error"}, .{});
            return;
        }
    }

    res.status = 200;
    try res.json(.{.msg = "add success"}, .{});
}

pub fn deleteUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const allocator = res.arena;

    if (req.param("id") == null) {
        res.status = 200;
        try res.json(.{.msg = "id error"}, .{});
        return;
    } 

    const id = req.param("id").?;

    const prep_res = try app.db.prepare(allocator, "DELETE FROM say_user WHERE id = ?");
    defer prep_res.deinit(allocator);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const param = .{ id };
    const exe_res = try app.db.execute(&prep_stmt, param);

    const ok: OkPacket = try exe_res.expect(.ok); 
    const affected_rows: u64 = ok.affected_rows;
    if (affected_rows == 0) {
        res.status = 200;
        try res.json(.{.msg = "delete error"}, .{});
        return;
    }

    res.status = 200;
    try res.json(.{.msg = "delete success"}, .{});
}
