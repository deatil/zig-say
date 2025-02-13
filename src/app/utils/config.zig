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
