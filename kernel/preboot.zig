//! Everything pertaining to the UEFI execution environment before
//! exiting boot services.

const std = @import("std");

const PrebootError = error{Console};
var opt_console_out: ?*std.os.uefi.protocol.SimpleTextOutput = null;

fn prepareConsole() !void {
    // Ensure console
    const console_out = opt_console_out orelse return PrebootError.Console;

    try console_out.setAttribute(.{ .background = .black, .foreground = .red });
    try console_out.clearScreen();
}

/// Prepare everything in the preboot environment.
/// This includes: console
pub fn init() !void {
    opt_console_out = std.os.uefi.system_table.con_out;
    prepareConsole() catch {}; // We don't necessarily need the console
}

/// Basic splash logging for tracibility
/// Converts msg to utf-16. Can fail if con_out is null.
/// `prepare` should be called first.
/// Logs to both the default console and first found serial
pub fn logStringLiteral(comptime msg: []const u8) !void {
    const console_out = opt_console_out orelse return PrebootError.Console;

    const con_msg = std.unicode.utf8ToUtf16LeStringLiteral(msg ++ "\r\n");
    _ = try console_out.outputString(con_msg);
}

/// Exit uefi boot services
pub fn boot() !void {
    logStringLiteral("Exiting boot services") catch {};
}
