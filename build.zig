const std = @import("std");
const builtin = @import("builtin");

pub const Version = struct {
    pub const major = "2";
    pub const minor = "12";
    pub const micro = "6";

    pub fn number() i32 {
        // the version number: 1.2.3 value is 10203
        return 20126;
    }

    pub fn dottedString() []const u8 {
        return comptime major ++ "." ++ minor ++ "." ++ micro;
    }

    pub fn extra() []const u8 {
        return comptime "-GITv" ++ major ++ "." ++ minor ++ "." ++ micro;
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

    const upstream = b.dependency("libxml2", .{});

    const lib = b.addStaticLibrary(.{
        .name = "libxml2",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.linkSystemLibrary("ws2_32");

    const libxml2_config_h = b.addConfigHeader(.{
        .style = .{ .cmake = upstream.path("config.h.cmake.in") },
    }, .{
        .ATTRIBUTE_DESTRUCTOR = "__attribute__((destructor))",
        .HAVE_ARPA_INET_H = false,
        .HAVE_ATTRIBUTE_DESTRUCTOR = true,
        .HAVE_DLFCN_H = false,
        .HAVE_DLOPEN = false,
        .HAVE_DL_H = false,
        .HAVE_FCNTL_H = true,
        .HAVE_FTIME = true,
        .HAVE_GETTIMEOFDAY = true,
        .HAVE_INTTYPES_H = true,
        .HAVE_ISASCII = true,
        .HAVE_LIBHISTORY = false,
        .HAVE_LIBREADLINE = false,
        .HAVE_MMAP = false,
        .HAVE_MUNMAP = false,
        .HAVE_NETDB_H = false,
        .HAVE_NETINET_IN_H = false,
        .HAVE_POLL_H = false,
        .HAVE_PTHREAD_H = false,
        .HAVE_SHLLOAD = false,
        .HAVE_STAT = true,
        .HAVE_STDINT_H = true,
        .HAVE_SYS_MMAN_H = false,
        .HAVE_SYS_SELECT_H = false,
        .HAVE_SYS_SOCKET_H = false,
        .HAVE_SYS_STAT_H = true,
        .HAVE_SYS_TIMEB_H = true,
        .HAVE_SYS_TIME_H = true,
        .HAVE_UNISTD_H = true,
        .HAVE_VA_COPY = true,
        .HAVE_ZLIB_H = false,
        .HAVE___VA_COPY = true,
        .SUPPORT_IP6 = false,
        .VA_LIST_IS_ARRAY = true,
        .VERSION = Version.number(),
        .XML_SOCKLEN_T = "int",
        .XML_THREAD_LOCAL = null,
        ._UINT32_T = null,
        .uint32_t = null,
    });
    lib.addConfigHeader(libxml2_config_h);

    const libxml2_xmlversion_h = b.addConfigHeader(.{
        .style = .{ .cmake = upstream.path("include/libxml/xmlversion.h.in") },
        .include_path = "libxml/xmlversion.h",
    }, .{
        .VERSION = Version.dottedString(),
        .LIBXML_VERSION_NUMBER = Version.number(),
        .LIBXML_VERSION_EXTRA = Version.extra(),
        .WITH_TRIO = false,
        .WITH_THREADS = true,
        .WITH_THREAD_ALLOC = false,
        .WITH_TREE = true,
        .WITH_OUTPUT = true,
        .WITH_PUSH = true,
        .WITH_READER = true,
        .WITH_PATTERN = true,
        .WITH_WRITER = true,
        .WITH_SAX1 = true,
        .WITH_FTP = false,
        .WITH_HTTP = false,
        .WITH_VALID = true,
        .WITH_HTML = true,
        .WITH_LEGACY = false,
        .WITH_C14N = true,
        .WITH_CATALOG = true,
        .WITH_XPATH = true,
        .WITH_XPTR = true,
        .WITH_XPTR_LOCS = false,
        .WITH_XINCLUDE = true,
        .WITH_ICONV = false,
        .WITH_ICU = false,
        .WITH_ISO8859X = true,
        .WITH_DEBUG = true,
        .WITH_MEM_DEBUG = false,
        .WITH_REGEXPS = true,
        .WITH_SCHEMAS = true,
        .WITH_SCHEMATRON = true,
        .WITH_MODULES = true,
        .MODULE_EXTENSION = target.result.dynamicLibSuffix(),
        .WITH_ZLIB = false,
        .WITH_LZMA = false,
    });
    lib.addConfigHeader(libxml2_xmlversion_h);
    lib.installConfigHeader(libxml2_xmlversion_h);

    const flags = &.{
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
    };
    const srcs = &.{
        "buf.c",
        "c14n.c",
        "catalog.c",
        "chvalid.c",
        "debugXML.c",
        "dict.c",
        "encoding.c",
        "entities.c",
        "error.c",
        "globals.c",
        "hash.c",
        "HTMLparser.c",
        "HTMLtree.c",
        "legacy.c",
        "list.c",
        // "nanoftp.c", // FTP
        "nanohttp.c",
        "parser.c",
        "parserInternals.c",
        "pattern.c",
        "relaxng.c",
        "SAX.c",
        "SAX2.c",
        "schematron.c",
        "threads.c",
        "tree.c",
        "uri.c",
        "valid.c",
        "xinclude.c",
        "xlink.c",
        "xmlIO.c",
        "xmlmemory.c",
        "xmlmodule.c",
        "xmlreader.c",
        "xmlregexp.c",
        "xmlsave.c",
        "xmlschemas.c",
        "xmlschemastypes.c",
        "xmlstring.c",
        "xmlunicode.c",
        "xmlwriter.c",
        "xpath.c",
        "xpointer.c",
        // "xzlib.c", // Zlib
    };
    lib.addCSourceFiles(.{ .root = upstream.path("."), .files = srcs, .flags = flags });

    lib.addIncludePath(upstream.path("include"));

    lib.installHeadersDirectory(upstream.path("include/libxml"), "libxml", .{
        .include_extensions = &.{".h"},
    });

    b.installArtifact(lib);

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

        exe.linkLibrary(lib);

        const run_cmd = b.addRunArtifact(exe);
        const run_step = b.step(example.name, example.desc);
        run_step.dependOn(&run_cmd.step);
        examples_step.dependOn(&exe.step);
    }
}
