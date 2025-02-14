const std = @import("std");
const myzql = @import("myzql");
const Conn = myzql.conn.Conn;

pub const mime = @import("./mime.zig");

pub const conf = @import("./config.zig");
pub const DB = conf.DB;
pub const config = conf.config;

pub const App = struct {
    db: *Conn,
    mime_map: *mime.MimeMap,
};


