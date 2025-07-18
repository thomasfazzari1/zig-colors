const std = @import("std");
const colors = @import("zig-colors");

pub fn main() !void {
    // Initialize with auto-detection
    colors.init();
    defer colors.deinit();

    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n{s}\n\n", .{"=== ZIG-COLORS DEMO ==="});

    // Basic colors
    try stdout.print("{s}\n", .{"Basic Colors:"});
    try stdout.print("  {}\n", .{colors.red.call("Red")});
    try stdout.print("  {}\n", .{colors.green.call("Green")});
    try stdout.print("  {}\n", .{colors.blue.call("Blue")});
    try stdout.print("  {}\n", .{colors.yellow.call("Yellow")});
    try stdout.print("  {}\n", .{colors.cyan.call("Cyan")});
    try stdout.print("  {}\n", .{colors.magenta.call("Magenta")});
    try stdout.print("  {}\n", .{colors.white.call("White")});
    try stdout.print("  {}\n", .{colors.black.bgWhite().call("Black (on white bg)")});

    // Bright colors
    try stdout.print("\n{s}\n", .{"Bright Colors:"});
    try stdout.print("  {}\n", .{colors.brightRed.call("Bright Red")});
    try stdout.print("  {}\n", .{colors.brightGreen.call("Bright Green")});
    try stdout.print("  {}\n", .{colors.brightBlue.call("Bright Blue")});
    try stdout.print("  {}\n", .{colors.brightYellow.call("Bright Yellow")});
    try stdout.print("  {}\n", .{colors.brightCyan.call("Bright Cyan")});
    try stdout.print("  {}\n", .{colors.brightMagenta.call("Bright Magenta")});
    try stdout.print("  {}\n", .{colors.brightWhite.bgBlack().call("Bright White on Black")});

    // Text styles
    try stdout.print("\n{s}\n", .{"Text Styles:"});
    try stdout.print("  {}\n", .{colors.bold.call("Bold text")});
    try stdout.print("  {}\n", .{colors.dim.call("Dim text")});
    try stdout.print("  {}\n", .{colors.italic.call("Italic text")});
    try stdout.print("  {}\n", .{colors.underline.call("Underlined text")});

    // Chained styles
    try stdout.print("\n{s}\n", .{"Chained Styles:"});
    try stdout.print("  {}\n", .{colors.red.bold().call("Bold red")});
    try stdout.print("  {}\n", .{colors.green.italic().underline().call("Italic underlined green")});
    try stdout.print("  {}\n", .{colors.blue.bold().dim().call("Bold dim blue")});
    try stdout.print("  {}\n", .{colors.brightMagenta.bold().italic().call("Bold italic bright magenta")});

    // Background colors
    try stdout.print("\n{s}\n", .{"Background Colors:"});
    try stdout.print("  {}\n", .{colors.white.bgRed().call("White on red")});
    try stdout.print("  {}\n", .{colors.black.bgGreen().call("Black on green")});
    try stdout.print("  {}\n", .{colors.white.bgBlue().call("White on blue")});
    try stdout.print("  {}\n", .{colors.bg.yellow().black().call("Black on yellow")});
    try stdout.print("  {}\n", .{colors.brightWhite.bgMagenta().call("Bright white on magenta")});

    // RGB colors (if supported)
    const level = colors.getLevel();
    if (colors.isSupported() and level == .truecolor) {
        try stdout.print("\n{s}\n", .{"RGB/Hex Colors (Truecolor mode):"});

        const style = colors.Style{};
        try stdout.print("  {}\n", .{style.rgb(255, 107, 107).call("Custom RGB (255, 107, 107)")});
        try stdout.print("  {}\n", .{style.hex("#FF6B6B").call("Hex color #FF6B6B")});
        try stdout.print("  {}\n", .{style.hex("#00CED1").call("Hex color #00CED1")});
        try stdout.print("  {}\n", .{style.rgb(147, 112, 219).bold().call("Bold purple RGB")});

        // RGB backgrounds
        try stdout.print("  {}\n", .{colors.white.bgRgb(50, 50, 50).call("White on dark gray RGB")});
        try stdout.print("  {}\n", .{colors.black.bgHex("#FFD700").call("Black on gold hex")});
    } else {
        try stdout.print("\n{s}\n", .{"(RGB/Hex colors not available - terminal doesn't support truecolor)"});
    }

    // Complex example
    try stdout.print("\n{s}\n", .{"Complex Example - Log Messages:"});

    const log_error = colors.red.bold();
    const log_warn = colors.yellow;
    const log_info = colors.blue;
    const log_success = colors.green.bold();

    try stdout.print("  {} {s}\n", .{ log_error.call("[ERROR]"), "Failed to connect to database" });
    try stdout.print("  {} {s}\n", .{ log_warn.call("[WARN]"), "Retrying connection..." });
    try stdout.print("  {} {s}\n", .{ log_info.call("[INFO]"), "Using fallback server" });
    try stdout.print("  {} {s}\n", .{ log_success.call("[SUCCESS]"), "Connection established!" });

    // Status indicators
    try stdout.print("\n{s}\n", .{"Status Indicators:"});
    try stdout.print("  {} {s}\n", .{ colors.green.call("✓"), "All tests passed" });
    try stdout.print("  {} {s}\n", .{ colors.red.call("✗"), "Build failed" });
    try stdout.print("  {} {s}\n", .{ colors.yellow.call("⚠"), "Warnings detected" });
    try stdout.print("  {} {s}\n", .{ colors.blue.call("ℹ"), "Information available" });

    // Color level info
    try stdout.print("\n{s}\n", .{"Terminal Information:"});
    try stdout.print("  Color support: {}\n", .{if (colors.isSupported()) colors.green.call("YES") else colors.red.call("NO")});
    try stdout.print("  Color level: {s}\n", .{switch (level) {
        .none => "None",
        .basic => "Basic (16 colors)",
        .ansi256 => "256 colors",
        .truecolor => "Truecolor (16M colors)",
    }});

    try stdout.print("\n", .{});
}
