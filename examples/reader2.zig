const std = @import("std");
const panic = std.debug.panic;

const c = @cImport({
    @cDefine("LIBXML_READER_ENABLED", "1");
    @cInclude("libxml/xmlreader.h");
});

fn processNode(reader: c.xmlTextReaderPtr) !void {
    const stdout = std.io.getStdOut().writer();

    const name: [*:0]const u8 = c.xmlTextReaderConstName(reader) orelse "--";
    const value: ?[*:0]const u8 = c.xmlTextReaderConstValue(reader);

    try stdout.print("{d} {d} {s} {d} {d}", .{
        c.xmlTextReaderDepth(reader),
        c.xmlTextReaderNodeType(reader),
        name,
        c.xmlTextReaderIsEmptyElement(reader),
        c.xmlTextReaderHasValue(reader),
    });
    if (value) |val| {
        if (c.xmlStrlen(value) > 40)
            try stdout.print(" :{s}...\n", .{val})
        else
            try stdout.print(" {s}\n", .{val});
    } else {
        try stdout.print("\n", .{});
    }
}

fn streamFile(filename: [:0]const u8) !void {
    var reader: c.xmlTextReaderPtr = undefined;
    var ret: i32 = undefined;

    reader = c.xmlReaderForFile(filename, null, c.XML_PARSE_DTDATTR |
        c.XML_PARSE_NOENT |
        c.XML_PARSE_DTDVALID) orelse {
        panic("Unable to open {s}\n", .{filename});
    };

    ret = c.xmlTextReaderRead(reader);
    while (ret == 1) {
        try processNode(reader);
        ret = c.xmlTextReaderRead(reader);
    }
    if (c.xmlTextReaderIsValid(reader) != 1) {
        panic("Document {s} does not validate\n", .{filename});
    }
    c.xmlFreeTextReader(reader);
    if (ret != 0) {
        panic("{s} : failed to parse\n", .{filename});
    }
}

pub fn main() !void {
    const filename = "examples/test2.xml";
    try streamFile(filename);
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
