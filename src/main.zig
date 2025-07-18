const std = @import("std");
const builtin = @import("builtin");
const io = std.io;
const process = std.process;

/// Color codes for terminal output
pub const Color = enum(u8) {
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,
    default = 39,

    // Bright variants
    bright_black = 90,
    bright_red = 91,
    bright_green = 92,
    bright_yellow = 93,
    bright_blue = 94,
    bright_magenta = 95,
    bright_cyan = 96,
    bright_white = 97,
};

/// Style codes for text formatting
pub const StyleCode = enum(u8) {
    reset = 0,
    bold = 1,
    dim = 2,
    italic = 3,
    underline = 4,
    blink = 5,
    reverse = 7,
    hidden = 8,
    strikethrough = 9,
};

/// Color support levels
pub const Level = enum(u2) {
    /// No colors
    none = 0,
    /// 16 colors
    basic = 1,
    /// 256 colors
    ansi256 = 2,
    /// 16M colors (RGB)
    truecolor = 3,
};

// Global state
var enabled: bool = true;
var color_level: Level = .basic;

/// RGB color value
pub const RGB = struct {
    r: u8,
    g: u8,
    b: u8,
};

/// Style builder for chaining color and formatting options
pub const Style = struct {
    fg: ?Color = null,
    bg: ?Color = null,
    fg_rgb: ?RGB = null,
    bg_rgb: ?RGB = null,
    bold_on: bool = false,
    dim_on: bool = false,
    italic_on: bool = false,
    underline_on: bool = false,

    // Foreground color methods
    pub fn black(self: Style) Style {
        return self.withFg(.black);
    }
    pub fn red(self: Style) Style {
        return self.withFg(.red);
    }
    pub fn green(self: Style) Style {
        return self.withFg(.green);
    }
    pub fn yellow(self: Style) Style {
        return self.withFg(.yellow);
    }
    pub fn blue(self: Style) Style {
        return self.withFg(.blue);
    }
    pub fn magenta(self: Style) Style {
        return self.withFg(.magenta);
    }
    pub fn cyan(self: Style) Style {
        return self.withFg(.cyan);
    }
    pub fn white(self: Style) Style {
        return self.withFg(.white);
    }

    // Bright foreground color methods
    pub fn brightBlack(self: Style) Style {
        return self.withFg(.bright_black);
    }
    pub fn brightRed(self: Style) Style {
        return self.withFg(.bright_red);
    }
    pub fn brightGreen(self: Style) Style {
        return self.withFg(.bright_green);
    }
    pub fn brightYellow(self: Style) Style {
        return self.withFg(.bright_yellow);
    }
    pub fn brightBlue(self: Style) Style {
        return self.withFg(.bright_blue);
    }
    pub fn brightMagenta(self: Style) Style {
        return self.withFg(.bright_magenta);
    }
    pub fn brightCyan(self: Style) Style {
        return self.withFg(.bright_cyan);
    }
    pub fn brightWhite(self: Style) Style {
        return self.withFg(.bright_white);
    }

    // Style methods
    pub fn bold(self: Style) Style {
        return self.withStyle(.{ .bold_on = true });
    }
    pub fn dim(self: Style) Style {
        return self.withStyle(.{ .dim_on = true });
    }
    pub fn italic(self: Style) Style {
        return self.withStyle(.{ .italic_on = true });
    }
    pub fn underline(self: Style) Style {
        return self.withStyle(.{ .underline_on = true });
    }

    /// Set custom RGB foreground color (requires truecolor support)
    pub fn rgb(self: Style, r: u8, g: u8, b: u8) Style {
        var s = self;
        s.fg = null;
        s.fg_rgb = RGB{ .r = r, .g = g, .b = b };
        return s;
    }

    /// Set custom hex foreground color (requires truecolor support)
    /// Example: style.hex("#FF6B6B")
    pub fn hex(self: Style, hex_str: []const u8) Style {
        const rgb_val = parseHex(hex_str) catch return self;
        return self.rgb(rgb_val.r, rgb_val.g, rgb_val.b);
    }

    /// Access background color methods
    pub const Bg = BgStyle{};

    /// Apply style to text and return a formattable struct
    pub fn call(self: Style, text: []const u8) StyledText {
        return StyledText{ .style = self, .text = text };
    }

    // Background color methods
    pub fn bgBlack(self: Style) Style {
        return self.withBg(.black);
    }
    pub fn bgRed(self: Style) Style {
        return self.withBg(.red);
    }
    pub fn bgGreen(self: Style) Style {
        return self.withBg(.green);
    }
    pub fn bgYellow(self: Style) Style {
        return self.withBg(.yellow);
    }
    pub fn bgBlue(self: Style) Style {
        return self.withBg(.blue);
    }
    pub fn bgMagenta(self: Style) Style {
        return self.withBg(.magenta);
    }
    pub fn bgCyan(self: Style) Style {
        return self.withBg(.cyan);
    }
    pub fn bgWhite(self: Style) Style {
        return self.withBg(.white);
    }

    /// Set custom RGB background color
    pub fn bgRgb(self: Style, r: u8, g: u8, b: u8) Style {
        var s = self;
        s.bg = null;
        s.bg_rgb = RGB{ .r = r, .g = g, .b = b };
        return s;
    }

    /// Set custom hex background color
    pub fn bgHex(self: Style, hex_str: []const u8) Style {
        const rgb_val = parseHex(hex_str) catch return self;
        return self.bgRgb(rgb_val.r, rgb_val.g, rgb_val.b);
    }

    // Helper methods to reduce duplication
    fn withFg(self: Style, color: Color) Style {
        var s = self;
        s.fg = color;
        s.fg_rgb = null;
        return s;
    }

    fn withBg(self: Style, color: Color) Style {
        var s = self;
        s.bg = color;
        s.bg_rgb = null;
        return s;
    }

    fn withStyle(self: Style, updates: struct {
        bold_on: ?bool = null,
        dim_on: ?bool = null,
        italic_on: ?bool = null,
        underline_on: ?bool = null,
    }) Style {
        var s = self;
        if (updates.bold_on) |v| s.bold_on = v;
        if (updates.dim_on) |v| s.dim_on = v;
        if (updates.italic_on) |v| s.italic_on = v;
        if (updates.underline_on) |v| s.underline_on = v;
        return s;
    }
};

