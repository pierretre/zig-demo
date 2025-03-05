const std = @import("std");
const HttpResponse = @import("http_response.zig").HttpResponse;
const HttpRequest = @import("http_request.zig").HttpRequest;
const HttpError = @import("errors.zig").HttpError;

const PORT = @import("constants.zig").PORT;

pub fn processRequest(server: *std.net.Server) !void {
    var client = try server.accept();
    defer client.stream.close();

    const client_reader = client.stream.reader();
    const client_writer = client.stream.writer();
    var response = HttpResponse.init(client_writer.any());

    var request_buffer: [1024]u8 = undefined;
    const request_size = try client_reader.read(request_buffer[0..]);

    _ = HttpRequest.init(request_buffer[0..request_size]) catch |err| switch (err) {
        error.HttpMethodNotAllowed => {
            try response.send405();
            return;
        },
        else => {
            std.debug.print("Found error {}", .{err});
        },
    };

    // Temporarly send 200 OK
    try response.send200("TEST");
}

pub fn main() !void {
    const addr = std.net.Address.initIp4(.{ 0, 0, 0, 0 }, PORT);
    var server = try addr.listen(.{});

    std.log.info("Server listening on port {d}", .{PORT});

    while (true) {
        processRequest(&server) catch |err| {
            std.log.err("{}", .{err});
        };
    }
}

test {
    std.testing.refAllDecls(@This());
}
