//! Simple splash logger for system things.
//! Sinks will be able to be explicitly configured
//! through a config in the efi partition or in etc.
//! Otherwise a reasonable tty will be used.

const std = @import("std");
const builtin = @import("builtin");
const tty = @import("../dev/tty.zig");

pub const Level = enum {
    trace,
    debug,
    info,
    warn,
    err,
    critical,
    fatal,
};

var thres: Level = undefined;

// Default log_thres
comptime {
    if (builtin.optimize_mode == std.builtin.OptimizeMode.Debug) {
        thres = Level.debug;
    } else {
        thres = Level.info;
    }
}

var sinks: [16]tty.Id = -1;

pub fn init() void {}

/// Log a utf-8 string to splash sinks
pub fn log(
    msg: [:0]const u8,
    lvl: Level,
) void {
    if (lvl >= thres) {
        return;
    }

    for (sinks) |sink| {
        const sink_tty = tty.getTty(sink);
        sink_tty.outputLine(msg);
    }
}
