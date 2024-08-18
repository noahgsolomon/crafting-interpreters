const std = @import("std");

const Node = struct {
    prev: ?*Node = null,
    next: ?*Node = null,
    value: []const u8,
};

const DLL = struct {
    head: ?*Node = null,
    tail: ?*Node = null,
    len: usize = 0,

    pub fn insert(self: *DLL, allocator: *std.mem.Allocator, value: []const u8) !void {
        const newNode = try allocator.create(Node);
        newNode.* = Node{
            .prev = self.tail,
            .next = self.head,
            .value = value,
        };

        if (self.tail) |tailNode| {
            tailNode.next = newNode;
        }
        self.tail = newNode;

        if (self.head == null) {
            self.head = newNode;
        }

        self.len += 1;

        std.debug.print("{d:*^20}\n", .{self.len});
        std.debug.print("added: {s}\n", .{value});
        if (newNode.prev) |prevNode| {
            std.debug.print("previous tail: {s}\n", .{prevNode.value});
        }
        std.debug.print("{s:*^20}\n\n", .{""});
    }

    pub fn delete(self: *DLL, value: []const u8, allocator: *std.mem.Allocator) void {
        if (self.len == 0) {
            return;
        }

        var node: ?*Node = self.head;

        while (node) |n| {
            if (std.ascii.eqlIgnoreCase(n.*.value, value)) {
                if (n.prev) |prev| {
                    prev.*.next = n.*.next;
                }
                if (n.next) |next| {
                    next.*.prev = n.*.prev;
                }
                allocator.destroy(n);
                self.len -= 1;
                return;
            }
            node = n.*.next;
        }
    }

    pub fn print(self: *DLL) void {
        if (self.len == 0) {
            std.debug.print("list is empty", .{});
            return;
        }

        var node: Node = self.head.?.*;

        for (self.len) |_| {
            if (std.ascii.eqlIgnoreCase(node.value, self.head.?.*.value)) {
                std.debug.print("=>{s}", .{node.value});
            } else if (std.ascii.eqlIgnoreCase(node.value, self.tail.?.*.value)) {
                std.debug.print("<=>{s}=>", .{node.value});
            } else {
                std.debug.print("<=>{s}", .{node.value});
            }
            node = node.next.?.*;
        }
        std.debug.print("\n", .{});
    }

    pub fn read(self: *DLL, index: usize) ?[]const u8 {
        var node: ?*Node = self.head;
        var curr_index: usize = 0;

        while (node) |n| {
            if (curr_index == index) {
                return n.*.value;
            }
            node = n.*.next;
            curr_index += 1;
        }
        return null;
    }

    pub fn deinit(self: *DLL, allocator: *std.mem.Allocator) void {
        if (self.len == 0) {
            return;
        }

        self.head.?.*.prev = null;
        self.tail.?.*.next = null;

        var node: ?*Node = self.head;

        while (node) |n| {
            const next_node = n.next;
            allocator.destroy(n);
            node = next_node;
        }

        self.head = null;
        self.tail = null;
        self.len = 0;
    }
};

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const strings = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven" };
    var list = DLL{};
    defer list.deinit(&allocator);

    for (strings) |string| {
        try list.insert(&allocator, string);
    }

    list.delete("three", &allocator);

    list.print();

    const index_two = list.read(2);

    std.debug.print("index two: {s}", .{index_two.?});
}
