const std = @import("std");
const kernel = @import("root.zig");

pub fn main() std.os.uefi.Error!void {
    try kernel.preboot.init();
    kernel.preboot.logStringLiteral("Midari OS") catch {};
    try kernel.preboot.boot();

    while (true) {}
}
