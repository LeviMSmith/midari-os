const std = @import("std");

pub const Error = error{
    Parse,
};

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

fn parse_header(self: *@This(), dbt: [*]const u8) !void {
    // I suspect that readInt may be doing extra work here for alignment
    // and that the dbt start is aligned to something, but I can't find anything
    // on that, so we go the safe route instead of pointer casting

    self.fdt_header.magic = std.mem.readInt(u32, dbt[0..4], .big);
    if (self.fdt_header.magic != 0xd00dfeed) {
        return .Parse;
    }

    self.fdt_header.totalsize = std.mem.readInt(u32, dbt[4..8], .big);
    self.fdt_header.off_dt_struct = std.mem.readInt(u32, dbt[8..12], .big);
    self.fdt_header.off_dt_strings = std.mem.readInt(u32, dbt[12..16], .big);
    self.fdt_header.off_mem_rsvmap = std.mem.readInt(u32, dbt[16..20], .big);
    self.fdt_header.version = std.mem.readInt(u32, dbt[20..24], .big);
    self.fdt_header.last_comp_version = std.mem.readInt(u32, dbt[24..28], .big);
    self.fdt_header.boot_cpuid_phys = std.mem.readInt(u32, dbt[28..32], .big);
    self.fdt_header.size_dt_strings = std.mem.readInt(u32, dbt[32..36], .big);
    self.fdt_header.size_dt_struct = std.mem.readInt(u32, dbt[36..40], .big);
}

/// Must have successfully called parse_header first.
fn parse_structure_block(self: *@This(), dbt: [*]const u8) void {}

pub fn init(self: *@This(), dtb: [*]const u8) !void {
    try self.parse_header(dtb);
    try self.parse_structure_block(dtb);
}
