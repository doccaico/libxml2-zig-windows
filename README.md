## libxml2-zig-windows

This binding tested on libxml2 2.12.6 and Zig master version. It's Windows only.

#### Fetch
```sh
$ zig fetch --save=libxml2 https://github.com/doccaico/libxml2-zig-windows/archive/<git-commit-hash>.tar.gz
```

#### Usage
```zig
// build.zig

const libxml2 = b.dependency("libxml2", .{ .target = target, .optimize = optimize });
exe.linkLibrary(libxml2.artifact("libxml2"));

// src\main.zig

const std = @import("std");

const c = @cImport({
    @cInclude("libxml/xmlreader.h");
});

[your code ...]
```
See more [examples](https://github.com/doccaico/libxml2-zig-windows/tree/main/examples)

#### Tests
```sh
$ git clone https://github.com/doccaico/libxml2-zig-windows.git
$ cd libxml2-zig-windows

# Builds all the examples
$ zig build examples

# To list available examples
$ zig build --help
```

Based on [mitchellh/zig-build-libxml2](https://github.com/mitchellh/zig-build-libxml2) and [ianprime0509/zig-libxml2](https://github.com/ianprime0509/zig-libxml2)
