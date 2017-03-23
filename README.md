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
* bochs (see below)

## Bochs
I tried `brew install bochs` but there were no display drivers included
in the build. I found that I had to compile myself
* Download source from https://sourceforge.net/projects/bochs/files/bochs/
* Extract
* configure
```commandline
./configure --enable-ne2000 \
            --enable-all-optimizations \
            --enable-cpu-level=6 \
            --enable-x86-64 \
            --enable-vmx=2 \
            --enable-pci \
            --enable-usb \
            --enable-usb-ohci \
            --enable-e1000 \
            --enable-debugger \
            --enable-disasm \
            --disable-debugger-gui \
            --with-sdl \
            --prefix=$HOME/opt/bochs
```
* Make
```commandline
make
```
* Install
```commandline
make install
```

## Build
```commandline
# Setup
mkdir -p build/kernel
mkdir -p build/iso/boot/grub

# Build the loader
nasm -f elf32 -o build/kernel/loader.o loader.s

# Link to produce executable
/usr/local/i386elfgcc/bin/i386-elf-ld -T link.ld -melf_i386 build/kernel/loader.o -o build/iso/boot/kernel.elf

# copy the bootloader
cp grub/stage2_eltorito build/iso/boot/grub/

# Copy the grub menu
cp menu.lst build/iso/boot/grub/menu.lst

# Generate bootable ISO
mkisofs -R \
        -b boot/grub/stage2_eltorito \
        -no-emul-boot \
        -boot-load-size 4 \
        -A c-os \
        -input-charset utf8 \
        -quiet \
        -boot-info-table \
        -o build/c-os.iso \
        build/iso
```

## Running
```commandline
~/opt/bochs/bin/bochs  -f bochsrc.txt -q
```

## Things I've learned
* I don't understand Make
* I don't understand linking
* Developing on straight MacOS requires a cross-compiled gcc, the bundled gcc
in X-Code won't work
* The bochs available through brew has no display libraries :(