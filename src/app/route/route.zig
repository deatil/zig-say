const lib = @import("say-lib");
const config = lib.global.config;

const controller = @import("./../controller/lib.zig");
const user_controller = controller.user;

const index = controller.index;
const admin = controller.admin;
const static = controller.static;

pub fn route(router: anytype) void {
    indexRoute(router);
    indexRoute2(router);

    adminRoute(router);
    staticRoute(router);
}

pub fn indexRoute(router: anytype) void {
    router.get("/", index.index.index, .{});
}

pub fn indexRoute2(router: anytype) void {
    router.get("/user/list", user_controller.getUser, .{});
    router.get("/user/info/:id", user_controller.getUserInfo, .{});
    router.get("/user/add", user_controller.addUser, .{});
    router.get("/user/del/:id", user_controller.deleteUser, .{});
    router.get("/user/update/:id", user_controller.updateUser, .{});
}

pub fn adminRoute(router: anytype) void {
    router.get("/admin/auth/login", admin.auth.login, .{});
    router.post("/admin/auth/login", admin.auth.loginSave, .{});

    router.get("/admin/index", admin.index.index, .{});
}

pub fn staticRoute(router: anytype) void {
    router.get("/static/*", static.static.index, .{});
}

