const std = @import("std");

const BuildError = error{UnsupportedArchitecture};

const target_name = "midari";

fn build_kernel(b: *std.Build) !void {
    //// Config ////
    // NOTE: target os and abi are overriden to simplify build.
    // arch can still be set by caller.
    var tq = b.standardTargetOptions(.{}).query;
    tq.os_tag = .freestanding;
    tq.abi = .msvc;

    const emmit_assy = b.option(bool, "emitasm", "Emmit Assembly") orelse false;

    const target = b.resolveTargetQuery(tq);
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule(target_name, .{
        .root_source_file = b.path("kernel/root.zig"),
        .target = target,
    });

    // Target
    const exe = b.addExecutable(.{
        .name = target_name,
        .root_module = b.createModule(.{
            .root_source_file = b.path("kernel/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = target_name, .module = mod },
            },
        }),
        .use_lld = true,
        .use_llvm = true,
        .linkage = .static,
    });

    exe.root_module.addAssemblyFile(b.path("kernel/head.S"));

    exe.setLinkerScript(b.path("kernel/script.ld"));

    b.installArtifact(exe);

    /////////////////////////
    ///// Other Formats /////
    /////////////////////////

    if (emmit_assy) {
        const asm_file = exe.getEmittedAsm();
        const install_asm = b.addInstallBinFile(asm_file, "midari.S");
        b.getInstallStep().dependOn(&install_asm.step);
    }

    const image = b.addObjCopy(exe.getEmittedBin(), .{
        .format = .bin,
    });

    const image_install = b.addInstallFileWithDir(image.getOutput(), .bin, "image");
    b.getInstallStep().dependOn(&image_install.step);
}

pub fn build(b: *std.Build) !void {
    try build_kernel(b);
}
