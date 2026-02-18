const std = @import("std");

pub fn main() void {
    const system_table = std.os.uefi.system_table;
    const console_out = system_table.con_out orelse return;

    const msg = std.unicode.utf8ToUtf16LeStringLiteral("Hello world!");
    _ = console_out.outputString(msg) catch return;

    while (true) {}
}
