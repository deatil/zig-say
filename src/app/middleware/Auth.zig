const std = @import("std");
const httpz = @import("httpz");

const say = @import("say");
const conf = say.global.config;
const http = say.utils.http;

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
    _ = self;
    _ = res;

    var cookies = req.cookies();
    const loginid = cookies.get("loginid") orelse "";
    if (loginid.len == 0) {
        return executor.next();
    }

    req.headers.add("loginid", loginid);
    return executor.next();
}
