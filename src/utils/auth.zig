const std = @import("std");
const mem = std.mem;
const testing = std.testing;
const Allocator = std.mem.Allocator;
const bcrypt = std.crypto.pwhash.bcrypt;

pub fn passwordHash(alloc: Allocator, pwword: []const u8) ![]const u8 {
    const hash_options = bcrypt.HashOptions{
        .params = .{ .rounds_log = 5 },
        .encoding = .phc,
        .silently_truncate_password = false,
    };

    var res: [bcrypt.hash_length * 2]u8 = undefined;
    const s = try bcrypt.strHash(pwword, hash_options, &res);

    var buf = std.ArrayList(u8).init(alloc);
    defer buf.deinit();

    try buf.appendSlice(s[0..]);

    return try buf.toOwnedSlice();
}

pub fn checkPasswordHash(pwword: []const u8, hash: []const u8) bool {
    const verify_options = bcrypt.VerifyOptions{};

    bcrypt.strVerify(hash, pwword, verify_options) catch {
        return false;
    };

    return true;
}

test "passwordHash" {
    const alloc = std.heap.page_allocator;

    const pwword = "test pass";
    const prefix = "$bcrypt$r=5$";
    const check = "$bcrypt$r=5$mMZ357Siaq4Omt4Dm97+6g$9AI7WP6aK9pGDrMrUHjcsfRtEh3V3hU";

    const pw = try passwordHash(alloc, pwword);
    try testing.expectEqual(true, mem.startsWith(u8, pw, prefix));

    try testing.expectEqual(true, checkPasswordHash(pwword, check));
}

