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

pub const Comment = struct {
    id: u32 = 0,
    user_id: u32 = 0,
    topic_id: u32 = 0,
    content: []const u8 = "",
    status: u16 = 0,
    add_time: u32 = 0,
    add_ip: []const u8 = "",
};

pub const CommentUser = struct {
    id: u32 = 0,
    user_id: u32 = 0,
    topic_id: u32 = 0,
    content: []const u8 = "",
    status: u16 = 0,
    add_time: u32 = 0,
    add_ip: []const u8 = "",

    username: ?[]const u8 = "",
    user_sign: ?[]const u8 = "",
};

pub const QueryWhere = struct {
    offset: u32 = 0,
    limit: u32 = 10,
    keywords: []const u8 = "",
    status: ?u16 = null,
    order: []const u8 = "c.id ASC",
};

pub const ResultCount = struct {
    n: u64 = 0,
};

pub fn getList(alloc: Allocator, conn: *Conn, where: QueryWhere) !ResultSet(BinaryResultRow) {
    if (where.status) |status| {
        const query =
            \\SELECT c.*, u.username, u.sign as user_sign
            \\FROM say_comment c
            \\LEFT JOIN say_user u ON u.id = c.user_id
            \\WHERE (c.content LIKE ? OR c.topic_id = ?) AND c.status = ?
            \\ORDER BY ?
            \\LIMIT ?, ?
        ;

        const new_keywords = try std.fmt.allocPrint(alloc, "%{s}%", .{where.keywords});
        const params = .{new_keywords, where.keywords, status, where.order, where.offset, where.limit};

        const prep_res = try conn.prepare(alloc, query);
        defer prep_res.deinit(alloc);
        const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

        const query_res = try conn.executeRows(&prep_stmt, params); 
        const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

        return rows;
    }
    
    const query =
        \\SELECT c.*, u.username, u.sign as user_sign
        \\FROM say_comment c
        \\LEFT JOIN say_user u ON u.id = c.user_id
        \\WHERE (c.content LIKE ? OR c.topic_id = ?)
        \\ORDER BY ?
        \\LIMIT ?, ?
    ;

    const new_keywords = try std.fmt.allocPrint(alloc, "%{s}%", .{where.keywords});
    const params = .{new_keywords, where.keywords, where.order, where.offset, where.limit};

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
            \\FROM say_comment
            \\WHERE (content LIKE ? OR topic_id = ?) AND status = ?
            \\LIMIT 1
        ;

        const new_keywords = try std.fmt.allocPrint(alloc, "%{s}%", .{where.keywords});
        const params = .{new_keywords, where.keywords, status};

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
        \\FROM say_comment
        \\WHERE (content LIKE ? OR topic_id = ?)
        \\LIMIT 1
    ;

    const new_keywords = try std.fmt.allocPrint(alloc, "%{s}%", .{where.keywords});
    const params = .{new_keywords, where.keywords};

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

pub fn getInfoById(alloc: Allocator, conn: *Conn, id: u32) !CommentUser {
    const query =
        \\SELECT c.*, u.username, u.sign as user_sign
        \\FROM say_comment c
        \\LEFT JOIN say_user u ON u.id = c.user_id
        \\WHERE c.id = ?
        \\LIMIT 1
    ;
    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const query_res = try conn.executeRows(&prep_stmt, .{id}); 
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

    const first_info = try rows.first();
    if (first_info) |val| {
        var comment: CommentUser = undefined;
        try val.scan(&comment);

        return comment;
    }

    return .{};
}

pub fn updateInfoById(alloc: Allocator, conn: *Conn, id: u32, comment: Comment) !bool {
    const query =
        \\UPDATE say_comment
        \\SET user_id = ?, topic_id = ?, content = ?, status = ?, add_time = ?, add_ip = ?
        \\WHERE id = ?
    ;

    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const exe_res = try conn.execute(&prep_stmt, .{ 
        comment.user_id, 
        comment.topic_id, 
        comment.content, 
        comment.status, 
        comment.add_time, 
        comment.add_ip, 

        id,
    });

    const ok: OkPacket = try exe_res.expect(.ok); 
    const affected_rows: u64 = ok.affected_rows;
    if (affected_rows == 0) {
        return false;
    }

    return true;
}

pub fn addInfo(alloc: Allocator, conn: *Conn, comment: Comment) !bool {
    const query =
        \\INSERT INTO say_comment
        \\(user_id, topic_id, content, status, add_time, add_ip)
        \\VALUES (?, ?, ?, ?, ?, ?)
    ;

    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);
    const params = .{ 
        comment.user_id, 
        comment.topic_id, 
        comment.content, 
        comment.status, 
        comment.add_time, 
        comment.add_ip, 
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
        \\DELETE FROM say_comment
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

pub fn getListByTopicId(alloc: Allocator, conn: *Conn, topic_id: u32, where: QueryWhere) !ResultSet(BinaryResultRow) {
    const query =
        \\SELECT c.*, u.username, u.sign as user_sign
        \\FROM say_comment c
        \\LEFT JOIN say_user u ON u.id = c.user_id
        \\WHERE c.topic_id = ? AND c.status = 1
        \\ORDER BY ?
        \\LIMIT ?, ?
    ;

    const params = .{topic_id, where.order, where.offset, where.limit};

    const prep_res = try conn.prepare(alloc, query);
    defer prep_res.deinit(alloc);
    const prep_stmt: PreparedStatement = try prep_res.expect(.stmt);

    const query_res = try conn.executeRows(&prep_stmt, params); 
    const rows: ResultSet(BinaryResultRow) = try query_res.expect(.rows);

    return rows;
}

pub fn getCountByTopicId(alloc: Allocator, conn: *Conn, topic_id: u32) !u64 {
    const query =
        \\SELECT count(id) as n
        \\FROM say_comment
        \\WHERE topic_id = ? AND status = 1
        \\LIMIT 1
    ;

    const params = .{topic_id};

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
