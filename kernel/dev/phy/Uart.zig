//! Object for handling a uart connection
//! TODO: Allow backing devices/drivers to be
//! selectable at compile time. E.g. don't include
//! support for the BCM2837. Or at least maybe generate
//! device list so this doesn't have to have everything
//! here in multiple places.

const Bcm2837 = @import("Bcm2837.zig");

const UartDriverTag = enum {
    none,
    bcm2837,
};

const UartDriver = union(UartDriverTag) {
    none: void,
    bcm2837: *Bcm2837.UartDriver,
};

init: *fn () void,
deinit: *fn () void,
write: *fn () void,

driver: UartDriver,
