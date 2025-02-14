const std = @import("std");
const httpz = @import("httpz");
const zig_time = @import("zig-time");

const lib = @import("say-lib");
const conf = lib.global.config;

const Logger = @This();

query: bool,

// Must defined a pub config structure, even if it's empty
pub const Config = struct {
   query: bool,
};

// Must define an `init` method, which will accept your Config
// Alternatively, you can define a init(config: Config, mc: httpz.MiddlewareConfig)
// here mc will give you access to the server's allocator and arena
pub fn init(config: Config) !Logger {
    return .{
        .query = config.query,
    };
}

// optionally you can define an "deinit" method
// pub fn deinit(self: *Logger) void {

// }

// Must define an `execute` method. `self` doesn't have to be `const`, but
// you're responsible for making your middleware thread-safe.
pub fn execute(self: *const Logger, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {
    if (conf.app.debug) {
        const start = std.time.microTimestamp();

        const now_datetime = try zig_time.now().utc().formatAlloc(res.arena, "YYYY-MM-DD HH:mm:ss");
        defer res.arena.free(now_datetime);

        defer {
            const elapsed = std.time.microTimestamp() - start;
            std.log.info("[{s}]\t{s}?{s}\t{d}\t{d}us", .{now_datetime, req.url.path, if (self.query) req.url.query else "", res.status, elapsed});
        }
    }

    return executor.next();
}