/// Background color style builder
pub const BgStyle = struct {
    pub fn black(self: BgStyle) Style {
        _ = self;
        return Style{ .bg = .black };
    }
    pub fn red(self: BgStyle) Style {
        _ = self;
        return Style{ .bg = .red };
    }
    pub fn green(self: BgStyle) Style {
        _ = self;
        return Style{ .bg = .green };
    }
    pub fn yellow(self: BgStyle) Style {
        _ = self;
        return Style{ .bg = .yellow };
    }
    pub fn blue(self: BgStyle) Style {
        _ = self;
        return Style{ .bg = .blue };
    }
    pub fn magenta(self: BgStyle) Style {
        _ = self;
        return Style{ .bg = .magenta };
    }
    pub fn cyan(self: BgStyle) Style {
        _ = self;
        return Style{ .bg = .cyan };
    }
    pub fn white(self: BgStyle) Style {
        _ = self;
        return Style{ .bg = .white };
    }

    /// Set custom RGB background color
    pub fn rgb(self: BgStyle, r: u8, g: u8, b: u8) Style {
        _ = self;
        return Style{ .bg_rgb = RGB{ .r = r, .g = g, .b = b } };
    }

    /// Set custom hex background color
    pub fn hex(self: BgStyle, hex_str: []const u8) Style {
        const rgb_val = parseHex(hex_str) catch return Style{};
        return self.rgb(rgb_val.r, rgb_val.g, rgb_val.b);
    }
};

/// Styled text that can be formatted
pub const StyledText = struct {
    style: Style,
    text: []const u8,

    pub fn format(self: StyledText, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        if (!enabled or color_level == .none) {
            try writer.writeAll(self.text);
            return;
        }

        // Write ANSI escape sequence
        try writer.writeAll("\x1b[");

        var first = true;

        // Text styles
        if (self.style.bold_on) {
            try self.writeCode(writer, "1", &first);
        }
        if (self.style.dim_on) {
            try self.writeCode(writer, "2", &first);
        }
        if (self.style.italic_on) {
            try self.writeCode(writer, "3", &first);
        }
        if (self.style.underline_on) {
            try self.writeCode(writer, "4", &first);
        }

        // Foreground color
        if (self.style.fg_rgb) |rgb| {
            if (color_level == .truecolor) {
                if (!first) try writer.writeAll(";");
                try std.fmt.format(writer, "38;2;{d};{d};{d}", .{ rgb.r, rgb.g, rgb.b });
                first = false;
            }
        } else if (self.style.fg) |fg| {
            if (!first) try writer.writeAll(";");
            try std.fmt.format(writer, "{d}", .{@intFromEnum(fg)});
            first = false;
        }

        // Background color
        if (self.style.bg_rgb) |rgb| {
            if (color_level == .truecolor) {
                if (!first) try writer.writeAll(";");
                try std.fmt.format(writer, "48;2;{d};{d};{d}", .{ rgb.r, rgb.g, rgb.b });
                first = false;
            }
        } else if (self.style.bg) |background| {
            if (!first) try writer.writeAll(";");
            try std.fmt.format(writer, "{d}", .{@intFromEnum(background) + 10});
            first = false;
        }

        try writer.writeAll("m");
        try writer.writeAll(self.text);
        try writer.writeAll("\x1b[0m");
    }

    fn writeCode(self: StyledText, writer: anytype, code: []const u8, first: *bool) !void {
        _ = self;
        if (!first.*) try writer.writeAll(";");
        try writer.writeAll(code);
        first.* = false;
    }
};

