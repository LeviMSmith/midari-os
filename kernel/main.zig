const std = @import("std");

pub export fn _start() callconv(.naked) noreturn {
    // Prepare stack pointer
    asm volatile (
        \\ldr x0, =_STACK_TOP
        \\mov sp, x0
    );

    while (true) {
        // You spin me right round baby
        // like a record baby round round
        // right round
        asm volatile ("wfe");
    }
}
