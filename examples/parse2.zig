const std = @import("std");
const print = std.debug.print;

const c = @cImport({
    @cInclude("libxml/parser.h");
    @cInclude("libxml/tree.h");
});

fn exampleFunc(filename: [:0]const u8) void {
    const ctxt: c.xmlParserCtxtPtr = c.xmlNewParserCtxt() orelse {
        print("Failed to allocate parser context\n", .{});
        return;
    };
    const doc = c.xmlCtxtReadFile(ctxt, filename, null, c.XML_PARSE_DTDVALID) orelse {
        print("Failed to parse {s}\n", .{filename});
        c.xmlFreeParserCtxt(ctxt);
        return;
    };
    if (ctxt.*.valid == 0)
        print("Failed to validate {s}\n", .{filename});

    c.xmlFreeDoc(doc);
    c.xmlFreeParserCtxt(ctxt);
}

pub fn main() void {
    const files = [_][:0]const u8{
        "examples/test1.xml",
        "examples/test2.xml",
        "examples/test3.xml",
    };
    for (files) |file| {
        exampleFunc(file);
    }
}

// examples/test1.xml:1: validity error : Validation failed: no DTD found !
// <doc/>
//     ^
// Failed to validate examples/test1.xml
// examples/test3.xml:1: validity error : Validation failed: no DTD found !
// <doc>
//     ^
// Failed to validate examples/test3.xml
