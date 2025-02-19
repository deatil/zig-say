const std = @import("std");
const httpz = @import("httpz");

const lib = @import("say-lib");
const conf = lib.global.config;
const auth = lib.utils.auth;
const http = lib.utils.http;

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
        const path = req.url.path;
        if (std.mem.startsWith(u8, path, "/admin/")) {
            if (!std.mem.startsWith(u8, path, "/admin/auth/")) {
                
                var cookies = req.cookies();
                const login_data = cookies.get("admin_login") orelse "";
                if (login_data.len == 0) {
                    if (req.method == .POST) {
                        try res.json(.{
                            .code = 1,
                            .msg = "请先登录",
                        }, .{});
                        return;
                    } else {
                        res.status = 303;
                        res.header("Location", "/admin/auth/login");
                        return;
                    }
                }

                const username = auth.decrypt(res.arena, login_data, conf.auth.key, conf.auth.iv) catch "";
                if (username.len == 0) {
                    try http.delCookie(res, "admin_login");

                    if (req.method == .POST) {
                        try res.json(.{
                            .code = 1,
                            .msg = "请先登录",
                        }, .{});
                        return;
                    } else {
                        res.status = 303;
                        res.header("Location", "/admin/auth/login");
                        return;
                    }
                }

                req.headers.add("admin_login", username);
            }
        }
    }

    return executor.next();
}
