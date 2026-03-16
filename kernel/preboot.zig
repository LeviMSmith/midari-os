//! Everything pertaining to the UEFI execution environment before
//! exiting boot services.

const std = @import("std");

pub const PrebootError = error{ Console, BootServices };
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
pub fn boot() !std.os.uefi.tables.MemoryMapInfo {
    const boot_services = std.os.uefi.system_table.boot_services orelse unreachable;
    const image_handle = std.os.uefi.handle;

    // Attempt to exit boot services a few times.
    // Could be things changing memory between calls, and firmware
    // sometimes stops changing memory after the first
    // attempt, so a few attempts in normal and expected.
    var exit_err: std.os.uefi.tables.BootServices.ExitBootServicesError = undefined;
    for (0..2) |i| {
        _ = i;

        const memory_map_info = boot_services.getMemoryMapInfo() catch |err| {
            logStringLiteral("Failed to get memory map info") catch {};
            return err;
        };
        boot_services.exitBootServices(image_handle, memory_map_info.key) catch |err| {
            exit_err = err;
            logStringLiteral("Attempt to exit boot services failed. Trying again.") catch {};
            continue;
        };

        return memory_map_info;
    }

    // All attempts failed
    logStringLiteral("Failed to exit boot services") catch {};
    return exit_err;
}
