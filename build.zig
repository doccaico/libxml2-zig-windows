const std = @import("std");
const builtin = @import("builtin");

pub const Version = struct {
    pub const major = "2";
    pub const minor = "12";
    pub const micro = "6";

    pub fn number() []const u8 {
        return comptime major ++ "0" ++ minor ++ micro;
    }

    pub fn string() []const u8 {
        return comptime "\"" ++ number() ++ "\"";
    }

    pub fn dottedString() []const u8 {
        return comptime "\"" ++ major ++ "." ++ minor ++ "." ++ micro ++ "\"";
    }

    pub fn extra() []const u8 {
        return comptime "\"" ++ "-GITv" ++ major ++ "." ++ minor ++ "." ++ micro ++ "\"";
    }
};

const Program = struct {
    name: []const u8,
    path: []const u8,
    desc: []const u8,
    wrapper: []const u8,
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libxml2 = b.addStaticLibrary(.{
        .name = "libxml2",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();

    try flags.appendSlice(&.{
        // Version info, hardcoded
        comptime "-DLIBXML_VERSION=" ++ Version.number(),
        comptime "-DLIBXML_VERSION_STRING=" ++ Version.string(),
        comptime "-DLIBXML_DOTTED_VERSION=" ++ Version.dottedString(),
        comptime "-DLIBXML_VERSION_EXTRA=" ++ Version.extra(),

        // These might now always be true (particularly Windows) but for
        // now we just set them all. We should do some detection later.
        "-DSEND_ARG2_CAST=",
        "-DGETHOSTBYNAME_ARG_CAST=",
        "-DGETHOSTBYNAME_ARG_CAST_CONST=",

        // Always on
        "-DLIBXML_STATIC=1",
        "-DLIBXML_AUTOMATA_ENABLED=1",
        // "-DLIBXML_EXPR_ENABLED=1",
        "-DWITHOUT_TRIO=1",
        "-DLIBXML_UNICODE_ENABLED=1",
        //

        // Options
        "-DLIBXML_C14N_ENABLED=1",
        "-DLIBXML_CATALOG_ENABLED=1",
        "-DLIBXML_DEBUG_ENABLED=1",
        // "-DLIBXML_FTP_ENABLED=0",
        "-DLIBXML_HTML_ENABLED=1",
        // "-DLIBXML_HTTP_ENABLED=1",
        // "-DLIBXML_ICONV_ENABLED=1",
        // "-DLIBXML_ICU_ENABLED=0",
        "-DLIBXML_ISO8859X_ENABLED=1",
        // "-DLIBXML_LEGACY_ENABLED=0",
        // "-DLIBXML_LZMA_ENABLED=1",
        // "-DLIBXML_MEM_DEBUG_ENABLED=0",
        "-DLIBXML_MODULES_ENABLED=1",
        "-DLIBXML_OUTPUT_ENABLED=1",
        "-DLIBXML_PATTERN_ENABLED=1",
        "-DLIBXML_PROGRAMS_ENABLED=1",
        "-DLIBXML_PUSH_ENABLED=0",
        // "-DLIBXML_PYTHON_ENABLED=1",
        "-DLIBXML_READER_ENABLED=1",
        "-DLIBXML_REGEXPS_ENABLED=1",
        "-DLIBXML_REGEXP_ENABLED=1",
        "-DLIBXML_SAX1_ENABLED=1",
        "-DLIBXML_SCHEMAS_ENABLED=1",
        "-DLIBXML_SCHEMATRON_ENABLED=1",
        // "-DLIBXML_TESTS_ENABLED=1",
        "-DLIBXML_THREADS_ENABLED=1",
        // "-DLIBXML_THREAD_ALLOC_ENABLED=0",
        // "-DLIBXML_TLS_ENABLED=0",
        "-DLIBXML_TREE_ENABLED=1",
        "-DLIBXML_VALID_ENABLED=1",
        "-DLIBXML_WRITER_ENABLED=1",
        "-DLIBXML_XINCLUDE_ENABLED=1",
        "-DLIBXML_XPATH_ENABLED=1",
        "-DLIBXML_XPTR_ENABLED=1",
        // "-DLIBXML_XPTR_LOCS_ENABLED=0",
        // "-DLIBXML_ZLIB_ENABLED=1",
        "-pedantic",
        "-Wall",
        "-Wextra",
        "-Wshadow",
        "-Wpointer-arith",
        "-Wcast-align",
        "-Wwrite-strings",
        "-Wstrict-prototypes",
        "-Wmissing-prototypes",
        "-Wno-long-long",
        "-Wno-format-extra-args",
        // For remove compile errors...
        // (xmlIO.c) declaration of 'struct _stat' will not be visible outside of this function
        // (xmlIO.c) call to undeclared function '_wstat'; ISO C99 and later do not support implicit
        // (xmlIO.c) call to undeclared function '_stat'; ISO C99 and later do not support implicit
        "-Wno-implicit-function-declaration",
    });

    libxml2.addCSourceFiles(.{ .files = srcs, .flags = flags.items });

    libxml2.addIncludePath(.{ .path = "include" });
    libxml2.addIncludePath(.{ .path = include_dir });
    libxml2.addIncludePath(.{ .path = override_include_dir });
    libxml2.addIncludePath(.{ .path = win32_include_dir });
    libxml2.linkSystemLibrary("ws2_32");

    b.installArtifact(libxml2);

    // examples
    const examples_step = b.step("examples", "Builds all the examples");
    const examples = [_]Program{
        .{
            .name = "reader1",
            .path = "examples/reader1.zig",
            .desc = "Parse an XML file with an xmlReader",
            .wrapper = "",
        },
        .{
            .name = "reader2",
            .path = "examples/reader2.zig",
            .desc = "Parse and validate an XML file with an xmlReader",
            .wrapper = "",
        },
        .{
            .name = "reader3",
            .path = "examples/reader3.zig",
            .desc = "Show how to extract subdocuments with xmlReader",
            .wrapper = "examples/reader3.c", // For FILE (stdio.h)
        },
        .{
            .name = "reader4",
            .path = "examples/reader4.zig",
            .desc = "Parse multiple XML files reusing an xmlReader",
            .wrapper = "",
        },
    };
    for (examples) |example| {
        const exe = b.addExecutable(.{
            .name = example.name,
            .root_source_file = .{ .path = example.path },
            .target = target,
            .optimize = optimize,
        });

        if (example.wrapper.len != 0) {
            exe.addIncludePath(.{ .path = "." });
            exe.addCSourceFile(.{ .file = .{ .path = example.wrapper }, .flags = &.{} });
        }

        exe.addIncludePath(.{ .path = "include" });
        exe.addIncludePath(.{ .path = include_dir });
        exe.addIncludePath(.{ .path = override_include_dir });
        exe.addIncludePath(.{ .path = win32_include_dir });
        exe.linkLibrary(libxml2);

        const run_cmd = b.addRunArtifact(exe);
        const run_step = b.step(example.name, example.desc);
        run_step.dependOn(&run_cmd.step);
        examples_step.dependOn(&exe.step);
    }
}

/// Directories with our includes.
const include_dir = "libxml2/include";
const override_include_dir = "override/include";
const win32_include_dir = "override/config/win32";

const srcs = &.{
    "libxml2/buf.c",
    "libxml2/c14n.c",
    "libxml2/catalog.c",
    "libxml2/chvalid.c",
    "libxml2/debugXML.c",
    "libxml2/dict.c",
    "libxml2/encoding.c",
    "libxml2/entities.c",
    "libxml2/error.c",
    "libxml2/globals.c",
    "libxml2/hash.c",
    "libxml2/HTMLparser.c",
    "libxml2/HTMLtree.c",
    "libxml2/legacy.c",
    "libxml2/list.c",
    "libxml2/nanoftp.c",
    "libxml2/nanohttp.c",
    "libxml2/parser.c",
    "libxml2/parserInternals.c",
    "libxml2/pattern.c",
    "libxml2/relaxng.c",
    "libxml2/SAX.c",
    "libxml2/SAX2.c",
    "libxml2/schematron.c",
    "libxml2/threads.c",
    "libxml2/tree.c",
    "libxml2/uri.c",
    "libxml2/valid.c",
    "libxml2/xinclude.c",
    "libxml2/xlink.c",
    "libxml2/xmlIO.c",
    "libxml2/xmlmemory.c",
    "libxml2/xmlmodule.c",
    "libxml2/xmlreader.c",
    "libxml2/xmlregexp.c",
    "libxml2/xmlsave.c",
    "libxml2/xmlschemas.c",
    "libxml2/xmlschemastypes.c",
    "libxml2/xmlstring.c",
    "libxml2/xmlunicode.c",
    "libxml2/xmlwriter.c",
    "libxml2/xpath.c",
    "libxml2/xpointer.c",
    "libxml2/xzlib.c",
};
