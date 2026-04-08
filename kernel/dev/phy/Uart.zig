//! Object for handling a uart connection

const Bcm2837 = @import("Bcm2837.zig");

const UartBackTemplateTag = enum {
    none,
    bcm2837,
};

const UartBackTemplate = union(UartBackTemplateTag) {
    none: void,
    bcm2837: Bcm2837.UartController,
};

// Vtable
pub fn 
