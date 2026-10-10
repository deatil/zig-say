const std = @import("std");

const zig_time = @import("zig-time");
const myzql = @import("myzql");
const httpz = @import("httpz");
const constants = myzql.constants;
const mysql_config = myzql.config;
const httpz_config = httpz.Config;

pub const App = struct {
    debug: bool = false,
    public_path: []const u8 = "",
    loc: zig_time.Location = zig_time.CTT,
};

pub const Server = struct {
    address: httpz_config.Address,
    request: httpz_config.Request,
};

pub const Auth = struct {
    key: []const u8 = "",
    iv: []const u8 = "",
};

pub const DB = struct {
    username: [:0]const u8 = "root",
    address: mysql_config.Address,
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
        .address = .{ .ip = std.Io.net.IpAddress.parseLiteral("192.168.56.1:3306") catch unreachable }
    };

    pub const server = Server{
        .address = .localhost(5883),
        .request = .{
            .max_header_count = 100,
            .max_param_count = 100,
            .max_query_count = 100,
            .max_form_count = 100,
            .max_multiform_count = 100,
        },
    };
};
