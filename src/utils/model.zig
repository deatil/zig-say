const std = @import("std");
const myzql = @import("myzql");
const Conn = myzql.conn.Conn;

// convenient function for testing
fn queryExpectOk(c: *Conn, query: []const u8) !void {
    const query_res = try c.query(query);
    _ = try query_res.expect(.ok);
}
