const zig_time = @import("zig-time");
const config = @import("./config.zig").config;

pub const time = zig_time;

pub fn now() zig_time.Time {
    return zig_time.now().setLoc(config.app.loc);
}

pub fn parse(comptime layout: []const u8, value: []const u8) !zig_time.Time {
    return try zig_time.parse(layout, value);
}
