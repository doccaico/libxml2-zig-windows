const std = @import("std");
const panic = std.debug.panic;
const print = std.debug.print;

const c = @cImport({
    @cInclude("libxml/xmlreader.h");
});

fn processNode(reader: c.xmlTextReaderPtr) void {
    const name: [*:0]const u8 = c.xmlTextReaderConstName(reader) orelse "--";
    const value: ?[*:0]const u8 = c.xmlTextReaderConstValue(reader);

    print("{d} {d} {s} {d} {d}", .{
        c.xmlTextReaderDepth(reader),
        c.xmlTextReaderNodeType(reader),
        name,
        c.xmlTextReaderIsEmptyElement(reader),
        c.xmlTextReaderHasValue(reader),
    });
    if (value) |val| {
        if (c.xmlStrlen(value) > 40)
            print(" :{s}...\n", .{val})
        else
            print(" {s}\n", .{val});
    } else {
        print("\n", .{});
    }
}

fn streamFile(filename: [:0]const u8) void {
    var reader: c.xmlTextReaderPtr = undefined;
    var ret: i32 = undefined;

    reader = c.xmlReaderForFile(filename, null, 0) orelse {
        panic("Unable to open {s}\n", .{filename});
    };

    ret = c.xmlTextReaderRead(reader);
    while (ret == 1) {
        processNode(reader);
        ret = c.xmlTextReaderRead(reader);
    }
    c.xmlFreeTextReader(reader);
    if (ret != 0) {
        panic("{s} : failed to parse\n", .{filename});
    }
}

pub fn main() void {
    const filename = "examples/test2.xml";
    streamFile(filename);
}

// 0 10 doc 0 0
// 0 1 doc 0 0
// 1 14 #text 0 1
//
// 1 1 src 1 0
// 1 14 #text 0 1
//
// 1 1 dest 1 0
// 1 14 #text 0 1
//
// 1 1 src 1 0
// 1 14 #text 0 1
//
// 0 15 doc 0 0
