const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const heap = std.heap;

const c = @cImport({
    @cInclude("libxml/HTMLparser.h");
    @cInclude("libxml/xpath.h");
});

const html =
    \\<!DOCTYPE html>
    \\<html lang="en">
    \\  <head>
    \\    <meta charset="utf-8">
    \\    <title></title>
    \\    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    \\    <meta name="format-detection" content="telephone=no,email=no,address=no">
    \\    <link rel="canonical" href="">
    \\
    \\    <!-- Import CSS -->
    \\    <!-- <link rel="stylesheet" href="style.css"> -->
    \\
    \\    <!-- Import JS -->
    \\    <!-- <script src=""></script> -->
    \\  </head>
    \\  <body>
    \\
    \\  <div class="tetris">
    \\    <a href="https://github.com/test/c">tetris-c</a>
    \\    <a href="https://github.com/test/zig">tetris-zig</a>
    \\    <a href="https://github.com/test/odin">tetris-odin</a>
    \\  </div>
    \\
    \\  <div class="weeks">
    \\    Today is            <b>Sunday</b>.
    \\  </div>
    \\  <div class="weeks">
    \\    Tomorrow            is    <b>Monday</b>.
    \\  </div>
    \\  <div class="weeks"></div>
    \\
    \\    <!-- Import JS -->
    \\    <script src="js/main.js"></script>
    \\
    \\  </body>
    \\</html>
;

fn get_string(allocator: Allocator, list_content: std.ArrayList([*c]u8), query: [:0]const u8) !std.ArrayList([*c]u8) {
    var list_string = std.ArrayList([*c]u8).init(allocator);

    for (list_content.items) |item| {
        const doc = c.htmlReadMemory(item, c.xmlStrlen(item), "", "utf-8", c.HTML_PARSE_NOERROR);
        defer c.xmlFreeDoc(doc);

        const ctx = c.xmlXPathNewContext(doc);
        defer c.xmlXPathFreeContext(ctx);

        const xpathObj = c.xmlXPathEvalExpression(query, ctx) orelse {
            return error.FailedXmlXPathEvalExpression;
        };
        defer c.xmlXPathFreeObject(xpathObj);

        assert(xpathObj.*.type == c.XPATH_STRING);

        const new_string = c.xmlCharStrdup(xpathObj.*.stringval) orelse {
            return error.FailedXmlCharStrdup;
        };
        try list_string.append(new_string);
    }
    return list_string;
}

fn get_content(allocator: Allocator, doc: c.htmlDocPtr, query: [:0]const u8) !std.ArrayList([*c]u8) {
    var list = std.ArrayList([*c]u8).init(allocator);

    const ctx = c.xmlXPathNewContext(doc);
    defer c.xmlXPathFreeContext(ctx);

    const xpathObj = c.xmlXPathEvalExpression(query, ctx) orelse {
        return error.FailedXmlXPathEvalExpression;
    };
    defer c.xmlXPathFreeObject(xpathObj);

    assert(xpathObj.*.type == c.XPATH_NODESET);

    var i: usize = 0;
    const len = xpathObj.*.nodesetval.*.nodeNr;
    while (i < len) : (i += 1) {
        const text = c.xmlNodeGetContent(xpathObj.*.nodesetval.*.nodeTab[i]) orelse {
            return error.FailedXmlNodeGetContent;
        };
        try list.append(text);
    }
    return list;
}

fn free_list(list: std.ArrayList([*c]u8)) void {
    for (list.items) |item| {
        c.xmlFree.?(item);
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const doc = c.htmlReadMemory(html, html.len, "", "utf-8", c.HTML_PARSE_NOERROR);
    defer c.xmlFreeDoc(doc);

    {
        const url_content = try get_content(allocator, doc, "//div[@class='tetris']/a/@href");
        defer free_list(url_content);

        const name_content = try get_content(allocator, doc, "//div[@class='tetris']/a[@href]");
        defer free_list(name_content);

        assert(url_content.items.len == 3 and name_content.items.len == 3);

        var i: usize = 0;
        while (i < 3) : (i += 1) {
            try stdout.print("{s} : {s}\n", .{ url_content.items[i], name_content.items[i] });
        }
    }

    {
        const list_content = try get_content(allocator, doc, "//div[@class='weeks']");
        defer free_list(list_content);

        const list_string = try get_string(allocator, list_content, "normalize-space(/)");
        defer free_list(list_string);

        for (list_string.items) |text| {
            try stdout.print("{s}\n", .{text});
        }
    }
}

// https://github.com/test/c : tetris-c
// https://github.com/test/zig : tetris-zig
// https://github.com/test/odin : tetris-odin
// Today is Sunday.
// Tomorrow is Monday.
