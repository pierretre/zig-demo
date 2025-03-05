# zig-demo
A quick demonstration of Zig programming language. The aim is to review the basics and familiarize with the concepts of Zig.

I chose to develop a simple http server from scratch including basic functionalities as:
* Loading static files
* Error managment
* More to come ...

If you want to know more about starting your own project, read [this](doc/SETUP.md).

## HTTP-SERVER
### Build and run the tests
```shell
zig build test --summary new
```

### Run the server
After build :
```shell
./zig-out/bin/zig-demo
```

Or simply
```shell
zig run src/main.zig
```

### examples of outputs
* #### GET:

    In another terminal :
    ```shell
    curl localhost:8080
    ```

    Result (Client):
    ```
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Welcome Page</title>
    </head>

    <body>
        <h1>Welcome to Zig Server</h1>
        <p>This is a simple welcome message served by a Zig server.</p>
    </body>

    </html>
    ```

    Result (Server):
    ```
    start-line:
            http_request.HttpMethod.GET /
    headers:
            Host: localhost:8080
            User-Agent: curl/8.5.0
            Accept: */*
    body:
    ```
* #### POST:

    In another terminal :
    ```shell
    curl localhost:8080
    ```

    Result (Client):
    ```
    ```

    Result (Server):
    ```
    start-line:
            http_request.HttpMethod.POST /
    headers:
            Host: localhost:8080
            User-Agent: curl/8.5.0
            Accept: */*
            Content-Length: 4
            Content-Type: application/x-www-form-urlencoded
    body:
            TEST
    ```

## Useful links
* [Zig in 100 Seconds](https://youtu.be/kxT8-C1vmd4)
* [Zig memory safety](https://www.scattered-thoughts.net/writing/how-safe-is-zig/)

## HTTP reference documentation :
* [HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP)