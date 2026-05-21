# How

How are we going to model the device heirarchy?

At a high level each device can reasonably be represented as a struct with virtual functions. Those virtual functions can be handled through whatever backing is necessary. If common devices exist, they can be templated and modified as necessary.

# Discovery

If we create a device for the SoC as a whole, we can easily access devices that we depend on

I think I've been thinking about device discovery wrong in this project. Or maybe how I'm modeling them. Really, we'd prefer to discover all devices and then figure out how to drive them, set up objects, etc.

In that case, we'd probably add the Bcm2837 SoC as a (temporary?) discovery method in addition to device tree and acpi. The bcm2837 can essentially statically return generic device descriptors and recommend a driver. In this case, because the uart pins are dependant on manipulating the gpio object in the SoC, they would require their own driver. That driver would implement, open (Set gpio pin functions and claim ownership), close (Release gpio pin ownership, powerdown), write (Could have generic uart write with an address since the uarts are very similar for that), read, etc.

This also implies that the uart would need to be able to speak to the gpio object. Probably also a v table. And also potentially a dedicated SoC device to help manage?

So instead of the SoC device struct owning the gpio and uart, there is just a list of each device type with an owned driver that can extend functionality. This could later be a generic pointer instead of a tagged union.
