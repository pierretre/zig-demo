const std = @import("std");

pub const HttpResponse = struct {
    writer: std.io.AnyWriter,

    pub fn init(writer: std.io.AnyWriter) HttpResponse {
        return HttpResponse{ .writer = writer };
    }

    pub fn send200(self: *HttpResponse, content: []u8, return_headers: *std.ArrayList([]const u8)) !void {
        try self.print("200 OK", return_headers, content);
    }

    pub fn sendLarge200(self: *HttpResponse, return_headers: *std.ArrayList([]const u8)) !HttpResponseWriter {
        try self.send200("", return_headers);
        return HttpResponseWriter.init(self.writer);
    }

    pub fn send404(self: *HttpResponse, return_headers: *std.ArrayList([]const u8)) !void {
        try self.print("404 Not Found", return_headers, "");
    }

    pub fn send405(self: *HttpResponse, return_headers: *std.ArrayList([]const u8)) !void {
        try self.print("405 Method Not Allowed", return_headers, "");
    }

    pub fn send413(self: *HttpResponse, return_headers: *std.ArrayList([]const u8)) !void {
        try self.print("413 Entity Too Large", return_headers, "");
    }

    pub fn send500(self: *HttpResponse, return_headers: *std.ArrayList([]const u8)) !void {
        try self.print("500 Internal Server Error", return_headers, "");
    }

    fn print(self: *HttpResponse, code: []const u8, return_headers: *std.ArrayList([]const u8), content: []const u8) !void {
        try self.writer.print("HTTP/1.1 {s}\r\n", .{code});
        for (return_headers.items) |header| {
            try self.writer.print("{s}\r\n", .{header});
        }
        try self.writer.print("\r\n{s}", .{content});
    }
};

pub const HttpResponseWriter = struct {
    writer: std.io.AnyWriter,

    pub fn init(writer: std.io.AnyWriter) HttpResponseWriter {
        return HttpResponseWriter{ .writer = writer };
    }

    pub fn write(self: *HttpResponseWriter, content: []const u8) !void {
        try self.writer.print("{s}", .{content});
    }
};
