const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const testing = std.testing;
const aes = std.crypto.core.aes;
const Allocator = std.mem.Allocator;
const bcrypt = std.crypto.pwhash.bcrypt;
const assert = std.debug.assert;

const zig_cbc = @import("./cbc.zig");

pub const Case = enum { lower, upper };
pub fn bytesToHex(alloc: Allocator, input: anytype, case: Case) ![]u8 {
    if (input.len == 0) return "";
    comptime assert(@TypeOf(input[0]) == u8);

    const charset = "0123456789" ++ if (case == .upper) "ABCDEF" else "abcdef";

    var result = try alloc.alloc(u8, input.len * 2);
    for (input, 0..) |b, i| {
        result[i * 2 + 0] = charset[b >> 4];
        result[i * 2 + 1] = charset[b & 15];
    }

    return result[0..];
}

pub fn hexToBytes(out: []u8, input: []const u8) ![]u8 {
    if (input.len & 1 != 0)
        return error.InvalidLength;
    if (out.len * 2 < input.len)
        return error.NoSpaceLeft;

    var in_i: usize = 0;
    while (in_i < input.len) : (in_i += 2) {
        const hi = try fmt.charToDigit(input[in_i], 16);
        const lo = try fmt.charToDigit(input[in_i + 1], 16);
        out[in_i / 2] = (hi << 4) | lo;
    }

    return out[0 .. in_i / 2];
}

pub fn passwordHash(alloc: Allocator, pwword: []const u8) ![]const u8 {
    const hash_options = bcrypt.HashOptions{
        .params = .{ .rounds_log = 5, .silently_truncate_password = false },
        .encoding = .phc,
    };

    var res: [bcrypt.hash_length * 2]u8 = undefined;
    const s = try bcrypt.strHash(pwword, hash_options, &res);

    var buf = std.array_list.Managed(u8).init(alloc);
    defer buf.deinit();

    try buf.appendSlice(s[0..]);

    return try buf.toOwnedSlice();
}

pub fn checkPasswordHash(pwword: []const u8, hash: []const u8) bool {
    const verify_options = bcrypt.VerifyOptions{ .silently_truncate_password = false };

    bcrypt.strVerify(hash, pwword, verify_options) catch {
        return false;
    };

    return true;
}

pub fn encrypt(alloc: Allocator, src: []const u8, key: []const u8, iv: []const u8) ![]const u8 {
    if (key.len < 32) {
        return error.KeyTooShort;
    }
    if (iv.len < 16) {
        return error.IVTooShort;
    }

    var new_key: [32]u8 = undefined;
    @memcpy(new_key[0..], key[0..32]);

    var new_iv: [16]u8 = undefined;
    @memcpy(new_iv[0..], iv[0..16]);

    const M = zig_cbc.CBC(aes.Aes256);
    const enc = M.init(new_key);

    var dst = try alloc.alloc(u8, M.paddedLength(src.len));
    enc.encrypt(dst, src, new_iv);

    dst = try bytesToHex(alloc, dst, .upper);
    return dst;
}

pub fn decrypt(alloc: Allocator, src: []const u8, key: []const u8, iv: []const u8) ![]const u8 {
    if (key.len < 32) {
        return error.KeyTooShort;
    }
    if (iv.len < 16) {
        return error.IVTooShort;
    }

    var new_key: [32]u8 = undefined;
    @memcpy(new_key[0..], key[0..32]);

    var new_iv: [16]u8 = undefined;
    @memcpy(new_iv[0..], iv[0..16]);

    const decoded = try alloc.alloc(u8, src.len);
    const decoded_src = hexToBytes(decoded, src) catch {
        return "";
    };

    const M = zig_cbc.CBC(aes.Aes256);
    const enc = M.init(new_key);

    const decrypted = try alloc.alloc(u8, M.maxDecryptedLength(decoded_src.len));
    const res = try enc.decryptAndTrim(decrypted, decoded_src, new_iv);

    return res;
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

test "encrypt" {
    const alloc = std.heap.page_allocator;

    const key = [_]u8{
        0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c,
        0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c,
    };
    const iv = [_]u8{
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
    };
    const src = "This is a test of AES-CBC that goes on longer than a couple blocks. It is a somewhat long test case to type out!";
    const en = "7233CD85D0B091ADA1180707AD30302EFA6E0BB5996BEB9BF55F36C774EA7FC897EA10717F216F15F10E7A81DADAE12A307D8953F27882DFFE20643048C66652BFD96BA10871FFB8B2E1530F86E58A1E21A80466716B82914A96D3151BD2DE85347C940D89C4EA70A607210AE3C27316982F6B4C153DC15F29D61D0827384534";

    const encrypted = try encrypt(alloc, src, &key, &iv);
    try testing.expectEqualStrings(en, encrypted);

    const decrypted = try decrypt(alloc, en, &key, &iv);
    try testing.expectEqualStrings(src, decrypted);
}
