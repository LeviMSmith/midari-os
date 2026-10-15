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

/// Kernel entry point. Gets called by _start
/// Assumes stack is ready.
fn kmain() noreturn {
    // Nab the DTB address
    const dbt: [*]const u8 = undefined;
    asm volatile (
        \\msr dbt, x0
    );

    var device_tree: DeviceTree = undefined;
    DeviceTree.init(&device_tree, dbt);

    // Prepare vector table registers
    // We start on EL1 on qemu. We should later
    //
    asm volatile (
        \\ldr x0, =exceptionVectorTable
        \\msr VBAR_EL1, x0
    );

    // Get our uart driver
    var pl011: Pl011 = .{ .state = undefined };
    pl011.init(&pl011, 0x09000000);

    pl011.write(&pl011, "Midari OS V0.1.0\n");
    pl011.write(
        &pl011,
    );

    asm volatile ("hlt");
    unreachable;
}

/// Actual kernel entrypoint. Named to match linker conventions
pub export fn _start() callconv(.naked) noreturn {
    // Prepare stack pointer
    // and call main to get out of the naked function.
    // You can't call functions from a naked function.
    asm volatile (
        \\ldr x0, =_STACK_BOTTOM
        \\mov sp, x0
        \\br %[main_ptr]
        :
        : [main_ptr] "r" (&kmain),
    );
}
