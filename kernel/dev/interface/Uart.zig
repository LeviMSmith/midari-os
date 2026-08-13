//! Object for handling a uart connection

pub const Driver = enum {
    bcm2837,
    pl011,
};

init: *fn (anyopaque) void,
deinit: *fn (anyopaque) void,

/// Synchronously write out the given buffer over uart.
write: *fn (anyopaque, []u8) void,

driver: ?Driver,
driver_state: ?anyopaque,
