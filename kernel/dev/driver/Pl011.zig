//! Inherit the Uart interface
//! Rough and dirty for a sprint to a serial hello world

const Uart = @import("../interface/Uart.zig");

const Self = @This();

pub fn _init(self: *Self, base_addr: usize) void {
    self.driver_state = &self.state;
    self.state.base_addr = base_addr;
    self.state.dr = base_addr;
    self.state.fr = base_addr + 0x18;
    self.state.lcr_h = base_addr + 0x2c;
    self.state.cr = base_addr + 0x30;

    self.state.lcr_h.* = 0b01110110; // 8e1

    // Enable UART, transmission on, recieve off
    // SIRLP, no loopback, no wardware flow control
    var cr_state = 0b0000000100000101;
    // Ensure we keep bits 3:6 the same per the doc's
    // "do not modify" requirement
    cr_state |= 0b0000000001111000 & self.state.lcr_h.*;
    self.state.cr.* = cr_state;
}

pub fn _deinit(self: *Self) void {
    _ = self;
}

pub fn _write(self: *Self, msg: []u8) void {
    _ = self;
    _ = msg;
}

const State = struct {
    base_addr: usize,
    dr: *u12,
    fr: *u9,
    lcr_h: *u8,
    cr: *u16,
};

state: State,

init: *fn (*Self, base_addr: usize) void = &_init,
deinit: *fn (*Self) void = &_deinit,
write: *fn (anyopaque, []u8) void = _write,

driver: ?Uart.Driver = Uart.Driver.pl011,
driver_state: ?anyopaque = null,
