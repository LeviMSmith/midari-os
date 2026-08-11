const std = @import("std");

extern fn exceptionVectorTable() callconv(.naked) noreturn;

/// Test exception handler.
pub export fn handleExceptionGeneric() callconv(.naked) noreturn {

    // Exception return
    // Don't return to vector table.
    // Just return control to processor.
    asm volatile (
        \\eret
    );
}

// Actual kernel entrypoint. Named to match linker conventions
pub export fn _start() callconv(.naked) noreturn {
    // Prepare stack pointer
    asm volatile (
        \\ldr x0, =_STACK_BOTTOM
        \\mov sp, x0
    );

    // Prepare vector table registers
    // Left L3 alone since I believe that's firmware controlled.
    asm volatile (
        \\ldr x0, =exceptionVectorTable
        \\msr VBAR_EL1, x0
        \\ldr x0, =exceptionVectorTable
        \\msr VBAR_EL2, x0
    );

    while (true) {
        // You spin me right round baby
        // like a record baby round round
        // right round
        asm volatile ("wfe");
    }
}
