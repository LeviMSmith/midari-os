const std = @import("std");

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

fn uart_put(msg: []const u8) void {
    _ = msg;
}

/// Kernel entry point. Gets called by _start
/// Assumes stack is ready.
fn kmain() noreturn {
    // Prepare vector table registers
    // Left L3 alone since I believe that's firmware controlled.
    asm volatile (
        \\ldr x0, =exceptionVectorTable
        \\msr VBAR_EL1, x0
    );

    while (true) {
        // You spin me right round baby
        // like a record baby round round
        // right round
        uart_put("midari ");
        asm volatile ("wfe");
    }

    asm volatile ("hlt");
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
