_KERNEL_BASE = 0x40000000;
_STACK_TOP = 0x50000000;
MAXPAGESIZE = 4K;

SECTIONS
{
  . = _KERNEL_BASE;
  . = ALIGN(CONSTANT(MAXPAGESIZE));

  _KERNEL_START = .;

  .text : {
    _TEXT_START = .;
    KEEP(*(.text.boot))
    *(.text .text.*)
    _TEXT_END = .;
  }

  .rodata : ALIGN(CONSTANT(MAXPAGESIZE)) {
    _RODATA_START = .;
    *(.rodata .rodata.*)
    _RODATA_END = .;
  }

  .data : ALIGN(CONSTANT(MAXPAGESIZE)) {
    _DATA_START = .;
    *(.data .data.*)
    _DATA_END = .;
  }

  .bss : ALIGN(CONSTANT(MAXPAGESIZE)) {
    _BSS_START = .;
    *(.bss .bss.* COMMON)
    _BSS_END = .;
  }

  .eh_frame : ALIGN(CONSTANT(MAXPAGESIZE)) {
    *(.eh_frame .eh_frame.*)
  }

  . = ALIGN(CONSTANT(MAXPAGESIZE));
  _KERNEL_END = .;

  _KERNEL_SIZE = _KERNEL_END - _KERNEL_START;
}
