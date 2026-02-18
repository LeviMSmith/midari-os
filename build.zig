const std = @import("std");

//// Utils ////

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

//// Almighty Main Build ////

pub fn build(b: *std.Build) !void {
    const kernel_out_path = try std.fs.path.join(b.allocator, &.{
        b.install_prefix,
        "kernel",
    });
    defer b.allocator.free(kernel_out_path);
    const kernel_in_path = "kernel" ++ std.fs.path.sep_str ++ "build.zig";

    const kernel_cmd = addSubprojectBuild(b, kernel_in_path, kernel_out_path);
    const kernel_step = b.step("kernel", "Build the kernel subproject");
    kernel_step.dependOn(&kernel_cmd.step);

    b.getInstallStep().dependOn(&kernel_cmd.step);
}
