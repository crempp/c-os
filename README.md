# c-os
The Chad Operating System.

## Inspiration
I've been meaning to read the mini-book [_The little book about OS development_](http://littleosbook.github.io/book.pdf) for a while. I finally got around to it and it made OS development seem simple enough for even me to tackle. The result is this toy OS.

## Requirements
These requirements are targeted at Mac. For Windows or Linux the requirements are mostly the same but details will vary.

* X-Code (Mac only, this will bootstrap the building of the cross-compiled gcc)
* Watcom compiler and linker ([see here](docs/watcom.md))
* NASM (`brew install nasm`)
* mkisofs (`brew install cdrtools`)
* bochs ([see here](docs/bochs.md))
* qemu (if you want an alternative tool - `brew install qemu`)

Detailed instructions on environment setup are in the [setup docs](docs/setup.md)

## Build
We use SCons for building because Make is the worst.

* *Build boot and kernel* `scons`
* *Clean up* `scons -c`

## Running
```commandline
$ ~/opt/bochs/bin/bochs -f bochsrc.txt -q
```

## TODO
1. Disk read retries in bootloader
2. Get ISO building working again
3. More SCons commands like building ISO or floppy

## Docs
* [Development Log](docs/devlog.md)
* [Installing Bochs from Source](docs/bochs.md)
* [Setting up the Watcom Toolchain on Mac](docs/watcom.md)
* [Setup for C-OS Development](docs/setup.md)
* [References]