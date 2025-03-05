const std = @import("std");
const HttpResponse = @import("http_response.zig").HttpResponse;
const HttpRequest = @import("http_request.zig").HttpRequest;
const errors = @import("errors.zig");

const constants = @import("constants.zig");

pub fn processRequest(server: *std.net.Server) !void {
    var client = try server.accept();
    defer client.stream.close();

    const client_reader = client.stream.reader();
    const client_writer = client.stream.writer();
    var response = HttpResponse.init(client_writer.any());

    var request_buffer: [constants.MAX_REQUEST_SIZE]u8 = undefined;
    const request_size = try client_reader.read(request_buffer[0..]);

    var request = HttpRequest.init(request_buffer[0..request_size]) catch |err| {
        try errors.handleError(err, &response);
        return;
    };

    var buffer: [constants.MAX_RESPONSE_SIZE]u8 = undefined;
    const length = request.process(&buffer) catch |err| {
        try errors.handleError(err, &response);
        return;
    };

    try response.send200(&buffer, length);
}

pub fn main() !void {
    const addr = std.net.Address.initIp4(.{ 0, 0, 0, 0 }, constants.PORT);
    var server = try addr.listen(.{});

    std.log.info("Server listening on port {d}", .{constants.PORT});

    while (true) {
        processRequest(&server) catch |err| {
            std.log.err("{}", .{err});
        };
    }
}

test {
    std.testing.refAllDecls(@This());
}
