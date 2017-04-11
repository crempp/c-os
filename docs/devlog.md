# Development Log
----

### March 23rd, 2017
Built a working example straight out of [Little OS Book](http://littleosbook.github.io/).

Today I learned:
* I don't understand Make
* I don't understand linking
* Developing on straight MacOS requires a cross-compiled gcc, the bundled gcc in X-Code won't work
* The bochs available through brew has no display libraries :(. I have to install from source.

### March 24th, 2017
I decided I wanted to write my own bootloader so threw out Grub and rolled up my sleaves.

### March 25th, 2017
Setup protected mode and successfully jumped from bootloader to Kernel entry code.

### March 26th, 2017
Made a fateful decision today. I will not enter protected mode and I will not create a 32/64 bit OS. I would like to run this OS with the [emulator](https://github.com/crempp/js86emu) I'm writing which uses an 8088 CPU and thus can not do fancy shit.

Building a 16-bit OS seems harder than I thought it would be. There are not many tools still available. I chose to use OpenWatcom as my compiler/linker. I hope it works.

### March 28th, 2017
Make is terrible, like really terrible. Let's try [SCons](http://scons.org/) because I like Python. 

### April 2nd, 2017
Finally got Watcom compiling and linking but the OS is not functioning.

Today I learned:
* When calling **to** or **from** assembly the Watcom linker expects the functions to be named with a trailing underscore (_).
* Adding `START=main_` to linker script solves `Warning! W1023: no starting address found, using 0100:0000`
* just try linking emu87, math87l, clibl. I think they may actually be needed
* To get rid of `Error! E2028: __STK is an undefined reference` use the `-s` parameter
* To get rid of `Error! E2028: _big_code_ is an undefined reference` use the `-zl` parameter
* To get rid of `Error! E2028: main_ is an undefined reference` you have to name the kernel entry function `_cstart` and the assembly refference `_cstart_`

### April 10th, 2017
Kernel is booting properly in real mode and passing strings to a function defined in assembly.

Today I learned:
* Had to add `segment _TEXT public align=1 class=CODE` to kernel-entry.s to get the entry code to be located at the beginning.
* The Watcom linker was putting the data segement in a different memory segement and then referencing with the DS register. I was not setting this register correctly at boot because I didn't know what the linker would do. To solve this I manually set the linker to put the data segement in memory segment 0x0200 and increased the number of sectors being loaded from disk. This get me by for a while but it'd be nice to setup the linker configs to just handle this.
