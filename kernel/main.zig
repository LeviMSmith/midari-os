const std = @import("std");
const kernel = @import("root.zig");

pub fn main() std.os.uefi.Error!void {
    try kernel.preboot.init();
    try kernel.preboot.logStringLiteral("Midari OS");
    // _ = try kernel.preboot.boot();

    while (true) {}
}
