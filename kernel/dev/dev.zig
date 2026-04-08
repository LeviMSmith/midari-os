//! The early model is this for device discovery and handling
//!
//! During kernel initialization, an initial device setup will
//! run. It can find devices from fixed hardware places,
//! acpi, device tree etc. as those things are implemented.
//! Those modules will own those devices. On top of those
//! though will be higher level more generic handlers for
//! application and kernel use.
//!
//! Devices are accessible by type with generic handlers, but
//! may be backed by another techology. E.g. Network over USB
//!
//! Devices
//!   TTY (Virtual)
//!     UART Backed
//!   UART (Physical/Virtual)
//!     GPIO Backed
//!       BCM2875
//!   GPIO (Physical/Virtual)
//!     BCM2875 Backed

const DeviceTree = @import("DeviceTree.zig");

device_tree: DeviceTree,

pub fn init(self: *@This(), dtb: [*]const u8) !void {
   // Discovery
   // try self.device_tree.init(dtb);
   _ = dtb;
}
