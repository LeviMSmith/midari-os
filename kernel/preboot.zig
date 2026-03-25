//! Everything pertaining to the UEFI execution environment before
//! exiting boot services up to and including the actual process
//! of exiting boot services.

const std = @import("std");
const Kinit = @import("Kinit.zig");

var opt_console_out: ?*std.os.uefi.protocol.SimpleTextOutput = null;

/// Find and prepare the uefi provided output console.
fn prepareConsole() std.os.uefi.Error!void {
    // Ensure console
    const console_out = std.os.uefi.system_table.con_out.?;
    opt_console_out = console_out;

    try console_out.setAttribute(.{ .background = .black, .foreground = .red });
    try console_out.clearScreen();
}

/// Prepare everything in the preboot environment.
pub fn init() std.os.uefi.Error!void {
    try prepareConsole();
}

/// Basic splash logging for tracibility
/// `prepare` should be called first.
pub fn logStringLiteral(comptime msg: []const u8) std.os.uefi.Error!void {
    const console_out = opt_console_out orelse return std.os.uefi.Error.NotFound;

    const con_msg = std.unicode.utf8ToUtf16LeStringLiteral(msg ++ "\r\n");
    var con_err: std.os.uefi.Error = undefined;
    _ = console_out.outputString(con_msg) catch |err| {
        con_err = err;
    };
}

/// Exit uefi boot services
pub fn boot(kinit: *Kinit) !void {
    const boot_services = std.os.uefi.system_table.boot_services orelse unreachable;
    const image_handle = std.os.uefi.handle;

    // Attempt to exit boot services a few times.
    // Could be things changing memory between calls and firmware
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

        kinit.memory_map_info = memory_map_info;

        return;
    }

    // All attempts failed
    logStringLiteral("Failed to exit boot services") catch {};
    return exit_err;
}
