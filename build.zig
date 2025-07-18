const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Expose module
    const mod = b.addModule("zig-colors", .{
        .root_source_file = b.path("src/main.zig"),
    });

    // Tests
    const tests = b.addTest(.{
        .root_source_file = b.path("tests/tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    tests.root_module.addImport("zig-colors", mod);

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_tests.step);

    // Demo executable
    const demo_test = b.addExecutable(.{
        .name = "demo",
        .root_source_file = b.path("tests/demo.zig"),
        .target = target,
        .optimize = optimize,
    });
    demo_test.root_module.addImport("zig-colors", mod);

    const run_demo = b.addRunArtifact(demo_test);
    const demo_step = b.step("demo", "Run demo test to see actual behavior in terminal");
    demo_step.dependOn(&run_demo.step);

    // Documentation
    const docs = b.addStaticLibrary(.{
        .name = "zig-colors",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const docs_step = b.step("docs", "Generate documentation");
    const install_docs = b.addInstallDirectory(.{
        .source_dir = docs.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    docs_step.dependOn(&install_docs.step);
}
