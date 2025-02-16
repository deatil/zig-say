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
