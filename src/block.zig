const std = @import("std");
const crypto = std.crypto;
const mem = std.mem;
const Sha256 = crypto.hash.sha2.Sha256;

pub const Block = struct {
    data: []const u8,
    hash: [hash_length]u8,
    prev_hash: ?[hash_length]u8,

    allocator: mem.Allocator,

    // Hash is a sha256 value, hex encoded (character size is 4 bits)
    pub const hash_length = 256 / 4;

    const Self = @This();

    pub fn init(data: []const u8, prev_hash: ?[hash_length]u8, allocator: mem.Allocator) !Block {
        var block = Block{
            .data = try allocator.dupe(u8, data),
            .hash = undefined,
            .prev_hash = prev_hash,
            .allocator = allocator,
        };

        try block.calculate_valid_hash();

        return block;
    }

    pub fn deinit(self: Self) void {
        self.allocator.free(self.data);
    }

    pub fn genesis(data: []const u8, allocator: mem.Allocator) !Block {
        return try Self.init(data, null, allocator);
    }

    pub fn is_genesis(self: Self) bool {
        if (self.prev_hash) |_| {
            return false;
        }

        return true;
    }

    fn valid_hash(hash: [hash_length]u8) bool {
        return mem.eql(u8, hash[0..4], "0000");
    }

    fn calculate_valid_hash(self: *Self) !void {
        var nonce: u64 = 0;

        while (true) {
            var hash = try self.calculate_hash(nonce);

            if (valid_hash(hash)) {
                for (hash) |v, i| {
                    self.hash[i] = v;
                }
                break;
            } else {
                nonce += 1;
            }
        }
    }

    pub fn calculate_hash(self: Self, nonce: u64) ![hash_length]u8 {
        var hash: [Sha256.digest_length]u8 = undefined;
        var hash_algo = Sha256.init(.{});

        var nonce_buf: [8]u8 = undefined;
        const nonce_str = try std.fmt.bufPrint(nonce_buf[0..], "{d}", .{nonce});

        hash_algo.update(self.data);

        if (self.prev_hash) |ph| {
            hash_algo.update(&ph);
        }

        hash_algo.update(nonce_str);
        hash_algo.final(hash[0..]);

        const encoded_hash = blk: {
            var buf: [hash_length]u8 = undefined;
            const hex_value = try std.fmt.bufPrint(buf[0..], "{x}", .{std.fmt.fmtSliceHexLower(hash[0..])});
            break :blk hex_value[0..hash_length].*;
        };

        return encoded_hash;
    }

    pub fn format(
        self: Self,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        if (self.is_genesis()) {
            try writer.print("=== Genesis Block\n", .{});
            try writer.print("  data: {s}\n", .{self.data});
            try writer.print("  hash: {s}\n", .{self.hash});
        } else {
            try writer.print("=== Block\n", .{});
            try writer.print("  data: {s}\n", .{self.data});
            try writer.print("  hash: {s}\n", .{self.hash});
            try writer.print("  prev_hash: {s}\n", .{self.prev_hash});
        }
    }
};
