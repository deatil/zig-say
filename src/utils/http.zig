const std = @import("std");
const Allocator = std.mem.Allocator;

const httpz = @import("httpz");
const Url = httpz.Url;

const HashMap = std.StringHashMap([]const u8);

pub fn parseFormData(allocator: Allocator, b: []const u8) !HashMap {
    var fd = HashMap.init(allocator);

    var it = std.mem.splitScalar(u8, b, '&');
    while (it.next()) |pair| {
        if (std.mem.indexOfScalarPos(u8, pair, 0, '=')) |sep| {
            const key_res = try Url.unescape(allocator, &[_]u8{}, pair[0..sep]);
            const value_res = try Url.unescape(allocator, &[_]u8{}, pair[sep + 1 ..]);
            try fd.put(key_res.value, value_res.value);
        } else {
            const key_res = try Url.unescape(allocator, &[_]u8{}, pair);
            try fd.put(key_res.value, "");
        }
    }

    return fd;
}

pub fn formatBuf(allocator: Allocator, b: []const u8) ![]const u8 {
    var buf = std.ArrayList(u8).init(allocator);
    defer buf.deinit();

    try buf.appendSlice(b[0..]);

    return try buf.toOwnedSlice();
}

pub fn setCookie(res: *httpz.Response, key: []const u8, value: []const u8) !void {
    try res.setCookie(key, value, .{
        .path = "/",
        // .domain = "*",
        .max_age = 1_000_000,
        .secure = true,
        .http_only = true,
        .partitioned = true,
        .same_site = .lax,  // or .none, or .strict (or null to leave out)
    });
}

pub fn delCookie(res: *httpz.Response, key: []const u8) !void {
    try res.setCookie(key, "", .{
        .path = "/",
        // .domain = "*",
        .max_age = 0,
        .secure = true,
        .http_only = true,
        .partitioned = true,
        .same_site = .lax,  // or .none, or .strict (or null to leave out)
    });
}

