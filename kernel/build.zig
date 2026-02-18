const std = @import("std");

const BuildError = error{UnsupportedArchitecture};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{
        .default_target = b.resolveTargetQuery(.{
            .os_tag = .uefi,
            .abi = .msvc,
        }).query,
    });
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "boot",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    var install: ?*std.Build.Step.InstallArtifact = undefined;
    switch (target.result.cpu.arch) {
        .aarch64 => blk: {
            install = b.addInstallArtifact(exe, .{
                .dest_sub_path = "EFI/BOOT/BOOTX64.EFI",
            });
            break :blk;
        },
        .x86_64 => blk: {
            install = b.addInstallArtifact(exe, .{
                .dest_sub_path = "EFI/BOOT/BOOTX64.EFI",
            });
            break :blk;
        },
        else => return BuildError.UnsupportedArchitecture,
    }

    b.getInstallStep().dependOn(&(install orelse unreachable).step);
}
