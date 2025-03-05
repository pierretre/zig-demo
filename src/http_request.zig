const std = @import("std");
const STATICS = @import("constants.zig").STATICS;
const HttpError = @import("errors.zig").HttpError;

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
    // protocol: []const u8,
    // headers: []const u8,
    // body: []const u8,

    pub fn init(request: []const u8) HttpError!HttpRequest {
        // var gpa = std.heap.page_allocator;

        var it_lines = std.mem.splitSequence(u8, request, "\r\n");

        var method: HttpMethod = undefined;
        var target: []const u8 = "";

        // Read the start-line
        if (it_lines.next()) |line| {
            var it_firstline = std.mem.splitSequence(u8, line, " ");

            method = HttpMethod.fromString(it_firstline.next() orelse return error.HttpBadRequest) catch return error.HttpMethodNotAllowed;
            target = it_firstline.next() orelse return error.HttpBadRequest;

            std.log.info("Request received: {s}", .{line});
        } else {
            return error.HttpBadRequest;
        }

        // const route = if (target.len == 1) "index.html" else target;

        // const full_path = try std.fmt.allocPrint(gpa, "{s}/{s}", .{ STATICS, route });
        // defer gpa.free(full_path);

        // Read the headers
        // TODO

        // Read the body
        // TODO
        return HttpRequest{ .method = method, .target = target };
    }

    // fn toString(self: *HttpRequest) []const u8 {
    //     // TODO
    // }
};

test "HttpMethod.GET from string" {
    try std.testing.expect(try HttpMethod.fromString("GET") == HttpMethod.GET);
}

test "error.HttpMethodNotAllowed from string" {
    try std.testing.expectError(HttpError.HttpMethodNotAllowed, HttpMethod.fromString("UNKNONW"));
}
