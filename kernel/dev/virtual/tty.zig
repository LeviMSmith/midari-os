//! A tty is a virtual device which handles an
//! interactive terminal over various supported
//! devices
//! They are always indexable with an integer number
//! as well as their filesystem path.
//! This file contains functionality for managing ttys
//! as well as the Tty struct itself.

const Uart = @import("phy/Uart.zig");

pub const Id = i32;

pub const TtyError = error{
    /// There is no initialized tty by that Id
    not_found,
};

const TtyDeviceType = enum {
    none,
    uart,
};

const TtyDevice = union(TtyDeviceType) {
    none: void,
    uart: *Uart,
};

pub const Tty = struct {
    /// In the case of a generic UART we may not know or care
    /// about character dimensions
    char_width: ?u32,

    /// In the case of a generic UART we may not know or care
    /// about character dimensions
    char_height: ?u32,

    device: TtyDevice,

    /// Output a utf-8 sequence to the tty
    pub fn output(self: *Tty, msg: [:0]u8) void {
        switch (self.device) {
            .uart => |uart| {
                uart.output(msg);
            },
        }
    }

    /// Output the end sequence to the tty
    /// if applicable
    pub fn outputEndl(self: *Tty) void {
        switch (self.device) {
            .uart => |uart| {
                uart.outputEndl();
            },
        }
    }

    /// Output a utf-8 line to the tty screen.
    /// Appends newline characters if applicable.
    pub fn outputLine(self: *Tty, msg: [:0]u8) void {
        switch (self.device) {
            .uart => |uart| {
                uart.output(msg);
                uart.outputEndl();
            },
        }
    }
};

const ttys: [8]?Tty = null;

pub fn getTty(id: Id) *Tty {
    const tty = &ttys[id];
    if (tty == null) {
        return TtyError.not_found;
    }

    return tty;
}
