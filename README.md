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

## Useful links
* [Zig in 100 Seconds](https://youtu.be/kxT8-C1vmd4)
* [Zig memory safety](https://www.scattered-thoughts.net/writing/how-safe-is-zig/)