const std = @import("std");
const print = std.debug.print;

const c = @cImport({
    @cInclude("libxml/parser.h");
    @cInclude("libxml/tree.h");
});

fn example3Func(content: [:0]const u8, length: i32) void {
    const doc = c.xmlReadMemory(content, length, "noname.xml", null, 0) orelse {
        print("Failed to parse document\n", .{});
        return;
    };
    c.xmlFreeDoc(doc);
}

pub fn main() void {
    const document = "<doc/>";
    example3Func(document, 6);
}
