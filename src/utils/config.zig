const std = @import("std");
const myzql = @import("myzql");
const constants = myzql.constants;

pub const DB = struct {
    username: [:0]const u8 = "root",
    address: std.net.Address = std.net.Address.initIp4(.{ 127, 0, 0, 1 }, 3306),
    password: []const u8 = "",
    database: [:0]const u8 = "",
    collation: u8 = constants.utf8mb4_general_ci,

    // cfgs from Golang driver
    client_found_rows: bool = false, // Return number of matching rows instead of rows changed
    ssl: bool = false,
    multi_statements: bool = false,
};

pub const App = struct {
    debug: bool = false,
    public_path: []const u8 = "",
    max_bytes_public_content: usize = std.math.pow(usize, 2, 20),
};

pub const Server = struct {
    port: ?u16 = null,
    address: ?[]const u8 = null,
};

pub const config = struct {
    pub const app = App{
        .debug = true,
        .public_path = "resources/static",
        .max_bytes_public_content = std.math.pow(usize, 2, 20),
    };

    pub const db = DB{
        .username = "root",   
        .password = "123456", 
        .database = "zig_say", 

        .address =  std.net.Address.initIp4(.{ 192, 168, 56, 1 }, 3306),
    };

    pub const server = Server{
        .port = 5882,
        // .address = "0.0.0.0",
    };
};
