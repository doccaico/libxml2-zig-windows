const std = @import("std");
const panic = std.debug.panic;

const c = @cImport({
    @cDefine("LIBXML_READER_ENABLED", "1");
    @cInclude("libxml/xmlreader.h");
});

fn processDoc(readerPtr: c.xmlTextReaderPtr) void {
    var ret = c.xmlTextReaderRead(readerPtr);
    while (ret == 1) {
        ret = c.xmlTextReaderRead(readerPtr);
    }

    const docPtr = c.xmlTextReaderCurrentDoc(readerPtr) orelse {
        std.debug.print("failed to obtain document\n", .{});
        return;
    };

    const URL = docPtr.*.URL;
    if (URL == null)
        std.debug.print("Failed to obtain URL\n", .{});

    if (ret != 0) {
        std.debug.print("{s}: Failed to parse\n", .{URL});
        return;
    }

    std.debug.print("{s}: Processed ok\n", .{URL});
}

pub fn main() !void {
    const filename1 = "examples/test1.xml";
    const filename2 = "examples/test2.xml";
    const filename3 = "examples/test3.xml";

    const readerPtr: ?*c.xmlTextReader = c.xmlReaderForFile(filename1, null, 0) orelse {
        panic("{s}: failed to create reader\n", .{filename1});
    };
    processDoc(readerPtr);

    const files = [_][:0]const u8{ filename2, filename3 };
    for (files) |f| {
        _ = c.xmlReaderNewFile(readerPtr, f, null, 0);
        if (readerPtr == null) {
            panic("{s}: failed to create reader\n", .{f});
            return;
        }
        processDoc(readerPtr);
    }
}

// examples/test1.xml: Processed ok
// examples/test2.xml: Processed ok
// examples/test3.xml: Processed ok
