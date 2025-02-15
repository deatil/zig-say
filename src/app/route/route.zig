const controller = @import("./../controller/lib.zig");
const user_controller = controller.user;

const index = controller.index;
const admin = controller.admin;
const static = controller.static;

pub fn route(router: anytype) void {
    index_route(router);
    index_route2(router);

    admin_route(router);
    static_route(router);
}

pub fn index_route(router: anytype) void {
    router.get("/", index.index.index, .{});
}

pub fn index_route2(router: anytype) void {
    router.get("/user/list", user_controller.getUser, .{});
    router.get("/user/info/:id", user_controller.getUserInfo, .{});
    router.get("/user/add", user_controller.addUser, .{});
    router.get("/user/del/:id", user_controller.deleteUser, .{});
    router.get("/user/update/:id", user_controller.updateUser, .{});
}

pub fn admin_route(router: anytype) void {
    router.get("/admin/index", admin.index.index, .{});
}

pub fn static_route(router: anytype) void {
    router.get("/static/*", static.static.index, .{});
}

