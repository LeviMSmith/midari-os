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
