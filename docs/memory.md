# Initialization

Memory is one of the biggest security and stability issues computers face. It has to be managed extremely carefully. I'm not trying to build fort nox here, but it's something to at least consider.

If we rely on linux boot conditions (which should be a pretty reasonable ask) the whole kernel image is loaded into memory. I don't

> The boot loader is expected to find and initialise all RAM that the kernel will use for volatile data storage in the system. It performs this in a machine dependent manner. (It may use internal algorithms to automatically locate and size all RAM, or it may use knowledge of the RAM in the machine, or any other method the boot loader designer sees fit.)

> The device tree blob (dtb) must be placed on an 8-byte boundary and must not exceed 2 megabytes in size. Since the dtb will be mapped cacheable using blocks of up to 2 megabytes in size, it must not be placed within any 2M region which must be mapped with any specific attributes.

which means that when we start up we don't really know where the dtb will be. Could be where I hard coded the stack to be in theory?
