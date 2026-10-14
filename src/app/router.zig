const say = @import("say");
const global = say.global;
const config = say.global.config;

const controller = @import("controller.zig");

const index = controller.index;
const admin = controller.admin;
const static = controller.static;
const errors = controller.errors;

const Logger = say.app.middleware.Logger;
const Auth = say.app.middleware.Auth;
const AdminAuth = say.app.middleware.AdminAuth;

pub fn route() !void {
    const io = global.server.io;

    const logger = try global.server.middleware(Logger, .{ 
        .io = io, 
        .query = true, 
        .debug = config.app.debug, 
    });

    var router = try global.server.router(.{
        .middlewares = &.{ logger },
    });

    try indexRoute(router);

    try adminRoute(router);

    staticRoute(router);

    // Fallback handlers for all unmatched routes (must be last)
    router.all("/*", errors.notFound, .{});
}

pub fn indexRoute(router: anytype) !void {
    const auth = try global.server.middleware(Auth, .{ .debug = config.app.debug });

    var group = router.group("/", .{
        .middlewares = &.{ auth },
    });

    group.get("/", index.index.index, .{});

    group.get("/auth/login", index.auth.login, .{});
    group.post("/auth/login", index.auth.loginSave, .{});
    group.get("/auth/logout", index.auth.logout, .{});

    group.get("/topic/:id", index.topic.view, .{});
    group.get("/topic/create", index.topic.create, .{});
    group.post("/topic/create", index.topic.createSave, .{});
    group.post("/topic/comment/add", index.topic.addComment, .{});
}

pub fn adminRoute(router: anytype) !void {
    const admin_auth = try global.server.middleware(AdminAuth, .{ .debug = config.app.debug });
    
    var group = router.group("/admin", .{
        .middlewares = &.{ admin_auth },
    });

    group.get("/auth/login", admin.auth.login, .{});
    group.post("/auth/login", admin.auth.loginSave, .{});
    group.get("/auth/logout", admin.auth.logout, .{});

    group.get("/", admin.index.index, .{});
    group.get("/index", admin.index.index, .{});
    group.get("/console", admin.index.console, .{});

    // profile
    group.get("/profile/password", admin.profile.password, .{});
    group.post("/profile/password", admin.profile.passwordSave, .{});

    // setting
    group.get("/setting", admin.setting.index, .{});
    group.post("/setting", admin.setting.save, .{});

    // user
    group.get("/user/index", admin.user.index, .{});
    group.get("/user/list", admin.user.list, .{});
    group.get("/user/add", admin.user.add, .{});
    group.post("/user/add", admin.user.addSave, .{});
    group.get("/user/edit", admin.user.edit, .{});
    group.post("/user/edit", admin.user.editSave, .{});
    group.post("/user/del", admin.user.del, .{});

    // topic
    group.get("/topic/index", admin.topic.index, .{});
    group.get("/topic/list", admin.topic.list, .{});
    group.get("/topic/edit", admin.topic.edit, .{});
    group.post("/topic/edit", admin.topic.editSave, .{});
    group.post("/topic/del", admin.topic.del, .{});

    // comment
    group.get("/comment/index", admin.comment.index, .{});
    group.get("/comment/list", admin.comment.list, .{});
    group.get("/comment/edit", admin.comment.edit, .{});
    group.post("/comment/edit", admin.comment.editSave, .{});
    group.post("/comment/del", admin.comment.del, .{});

    group.all("/*", errors.notFound, .{});
}

pub fn staticRoute(router: anytype) void {
    router.get("/static/*", static.index, .{});
}
