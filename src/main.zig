const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

const httpz = @import("httpz");
const vin = @import("zig-vin");
const time = @import("zig-time");

const myzql = @import("myzql");
const Conn = myzql.conn.Conn;

const say = @import("say");
const config = say.global.config;
const mime = say.global.mime;
const App = say.global.App;
const Server = say.global.Server;

const route = say.app.router.route;

const opts = @import("say-opts");

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
        .request = config.server.request,
    }, &app);

    defer server.deinit();
    defer server.stop();

    // set global server
    say.global.server = &server;

    try route();

    try showMsg(allocator, io);

    try server.listen();
}

fn showMsg(allocator: Allocator, io: Io) !void {
    const address_string = try allocator.print("{f}", .{config.server.address});
    const time_string = try time.now(io).formatAlloc(allocator, "YYYY-MM-DD HH:mm:ss");

    std.debug.print("Zig-say started. \n", .{});
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

    var env = try vin.Environment.initWithLoader(alloc, .{}, dl_ptr.loader());
    env.withIo(io);

    return env;
}
