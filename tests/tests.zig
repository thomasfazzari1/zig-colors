const std = @import("std");
const testing = std.testing;
const colors = @import("zig-colors");

// Setup test environment to ensure consistent behavior
fn setupTestEnvironment() void {
    colors.init();
    colors.setEnabled(true);
    colors.setLevel(.basic);
}

test "basic colors exist" {
    setupTestEnvironment();

    // Verify all basic colors are accessible
    _ = colors.red;
    _ = colors.green;
    _ = colors.blue;
    _ = colors.yellow;
    _ = colors.cyan;
    _ = colors.magenta;
    _ = colors.white;
    _ = colors.black;
}

test "bright colors exist" {
    setupTestEnvironment();

    // Verify all bright colors are accessible
    _ = colors.brightRed;
    _ = colors.brightGreen;
    _ = colors.brightBlue;
    _ = colors.brightYellow;
    _ = colors.brightCyan;
    _ = colors.brightMagenta;
    _ = colors.brightWhite;
    _ = colors.brightBlack;
}

test "style chaining" {
    setupTestEnvironment();

    // Test method chaining
    const styled = colors.red.bold().underline();
    try testing.expect(styled.fg == .red);
    try testing.expect(styled.bold_on == true);
    try testing.expect(styled.underline_on == true);
    try testing.expect(styled.dim_on == false);
    try testing.expect(styled.italic_on == false);
}

test "bright colors chaining" {
    setupTestEnvironment();

    // Test bright colors with styles
    const bright = colors.brightRed.bold();
    try testing.expect(bright.fg == .bright_red);
    try testing.expect(bright.bold_on == true);

    // Test method chaining
    const bright_styled = colors.brightWhite.bgRed();
    try testing.expect(bright_styled.fg == .bright_white);
    try testing.expect(bright_styled.bg == .red);
}

test "background colors via namespace" {
    setupTestEnvironment();

    const bg_yellow = colors.bg.yellow();
    try testing.expect(bg_yellow.bg == .yellow);
    try testing.expect(bg_yellow.fg == null);

    // Chaining with foreground
    const complex = colors.bg.blue().white();
    try testing.expect(complex.bg == .blue);
    try testing.expect(complex.fg == .white);
}

test "background colors via methods" {
    setupTestEnvironment();

    const white_on_blue = colors.white.bgBlue();
    try testing.expect(white_on_blue.fg == .white);
    try testing.expect(white_on_blue.bg == .blue);

    // Test all background methods
    const red_on_green = colors.red.bgGreen();
    try testing.expect(red_on_green.fg == .red);
    try testing.expect(red_on_green.bg == .green);
}

test "rgb colors" {
    setupTestEnvironment();
    colors.setLevel(.truecolor);

    const style = colors.Style{};
    const custom = style.rgb(255, 107, 107);
    try testing.expect(custom.fg_rgb != null);
    try testing.expect(custom.fg_rgb.?.r == 255);
    try testing.expect(custom.fg_rgb.?.g == 107);
    try testing.expect(custom.fg_rgb.?.b == 107);
}

test "hex color parsing" {
    setupTestEnvironment();
    colors.setLevel(.truecolor);

    // With hash prefix
    const style1 = colors.Style{};
    const with_hash = style1.hex("#FF6B6B");
    try testing.expect(with_hash.fg_rgb != null);
    try testing.expect(with_hash.fg_rgb.?.r == 255);
    try testing.expect(with_hash.fg_rgb.?.g == 107);
    try testing.expect(with_hash.fg_rgb.?.b == 107);

    // Without hash prefix
    const style2 = colors.Style{};
    const without_hash = style2.hex("FF6B6B");
    try testing.expect(without_hash.fg_rgb != null);
    try testing.expect(without_hash.fg_rgb.?.r == 255);
}

test "invalid hex color" {
    setupTestEnvironment();

    // Invalid hex should return unchanged style
    const style1 = colors.Style{};
    const invalid = style1.hex("GGGGGG");
    try testing.expect(invalid.fg_rgb == null);

    const style2 = colors.Style{};
    const too_short = style2.hex("#FFF");
    try testing.expect(too_short.fg_rgb == null);
}

