//! Inherit the Uart interface
//! Rough and dirty for a sprint to a serial hello world

const Uart = @import("../interface/Uart.zig");

const Self = @This();

fn bit(comptime T: type, comptime pos: T) T {
    return 1 << pos;
}

const FrBit = enum(u16) {
    cts = bit(u16, 0), // Clear to send
    dsr = bit(u16, 1), // Data set ready
    dcd = bit(u16, 2), // Data carrier detect
    busy = bit(u16, 3), // UART busy
    rxfe = bit(u16, 4), // Recieve FIFO empty
    txff = bit(u16, 5), // Transmit FIFO full
    rxff = bit(u16, 6), // Receive FIFO full
    txfe = bit(u16, 7), // Transmit FIFO empty
    ri = bit(u16, 8), // Ring indicator
};

const CrBit = enum(u16) {
    uarten = bit(u16, 0), // Enable the uart
    siren = bit(u16, 1), // Enable SIR (infrared things)
    sirlp = bit(u16, 2), // SIR Low power
    lbe = bit(u16, 7), // Loopback enable
    txe = bit(u16, 8), // Transmission enable
    rxe = bit(u16, 9), // Recieve enable
    dtr = bit(u16, 10), // Data transmit ready
    rts = bit(u16, 11), // Ready to send
    out1 = bit(u16, 12),
    out2 = bit(u16, 13),
    rtsen = bit(u16, 14), // RTS hardware flow enable
    ctsen = bit(u16, 15), // CTS hardware flow enable
};

const LcrHBit = enum(u16) {
    brk = bit(u16, 0), // Send break
    pen = bit(u16, 1), // Parity enable
    eps = bit(u16, 2), // Even parity select
    stp2 = bit(u16, 3), // Two stop bits select
    fen = bit(u16, 4), // Enable fifos
    sps = bit(u16, 7), // Stick parity select
};

/// Unsafely set the cr register without
/// modifying the reserved bits
fn setCrRaw(self: *Self, opt: u16) void {
    const preserve_mask: u32 = 0b11110000;

    self.state.cr.* =
        (opt & ~preserve_mask) |
        (self.state.cr.* & preserve_mask);
}

/// Disables the uart and flushes any ongoing writes
/// before setting the CR and returning
fn setCr(self: *Self, opt: u16) void {
    // Disable the device
    const clear_state: u16 = 0;
    self.setCrRaw(clear_state);

    // Ensure we've finished trasmitting the last character
    // TODO: Don't do a dumb poll since it could hang
    while (true) {
        if (self.state.fr.* & @intFromEnum(FrBit.busy) == 0) {
            break;
        }
    }

    // Set the register while being sensitive to FIFO
    // requirements
    if (self.state.lcr_h.* & @as(u32, @intCast(@intFromEnum(LcrHBit.fen))) != 0) {
        // Flush FIFO if enabled and then restore
        self.state.lcr_h.* &= ~@as(u32, @intCast(@intFromEnum(LcrHBit.fen)));
        self.setCrRaw(opt);
        self.state.lcr_h.* |= @as(u32, @intCast(@intFromEnum(LcrHBit.fen)));
    } else {
        self.setCrRaw(opt);
    }
}

fn setLcrH(self: *Self, opt: u16) void {
    const preserve_mask: u32 = 0b1111111100000000;

    self.state.cr.* =
        (opt & ~preserve_mask) |
        (self.state.cr.* & preserve_mask);
}

/// Prepare the UART to be able to transmit and receive
pub fn _init(self: *Self, base_addr: usize) void {
    // Prepare addresses
    // self.driver_state = &self.state;
    self.state.base_addr = base_addr;
    self.state.dr = @ptrFromInt(base_addr);
    self.state.fr = @ptrFromInt(base_addr + 0x18);
    self.state.lcr_h = @ptrFromInt(base_addr + 0x2c);
    self.state.cr = @ptrFromInt(base_addr + 0x30);

    self.setLcrH(0b01100000); // 8n1
    self.setCr(@intFromEnum(CrBit.uarten) | @intFromEnum(CrBit.txe));
}

pub fn _deinit(self: *Self) void {
    _ = self;
}

/// Assumes device is already ready to transmit
pub fn _write(self: *Self, msg: []const u8) void {
    // Very dumb no fifo, no DMA approach.
    // Write the character, wait until we're not busy,
    // transmit the next

    for (msg) |c| {
        self.state.dr.* = c;
        // TODO: Don't dumb poll
        while (true) {
            if (self.state.fr.* & @intFromEnum(FrBit.busy) == 0) {
                break;
            }
        }
    }
}

const State = struct {
    base_addr: usize,
    dr: *volatile u32,
    fr: *volatile u32,
    lcr_h: *volatile u32,
    cr: *volatile u32,
};

state: State,

init: *const fn (*Self, base_addr: usize) void = &_init,
deinit: *const fn (*Self) void = &_deinit,
write: *const fn (*Self, []const u8) void = &_write,

driver: ?Uart.Driver = Uart.Driver.pl011,
