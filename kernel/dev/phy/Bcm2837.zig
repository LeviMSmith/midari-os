//! Handle the BCM2837 as a device that provides a few hard coded
//! peripherals

const _Uart = @import("Uart.zig");
const Bcm2837 = @This();

////////////////
///// GPIO /////
////////////////

pub const GpioDriver = struct {};

// GPIO addresses
const gpio_funsel_0: *volatile u32 = @ptrFromInt(0x7E200000);
const gpio_funsel_1: *volatile u32 = @ptrFromInt(0x7E200004);
const gpio_funsel_2: *volatile u32 = @ptrFromInt(0x7E200008);
const gpio_funsel_3: *volatile u32 = @ptrFromInt(0x7E20000C);
const gpio_funsel_4: *volatile u32 = @ptrFromInt(0x7E200010);
const gpio_funsel_5: *volatile u32 = @ptrFromInt(0x7E200014);

const gpio_outset_0: *volatile u32 = @ptrFromInt(0x7E20001C);
const gpio_outset_1: *volatile u32 = @ptrFromInt(0x7E200020);

////////////////
///// UART /////
////////////////

pub const UartMiniDriver = struct {
    bcm2837: *Bcm2837,
};

pub const UartFullDriver = struct {
    bcm2837: *Bcm2837,
};

uart_mini: UartMiniDriver,
uart_full: UartFullDriver,

/// Dumb initialization of pins for uart.
/// Make this smarter after we get a hello world
fn uart_init() void {
    // Clear FSEL14 + FSEL15
    gpio_funsel_1.* &= 0b11111111111111000000111111111111;

    // Set both FSEL14 + FSEL15 to alternate function 0 (value: 0b100) (uart0)
    gpio_funsel_1.* |= 0b00000000000000100100000000000000;
}

fn uart_deinit() void {}
fn uart_write(msg: [:0]u8) void {
    _ = msg;
}

/// BCM2837 provides a two hardware uarts through configurable
/// GPIO pins. This function returns a Uart object that represents
/// that Uart and configures those GPIOs for the UART.
pub fn Uart(self: *@This()) _Uart {
    // Store a pointer to BCM so the Uart can talk to the GPIO
    self.uart.bcm2837 = &self;

    return .{
        .init = uart_init,
        .deinit = uart_deinit,
        .driver = .{ .bcm2837 = &self.uart },
    };
}
