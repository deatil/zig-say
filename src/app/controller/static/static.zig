const std = @import("std");
const Allocator = std.mem.Allocator;
const httpz = @import("httpz");

const lib = @import("say-lib");
const App = lib.global.App;
const config = lib.global.config;

pub fn index(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const resource = try matchPublicContent(res.arena, app, req) orelse {
        // Cache 404 responses for 5 minutes to avoid repeated requests
        // Note: Logger may show 200 due to httpz internal processing,
        // but browsers correctly receive 404
        res.status = 404;
        res.header("content-type", "text/plain");
        res.header("cache-control", "public, max-age=300");
        res.body = "Not Found";
        return;
    };

    // Handle conditional requests (If-Modified-Since)
    if (req.header("if-modified-since")) |if_modified| {
        if (std.mem.eql(u8, if_modified, resource.last_modified)) {
            res.status = 304;
            res.header("cache-control", resource.cache_control);
            res.header("last-modified", resource.last_modified);
            return;
        }
    }

    // Send file with cache headers
    res.status = 200;
    res.body = resource.content;
    res.header("content-type", resource.mime_type);
    res.header("cache-control", resource.cache_control);
    res.header("last-modified", resource.last_modified);
}

const StaticResource = struct {
    content: []const u8,
    mime_type: []const u8 = "application/octet-stream",
    cache_control: []const u8,
    last_modified: []const u8,
};

fn matchPublicContent(alloc: Allocator, app: *App, req: *httpz.Request) !?StaticResource {
    if (req.url.path.len <= "/static/".len or req.method != .GET) return null;

    const file_path = req.url.path["/static/".len..];
    const full_path = try std.fs.path.join(alloc, &.{ config.app.public_path, file_path });
    defer alloc.free(full_path);

    const absolute_path = if (std.fs.path.isAbsolute(full_path))
        try alloc.dupe(u8, full_path)
    else
        std.fs.cwd().realpathAlloc(alloc, full_path) catch return null;
    defer alloc.free(absolute_path);

    const file = std.fs.cwd().openFile(absolute_path, .{ .mode = .read_only }) catch return null;
    defer file.close();

    const stat = try file.stat();
    const extension = std.fs.path.extension(file_path);

    return .{
        .content = try file.readToEndAlloc(alloc, stat.size),
        .mime_type = app.mime_map.get(extension) orelse "application/octet-stream",
        .cache_control = getCacheControl(extension),
        .last_modified = try formatHttpDate(alloc, stat.mtime),
    };
}

/// Determine Cache-Control header based on file extension
fn getCacheControl(extension: []const u8) []const u8 {
    const static_assets = [_][]const u8{
        ".css",  ".js",  ".woff", ".woff2", ".ttf", ".eot",
        ".png",  ".jpg", ".jpeg", ".gif",   ".svg", ".ico",
        ".webp", ".map",
    };

    for (static_assets) |ext| {
        if (std.mem.eql(u8, extension, ext)) {
            // Cache static assets for 1 year (immutable)
            return "public, max-age=31536000, immutable";
        }
    }

    // Default: cache for 1 hour with revalidation
    return "public, max-age=3600, must-revalidate";
}

/// Format timestamp to HTTP date format (RFC 7231): "Mon, 29 Oct 2025 12:00:00 GMT"
fn formatHttpDate(alloc: Allocator, timestamp_ns: i128) ![]const u8 {
    const secs: i64 = @intCast(@divFloor(timestamp_ns, std.time.ns_per_s));
    const epoch_seconds = std.time.epoch.EpochSeconds{ .secs = @intCast(secs) };
    const epoch_day = epoch_seconds.getEpochDay();
    const year_day = epoch_day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();
    const day_seconds = epoch_seconds.getDaySeconds();

    const weekdays = [_][]const u8{ "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" };
    const months = [_][]const u8{ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };

    return std.fmt.allocPrint(alloc, "{s}, {d:0>2} {s} {d} {d:0>2}:{d:0>2}:{d:0>2} GMT", .{
        weekdays[@intCast((epoch_day.day + 3) % 7)],
        month_day.day_index + 1,
        months[month_day.month.numeric() - 1],
        year_day.year,
        day_seconds.getHoursIntoDay(),
        day_seconds.getMinutesIntoHour(),
        day_seconds.getSecondsIntoMinute(),
    });
}
