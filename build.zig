const std = @import("std");

const BuildError = error{UnsupportedArchitecture};

fn build_kernel(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const target_name = switch (target.result.cpu.arch) {
        .aarch64 => "BOOTAARCH64",
        .x86_64 => "BOOTX64",
        else => return BuildError.UnsupportedArchitecture,
    };

    const dep = b.dependency("kernel", .{
        .target = target,
        .optimize = optimize,
    });
    const exe = dep.artifact(target_name);

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
