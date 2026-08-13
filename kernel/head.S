.section .text.boot, "ax"
.globl   boot

boot:
	nop                 // code0
	b      _start       // code1
	.quad  0            // text_offset, tell the bootloader we're not an EFI app
	.quad  _KERNEL_SIZE // image_size
	.quad  0            // flags
	.quad  0            // res2
	.quad  0            // res3
	.quad  0            // res4
	.ascii "ARM\x64"    // Magico
	.long  0            // res5

	.section .text.exceptions, "ax"
	.globl   exceptionVectorTable
	.type    exceptionVectorTable, %function
	.p2align 11

	// All exceptions use same for now
exceptionVectorTable:
	// Exception from the current EL while using SP_EL0
	b     handleExceptionGeneric // Synchronous
	eret
	.skip 120
	b     handleExceptionGeneric // IRQ
	eret
	.skip 120
	b     handleExceptionGeneric // FIQ
	eret
	.skip 120
	b     handleExceptionGeneric // SError
	eret
	.skip 120

	// Exception from the current EL while using SP_ELx
	b     handleExceptionGeneric // Synchronous
	eret
	.skip 120
	b     handleExceptionGeneric // IRQ
	eret
	.skip 120
	b     handleExceptionGeneric // FIQ
	eret
	.skip 120
	b     handleExceptionGeneric // SError
	eret
	.skip 120

	// Exception from a lower EL and at least one lower EL is AArch64
	b     handleExceptionGeneric // Synchronous
	eret
	.skip 120
	b     handleExceptionGeneric // IRQ
	eret
	.skip 120
	b     handleExceptionGeneric // FIQ
	eret
	.skip 120
	b     handleExceptionGeneric // SError
	eret
	.skip 120

	// Exception from a lower EL and all lower ELs are AArch32
	b     handleExceptionGeneric // Synchronous
	eret
	.skip 120
	b     handleExceptionGeneric // IRQ
	eret
	.skip 120
	b     handleExceptionGeneric // FIQ
	eret
	.skip 120
	b     handleExceptionGeneric // SError
	eret
	.skip 120
