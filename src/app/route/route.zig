const controller = @import("./../controller/controller.zig");
const index_controller = controller.index;
const user_controller = controller.user;
const static_controller = controller.static;

pub fn route(router: anytype) void {
    router.get("/api/user/:id", index_controller.getUser, .{});
    router.get("/html", index_controller.showHtml, .{});

    router.get("/user/list", user_controller.getUser, .{});
    router.get("/user/info/:id", user_controller.getUserInfo, .{});
    router.get("/user/add", user_controller.addUser, .{});
    router.get("/user/del/:id", user_controller.deleteUser, .{});
    router.get("/user/update/:id", user_controller.updateUser, .{});

    router.get("/static/*", static_controller.static, .{});
}
