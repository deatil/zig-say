const std = @import("std");
const httpz = @import("httpz");

const AdminAuth = @This();

debug: bool,

// Must defined a pub config structure, even if it's empty
pub const Config = struct {
   debug: bool = false,
};

// Must define an `init` method, which will accept your Config
// Alternatively, you can define a init(config: Config, mc: httpz.MiddlewareConfig)
// here mc will give you access to the server's allocator and arena
pub fn init(config: Config) !AdminAuth {
    return .{
        .debug = config.debug,
    };
}

// optionally you can define an "deinit" method
// pub fn deinit(self: *AdminAuth) void {

// }

// Must define an `execute` method. `self` doesn't have to be `const`, but
// you're responsible for making your middleware thread-safe.
pub fn execute(self: *const AdminAuth, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {
    if (self.debug) {
        _ = res;

        const path = req.url.path;
        if (std.mem.startsWith(u8, path, "/admin/")) {
            std.debug.print("111111111111111111111 \n", .{});
        }
    }

    return executor.next();
}
