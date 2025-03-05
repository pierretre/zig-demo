const std = @import("std");

pub const HttpResponse = struct {
    writer: std.io.AnyWriter,

    pub fn init(writer: std.io.AnyWriter) HttpResponse {
        return HttpResponse{ .writer = writer };
    }

    pub fn send200(self: *HttpResponse, content: []const u8) !void {
        try self.writer.writeAll("HTTP/1.1 200 OK\r\nContent-Length: ");
        try self.writer.print("{}\r\n\r\n", .{content.len});
        try self.writer.writeAll(content);
    }

    pub fn send404(self: *HttpResponse) !void {
        try self.writer.writeAll("HTTP/1.1 404 Not Found\r\nContent-Length: 13\r\n\r\n404 Not Found");
    }

    pub fn send405(self: *HttpResponse) !void {
        try self.writer.writeAll("TODO : 405 Method Not Allowed"); // TODO
    }

    pub fn send500(self: *HttpResponse) !void {
        try self.writer.writeAll("HTTP/1.1 500 Internal Server Error\r\nContent-Length: 21\r\n\r\nInternal Server Error");
    }
};
