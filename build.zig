const std = @import("std");
const sub_kernel = @import("kernel/build.zig");

pub fn build(b: *std.Build) !void {
    const enable_kernel = b.option(bool, "kernel", "Build kernel") orelse true;

    // if (enable_kernel) sub_kernel.addToBuild(b, target, optimize);
    if (enable_kernel) _ = try sub_kernel.build(b);
}
