const std = @import("std");

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

// mysql curd function
fn runMyzql() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        switch (gpa.deinit()) {
            .ok => {},
            .leak => std.log.err("memory leak detected", .{}),
        }
    }

    var c = try connMyzql(allocator);
    defer c.deinit();

    try exampleSelect(&c, allocator);

    // try exampleInsert(&c, allocator);

    // try exampleDelete(&c, allocator);

    try exampleUpdate(&c, allocator);

}

fn connMyzql(allocator: std.mem.Allocator) !Conn {
    // Setting up client
    var client = try Conn.init(
        allocator,
        &.{
            .username = "root",   
            .password = "123456", 
            .database = "zig_blog", 

            .address =  std.net.Address.initIp4(.{ 192, 168, 56, 1 }, 3306),
        },
    );

    // Connection and Authentication
    try client.ping();

    return client;
}

// convenient function for testing
fn queryExpectOk(c: *Conn, query: []const u8) !void {
    const query_res = try c.query(query);
    _ = try query_res.expect(.ok);
}

fn queryExpectOkLogError(c: *Conn, query: []const u8) void {
    queryExpectOk(c, query) catch |err| {
        std.debug.print("Error: {}\n", .{err});
    };
}

fn exampleSelect(c: *Conn, allocator: std.mem.Allocator) !void {
    const Person = struct {
        name: []const u8,
        cookie: []const u8,

        fn greet(self: @This()) void {
            std.debug.print("Hello, {s}! You cookie {s}.\n", .{ self.name, self.cookie });
        }
    };

    { // Select
        const query =
            \\SELECT username, cookie
            \\FROM blog_user
        ;
        const prep_res = try c.prepare(allocator, query);
        defer prep_res.deinit(allocator);
        const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

        { // Iterating over rows, scanning into struct or creating struct
            const query_res = try c.executeRows(&prep_stmt, .{}); // no parameters because there's no ? in the query
            const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);
            const rows_iter = rows.iter();
            while (try rows_iter.next()) |row| {
                {
                    // scanning into preallocated person
                    var person: Person = undefined;
                    try row.scan(&person);
                    person.greet();
                }
            }
        }

    }
}

fn exampleInsert(c: *Conn, allocator: std.mem.Allocator) !void {
    { // Insert
        const prep_res = try c.prepare(allocator, "INSERT INTO blog_user (username, cookie) VALUES (?, ?)");
        defer prep_res.deinit(allocator);
        const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);
        const params = .{
            .{ "John", "cookie1" },
            .{ "Sam", "cookie2" },
        };

        inline for (params) |param| {
            const exe_res = try c.execute(&prep_stmt, param);
            const ok: OkPacket = try exe_res.expect(.ok); // expecting ok here because there's no rows returned
            const last_insert_id: u64 = ok.last_insert_id;
            std.debug.print("last_insert_id: {any}\n", .{last_insert_id});
        }
    }
}

fn exampleDelete(c: *Conn, allocator: std.mem.Allocator) !void {
    { // Insert
        const prep_res = try c.prepare(allocator, "DELETE FROM blog_user WHERE id = ?");
        defer prep_res.deinit(allocator);
        const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

        const param = .{ 2 };
        const exe_res = try c.execute(&prep_stmt, param);

        const ok: OkPacket = try exe_res.expect(.ok); // expecting ok here because there's no rows returned
        const last_insert_id: u64 = ok.last_insert_id;
        std.debug.print("last_insert_id: {any}\n", .{last_insert_id});

    }
}

fn exampleUpdate(c: *Conn, allocator: std.mem.Allocator) !void {
    { // Insert
        const prep_res = try c.prepare(allocator, "UPDATE blog_user SET sign = ? WHERE id = ?");
        defer prep_res.deinit(allocator);
        const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

        const param = .{ "sign text", 3 };
        const exe_res = try c.execute(&prep_stmt, param);

        const ok: OkPacket = try exe_res.expect(.ok); // expecting ok here because there's no rows returned
        const last_insert_id: u64 = ok.last_insert_id;
        std.debug.print("last_insert_id: {any}\n", .{last_insert_id});

    }
}