test "background rgb and hex" {
    setupTestEnvironment();
    colors.setLevel(.truecolor);

    // Test RGB background
    const rgb_bg = colors.white.bgRgb(100, 150, 200);
    try testing.expect(rgb_bg.bg_rgb != null);
    try testing.expect(rgb_bg.bg_rgb.?.r == 100);
    try testing.expect(rgb_bg.bg_rgb.?.g == 150);
    try testing.expect(rgb_bg.bg_rgb.?.b == 200);

    // Test hex background
    const hex_bg = colors.black.bgHex("#FF00FF");
    try testing.expect(hex_bg.bg_rgb != null);
    try testing.expect(hex_bg.bg_rgb.?.r == 255);
    try testing.expect(hex_bg.bg_rgb.?.g == 0);
    try testing.expect(hex_bg.bg_rgb.?.b == 255);
}

test "strip ANSI codes" {
    setupTestEnvironment();

    const colored = "\x1b[31mRed Text\x1b[0m";
    const clean = try colors.strip(colored, testing.allocator);
    defer testing.allocator.free(clean);

    try testing.expectEqualStrings("Red Text", clean);
}

test "strip complex ANSI codes" {
    setupTestEnvironment();

    const complex = "\x1b[1;31;43mBold Red on Yellow\x1b[0m";
    const clean = try colors.strip(complex, testing.allocator);
    defer testing.allocator.free(clean);

    try testing.expectEqualStrings("Bold Red on Yellow", clean);
}

test "formatting with StyledText" {
    setupTestEnvironment();

    const red_text = try std.fmt.allocPrint(testing.allocator, "{}", .{colors.red.call("Error!")});
    defer testing.allocator.free(red_text);

    // Verify ANSI codes are present
    try testing.expect(std.mem.indexOf(u8, red_text, "\x1b[") != null);
    try testing.expect(std.mem.indexOf(u8, red_text, "31m") != null); // Red color code
    try testing.expect(std.mem.indexOf(u8, red_text, "Error!") != null);
    try testing.expect(std.mem.indexOf(u8, red_text, "\x1b[0m") != null); // Reset code
}

test "color support detection" {
    colors.init(); // Don't force enable for this test

    // Verify functions exist and return correct types
    const supported = colors.isSupported();
    try testing.expect(@TypeOf(supported) == bool);

    const level = colors.getLevel();
    try testing.expect(@TypeOf(level) == colors.Level);
}

test "manual enable/disable" {
    colors.init();

    // Test disabling colors
    colors.setEnabled(false);
    const disabled_text = try std.fmt.allocPrint(testing.allocator, "{}", .{colors.red.call("Test")});
    defer testing.allocator.free(disabled_text);
    try testing.expectEqualStrings("Test", disabled_text);

    // Test re-enabling colors
    colors.setEnabled(true);
    const enabled_text = try std.fmt.allocPrint(testing.allocator, "{}", .{colors.red.call("Test")});
    defer testing.allocator.free(enabled_text);
    try testing.expect(std.mem.indexOf(u8, enabled_text, "\x1b[") != null);
}

test "all style combinations" {
    setupTestEnvironment();

    const all_styles = colors.red.bold().dim().italic().underline();
    try testing.expect(all_styles.fg == .red);
    try testing.expect(all_styles.bold_on == true);
    try testing.expect(all_styles.dim_on == true);
    try testing.expect(all_styles.italic_on == true);
    try testing.expect(all_styles.underline_on == true);
}

test "complex real-world usage" {
    setupTestEnvironment();

    // Simulate a logger
    const log = struct {
        const error_style = colors.red.bold();
        const warn_style = colors.yellow;
        const info_style = colors.blue;
        const debug_style = colors.dim;

        pub fn err(msg: []const u8) ![]u8 {
            return try std.fmt.allocPrint(testing.allocator, "{} {s}", .{ error_style.call("ERROR:"), msg });
        }
    };

    const output = try log.err("Something went wrong");
    defer testing.allocator.free(output);

    try testing.expect(std.mem.indexOf(u8, output, "ERROR:") != null);
    try testing.expect(std.mem.indexOf(u8, output, "Something went wrong") != null);
}
