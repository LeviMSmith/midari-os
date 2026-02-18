const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Kernel build overrides os and abi!
    const kernel_dep = b.dependency("kernel", .{
        .target = target,
        .optimize = optimize,
    });

    // Grab an artifact defined by kernel/build.zig
    const kernel_efi = kernel_dep.artifact("boot"); // name must match the executable step name


    // Hook it into your default install step
    b.getInstallStep().dependOn(&kernel_efi.step);
}

