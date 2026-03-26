const std = @import("std");
const kernel = @import("root.zig");

var kinit: kernel.Kinit = undefined;

pub fn main() std.os.uefi.Error!void {
    try kernel.preboot.init();
    try kernel.preboot.logStringLiteral("Midari OS");
    try kernel.preboot.boot(&kinit);

    kinit.boot() catch {};
}
