const std = @import("std");
const Io = std.Io;

const vin = @import("zig-vin");

const myzql = @import("myzql");
const Conn = myzql.conn.Conn;

const say = @import("say");

pub const config = say.config;

pub const mime = @import("mime.zig");

pub const App = struct {
    io: Io,
    db: *Conn,
    mime_map: *mime.MimeMap,
    view: *vin.Environment
};
