//! Everything pertaining to the UEFI execution environment before
//! exiting boot services up to and including the actual process
//! of exiting boot services.

const std = @import("std");

pub const PrebootError = error{ Console, BootServices };
var opt_console_out: ?*std.os.uefi.protocol.SimpleTextOutput = null;
var opt_dbg_console_out: ?*std.os.uefi.protocol.SerialIo = null;

/// Find and prepare the uefi provided output console.
fn prepareConsole() !void {
    // Ensure console
    const console_out = std.os.uefi.system_table.con_out orelse return PrebootError.Console;
    opt_console_out = console_out;

    try console_out.setAttribute(.{ .background = .black, .foreground = .red });
    try console_out.clearScreen();
}

/// Automatically find a suitable serial out for
/// debug information and prepare it to be easily
/// output to.
fn prepareDbgConsole() !void {

    // 1. Enumate devices by serial capability
    // 2. Pick one
    // 3. Set settings.

    const boot_services = std.os.uefi.system_table.boot_services orelse unreachable;
    const handles = try boot_services.locateHandleBuffer(.{
        .by_protocol = &std.os.uefi.protocol.SerialIo.guid,
    });

    // TODO: Actually check if we found one
    const handle = (handles orelse return PrebootError.BootServices)[0];
    opt_dbg_console_out = try boot_services.openProtocol(std.os.uefi.protocol.SerialIo, handle, .{
        .exclusive = .{
            .agent = std.os.uefi.handle,
        },
    });

    // const dbg_console_out = opt_dbg_console_out orelse unreachable;

    // TODO: Make this work off of a config file in the efi partition
    // Reasonable defaults for now
    // dbg_console_out.setAttribute(9600, 16384, 10 * 1000 * 1000, std.os.uefi.protocol.SerialIo.ParityType.default_parity, 8, );
}

/// Prepare everything in the preboot environment.
/// This includes: console, debug console
pub fn init() !void {
    prepareConsole() catch {}; // We don't necessarily need the console
    prepareDbgConsole() catch {}; // We don't necessarily need the console
}

/// Basic splash logging for tracibility
/// `prepare` should be called first.
/// Logs to both the default console and first found serial
/// Returned error is always main console. Serial will be silently
/// ignored
pub fn logStringLiteral(comptime msg: []const u8) !void {
    const console_out = opt_console_out orelse return PrebootError.Console;

    const con_msg = std.unicode.utf8ToUtf16LeStringLiteral(msg ++ "\r\n");
    var con_err: anyerror = undefined;
    _ = console_out.outputString(con_msg) catch |err| {
        con_err = err;
    };

    const dbg_console_out = opt_dbg_console_out orelse {
        _ = console_out.outputString(std.unicode.utf8ToUtf16LeStringLiteral("Failed to repeat message to serial console. Not set.")) catch {};
        return con_err;
    };
    _ = dbg_console_out.write(msg ++ "\r\n") catch {
        _ = console_out.outputString(std.unicode.utf8ToUtf16LeStringLiteral("Failed to repeat message to serial console. Write error.")) catch {};
    };

    return con_err;
}

/// Exit uefi boot services
pub fn boot() !std.os.uefi.tables.MemoryMapInfo {
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

        return memory_map_info;
    }

    // All attempts failed
    logStringLiteral("Failed to exit boot services") catch {};
    return exit_err;
}
