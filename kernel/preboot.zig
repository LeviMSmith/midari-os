const std = @import("std");

const PrebootError = error{Console};

fn preparePrebootConsole() !void {
    const system_table = std.os.uefi.system_table;
    const console_out = system_table.con_out orelse return PrebootError.Console;
}

pub fn preparePreboot() void {
    preparePrebootConsole();
}