// Pre-defined color styles
pub const black = Style{ .fg = .black };
pub const red = Style{ .fg = .red };
pub const green = Style{ .fg = .green };
pub const yellow = Style{ .fg = .yellow };
pub const blue = Style{ .fg = .blue };
pub const magenta = Style{ .fg = .magenta };
pub const cyan = Style{ .fg = .cyan };
pub const white = Style{ .fg = .white };

// Pre-defined bright color styles
pub const brightBlack = Style{ .fg = .bright_black };
pub const brightRed = Style{ .fg = .bright_red };
pub const brightGreen = Style{ .fg = .bright_green };
pub const brightYellow = Style{ .fg = .bright_yellow };
pub const brightBlue = Style{ .fg = .bright_blue };
pub const brightMagenta = Style{ .fg = .bright_magenta };
pub const brightCyan = Style{ .fg = .bright_cyan };
pub const brightWhite = Style{ .fg = .bright_white };

// Pre-defined text styles
pub const bold = Style{ .bold_on = true };
pub const dim = Style{ .dim_on = true };
pub const italic = Style{ .italic_on = true };
pub const underline = Style{ .underline_on = true };

// Background colors namespace
pub const bg = Style.Bg;

/// Initialize color support detection
pub fn init() void {
    enabled = detectColorSupport();
    color_level = detectColorLevel();
}

/// Reset all styles and cleanup
pub fn deinit() void {
    _ = io.getStdOut().write("\x1b[0m") catch {};
}

/// Check if colors are supported in current environment
pub fn isSupported() bool {
    return enabled and color_level != .none;
}

/// Get current color support level
pub fn getLevel() Level {
    return color_level;
}

/// Manually set color support level
pub fn setLevel(level: Level) void {
    color_level = level;
}

/// Enable or disable color output
pub fn setEnabled(enable: bool) void {
    enabled = enable;
}

fn detectColorSupport() bool {
    if (builtin.os.tag == .windows) {
        // Windows 10+ supports ANSI by default
        return true;
    }

    return io.getStdOut().isTty();
}

fn detectColorLevel() Level {
    const allocator = std.heap.page_allocator;

    // Check NO_COLOR env var
    if (process.getEnvVarOwned(allocator, "NO_COLOR")) |_| {
        return .none;
    } else |_| {}

    // Check COLORTERM for truecolor
    if (process.getEnvVarOwned(allocator, "COLORTERM")) |colorterm| {
        defer allocator.free(colorterm);
        if (std.mem.eql(u8, colorterm, "truecolor") or std.mem.eql(u8, colorterm, "24bit")) {
            return .truecolor;
        }
    } else |_| {}

    // Check TERM env var
    if (process.getEnvVarOwned(allocator, "TERM")) |term| {
        defer allocator.free(term);

        if (std.mem.indexOf(u8, term, "256color") != null) return .ansi256;
        if (std.mem.indexOf(u8, term, "truecolor") != null) return .truecolor;
        if (std.mem.eql(u8, term, "dumb")) return .none;
    } else |_| {}

    return .basic;
}

/// Parse hex color string to RGB
fn parseHex(hex: []const u8) !RGB {
    var clean_hex = hex;

    // Skip # if present
    if (clean_hex.len > 0 and clean_hex[0] == '#') {
        clean_hex = clean_hex[1..];
    }

    if (clean_hex.len != 6) return error.InvalidHexColor;

    const r = try std.fmt.parseInt(u8, clean_hex[0..2], 16);
    const g = try std.fmt.parseInt(u8, clean_hex[2..4], 16);
    const b = try std.fmt.parseInt(u8, clean_hex[4..6], 16);

    return RGB{ .r = r, .g = g, .b = b };
}

/// Print with color and formatting
pub fn print(style: anytype, comptime fmt: []const u8, args: anytype) !void {
    const stdout = io.getStdOut().writer();

    if (@TypeOf(style) == Color) {
        const s = Style{ .fg = style };
        try stdout.print("{}", .{s.call(std.fmt.comptimePrint(fmt, args))});
    } else if (@TypeOf(style) == Style) {
        try stdout.print("{}", .{style.call(std.fmt.comptimePrint(fmt, args))});
    }
}

/// Remove ANSI escape codes from text
pub fn strip(text: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var result = std.ArrayList(u8).init(allocator);
    errdefer result.deinit();

    var i: usize = 0;
    while (i < text.len) {
        if (i + 1 < text.len and text[i] == '\x1b' and text[i + 1] == '[') {
            i += 2;
            while (i < text.len and text[i] != 'm') : (i += 1) {}
            if (i < text.len) i += 1;
        } else {
            try result.append(text[i]);
            i += 1;
        }
    }

    return result.toOwnedSlice();
}
