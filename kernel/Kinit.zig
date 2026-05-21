const std = @import("std");
const Dev = @import("dev/Dev.zig");

memory_map_info: std.os.uefi.tables.MemoryMapInfo,
dtb: ?[*]u8,
dev: Dev,

/// Initialize the entire environment
pub fn boot(self: *@This()) !void {
    // Device tree
    if (self.dtb != null) {
        try self.dev.init(self.dtb orelse unreachable);
    }

    while (true) {}
}
