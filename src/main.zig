const std = @import("std");

const PORT = 8080;
const STATICS: []const u8 = "static/";

pub fn processRequest(server: *std.net.Server) !void {
    var gpa = std.heap.page_allocator;

    var client = try server.accept();
    defer client.stream.close();

    const client_reader = client.stream.reader();
    const client_writer = client.stream.writer();

    var request_buffer: [1024]u8 = undefined;
    const request_size = try client_reader.read(request_buffer[0..]);
    const request = request_buffer[0..request_size];

    var it_lines = std.mem.splitSequence(u8, request, "\r\n");

    var method: []const u8 = "";
    var route: []const u8 = "";

    if (it_lines.next()) |x| {
        var it_firstline = std.mem.splitSequence(u8, x, " ");
        method = if (it_firstline.next()) |y| y else "";
        route = if (it_firstline.next()) |y| y else "";

        std.log.info("Request received: Method: {s}, Route: {s}", .{ method, route });
    }

    // Si route est vide, on ouvre index.html
    route = if (route.len == 1) "index.html" else route;

    const full_path = try std.fmt.allocPrint(gpa, "{s}{s}", .{ STATICS, route });
    defer gpa.free(full_path);

    const file = std.fs.cwd().openFile(full_path, .{}) catch |err| {
        if (err == error.FileNotFound) {
            const response_404 = "HTTP/1.1 404 Not Found\r\nContent-Length: 13\r\n\r\n404 Not Found";
            try client_writer.writeAll(response_404);
            return;
        }
        return err;
    };
    defer file.close();

    // const file_size = try file.getEndPos();
    // const file_buffer = try gpa.alloc(u8, file_size);
    // defer gpa.free(file_buffer);

    // try file.readAll(file_buffer);
    var buffer: [512]u8 = undefined;
    const end_index = try file.readAll(&buffer);

    const response_200 = try std.fmt.allocPrint(gpa, "HTTP/1.1 200 OK\r\n\r\n{s}", .{buffer[0..end_index]});

    try client_writer.writeAll(response_200);
    gpa.free(response_200);
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
