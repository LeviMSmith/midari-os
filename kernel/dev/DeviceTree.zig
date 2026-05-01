//! Everything pertaining to the device tree state in the kernel

const std = @import("std");

pub const FdtHeader = struct {
    magic: u32,
    totalsize: u32,
    off_dt_struct: u32,
    off_dt_strings: u32,
    off_mem_rsvmap: u32,
    version: u32,
    last_comp_version: u32,
    boot_cpuid_phys: u32,
    size_dt_strings: u32,
    size_dt_struct: u32,
};

fdt_header: FdtHeader,

pub const Error = error{
    DtbParse,
};

fn parse_header(self: *@This(), dbt: [*]const u8) !void {
    self.fdt_header.magic = std.mem.readInt(u32, dbt[0..4], .big);
}

/// Parse out DTB and prepare discovered devices
pub fn init(self: *@This(), dtb: [*]const u8) !void {
    try self.parse_header(dtb);
}
