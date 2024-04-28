### libxml2-build (WIP)

Based on [mitchellh/zig-libxml2](https://github.com/mitchellh/zig-libxml2)

== Only works on Windows ==

#### Usage
```sh
$ git clone https://github.com/doccaico/libxml2-build.git

$ cd libxml2-build

$ git clone https://github.com/GNOME/libxml2.git -b v2.12.6 --depth 1

$ zig build reader1
```

#### Tests
```sh
# Builds all the examples
$ zig build examples

# To list available examples
$ zig build --help
```
