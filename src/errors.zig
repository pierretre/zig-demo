const std = @import("std");
const HttpResponse = @import("http_response.zig").HttpResponse;

pub const HttpError = error{
    HttpBadRequest,
    HttpUnauthorized,
    HttpForbidden,
    HttpNotFound,
    HttpMethodNotAllowed,
    HttpInternalServerError,
    HttpEntityTooLarge,
};

pub fn handleError(err: anyerror, response: *HttpResponse) !void {
    switch (err) {
        error.FileNotFound => {
            try response.send404();
        },
        error.HttpMethodNotAllowed => {
            try response.send405();
        },
        error.HttpEntityTooLarge => {
            try response.send413();
        },
        else => {
            std.debug.print("Found error {}", .{err});
            try response.send500();
        },
    }
}

// TESTS :

fn fails() HttpError![]const u8 {
    return error.HttpBadRequest;
}

test "return error instead of chars" {
    _ = fails() catch |err| {
        try std.testing.expect(err == error.HttpBadRequest);
        return;
    };
    try std.testing.expect(false);
}

test "error switch" {
    _ = fails() catch |err| switch (err) {
        error.HttpBadRequest => {
            try std.testing.expect(true);
            return;
        },
        else => {
            try std.testing.expect(false);
            return;
        },
    };
    try std.testing.expect(false);
}

fn testHandler(err: anyerror) !bool {
    switch (err) {
        // ...
        else => {
            return true;
        },
    }
}
test "error handler" {
    _ = fails() catch |err| try std.testing.expect(try testHandler(err));
}
