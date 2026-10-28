const std = @import("std");
const Pl011 = @import("dev/driver/Pl011.zig");
const DeviceTree = @import("dev/discovery/DeviceTree.zig");

extern fn exceptionVectorTable() callconv(.naked) noreturn;

/// Test exception handler.
/// This will cause a loop for illegal instructions
/// since it branches directly back to the instruction
/// that caused the exception.
pub export fn handleExceptionGeneric() callconv(.naked) noreturn {

    // Exception return
    // Don't return to vector table.
    // Just return control to processor.
    asm volatile (
        \\eret
    );
}

var stack: [0x4000]u8 = undefined;

/// Kernel entry point. Gets called by _start
/// Requires a prepared stack space.
fn kmain() noreturn {
    // Nab the DTB address
    var dbt: u64 = undefined;

    asm volatile (
        \\str x0, [%[addr]]
        :
        : [addr] "r" (&dbt),
        : .{ .memory = true });

    // var device_tree: DeviceTree = undefined;
    // try DeviceTree.init(&device_tree, dbt);

    // Prepare vector table registers
    // We start on EL1 on qemu. We should later
    //
    asm volatile (
        \\ldr x0, =exceptionVectorTable
        \\msr VBAR_EL1, x0
    );

    // Let ourselves use SIMD for zig's routines.
    // NOTE: This should obviously later be handled more carefully.
    // Possession of the device needs to be managed if we ever
    // get to user space.
    // CPACR_EL1

    // asm volatile (
    //     \\mov x0, #(3 << 20)
    //     \\orr x0, x0, #(3<<16)
    //     \\msr CPACR_EL1, x0
    //     \\mov x0, xzr
    //     \\msr FPCR, x0
    //     \\isb
    // );

    // Get our uart driver
    var pl011: Pl011 = .{ .state = undefined };
    pl011.init(&pl011, 0x09000000);

    pl011.write(&pl011, "Midari OS V0.1.0\n");

    while (true) {
        asm volatile (
            \\wfe
        );
    }
    unreachable;
}

/// Actual kernel entrypoint. Named to match linker conventions
pub export fn _start() callconv(.naked) noreturn {
    // Prepare stack pointer
    // and call main to get out of the naked function.
    // You can't call functions from a naked function.
    // asm volatile (
    //     \\ldr x1, =%[stack_ptr]
    //     \\mov sp, x1
    //     \\br %[main_ptr]
    //     :
    //     : [main_ptr] "r" (&kmain),
    //       [stack_ptr] "r" (&stack),
    // );

    asm volatile (
        \\ldr x1, =_STACK_LOW
        \\mov sp, x1
        \\br %[main_ptr]
        :
        : [main_ptr] "r" (&kmain),
    );
}
