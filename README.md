# c-os
The Chad Operating System.

## Inspiration
I've been meaning to read the mini-book [_The little book about OS development_](http://littleosbook.github.io/book.pdf)
for a while. I finally got around to it and it made OS development seem
simple enough for even me to tackle. The result is this toy OS.

## Requirements
These requirements are targeted at Mac. For Windows or Linux the requirements
are mostly the same but details will vary.
* X-Code (Mac only, this will bootstrap the building of the cross-compiled gcc)
* [Cross-compiled version of gcc](https://github.com/cfenollosa/os-tutorial/tree/master/11-kernel-crosscompiler)
* Requirements listed in above gcc instructions
* NASM (`brew install nasm`)
* mkisofs (`brew install cdrtools`)
* -bochs (see below)-
* qemu (`brew install qemu`)

Detailed instructions on environment setup are in the [setup docs](docs/setup.md)

## Bochs
For details on setting up and using bochs see the [bochs docs](docs/bochs.md)

## Build
Use make to easily build and run the OS
* *Build boot and kernel* `make`
* *Build the bootloader* `make build-boot`
* *Build distribution (fld/iso)* `make dist`
* *Build the ISO* `make os.iso`
* *Build the floppy* `make os.flp`
* *Run the kernel in Bochs (not working)* `make run-bochs`
* *Run the kernel in Qemu* `make run-qemu`
* *Clean up* `make clean`

If you want to build the pieces with out make here are the commands:

Building the bootloader
```commandline
nasm -f bin src/bootsect.s -o build/boot/bootsect.bin
```

## Running
```commandline
make run-qemu
```

## Things I've learned
* I don't understand Make
* I don't understand linking
* Developing on straight MacOS requires a cross-compiled gcc, the bundled gcc
in X-Code won't work
* The bochs available through brew has no display libraries :(

## References
* [Little OS Book](http://littleosbook.github.io/)
* [os-tutorial](https://github.com/cfenollosa/os-tutorial)
* [Writing a Simple Operating System - from Scratch](http://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf)
* [OSDev](http://wiki.osdev.org/)



* http://mikeos.sourceforge.net/write-your-own-os.html
* https://github.com/joesavage/bare-bones-bootloader
* http://www.osdever.net/bkerndev/Docs/title.htm