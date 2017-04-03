## General Notes
* When calling from or to assembly the Watcom linker expects the functions to
be named with a trailing underscore (_).
* Adding `START=main_` to linker script solves
`Warning! W1023: no starting address found, using 0100:0000`
* just try linking emu87, math87l, clibl. I think they may actually be needed
* To get rid of `Error! E2028: __STK is an undefined reference` use the `-s`
parameter
* To get rid of `Error! E2028: _big_code_ is an undefined reference` use the
`-zl` parameter
* To get rid of `Error! E2028: main_ is an undefined reference` you have to name
the kernel entry function `_cstart` and the assembly refference `_cstart_`

## Installing Watcom
* ...
* Move to ~/opt
* setup path

## Refs:
* Watcom tools: https://github.com/open-watcom/open-watcom-v2/blob/master/projects.txt
* Watcom wcc: http://users.pja.edu.pl/~jms/qnx/help/watcom/compiler-tools/cpopts.html
* Watcom wlink: http://users.pja.edu.pl/~jms/qnx/help/watcom/compiler-tools/wlink.html

* http://mikeos.sourceforge.net/write-your-own-os.html
* https://github.com/joesavage/bare-bones-bootloader
* http://www.osdever.net/bkerndev/Docs/title.htm
* http://www.brokenthorn.com/Resources/OSDevVga.html

* Watcom
** https://github.com/open-watcom/open-watcom-v2
** http://wiki.osdev.org/Watcom

