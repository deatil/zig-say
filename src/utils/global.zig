const std = @import("std");
const Io = std.Io;

const vin = @import("zig-vin");
const httpz = @import("httpz");
const myzql = @import("myzql");
const say = @import("say");

const Conn = myzql.conn.Conn;

pub const mime = @import("mime.zig");
pub const config = say.config;

pub const App = struct {
    io: Io,
    db: *Conn,
    mime_map: *mime.MimeMap,
    view: *vin.Environment,
};

pub const Server = httpz.Server(*App);

pub var server: *Server = undefined;
