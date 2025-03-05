const std = @import("std");

pub const HttpResponse = struct {
    writer: std.io.AnyWriter,

    pub fn init(writer: std.io.AnyWriter) HttpResponse {
        return HttpResponse{ .writer = writer };
    }

    pub fn send200(self: *HttpResponse, content: []u8, size: usize) !void {
        try self.writer.print("HTTP/1.1 200 OK\r\nContent-Length: {d}\r\n\r\n{s}", .{ size, content });
    }

    pub fn send404(self: *HttpResponse) !void {
        try self.writer.writeAll("HTTP/1.1 404 Not Found\r\nContent-Length: 13\r\n\r\n404 Not Found");
    }

    pub fn send405(self: *HttpResponse) !void {
        try self.writer.writeAll("HTTP/1.1 405 Method Not Allowed\r\nContent-Type: text/plain\r\nContent-Length: 28\r\n\r\n405 Method Not Allowed");
    }

    pub fn send413(self: *HttpResponse) !void {
        try self.writer.writeAll("HTTP/1.1 413 Entity Too Large\r\nContent-Type: text/plain\r\nContent-Length: 30\r\n\r\n413 Entity Too Large");
    }

    pub fn send500(self: *HttpResponse) !void {
        try self.writer.writeAll("HTTP/1.1 500 Internal Server Error\r\nContent-Length: 21\r\n\r\nInternal Server Error");
    }
};
