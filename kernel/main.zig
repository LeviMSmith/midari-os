const std = @import("std");
const preboot = @import("preboot.zig");

pub fn main() std.os.uefi.Error!void {
    try preboot.prepare();
    preboot.logStringLiteral("Hello world!") catch {};

    while (true) {}
}
