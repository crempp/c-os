# Development Log
----

### May 26th 2020
It's been a while.

Where I left off I had converted all the kernel C code to assembly and updated the SConstruct file appropriately. The system was building and booting but not running the kernel code correctly.

When I started today the bootloader was still working but the kernel was not being linked correctly. I remember this being an issue last I worked on the OS. After some debugging and research I found a couple of things.

Bugs:
1. The linked kernel.bin output had 0x10 null bytes at the beginning.
2. The data segment was starting at 0x20 in the output binary cutting off most of the code

I looked like the kernel map coming out of the linker was messing up the assembly segment locations. My research provided:

* The `offset` parameter to `output` directive does not work like I thought. I thought it meant the offset for code start but when I read the documentation:
       _specifies that linear addresses below n should be skipped when outputting the executable image._
I realized it would cut out anything after that offset. Oopsies.
* I kept getting the error `Warning! W1023: no starting address found, using 0001:0000`. It was just an error but looked mighty similar to the two bugs. I found that adding `start_` to kernel.s and `option START=start_` to linkerscript.lnk fixed the warning but neither bugs.

Finally stumbled upon the `option offset` in the documentation. Adding `option offset=0x00500` fixed both bugs.

Now the switch to assembly only is complete. I'm excited to start working on the kernel again.

### September 22nd, 2018
Cleaned up the video driver. Not sure if it'll stay how it is but it's a little better now.

I found the bug with v_print_nl - it seems that int 10h does not push/pop and I have to reset the AH/AL/BH/BL parameters each time it's called.

