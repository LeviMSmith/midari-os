/// Driver information for a device
pub const Driver = struct {
    /// Comma separated list of potential drivers
    proposed_drivers: [256]u8,
    /// The actual bound driver
    bound_driver: [16]u8,
};

pub const InterfaceTypeTag = enum {
    uart,
    gpio,
};

interface_type: InterfaceTypeTag,
interface: anyopaque,
driver: Driver,
