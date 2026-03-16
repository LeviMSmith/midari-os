const std = @import("std");

const BuildError = error{UnsupportedArchitecture};

fn build_kernel(b: *std.Build) !void {
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

    const mod = b.addModule(target_name, .{
        .root_source_file = b.path("kernel/root.zig"),
        .target = target
    });

    // Target
    const exe = b.addExecutable(.{
        .name = target_name,
        .root_module = b.createModule(.{
            .root_source_file = b.path("kernel/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = target_name, .module = mod},
            },
        }),
    });

    const target_output = b.addInstallArtifact(exe, .{
        .dest_dir = .{
            .override = .{
                .custom = "EFI" ++ std.fs.path.sep_str ++ "BOOT",
            },
        },
    });

    b.getInstallStep().dependOn(&target_output.step);
}

pub fn build(b: *std.Build) !void {
    try build_kernel(b);
}