TODO:
  * Switch to all assembly. This will fix the compilation problems I'm having with Watcom in the build system, make calling more streamlined and make the build smaller (28k or bust).
  * Move constants out to a shared file (https://stackoverflow.com/a/22583433/1436323)

### September 3rd, 2018
Got the Docker build container, CircleCI and deployment working. That is a story for another day. Now you can see the the OS running at http://c-os.chadrempp.com/

### July 30th, 2018
After getting the bootloader to load more than one track I was immediately stuck again when the CONST section of the kernel wasn't where I thought it should be in memory.

First I found that the linker offsets for the assembly segments were wrong. Fixed those.

Next I realized that the segment registers needed to be setup for the kernel once we get to the entry point.

Things still weren't working. I modified the code to print the address the bootloader was copying sectors to using the print_hex function. Within that function the ROR instruction would execute and then the IP register zeroed out. This was quite odd so I assumed it was a bug in pcjs. I upgraded pcjs to no avail. After debugging pcjs itself for a while I finally stumbled on some obscure information that many instructions on the 8088 don't support all addressing modes. For example ROR and SHR can't use immediate values or memory locations (these are functionally the same) but must use the CL register.
Using the `cpu 8086` directive in nasm helps point these out. After updating the code the address printing worked but along the way I found the actual bugs that led me to even try hex printing. In a few areas I was overwriting registers which messed up loading addresses. Fixed those and now the kernel CONST segment is in the right spot.

The kernel is running and I see the kernel message but the screen is acting wacky.

### July 29th, 2018
Finally found [example](https://forum.osdev.org/viewtopic.php?f=1&t=24041) code that loads more than one cylinder from a disk. This allowed me to finally load the entire kernel. The kernel isn't working yet but it's loading.

### July 25th - 28th, 2018
Tried in vain to get multi sector disk loading to work. No luck. I have decided to start over but in the meantime I took a break by writing routines to print the available memory. This was more difficult than I thought but finally got it to work.

### July 13th - 24th, 2018
These two weeks were spent getting the OS to boot in pcjs which is the only accurate 8088 emulator I could get working on my Mac and with the binary I was producing.

Some work went into getting pcjs working with the floppy boot disk by padding up to 160k and running the diskdump tool. See here for supported disk sizes (files must be this size) [https://github.com/jeffpar/pcjs/blob/master/modules/shared/lib/diskapi.js#L155-L177](https://github.com/jeffpar/pcjs/blob/master/modules/shared/lib/diskapi.js#L155-L177)

I added pcjs directly to this project in a pcjs directory for the moment for simplified testing.

Now that I'm testing in a true 8088 XT environment I found some issues.
* pusha/popa doesn't exist until the 80186 ([see here](https://www.pagetable.com/?p=8))
* on the XT and earlier the BIOS only supports Int 13h functions 0 - 5.
This means that you can't get the disk params (function 08h). Also, there's
odd Int 13h behavior that's difficult to find documentation on like
* Int 13h function 2 doesn't return the sectors read (BIOS bug?). I decided to skip that check.
* The data segment produced by the linker for the kernel data was messed up. I actually forget what the exact problem was but it was a combination of the segment registers and the linker script settings. It's sorted now.

I broke out the BIOS video functions to a shared assembly file to reduce code duplication. I also wrote a temporary script package.sh to build the pcjs disk image until I can wrap it into Scons.

I still need to update the disk loading code to copy more than one track. That's next...

### July 8th, 2018
I wondered if I should rewrite the video driver to not use bios interrupts since
I kept seeing code useing I/O and DMA. I think that's only because in protected
mode you don't have the BIOS available. I'll continue using the BIOS since it's
so much easier.

While messing with video modes I found that bochs doesn't support MDA which is
a common video card on old systems. I determined I need a better emulator for
old systems. In my investigation I found that pcem and 86box were the two leaders.
I couldn't get pcem to compile (I was close). I was able to run pcem via wine
but not 86box. However I couldn't get disks to boot on an XT.

I settled on using a Javascript emulator called [pcjs](https://www.pcjs.org/).

### April 11th, 2017
Solved the issue with refrencing data values by using the following linker ordering:
```
order
    clname CODE
        segaddr=0x0100
        segment _TEXT
    clname DATA
        segment CONST  segaddr=0x0200 offset=0x0100
        segment CONST2 segaddr=0x0200 offset=0x0200
        segment _DATA  segaddr=0x0200 offset=0x0300
```

This is unfortunate because it introduced a bunch of null space in the binary caused by the offsets in the DATA class but I can not currently find a way around this.

Also:
* fleshed out some of the video functionality and fixed a bug in the `v_printhex` function.
* added a ports driver (nothing to test on yet) and in the process learned how to inline assembly in Watcom.
* reorganized project by adding a drivers directory

### April 10th, 2017
Kernel is booting properly in real mode and passing strings to a function defined in assembly.

Today I learned:
* Had to add `segment _TEXT public align=1 class=CODE` to kernel-entry.s to get the entry code to be located at the beginning.
* The Watcom linker was putting the data segement in a different memory segement and then referencing with the DS register. I was not setting this register correctly at boot because I didn't know what the linker would do. To solve this I manually set the linker to put the data segement in memory segment 0x0200 and increased the number of sectors being loaded from disk. This get me by for a while but it'd be nice to setup the linker configs to just handle this.

### April 2nd, 2017
Finally got Watcom compiling and linking but the OS is not functioning.

Today I learned:
* When calling **to** or **from** assembly the Watcom linker expects the functions to be named with a trailing underscore (_).
* Adding `START=main_` to linker script solves `Warning! W1023: no starting address found, using 0100:0000`
* just try linking emu87, math87l, clibl. I think they may actually be needed
* To get rid of `Error! E2028: __STK is an undefined reference` use the `-s` parameter
* To get rid of `Error! E2028: _big_code_ is an undefined reference` use the `-zl` parameter
* To get rid of `Error! E2028: main_ is an undefined reference` you have to name the kernel entry function `_cstart` and the assembly refference `_cstart_`

### March 28th, 2017
Make is terrible, like really terrible. Let's try [SCons](http://scons.org/) because I like Python.

### March 26th, 2017
Made a fateful decision today. I will not enter protected mode and I will not create a 32/64 bit OS. I would like to run this OS with the [emulator](https://github.com/crempp/js86emu) I'm writing which uses an 8088 CPU and thus can not do fancy shit.

Building a 16-bit OS seems harder than I thought it would be. There are not many tools still available. I chose to use OpenWatcom as my compiler/linker. I hope it works.

### March 25th, 2017
Setup protected mode and successfully jumped from bootloader to Kernel entry code.

### March 24th, 2017
I decided I wanted to write my own bootloader so threw out Grub and rolled up my sleaves.

### March 23rd, 2017
Built a working example straight out of [Little OS Book](http://littleosbook.github.io/).

Today I learned:
* I don't understand Make
* I don't understand linking
* Developing on straight MacOS requires a cross-compiled gcc, the bundled gcc in X-Code won't work
* The bochs available through brew has no display libraries :(. I have to install from source.
