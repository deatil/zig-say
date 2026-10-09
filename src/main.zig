const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

const httpz = @import("httpz");
const vin = @import("zig-vin");
const time = @import("zig-time");
const myzql = @import("myzql");
const Conn = myzql.conn.Conn;

const lib = @import("say-pkg");
const App = lib.global.App;
const config = lib.global.config;
const mime = lib.global.mime;

const opts = @import("say-opts");

const Server = httpz.Server(*App);

const Logger = lib.app.middleware.Logger;
const AdminAuth = lib.app.middleware.AdminAuth;
const route = lib.app.router.route;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.arena.allocator();

    var db = try initDB(allocator, io);
    defer db.deinit(allocator, io);

    var mime_map = mime.MimeMap.init(allocator);
    defer mime_map.deinit();
    try mime_map.build();

    var view = try initView(allocator, io);
    defer view.deinit();

    var app: App = .{
        .io = io,
        .db = &db,
        .mime_map = &mime_map,
        .view = &view,
    };

    var server = try Server.init(io, allocator, .{
        .address = config.server.address,
    }, &app);

    var router = try server.router(.{});

    const logger = try server.middleware(Logger, .{ .io = io, .query = true, .debug = config.app.debug });
    const admin_auth = try server.middleware(AdminAuth, .{ .debug = config.app.debug });
    router.middlewares = &.{ logger, admin_auth };

    route(router);

    try showMsg(allocator, io);

    try server.listen();
}

fn showMsg(allocator: Allocator, io: Io) !void {
    var buf: [256]u8 = undefined;
    var stream: std.Io.Writer = .fixed(&buf);
    try config.server.address.format(&stream);

    const address_string = stream.buffered();

    const time_string = try time.now(io).formatAlloc(allocator, "YYYY-MM-DD HH:mm:ss");

    std.debug.print("Zig-say started \n", .{});
    std.debug.print("Run time: {s} \n", .{time_string});
    std.debug.print("Server address: {s} \n", .{address_string});
}

fn initDB(allocator: Allocator, io: Io) !Conn {
    var client = try Conn.init(
        allocator,
        io,
        &.{
            .username = config.db.username,
            .password = config.db.password,
            .database = config.db.database,
            .address = config.db.address,
        },
    );

    try client.ping(io);

    return client;
}

fn initView(alloc: Allocator, io: std.Io) !vin.Environment {
    var dl_ptr = try alloc.create(vin.DirLoader);
    dl_ptr.* = .{
        .io = io,
        .root = try std.Io.Dir.openDirAbsolute(io, opts.tmp_path, .{}),
        .options = .{ 
            .suffix = ".html", 
            .max_bytes = 1 << 20,
        },
    };

    const env = try vin.Environment.initWithLoader(alloc, .{}, dl_ptr.loader());
    return env;
}
