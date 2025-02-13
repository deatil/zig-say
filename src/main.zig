const std = @import("std");
const httpz = @import("httpz");
const zmpl = @import("zmpl");
const myzql = @import("myzql");
const Conn = myzql.conn.Conn;

const lib = @import("say-lib");
const App = lib.global.App;
const config = lib.global.config;

const controller = @import("./app/controller/controller.zig");
const index_controller = controller.index;
const user_controller = controller.user;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var db = try Conn.init(
        allocator,
        &.{
            .username = config.db.username,   
            .password = config.db.password,  
            .database = config.db.database,  
            .address =  config.db.address,  
        },
    );
    defer db.deinit();
    try db.ping();

    var app = App{
        .db = &db,
    };

    var server = try httpz.Server(*App).init(allocator, .{.port = 5882}, &app);

    var router = server.router(.{});

    router.get("/api/user/:id", index_controller.getUser, .{});
    router.get("/html", index_controller.showHtml, .{});

    router.get("/user/list", user_controller.getUser, .{});
    router.get("/user/info/:id", user_controller.getUserInfo, .{});
    router.get("/user/add", user_controller.addUser, .{});
    router.get("/user/del/:id", user_controller.deleteUser, .{});

    try server.listen(); 
}
