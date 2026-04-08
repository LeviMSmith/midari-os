//! This struct abstracts a GPIO controller for use by the kernel.

const Bcm2837 = @import("Bcm2837.zig");

/// Use of none instead of an optional member is intentional for
/// code cleanliness purposes.
const GpioBackTemplateTag = enum {
    none,
    bcm2837,
};

/// This struct may be extended by a backer if it has more information
/// than the generic Gpio interface implements.
/// Members are always pointers.
pub const GpioBackTemplate = union(GpioBackTemplateTag) {
    none: void,
    bcm2837: *Bcm2837.GpioController,
};

backer: GpioBackTemplate,
