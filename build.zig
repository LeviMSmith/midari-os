const std = @import("std");

pub fn build(b: *std.Build) void {
    const kernel_cmd = addSubprojectBuild(b, "kernel/build.zig", "zig-out/kernel");
    const kernel_step = b.step("kernel", "Build the kernel subproject");
    kernel_step.dependOn(&kernel_cmd.step);

    // Keep root `zig build` useful today: build the kernel by default.
    b.getInstallStep().dependOn(&kernel_cmd.step);

    // Future userspace/program subproject entrypoint.
    // if (pathExists("base/build.zig")) {
    //     const base_cmd = addSubprojectBuild(b, "base/build.zig", "zig-out/base");
    //     const base_step = b.step("base", "Build the base subproject");
    //     base_step.dependOn(&base_cmd.step);
    // }
}

fn addSubprojectBuild(b: *std.Build, build_file: []const u8, prefix: []const u8) *std.Build.Step.Run {
    return b.addSystemCommand(&.{
        "zig",
        "build",
        "--build-file",
        build_file,
        "--prefix",
        prefix,
    });
}
