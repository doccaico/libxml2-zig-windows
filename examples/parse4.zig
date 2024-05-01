const std = @import("std");
const print = std.debug.print;

const c = @cImport({
    @cInclude("stdio.h");

    @cInclude("libxml/parser.h");
    @cInclude("libxml/tree.h");
});

var desc: ?*c.FILE = undefined;

fn readPacket(mem: *c_char, size: c_ulonglong) c_int {
    return @intCast(c.fread(mem, 1, size, desc));
}

fn example4Func(filename: [:0]const u8) void {
    var chars: [4]c_char = undefined;

    var res: c_int = readPacket(@ptrCast(&chars), 4);
    if (res <= 0) {
        print("Failed to parse {s}\n", .{filename});
        return;
    }

    const ctxt = c.xmlCreatePushParserCtxt(null, null, @ptrCast(&chars), res, filename) orelse {
        print("Failed to create parser context !\n", .{});
        return;
    };

    res = readPacket(@ptrCast(&chars), 4);
    while (res > 0) : (res = readPacket(@ptrCast(&chars), 4)) {
        _ = c.xmlParseChunk(ctxt, @ptrCast(&chars), res, 0);
    }

    _ = c.xmlParseChunk(ctxt, @ptrCast(&chars), 0, 1);

    const doc = ctxt.*.myDoc;
    res = ctxt.*.wellFormed;
    c.xmlFreeParserCtxt(ctxt);

    if (res == 0) {
        print("Failed to parse {s}\n", .{filename});
    }

    c.xmlFreeDoc(doc);
}

pub fn main() void {
    const files = [_][:0]const u8{
        "examples/test1.xml",
        "examples/test2.xml",
        "examples/test3.xml",
    };
    for (files) |file| {
        desc = c.fopen(file, "rb");
        if (desc) |d| {
            example4Func(file);
            _ = c.fclose(d);
        } else {
            print("Failed to parse {s}\n", .{file});
        }
    }
}
