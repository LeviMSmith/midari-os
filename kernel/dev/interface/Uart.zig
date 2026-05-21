//! Object for handling a uart connection

pub const Driver = enum {
    none,
    bcm2837,
};

init: *fn () void,
deinit: *fn () void,
write: *fn ([]u8) void,

driver: Driver,
driver_state: anyopaque,
