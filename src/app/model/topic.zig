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

pub const Topic = struct {
    id: u32 = 0,
    user_id: u32 = 0,
    title: []const u8 = "",
    content: []const u8 = "",
    views: u64 = 0,
    status: u16 = 0,
    add_time: u32 = 0,
    add_ip: []const u8 = "",
};

pub const TopicUser = struct {
    id: u32 = 0,
    user_id: u32 = 0,
    title: []const u8 = "",
    content: []const u8 = "",
    views: u64 = 0,
    status: u16 = 0,
    add_time: u32 = 0,
    add_ip: []const u8 = "",

    username: []const u8 = "",
    user_sign: []const u8 = "",
};

pub const QueryWhere = struct {
    offset: u32 = 0,
    limit: u32 = 10,
    keywords: []const u8 = "",
    status: ?u16 = null,
    order: []const u8 = "id ASC",
};

pub const ResultCount = struct {
    n: u64 = 0,
};

pub fn getList(alloc: Allocator, conn: *Conn, where: QueryWhere) !ResultSet(BinaryResultRow) {
    if (where.status) |status| {
        const query =
            \\SELECT t.*, u.username, u.sign as user_sign
            \\FROM say_topic t
            \\LEFT JOIN say_user u ON u.id = t.user_id
            \\WHERE t.title LIKE ? AND t.status = ?
            \\ORDER BY ?
            \\LIMIT ?, ?
        ;

        const new_keywords = try std.fmt.allocPrint(alloc, "%{s}%", .{where.keywords});
        const params = .{new_keywords, status, where.order, where.offset, where.limit};

        const prep_res = try conn.prepare(alloc, query);
        defer prep_res.deinit(alloc);
        const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

        const query_res = try conn.executeRows(&prep_stmt, params); 
        const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

        return rows;
    }
    
    const query =
        \\SELECT t.*, u.username, u.sign as user_sign
        \\FROM say_topic t
        \\LEFT JOIN say_user u ON u.id = t.user_id
        \\WHERE t.title LIKE ? 
        \\ORDER BY ?
        \\LIMIT ?, ?
    ;

    const new_keywords = try std.fmt.allocPrint(alloc, "%{s}%", .{where.keywords});
    const params = .{new_keywords, where.order, where.offset, where.limit};

    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const query_res = try conn.executeRows(&prep_stmt, params); 
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

    return rows;
}

pub fn getCount(alloc: Allocator, conn: *Conn, where: QueryWhere) !u64 {
    if (where.status) |status| {
        const query =
            \\SELECT count(id) as n
            \\FROM say_topic
            \\WHERE title LIKE ? AND status = ?
            \\LIMIT 1
        ;

        const new_keywords = try std.fmt.allocPrint(alloc, "%{s}%", .{where.keywords});
        const params = .{new_keywords, status};

        const prep_res = try conn.prepare(alloc, query);
        defer prep_res.deinit(alloc);
        const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

        const query_res = try conn.executeRows(&prep_stmt, params); 
        const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

        const first_info = try rows.first();
        if (first_info) |val| {
            var resultCount: ResultCount = undefined;
            try val.scan(&resultCount);

            return resultCount.n;
        }

        return 0;
    }
    
    const query =
        \\SELECT count(id) as n
        \\FROM say_topic
        \\WHERE title LIKE ?
        \\LIMIT 1
    ;

    const new_keywords = try std.fmt.allocPrint(alloc, "%{s}%", .{where.keywords});
    const params = .{new_keywords};

    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const query_res = try conn.executeRows(&prep_stmt, params); 
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

    const first_info = try rows.first();
    if (first_info) |val| {
        var resultCount: ResultCount = undefined;
        try val.scan(&resultCount);

        return resultCount.n;
    }

    return 0;
}

pub fn getInfoById(alloc: Allocator, conn: *Conn, id: u32) !TopicUser {
    const query =
        \\SELECT t.*, u.username, u.sign as user_sign
        \\FROM say_topic t
        \\LEFT JOIN say_user u ON u.id = t.user_id
        \\WHERE t.id = ?
        \\LIMIT 1
    ;
    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const query_res = try conn.executeRows(&prep_stmt, .{id}); 
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

    const first_info = try rows.first();
    if (first_info) |val| {
        var topic: TopicUser = undefined;
        try val.scan(&topic);

        return topic;
    }

    return .{};
}

pub fn updateInfoById(alloc: Allocator, conn: *Conn, id: u32, topic: Topic) !bool {
    const query =
        \\UPDATE say_topic
        \\SET user_id = ?, title = ?, content = ?, views = ?, status = ?, add_time = ?, add_ip = ?
        \\WHERE id = ?
    ;

    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const exe_res = try conn.execute(&prep_stmt, .{ 
        topic.user_id, 
        topic.title, 
        topic.content, 
        topic.views, 
        topic.status, 
        topic.add_time, 
        topic.add_ip, 

        id,
    });

    const ok: OkPacket = try exe_res.expect(.ok); 
    const affected_rows: u64 = ok.affected_rows;
    if (affected_rows == 0) {
        return false;
    }

    return true;
}

pub fn addInfo(alloc: Allocator, conn: *Conn, topic: Topic) !bool {
    const query =
        \\INSERT INTO say_topic
        \\(user_id, title, content, views, status, add_time, add_ip)
        \\VALUES (?, ?, ?, ?, ?, ?, ?)
    ;

    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);
    const params = .{ 
        topic.user_id, 
        topic.title, 
        topic.content, 
        topic.views, 
        topic.status, 
        topic.add_time, 
        topic.add_ip, 
    };

    const exe_res = try conn.execute(&prep_stmt, params);
    const ok: OkPacket = try exe_res.expect(.ok); 
    const affected_rows: u64 = ok.affected_rows;

    if (affected_rows > 0) {
        return true;
    }

    return false;
}

pub fn deleteInfo(alloc: Allocator, conn: *Conn, id: u32) !bool {
    const query =
        \\DELETE FROM say_topic
        \\WHERE id = ?
    ;

    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const param = .{ id };
    const exe_res = try conn.execute(&prep_stmt, param);

    const ok: OkPacket = try exe_res.expect(.ok); 
    const affected_rows: u64 = ok.affected_rows;
    if (affected_rows > 0) {
        return true;
    }

    return false;
}