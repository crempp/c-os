## Memory Map

```
+------------+------------+-----------+---------------------------------------+--------+--------+
|    Start   |    End     | Size      | Description                           | Usable | Notes  |
+============+============+===========+=======================================+========+========+
|                                       Low memory (< 1 MiB)                                    |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x00000000 | 0x000003FF | 1Kib      | Real Mode IVT [1]                     |   P    | 1      |
+------------+------------+-----------+---------------------------------------+--------+--------+
|      0x000 |      0x003 | 4b        | Int 0x00 - Divide by 0                |        |        |
|      0x004 |      0x007 | 4b        | Int 0x01 - Reserved                   |        |        |
|      0x008 |      0x00B | 4b        | Int 0x02 - NMI Interrupt              |        |        |
|      0x00C |      0x00F | 4b        | Int 0x03 - Breakpoint                 |        |        |
|      0x010 |      0x013 | 4b        | Int 0x04 - Overflow                   |        |        |
|      0x014 |      0x017 | 4b        | Int 0x05 - Bounds range exceeded      |        |        |
|      0x018 |      0x01B | 4b        | Int 0x06 - Invalid opcode             |        |        |
|      0x01C |      0x01F | 4b        | Int 0x07 - Device not available       |        |        |
|      0x020 |      0x023 | 4b        | Int 0x08 - Double fault               |        |        |
|      0x024 |      0x027 | 4b        | Int 0x09 - Coproc segment overrun     |        |        |
|      0x028 |      0x02B | 4b        | Int 0x0A - Invalid TSS                |        |        |
|      0x02C |      0x02F | 4b        | Int 0x0B - Segment not present        |        |        |
|      0x030 |      0x033 | 4b        | Int 0x0C - Stack-segment fault        |        |        |
|      0x034 |      0x037 | 4b        | Int 0x0D - General protection fault   |        |        |
|      0x038 |      0x03B | 4b        | Int 0x0E - Page fault                 |        |        |
|      0x03C |      0x03F | 4b        | Int 0x0F - Reserved                   |        |        |
|      0x040 |      0x043 | 4b        | Int 0x10 - x87 FPU error              |        |        |
|      0x044 |      0x047 | 4b        | Int 0x11 - Alignment check            |        |        |
|      0x048 |      0x04B | 4b        | Int 0x12 - Machine check              |        |        |
|      0x04C |      0x04F | 4b        | Int 0x13 - SIMD Float-Point Exception |        |        |
|      0x050 |      0x07F | 4b        | 0x14-0x1F - Reserved                  |        |        |
|      0x080 |      0x3FF | 4b        | 0x20-0xFF - User definable            |        |        |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x00000400 | 0x000004FF | 256b      | BDA (BIOS Data Area) [2]              |   P    | 1      |
+------------+------------+-----------+---------------------------------------+--------+--------+
|      0x400 |      0x407 | 8b        | Base I/O address for COM1-COM4 serial |        |        |
|      0x408 |      0x40D | 6b        | Base I/O address LPT1-LPT3 parallel   |        |        |
|      0x40E |      0x40F | 2b        | EBDA base address (usually)           |        | 10     |
|      0x410 |      0x411 | 2b        | Installed hardware                    |        |        |
|      0x412 |      0x412 | 1b        | POST status                           |        | 14     |
|      0x413 |      0x414 | 2b        | Base memory size in kbytes (0-640)    |        |        |
|      0x415 |      0x416 | 2b        | Reserved                              |        |        |
|      0x417 |      0x418 | 2b        | Keyboard status flags                 |        |        |
|      0x419 |      0x419 | 1b        | Keyboard Alt-nnn keypad workspace     |        |        |
|      0x41A |      0x41B | 2b        | Keyboard ptr to next char in buffer   |        |        |
|      0x41C |      0x41D | 2b        | Keyboard ptr to first free buff slot  |        |        |
|      0x41E |      0x43D | 32b       | Keyboard circular buffer              |        |        |
|      0x43E |      0x43E | 1b        | Diskette recalibrate status           |        |        |
|      0x43F |      0x43F | 1b        | Diskette motor status                 |        |        |
|      0x440 |      0x440 | 1b        | Diskette motor turn-off time-out cnt  |        |        |
|      0x441 |      0x441 | 1b        | Diskette last operation status        |        |        |
|      0x442 |      0x448 | 7b        | Diskette/Fixed disk status/cmd bytes  |        |        |
|      0x449 |      0x449 | 1b        | Video current mode                    |        |        |
|      0x44A |      0x44B | 2b        | Video columns on screen               |        |        |
|      0x44C |      0x44D | 2b        | Video page (regen buff) size in bytes |        |        |
|      0x44E |      0x44F | 2b        | Video cur page address in regen buff  |        |        |
|      0x450 |      0x45F | 16b       | Video cursor position                 |        |        |
|      0x460 |      0x461 | 2b        | Video cursor type                     |        |        |
|      0x462 |      0x462 | 1b        | Video current page number             |        |        |
|      0x463 |      0x464 | 2b        | Video CRT controller base address     |        |        |
|      0x465 |      0x465 | 1b        | Video cur setting of mode select reg  |        |        |
|      0x466 |      0x466 | 1b        | Video cur setting of CGA palette reg  |        |        |
|      0x467 |      0x46A | 4b        | POST realmode re-entry addr after rst |        |        |
|      0x46B |      0x46B | 1b        | POST last unexpected interrupt        |        |        |
|      0x46C |      0x46F | 4b        | Timer ticks since midnight            |        |        |
|      0x470 |      0x470 | 1b        | Timer overflow                        |        |        |
|      0x471 |      0x471 | 1b        | Ctrl-Break flag                       |        |        |
|      0x472 |      0x473 | 2b        | POST reset flag                       |        |        |
|      0x474 |      0x474 | 1b        | Fixed disk last operation status      |        |        |
|      0x475 |      0x475 | 1b        | Fixed disk: num of fixed disk drives  |        |        |
|      0x476 |      0x476 | 1b        | Fixed disk: control byte              |        |        |
|      0x477 |      0x477 | 1b        | Fixed disk: I/O port offset           |        |        |
|      0x478 |      0x47A | 3b        | Parallel devices 1-3 time-out counters|        |        |
|      0x47B |      0x47B | 1b        | parallel device 4 time-out counter    |        | 13     |
|      0x47C |      0x47F | 4b        | Serial devices 1-4 time-out counters  |        |        |
|      0x480 |      0x481 | 2b        | Keyboard buffer start                 |        |        |
|      0x482 |      0x483 | 2b        | Keyboard buffer end+1                 |        |        |
| ---------- | ---------- | --------- | ---XT BIOS dated 11/08/82 ends here-- | ------ | ------ |
|      0x484 |      0x484 | 1b        | Video rows on screen minus one        |        |15,16,17|
|      0x485 |      0x486 | 2b        | Video character height in scan-lines  |        |15,16,17|
|      0x487 |      0x487 | 1b        | Video control                         |        | 15,17  |
|      0x488 |      0x488 | 1b        | Video switches                        |        | 15,17  |
|      0x489 |      0x489 | 1b        | Video mode-set option control         |        | 16,17  |
|      0x48A |      0x48A | 1b        | Video idx Display Comb Code table     |        | 16,17  |
|      0x48B |      0x48B | 1b        | Diskette media control                |        | 9      |
|      0x48C |      0x48C | 1b        | Fixed disk controller status          |        | 9      |
|      0x48D |      0x48D | 1b        | Fixed disk controller Error Status    |        | 9      |
|      0x48E |      0x48E | 1b        | Fixed disk Interrupt Control          |        | 9      |
|      0x48F |      0x48F | 1b        | Diskette controller information       |        | 9      |
|      0x490 |      0x491 | 2b        | Diskette drive 0/1 media states       |        |        |
|      0x492 |      0x493 | 2b        | Diskette drive 0/1 media states start |        |        |
|      0x494 |      0x495 | 2b        | Diskette drive 0/1 current track num  |        |        |
|      0x496 |      0x497 | 2b        | Keyboard status byte 3 and 2          |        |        |
|      0x498 |      0x49B | 4b        | Timer2: ptr to user wait-complete flg |        | 7,11   |
|      0x49C |      0x49F | 4b        | Timer2: user wait count in microsecs  |        | 7,11   |
|      0x4A0 |      0x4A0 | 1b        | Timer2: Wait active flag              |        | 7,11   |
|      0x4A1 |      0x4A7 | 7b        | Reserved for network adapters         |        |        |
|      0x4A4 |      0x4A7 | 4b        | Saved Fixed Disk Interrupt Vector     |        | 12     |
|      0x4A8 |      0x4AB | 4b        | Video ptr to Video Save Pointer Table |        |15,16,17|
|      0x4AC |      0x4AF | 4b        | Reserved                              |        |        |
|      0x4B0 |      0x4B3 | 4b        | Ptr to 3363 Opt disk driver/BIOS entry|        |        |
|      0x4B4 |      0x4B5 | 2b        | Reserved                              |        |        |
|      0x4B6 |      0x4B8 | 3b        | Reserved for POST?                    |        |        |
|      0x4B9 |      0x4BF | 7b        | ???                                   |        |        |
|      0x4C0 |      0x4CD | 14b       | Reserved                              |        |        |
|      0x4CE |      0x4CF | 2b        | Count of days since last boot?        |        |        |
|      0x4D0 |      0x4EF | 32b       | Reserved                              |        |        |
|      0x4F0 |      0x4FF | 16b       | Reserved for user                     |        |        |
|      0x500 |      0x500 | 1b        | Print Screen Status byte              |        |        |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x00000500 | 0x00007BFF | ~30KiB    | RAM: Conventional memory              |  GF    | 3      |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x00007C00 | 0x00007DFF | 512b      | RAM: Partially unusable (OS Bootsect) |  P     | 4, 5   |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x00007E00 | 0x0007FFFF | 480.5 KiB | RAM: Conventional memory              |  GF    | 3      |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x00080000 | 0x0009FBFF | ~120 KiB  | RAM: Conventional memory              |  FiE   | 6      |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x0009FC00 | 0x0009FFFF | 1 KiB     | EBDA (Extended BIOS Data Area)        |  X     | 4      |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x000A0000 | 0x000BFFFF | 128 Kib   | Video Memory [3]                      |  P     |        |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x000B0000 | 0x000B0FFF | 4 Kib     | MDA framebuffers [4]                  |        | 18     |
| 0x000B8000 | 0x000BBFFF | 16 Kib    | CGA framebuffers [4]                  |        |        |
| 0x000B0000 | 0x000BFFFF | 64 Kib    | Hercules framebuffers [4]             |        |        |
| 0x000A0000 | 0x000AFFFF | 64 Kib    | EGA framebuffers [3]                  |        |        |
| 0x000B0000 | 0x000B7FFF | 32 Kib    | EGA framebuffers (5151 Display) [3]   |        |        |
| 0x000B8000 | 0x000BFFFF | 32 Kib    | EGA framebuffers (5153/5154 Disp) [3] |        |        |
| 0x000A0000 | 0x000AFFFF | 64 Kib    | VGA framebuffers [3]                  |        |        |
| 0x000B0000 | 0x000B7FFF | 32 Kib    | VGA framebuffers (MDA emulation) [3]  |        |        |
| 0x000B8000 | 0x000BFFFF | 32 Kib    | VGA framebuffers (CGA emulation) [3]  |        |        |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x000C0000 | 0x000FFFFF | 256 Kib   | Expansion ROM BIOSs                   |  P     |        |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x000C0000 | 0x000C3FFF | 16 Kib    | EGA BIOS [3]                          |        |        |
| 0x000C0000 | 0x000C5FFF | 24 Kib    | VGA BIOS [3]                          |        |        |
| 0x000C6800 | 0x000C7FFF | 6 Kib     | VGA BIOS ? [3]                        |        |        |
| 0x000CA000 | 0x000CA800 | 2 Kib     | VGA BIOS ? [3]                        |        |        |
| 0x000C8000 | 0x000CBFFF | 16 Kib    | Hard disk controller BIOS [3]         |        |        |
| 0x000CC000 | 0x000CDFFF | 8 Kib     | IBM PC Network NETBIOS [3]            |        |        |
| 0x000C8000 | 0x000EFFFF | 160 Kib   | Reserved?                             |        |        |
| 0x000F0000 | 0x000FFFFF | 64 KiB    | System BIOS                           |        |        |
+------------+------------+-----------+---------------------------------------+--------+--------+
|                                       High memory (> 1 MiB)                                   |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x00100000 | 0x00EFFFFF | 14 MiB    | RAM: Extended memory                  |  FiE   |        |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x00F00000 | 0x00FFFFFF | 1 MiB     | Possible hardware / ISA Memory Hole   |        |        |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0x01000000 | ????????	  | ???       | RAM: More Extended memory             |        |        |
+------------+------------+-----------+---------------------------------------+--------+--------+
| 0xC0000000 | 0xFFFFFFFF | 1 GiB     | various                               |        |        |
+------------+------------+-----------+---------------------------------------+--------+--------+

+-----------------------+
|          KEY          |
+-----+-----------------+
| FiE | Free if Exists  |
| GF  | Guaranteed Free |
| P   | Partially Free  |
| X   | Not Usable      |
+-----+-----------------+
```


