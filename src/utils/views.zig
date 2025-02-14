const std = @import("std");
const zmpl = @import("zmpl");
const Allocator = std.mem.Allocator;

pub fn view(allocator: Allocator, tpl: []const u8, data: zmpl.Data) []const u8 {
    const Context = struct { foo: []const u8 = "default" };
    const context = Context { .foo = "bar" };

    if (zmpl.find(tpl)) |template| {
        const output = try template.render(&data, Context, context, .{});
        defer allocator.free(output);

        return output;
    } else {
        return "not found";
    }
}

