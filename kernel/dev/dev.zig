//! The early model is this for device discovery and handling
//!
//! During kernel initialization, an initial device setup will
//! run. It can find devices from fixed hardware places,
//! acpi, device tree etc. as those things are implemented.
//! Those modules will own those devices. On top of those
//! though will be higher level more generic handlers for
//! application and kernel use.
//!
//! Devices are accessible by type with generic handlers, but
//! may be backed by another techology. E.g. Network over USB

const DeviceTree = @import("DeviceTree.zig");
const Uart = @import("interface/Uart.zig");
const Gpio = @import("interface/Gpio.zig");
const Device = @import("Device.zig");
const bcm2837 = @import("driver/broadcom/bcm2837.zig");

pub const Error = error{
    oom,
};

pub const DriverProvider = struct {
    uart: ?[][]u8,
    gpio: ?[][]u8,
};

device_tree: DeviceTree,

// These will be dynamic once we get memory set up.
uarts: [2]Uart,
uart_len: usize,
gpios: [2]Gpio,
gpio_len: usize,

devices: [4]Device,
device_len: usize,

const Self = @This();

/// Get an empty interface struct for use in device discovery
pub fn getNewDevice(self: *Self, comptime T: anytype) !*Device {
    if (self.uart_len >= self.uarts.len or self.device_len >= self.devices.len) {
        return Error.oom;
    }

    const dev = &self.devices[self.device_len];
    self.device_len += 1;

    // This will drastically change when we go to dynamic memory
    const interface, const interface_type = switch (T) {
        Device.InterfaceTypeTag.uart => {
            const uart = &self.uarts[self.uart_len];
            self.uart_len += 1;
            return .{ uart, T };
        },
        Device.InterfaceTypeTag.gpio => {
            const gpio = &self.gpios[self.gpio_len];
            self.gpio_len += 1;
            return .{ gpio, T };
        },
        _ => @compileError("Invalid interface type passed to getNewDevice"),
    };

    dev.interface = interface;
    dev.interface_type = interface_type;
    return dev;
}

/// Prepare memory for later use
pub fn init(self: *Self, dtb: [*]const u8) !void {
    self.uart_len = 0;
    self.gpio_len = 0;
    self.device_len = 0;

    // Discovery
    // try self.device_tree.init(dtb);
    _ = dtb;
    try bcm2837.discover(self);

    // Driver init

}
