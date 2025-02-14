const std = @import("std");
const httpz = @import("httpz");
const zmpl = @import("zmpl");
const myzql = @import("myzql");
const Conn = myzql.conn.Conn;

const Server = httpz.Server(*App);

const lib = @import("say-lib");
const App = lib.global.App;
const config = lib.global.config;
const mime = lib.global.mime;

const Logger = @import("./app/middleware/Logger.zig");
const route = @import("./app/route/route.zig").route;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // initDB
    var db = try initDB(allocator);
    defer db.deinit();

    // mime_map
    var mime_map = mime.MimeMap.init(allocator);
    defer mime_map.deinit();
    try mime_map.build();

    var app = App{
        .db = &db,
        .mime_map = &mime_map,
    };

    var server = try Server.init(allocator, .{
        .port = config.server.port,
        .address = config.server.address,
    }, &app);

    var router = server.router(.{});

    // middleware
    const logger = try server.middleware(Logger, .{ .query = true });
    router.middlewares = &.{logger};

    route(router);

    try server.listen(); 
}

fn initDB(allocator: std.mem.Allocator) !Conn {
    var client = try Conn.init(
        allocator,
        &.{
            .username = config.db.username,   
            .password = config.db.password,  
            .database = config.db.database,  
            .address =  config.db.address,  
        },
    );
    
    try client.ping();

    return client;
}

