//! Drivers and discovery for devices on this platform

const Dev = @import("../../Dev.zig");
const Device = @import("../../Device.zig");

////////////////////
///// DISCOVER /////
////////////////////

fn discoverGpio(dev: *Dev) !void {
    const gpio_device = try dev.getNewDevice(Device.InterfaceTypeTag.gpio);

    gpio_device.driver.proposed_drivers = "bcm2837_gpio";
}

fn discoverUart(dev: *Dev) !void {
    const uart_device = try dev.getNewDevice(Device.InterfaceTypeTag.uart);

    uart_device.driver.proposed_drivers = "bcm2837_uart";
}

/// Prepare devices that we know of statically for this platform
/// Fails if the device struct fails to give us empty interfaces
pub fn discover(dev: *Dev) !void {
    var failed: ?anyerror = null;

    discoverGpio(dev) catch |err| {
        failed = err;
    };
    discoverUart(dev) catch |err| {
        failed = err;
    };

    if (failed != null) {
        return failed;
    }
}
