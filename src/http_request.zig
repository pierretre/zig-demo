const std = @import("std");
const constants = @import("constants.zig");
const HttpError = @import("errors.zig").HttpError;
const ArrayList = std.ArrayList;

const HttpMethod = enum {
    GET,
    HEAD,
    POST,
    PUT,
    DELETE,
    CONNECT,
    OPTIONS,
    TRACE,
    PATCH,

    pub fn fromString(method: []const u8) !HttpMethod {
        return std.meta.stringToEnum(HttpMethod, method) orelse error.HttpMethodNotAllowed;
    }
};

pub const HttpRequest = struct {
    method: HttpMethod,
    target: []const u8,
    headers: ArrayList([]const u8),
    body: []const u8,
    content_length: usize,

    pub fn init(request: []const u8) anyerror!HttpRequest {
        var it_lines = std.mem.splitSequence(u8, request, "\r\n");

        var method: HttpMethod = undefined;
        var target: []const u8 = "";

        // Read the start-line
        if (it_lines.next()) |line| {
            var it_firstline = std.mem.splitSequence(u8, line, " ");

            method = HttpMethod.fromString(it_firstline.next() orelse return error.HttpBadRequest) catch return error.HttpMethodNotAllowed;
            target = it_firstline.next() orelse return error.HttpBadRequest;
        } else {
            return error.HttpBadRequest;
        }

        const gpa = std.heap.page_allocator;
        var headers = ArrayList([]const u8).init(gpa);
        errdefer headers.deinit();

        var content_length: usize = 0;
        while (it_lines.next()) |line| {
            if (line.len == 0) {
                break;
            }

            if (std.mem.startsWith(u8, line, "Content-Length: ")) {
                const value = line[16..];
                content_length = try std.fmt.parseInt(usize, value, 10);
            }
            try headers.append(line);
        }

        // Read the body
        var body: []const u8 = "";
        if (content_length > constants.MAX_REQUEST_SIZE) {
            return error.HttpEntityTooLarge;
        }
        if (content_length > 0) {
            const request_len = request.len;
            const body_start = request_len - content_length;
            if (body_start < request_len) {
                body = request[body_start..];
            }
        }

        return HttpRequest{ .method = method, .target = target, .headers = headers, .body = body, .content_length = content_length };
    }

    pub fn process(self: *HttpRequest, buffer: []u8, return_headers: *ArrayList([]const u8)) !void {
        try self.printRequest();
        return switch (self.method) {
            HttpMethod.GET => {
                try self.get(buffer, return_headers);
            },
            else => {},
        };
    }

    fn get(self: *HttpRequest, buffer: []u8, return_headers: *ArrayList([]const u8)) !void {
        var gpa = std.heap.page_allocator;
        const route = if (self.target.len <= 1) "index.html" else self.target;

        const full_path = try std.fmt.allocPrint(gpa, "{s}/{s}", .{ constants.STATICS, route });
        defer gpa.free(full_path);

        // In case the file is not found, while return 404 Not Found :
        const file = try std.fs.cwd().openFile(full_path, .{});
        defer file.close();

        const content_type = getContentType(route);
        try appendHeader(return_headers, "Content-Type", content_type);

        var length_buf: [20]u8 = undefined;
        const content_length: []const u8 = try std.fmt.bufPrint(&length_buf, "{d}", .{try file.readAll(buffer)});
        try appendHeader(return_headers, "Content-Length", content_length);
    }

    fn appendHeader(headers: *ArrayList([]const u8), name: []const u8, value: anytype) !void {
        const header = try std.fmt.allocPrint(headers.allocator, "{s}: {s}", .{ name, value });
        try headers.append(header);
    }

    fn getContentType(path: []const u8) []const u8 {
        if (std.mem.endsWith(u8, path, ".html")) return "text/html";
        if (std.mem.endsWith(u8, path, ".css")) return "text/css";
        if (std.mem.endsWith(u8, path, ".js")) return "application/javascript";
        if (std.mem.endsWith(u8, path, ".json")) return "application/json";
        if (std.mem.endsWith(u8, path, ".png")) return "image/png";
        if (std.mem.endsWith(u8, path, ".jpg") or std.mem.endsWith(u8, path, ".jpeg")) return "image/jpeg";
        if (std.mem.endsWith(u8, path, ".svg")) return "image/svg+xml";
        if (std.mem.endsWith(u8, path, ".ico")) return "image/x-icon";
        return "application/octet-stream";
    }

    fn printRequest(self: *HttpRequest) !void {
        std.debug.print("\nstart-line:\n\t{} {s}\n", .{ self.method, self.target });
        std.debug.print("headers:\n", .{});
        for (self.headers.items) |header| {
            std.debug.print("\t{s}\n", .{header});
        }
        std.debug.print("body:\n\t{s}", .{self.body});
    }
};

test "HttpMethod.GET from string" {
    try std.testing.expect(try HttpMethod.fromString("GET") == HttpMethod.GET);
}

test "error.HttpMethodNotAllowed from string" {
    try std.testing.expectError(HttpError.HttpMethodNotAllowed, HttpMethod.fromString("UNKNOWN"));
}
