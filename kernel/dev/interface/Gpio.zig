//! This struct abstracts a GPIO controller for use by the kernel.

pub const Driver = enum {
    none,
    bcm2837,
};

driver: Driver,
driver_state: anyopaque,
