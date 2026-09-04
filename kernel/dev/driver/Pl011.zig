//! Inherit the Uart interface
//! Rough and dirty for a sprint to a serial hello world

const Uart = @import("../interface/Uart.zig");

const Self = @This();

const CrBit = enum(u15) {
    uarten = 0, // Enable the uart
    siren = 1, // Enable SIR (infrared things)
    sirlp = 2, // SIR Low power
    lbe = 7, // Loopback enable
    txe = 8, // Transmission enable
    rxe = 9, // Recieve enable
    dtr = 10, // Data transmit ready
    rts = 11, // Ready to send
    out1 = 12,
    out2 = 13,
    rtsen = 14, // RTS hardware flow enable
    ctsen = 15, // CTS hardware flow enable
};

/// Unsafely set the cr register without
/// modifying the reserved bits
fn setCrRaw(self: *Self, opt: u15) void {
    opt |= 0b0000000001111000 & self.state.cr.*;
    self.state.cr.* = @intCast(opt);
}

/// Disables the uart and flushes any ongoing writes
/// before setting the CR and returning
fn setCr(self: *Self, opt: u15) void {
    _ = opt;

    const clear_state: u15 = 0;
    self.setCrRaw(clear_state);
}

pub fn _init(self: *Self, base_addr: usize) void {
    self.driver_state = &self.state;
    self.state.base_addr = base_addr;
    self.state.dr = @ptrFromInt(base_addr);
    self.state.fr = @ptrFromInt(base_addr + 0x18);
    self.state.lcr_h = @ptrFromInt(base_addr + 0x2c);
    self.state.cr = @ptrFromInt(base_addr + 0x30);

    self.state.lcr_h.* = 0b01110110; // 8e1

    // Enable UART, transmission on, recieve off
    // SIRLP off, no loopback, no hardware flow control
    var cr_state = 0b0000000100000001;
    // Ensure we keep bits 3:6 the same per the doc's
    // "do not modify" requirement
    cr_state |= 0b0000000001111000 & self.state.cr.*;
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
    dr: *volatile u32,
    fr: *volatile u32,
    lcr_h: *volatile u32,
    cr: *volatile u32,
};

state: State,

init: *fn (*Self, base_addr: usize) void = &_init,
deinit: *fn (*Self) void = &_deinit,
write: *fn (anyopaque, []u8) void = &_write,

driver: ?Uart.Driver = Uart.Driver.pl011,
driver_state: ?anyopaque = null,
