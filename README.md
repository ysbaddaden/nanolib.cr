# Nano

A minimal alternative core library for the Crystal programming language.

## What

Nano is an alternative core library that doesn't need a GC and tries to bring
some features from stdlib that don't allocate memory behind your back, yet still
leverage structs, generics and exceptions that don't raise but will panic (print
a backtrace & exit the current thread or program).

The initial intent was to have a minimal interface to implement a GC, making
sure the stdlib won't try to allocate... which would use the GC (oops).

You can use it to write programs like you would C programs, or write a C
library. You may even use it to start programmming microcontrollers (e.g.
Arduino, RP2040).

## How

The crystal compiler allows to configure an alternate prelude (a simple crystal
file) that will be loaded instead of the default prelude that will load
everything from the official core library. The compiler even ships an `empty`
prelude that only defines a `main` function and nothing more.

That empty prelude is very bare metal. Only the few compiler intrinsics are
available, that is almost nothing but basic arithmetic, pointers and support for
literals.

Nano is an attempt to bring back some niceties from the stdlib, with no GC, no
hidden allocations. Pointer#malloc is available but you know when it's called,
why it is, and are responsible to clean up the memory (or not).

## Usage

Add the nano shard:

```yaml
dependencies:
  nano:
    github: ysbaddaden/nanolib.cr
    branch: main
```

Then use nano as your prelude:

```console
$ crystal run app.cr --prelude=nano --release
```

Alternatively you can write your own prelude and only require the bits of nano
you want. See `src/nano.cr` for example. This is currently required for
microcontrollers.

For running tests and specs, you might be interested in
[microtest](https://github.com/ysbaddaden/microtest.cr).

## License

Distributed under the Apache 2.0 license.
