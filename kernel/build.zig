const std = @import("std");

const BuildError = error{UnsupportedArchitecture};

pub fn build(b: *std.Build) !void {
    //// Config ////
    // NOTE: target os and abi are overriden to simplify build.
    // arch can still be set by caller.
    var tq = b.standardTargetOptions(.{}).query;
    tq.os_tag = .uefi;
    tq.abi = .msvc;

    const target = b.resolveTargetQuery(tq);
    const optimize = b.standardOptimizeOption(.{});

    const target_name = switch (target.result.cpu.arch) {
        .aarch64 => "BOOTAARCH64",
        .x86_64 => "BOOTX64",
        else => return BuildError.UnsupportedArchitecture,
    };

    // Target
    const exe = b.addExecutable(.{
        .name = target_name,
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);
}
