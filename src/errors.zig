const std = @import("std");

pub const HttpError = error{
    HttpBadRequest,
    HttpUnauthorized,
    HttpForbidden,
    HttpNotFound,
    HttpMethodNotAllowed,
    HttpInternalServerError,
};

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
