const std = @import("std");
const Io = std.Io;

const vin = @import("zig-vin");

const myzql = @import("myzql");
const Conn = myzql.conn.Conn;

const lib = @import("say-pkg");

pub const config = lib.config;
pub const DB = config.DB;

pub const mime = @import("mime.zig");

pub const App = struct {
    io: Io,
    db: *Conn,
    mime_map: *mime.MimeMap,
    view: *vin.Environment
};
