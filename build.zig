const std = @import("std");

fn build_bootloader(b: *std.Build) void {
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
            .root_source_file = b.path("boot/efi/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const install = b.addInstallArtifact(exe, .{
        .dest_sub_path = "EFI/BOOT/BOOTX64.EFI",
    });
    b.getInstallStep().dependOn(&install.step);
}

pub fn build(b: *std.Build) void {
    build_bootloader(b);
}
