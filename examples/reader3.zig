const std = @import("std");
const panic = std.debug.panic;
const print = std.debug.print;

const c = @cImport({
    @cInclude("examples/reader3.h");

    @cInclude("libxml/xmlreader.h");
});

fn extractFile(filename: [:0]const u8, pattern: [:0]const u8) ?c.xmlDocPtr {
    var doc: c.xmlDocPtr = undefined;
    var reader: c.xmlTextReaderPtr = undefined;
    var ret: i32 = undefined;

    reader = c.xmlReaderForFile(filename, null, 0) orelse {
        print("Unable to open {s}\n", .{filename});
        return null;
    };

    if (c.xmlTextReaderPreservePattern(reader, pattern, null) < 0) {
        panic("{s} : failed add preserve pattern {s}\n", .{ filename, pattern });
    }

    ret = c.xmlTextReaderRead(reader);
    while (ret == 1) {
        ret = c.xmlTextReaderRead(reader);
    }
    if (ret != 0) {
        panic("{s} : failed to parse\n", .{filename});
        c.xmlFreeTextReader(reader);
        return null;
    }
    doc = c.xmlTextReaderCurrentDoc(reader);
    c.xmlFreeTextReader(reader);

    return doc;
}

pub fn main() !void {
    const filename = "examples/test3.xml";
    const pattern = "preserved";
    const doc: ?c.xmlDocPtr = extractFile(filename, pattern);
    if (doc) |d| {
        _ = c.xmlDocDump(c.getStdout(), d);
        c.xmlFreeDoc(d);
    }
}

// <?xml version="1.0"?>
// <doc><parent><preserved/><preserved>
//       content1
//       <child1/>
//       <child2>content2</child2>
//       <preserved>too</preserved>
//       <child2>content3</child2>
//       <preserved/>
//       <child2>content4</child2>
//       <preserved/>
//       <child2>content5</child2>
//       content6
//     </preserved><preserved/><preserved/></parent></doc>
