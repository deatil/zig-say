const lib = @import("say-lib");
const config = lib.global.config;

const controller = @import("./../controller/lib.zig");

const index = controller.index;
const admin = controller.admin;
const static = controller.static;
const error_handler = controller.error_handler;

pub fn route(router: anytype) void {
    indexRoute(router);

    adminRoute(router);
    staticRoute(router);

    // Fallback handler for all unmatched routes (must be last)
    router.get("/*", error_handler.error_handler.notFound, .{});
}

pub fn indexRoute(router: anytype) void {
    router.get("/", index.index.index, .{});

    router.get("/auth/login", index.auth.login, .{});
    router.post("/auth/login", index.auth.loginSave, .{});
    router.get("/auth/logout", index.auth.logout, .{});

    router.get("/topic/:id", index.topic.view, .{});
    router.get("/topic/create", index.topic.create, .{});
    router.post("/topic/create", index.topic.createSave, .{});
    router.post("/topic/comment/add", index.topic.addComment, .{});
}

pub fn adminRoute(router: anytype) void {
    router.get("/admin/auth/login", admin.auth.login, .{});
    router.post("/admin/auth/login", admin.auth.loginSave, .{});
    router.get("/admin/auth/logout", admin.auth.logout, .{});

    router.get("/admin/index", admin.index.index, .{});
    router.get("/admin/console", admin.index.console, .{});

    // profile
    router.get("/admin/profile/password", admin.profile.password, .{});
    router.post("/admin/profile/password", admin.profile.passwordSave, .{});

    // setting
    router.get("/admin/setting", admin.setting.index, .{});
    router.post("/admin/setting", admin.setting.save, .{});

    // user
    router.get("/admin/user/index", admin.user.index, .{});
    router.get("/admin/user/list", admin.user.list, .{});
    router.get("/admin/user/add", admin.user.add, .{});
    router.post("/admin/user/add", admin.user.addSave, .{});
    router.get("/admin/user/edit", admin.user.edit, .{});
    router.post("/admin/user/edit", admin.user.editSave, .{});
    router.post("/admin/user/del", admin.user.del, .{});

    // topic
    router.get("/admin/topic/index", admin.topic.index, .{});
    router.get("/admin/topic/list", admin.topic.list, .{});
    router.get("/admin/topic/edit", admin.topic.edit, .{});
    router.post("/admin/topic/edit", admin.topic.editSave, .{});
    router.post("/admin/topic/del", admin.topic.del, .{});

    // comment
    router.get("/admin/comment/index", admin.comment.index, .{});
    router.get("/admin/comment/list", admin.comment.list, .{});
    router.get("/admin/comment/edit", admin.comment.edit, .{});
    router.post("/admin/comment/edit", admin.comment.editSave, .{});
    router.post("/admin/comment/del", admin.comment.del, .{});
}

pub fn staticRoute(router: anytype) void {
    router.get("/static/*", static.static.index, .{});
}
