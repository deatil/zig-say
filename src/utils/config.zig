const std = @import("std");

const zig_time = @import("zig-time");
const myzql = @import("myzql");
const constants = myzql.constants;

pub const App = struct {
    debug: bool = false,
    public_path: []const u8 = "",
    loc: zig_time.Location = zig_time.CTT,
};

pub const Server = struct {
    port: ?u16 = null,
    address: ?[]const u8 = null,
};

pub const Auth = struct {
    key: []const u8 = "",
    iv: []const u8 = "",
};

pub const DB = struct {
    username: [:0]const u8 = "root",
    address: std.net.Address = std.net.Address.initIp4(.{ 127, 0, 0, 1 }, 3306),
    password: []const u8 = "",
    database: [:0]const u8 = "",
    collation: u8 = constants.utf8mb4_general_ci,
    client_found_rows: bool = false,
    ssl: bool = false,
    multi_statements: bool = false,
};

pub const config = struct {
    pub const app = App{
        .debug = true,
        .public_path = "resources/static",
        .loc = zig_time.CTT,
    };

    pub const auth = Auth{
        .key = "qwedrftgfrt5rtfgtr4rtgfrt56yjws1",
        .iv = "tyhgfvbnhjuiklw3",
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
