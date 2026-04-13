//! Handle the BCM2837 as a device that provides a few hard coded
//! peripherals

const _Uart = @import("Uart.zig");

/// Our extension of the GPIO interface specific to this SOC
pub const GpioDriver = struct {};

/// Our extension of the UART interface specific to this SOC
pub const UartDriver = struct {
    bcm2837: *@This(),
    r_buffer: [256]u8,
    w_buffer: [256]u8,
};

/// The BCM2837's sole uart provided through GPIO functionality.
/// TODO: This memory should not be owned by the BCM2837 device
/// and should probably be allocated dynamically when the UART
/// is initialized.
uart: UartDriver,

fn uart_init() void {}
fn uart_deinit() void {}

/// BCM2837 provides a single hardware uart through configurable
/// GPIO pins. This function returns a Uart object that represents
/// that Uart and configures those GPIOs for the UART.
pub fn Uart(self: *@This()) _Uart {
    self.uart.bcm2837 = &self;

    return .{
        .init = uart_init,
        .deinit = uart_deinit,
        .driver = .{ .bcm2837 = &self.uart },
    };
}
