const std = @import("std");
const print = std.debug.print;

const c = @cImport({
    @cInclude("libxml/parser.h");
    @cInclude("libxml/tree.h");
});

fn example1Func(filename: [:0]const u8) void {
    var doc: c.xmlDocPtr = undefined;

    doc = c.xmlReadFile(filename, null, 0) orelse {
        print("Failed to parse {s}\n", .{filename});
        return;
    };
    c.xmlFreeDoc(doc);
}

pub fn main() void {
    const files = [_][:0]const u8{
        "examples/test1.xml",
        "examples/test2.xml",
        "examples/test3.xml",
    };
    for (files) |file| {
        example1Func(file);
    }
}