### Notes
1. During the PC boot process, the Real Mode IVT and BDA must be carefully preserved, because it is being used. After all the BIOS functions have been called, and your kernel is loaded into memory somewhere, the bootloader or kernel may exit Real Mode forever (often by going into 32bit Protected Mode). If the kernel never uses Real Mode again, then the first 0x500 bytes of memory in the PC may be reused and overwritten.
2. ????
3. Guaranteed free for use
4. Typical location
5. Bootloader code is usually loaded and running in memory at physical addresses 0x7C00 through 0x7DFF. So that memory area is likely to also be unusable until execution has been transferred to a second stage bootloader, or to your kernel.
6. Size depends on EBDA size
7. AT
8. XT
9. not XT
10. PS/2
11. PS/2 exc Mod 30
12. PS/2 Mod 30
13. not PS/2
14. Conv
15. EGA
16. MCGA
17. VGA
18. The entire 32k from 0B0000h to 0B7FFFh is filled with repeats of this 4k area.


## References
* [1] https://wiki.osdev.org/IVT
* [2] http://mirrors.josefsipek.net/www.nondot.org/sabre/os/files/Booting/BIOS_SEG.txt
* [3] http://nerdlypleasures.blogspot.com/2015/03/my-complete-ibm-important-video-card.html
* [4] http://www.seasip.info/VintagePC/index.html
* [5] http://nersp.nerdc.ufl.edu/~esi4161/files/dosman/chap2
