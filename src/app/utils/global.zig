const std = @import("std");
const myzql = @import("myzql");
const Conn = myzql.conn.Conn;

pub const conf = @import("./config.zig");
pub const DB = conf.DB;

pub const App = struct {
    db: *Conn,
};

pub const config = struct {
    pub const db = DB{
        .username = "root",   
        .password = "123456", 
        .database = "zig_say", 

        .address =  std.net.Address.initIp4(.{ 192, 168, 56, 1 }, 3306),
    };
};
