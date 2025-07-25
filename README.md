<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/assets/zig-colors-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset=".github/assets/zig-colors-light.svg">
    <img alt="zig-colors" src=".github/assets/zig-colors-light.svg" width="600">
  </picture>

[![CI](https://github.com/thomasfazzari1/zig-colors/workflows/CI/badge.svg)](https://github.com/thomasfazzari1/zig-colors/actions)
[![Zig 0.13.0](https://img.shields.io/badge/zig-0.13.0-orange.svg)](https://ziglang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

## Features

- **Full color support** - 16 colors, 256 colors, and RGB/Hex (16M colors)
- **Chainable API** - Intuitive and composable: `red.bold().underline()`
- **Zero dependencies** - Pure Zig implementation
- **Auto-detection** - Automatically detects terminal capabilities
- **Cross-platform** - Works on Windows, macOS, and Linux
- **Extensive styling** - Bold, dim, italic, underline, and more

## Installation

Add `zig-colors` to your `build.zig.zon`:

```zig
.{
    .name = "my-project",
    .version = "0.1.0",
    .dependencies = .{
        .@"zig-colors" = .{
            .url = "https://github.com/thomasfazzari1/zig-colors/archive/refs/tags/v0.1.0.tar.gz",
            .hash = "1220331bffdeca5488ee0a3a73f9c274f9856b63006d22b7fa2b810eb8a3fb9db867",
        },
    },
}
```

Then in your build.zig:

```zig
zigconst colors_dep = b.dependency("zig-colors", .{});
exe.root_module.addImport("zig-colors", colors_dep.module("zig-colors"));
```

## Quick Start

```zig
const std = @import("std");
const colors = @import("zig-colors");

pub fn main() !void {
    // Initialize color support detection
    colors.init();
    defer colors.deinit();

    // Simple colors
    std.debug.print("{}\n", .{colors.red.call("Error!")});
    std.debug.print("{}\n", .{colors.green.bold().call("Success!")});

    // Background colors
    std.debug.print("{}\n", .{colors.white.bgBlue().call("Info")});

    // RGB/Hex colors (if terminal supports it)
    const style = colors.Style{};
    std.debug.print("{}\n", .{style.hex("#FF6B6B").bold().call("Custom color!")});
}
```

## Usage Examples

### Basic Colors

```zig
// Foreground colors
colors.red.call("Red text")
colors.green.call("Green text")
colors.blue.call("Blue text")
colors.yellow.call("Yellow text")
colors.magenta.call("Magenta text")
colors.cyan.call("Cyan text")
colors.white.call("White text")
colors.black.call("Black text")

// Bright variants
colors.brightRed.call("Bright red")
colors.brightGreen.call("Bright green")
// ... and more
```

### Text Styles

```zig
colors.bold.call("Bold text")
colors.dim.call("Dim text")
colors.italic.call("Italic text")
colors.underline.call("Underlined text")
```

### Styles Chaining

```zig
// Combine multiple styles
colors.red.bold().underline().call("Important error!")
colors.green.italic().call("Emphasized success")
colors.yellow.dim().call("Subtle warning")

// Complex combinations
colors.white.bgRed().bold().call("Alert!")
colors.brightBlue.bgBlack().underline().call("Highlighted")
```

### Background Colors

```zig
// Using background methods
colors.white.bgRed().call("White on red")
colors.black.bgGreen().call("Black on green")

// Using the bg namespace
colors.bg.yellow().black().call("Black on yellow")
colors.bg.blue().white().bold().call("Bold white on blue")
```

### RGB & Hex Colors

```zig
// RGB colors (requires truecolor terminal support)
const style = colors.Style{};
style.rgb(255, 107, 107).call("Custom RGB")
style.rgb(100, 200, 255).bold().call("Bold custom blue")

// Hex colors
style.hex("#FF6B6B").call("Hex color")
style.hex("#00CED1").underline().call("Underlined hex")

// RGB backgrounds
colors.white.bgRgb(50, 50, 50).call("White on dark gray")
colors.black.bgHex("#FFD700").call("Black on gold")
```

### Conditional Styling

```zig
// Only style if colors are supported
if (colors.isSupported()) {
    std.debug.print("{}\n", .{colors.green.call("✓ Colors supported!")});
} else {
    std.debug.print("Colors not supported\n", .{});
}

// Check color level
const level = colors.getLevel();
if (level == .truecolor) {
    // Use RGB colors
    const style = colors.Style{};
    std.debug.print("{}\n", .{style.hex("#FF6B6B").call("Truecolor!")});
}
```

### Building a Logger

```zig
const Logger = struct {
    const err = colors.red.bold();
    const warn = colors.yellow;
    const info = colors.blue;
    const success = colors.green.bold();

    pub fn logError(msg: []const u8) void {
        std.debug.print("{} {s}\n", .{err.call("ERROR:"), msg});
    }

    pub fn logWarn(msg: []const u8) void {
        std.debug.print("{} {s}\n", .{warn.call("WARN:"), msg});
    }

    pub fn logInfo(msg: []const u8) void {
        std.debug.print("{} {s}\n", .{info.call("INFO:"), msg});
    }

    pub fn logSuccess(msg: []const u8) void {
        std.debug.print("{} {s}\n", .{success.call("SUCCESS:"), msg});
    }
};
```

## API Reference

For complete API documentation, visit the **[full documentation](https://thomasfazzari1.github.io/zig-colors-docs/)**.

## Testing

The library includes comprehensive tests:

```bash
# Run unit tests
zig build test

# Run visual demo
zig build demo
```

## License

This project is licensed under the Apache License 2.0 - See [LICENSE](LICENSE) for details.
