const std = @import("std");

memory_map_info: std.os.uefi.tables.MemoryMapInfo,
dtb: ?*anyopaque,
