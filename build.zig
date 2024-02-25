const std = @import("std");
const builtin = @import("builtin");

const ArrayList = std.ArrayList;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zycore = b.addStaticLibrary(.{
        .name = "zycore",
        .target = target,
        .optimize = optimize,
    });
    zycore.want_lto = false;
    if (optimize == .Debug or optimize == .ReleaseSafe)
        zycore.bundle_compiler_rt = true;

    zycore.linkLibC();
    zycore.addIncludePath(.{ .path = "include" });
    zycore.addIncludePath(.{ .path = "src" });

    var zycore_flags = ArrayList([]const u8).init(b.allocator);
    var zycore_sources = ArrayList([]const u8).init(b.allocator);
    defer zycore_flags.deinit();
    defer zycore_sources.deinit();

    try zycore_flags.append("-DZYCORE_STATIC_BUILD=1");
    try zycore_sources.append("src/API/Memory.c");
    try zycore_sources.append("src/API/Process.c");
    try zycore_sources.append("src/API/Synchronization.c");
    try zycore_sources.append("src/API/Terminal.c");
    try zycore_sources.append("src/API/Thread.c");
    try zycore_sources.append("src/Allocator.c");
    try zycore_sources.append("src/ArgParse.c");
    try zycore_sources.append("src/Bitset.c");
    try zycore_sources.append("src/Format.c");
    try zycore_sources.append("src/List.c");
    try zycore_sources.append("src/String.c");
    try zycore_sources.append("src/Vector.c");
    try zycore_sources.append("src/Zycore.c");
    zycore.addCSourceFiles(.{ .files = zycore_sources.items, .flags = zycore_flags.items });

    zycore.installHeadersDirectory("include/Zycore", "Zycore");

    b.installArtifact(zycore);
}
