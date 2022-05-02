const std = @import("std");
const mem = std.mem;
const testing = std.testing;
const ArrayList = std.ArrayList;

const Block = @import("block.zig").Block;

pub const Blockchain = struct {
    blocks: ArrayList(Block),
    allocator: mem.Allocator,

    const Self = @This();

    pub fn init(allocator: mem.Allocator) !Blockchain {
        const blocks = ArrayList(Block);

        var blockchain = Blockchain{
            .blocks = blocks.init(allocator),
            .allocator = allocator,
        };

        try blockchain.set_genesis_block();

        return blockchain;
    }

    pub fn deinit(self: Self) void {
        for (self.blocks.items) |block| {
            block.deinit();
        }
        self.blocks.deinit();
    }

    fn set_genesis_block(self: *Self) !void {
        const block = try Block.genesis("Genesis", self.allocator);

        try self.blocks.append(block);
    }

    pub fn get_last_block(self: Self) Block {
        const items = self.blocks.items;

        return items[items.len - 1];
    }

    pub fn new_block(self: *Self, data: []const u8) !Block {
        const last_block = self.get_last_block();
        const block = try Block.init(data, last_block.hash, self.allocator);

        try self.blocks.append(block);

        return block;
    }
};

test "it creates a blockchain genesis block" {
    var blockchain = try Blockchain.init(testing.allocator);
    defer blockchain.deinit();

    const last_block = blockchain.get_last_block();

    try testing.expect(mem.eql(u8, last_block.data, "Genesis"));
}

test "it appends a block to the blockchain" {
    var blockchain = try Blockchain.init(testing.allocator);
    defer blockchain.deinit();

    {
        const new_block = try blockchain.new_block("foo");

        try testing.expect(mem.eql(u8, new_block.data, "foo"));
    }
}
