const std = @import("std");
const preboot = @import("preboot.zig");

pub fn main() std.os.uefi.Error!void {
    try preboot.init();
    preboot.logStringLiteral("Midari OS") catch {};
    try preboot.boot();

    while (true) {}
}
