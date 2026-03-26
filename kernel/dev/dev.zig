//! The early model is this for device discovery and handling
//!
//! During kernel initialization, an initial device setup will
//! run. It can find devices from fixed hardware places,
//! acpi, device tree etc. as those things are implemented.
//! Those modules will own those devices. On top of those
//! though will be higher level more generic handlers for
//! application and kernel use.
//!
//! For example,
//! 1. UEFI passes ACPI table and DBI to kernel
//! 2. Kernel does it's thing until we get to
//!    device initialization
//! 3. Device module will go through each of it's
//!    known methods for discovering and controlling
//!    devices, keeping track as it goes along
//! 4. These devices will have device files in a sort of
//!    VFS that enables access (or at least handles) to
//!    those physical or virtual devices, so in our example,
//!    a uart or com port could be discovered and a tty
//!    would be allocated.
//! 5. The code in the device type specifics will handle the vfs
//!    implementation

const DeviceTree = @import("DeviceTree.zig");

device_tree: DeviceTree,

pub fn init(self: *@This(), dtb: [*]const u8) !void {
   try self.device_tree.init(dtb);
}
