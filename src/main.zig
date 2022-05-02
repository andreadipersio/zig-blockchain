const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const io = std.io;

const Blockchain = @import("blockchain.zig").Blockchain;

const Command = union(enum) {
    quit: void,
    list: void,
    last: void,
    get: usize,
    new: []const u8,

    fn execute(self: Command, blockchain: *Blockchain, writer: anytype) !void {
        _ = switch (self) {
            Command.quit => std.process.exit(0),

            Command.new => |data| {
                try writer.print("{s}", .{blockchain.new_block(data)});
            },

            Command.list => {
                for (blockchain.blocks.items) |block, i| {
                    try writer.print("Index: {d}\n{s}\n", .{ i, block });
                }
            },

            Command.last => {
                try writer.print("{s}", .{blockchain.get_last_block()});
            },

            Command.get => |index| {
                if (index >= blockchain.blocks.items.len) {
                    try writer.print("error: index out of range!\n", .{});
                    return;
                }

                try writer.print("{s}", .{blockchain.blocks.items[index]});
            },
        };
    }
};

const input_bufsize = 128;

pub fn print_help(writer: anytype) !void {
    try writer.print(
        \\Commands:
        \\  list       - list all the blocks
        \\  new <data> - store data in a new block
        \\  last       - get the last block
        \\  get <i>    - get block at index i, starting from 0.
        \\  quit       - quit
        \\  ?          - this message
        \\
        \\
    , .{});
}

fn parse_command(user_input: []const u8, _: anytype) !?Command {
    {
        const command = "quit";

        if (mem.eql(u8, user_input, command)) {
            return Command.quit;
        }
    }

    {
        const command = "list";

        if (mem.eql(u8, user_input, command)) {
            return Command.list;
        }
    }

    {
        const command = "last";

        if (mem.eql(u8, user_input, command)) {
            return Command.last;
        }
    }

    {
        const command = "new";

        if (mem.startsWith(u8, user_input, command)) {
            const argument = mem.trimLeft(u8, user_input[command.len..user_input.len], " ");

            return Command{ .new = argument };
        }
    }

    {
        const command = "get";

        if (mem.startsWith(u8, user_input, command)) {
            const argument = mem.trimLeft(u8, user_input[command.len..user_input.len], " ");

            return Command{ .get = try std.fmt.parseInt(usize, argument, 10) };
        }
    }

    return null;
}

pub fn main() anyerror!void {
    const stdin = io.getStdIn().reader();
    const stdout = io.getStdOut().writer();

    var arena = heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var blockchain = try Blockchain.init(arena.allocator());

    try stdout.print(
        \\==================
        \\= Zig Blockchain =
        \\==================
        \\
    , .{});

    try print_help(stdout);

    while (true) {
        try stdout.print("> ", .{});

        var buf: [input_bufsize]u8 = undefined;

        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
            const command = try parse_command(mem.trimRight(u8, user_input, "\r"), stdout);

            if (command) |cmd| {
                try cmd.execute(&blockchain, stdout);
            } else {
                try print_help(stdout);
            }
        } else {}
    }
}
