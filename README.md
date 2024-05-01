## libxml2-zig-windows

This binding tested on libxml2 2.12.6 and Zig master version. It's Windows only.

#### Fetch
```sh
$ zig fetch --save=libxml2 https://github.com/doccaico/libxml2-zig-windows/archive/<git-commit-hash>.tar.gz
```

#### Usage
```zig
const std = @import("std");

const c = @cImport({
    @cInclude("libxml/xmlreader.h");
});

[your code ...]
```
See more [examples](https://github.com/doccaico/libxml2-zig-windows/tree/main/examples)

#### Tests
```sh
# Builds all the examples
$ zig build examples

# To list available
$ zig build --help
```

Based on [mitchellh/zig-build-libxml2](https://github.com/mitchellh/zig-build-libxml2) and [ianprime0509/zig-libxml2](https://github.com/ianprime0509/zig-libxml2)
