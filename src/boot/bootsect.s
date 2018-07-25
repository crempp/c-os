; C-OS Single-Stage Bootloader
;
; The C-OS bootloader is fairly simple.
;   * Identify boot drive
;   * Setup stack
;   * Print boot messages
;   * Bring the kernel (and all the kernel needs to bootstrap) into memory
;   * Provide the kernel with the information it needs to work correctly
;   * Transfer control to the kernel
;
; Disk Geometries
;-------------------------------------------------------------------------------
;     163,840 bytes  (160K) c=40 h=1 s=8     5.25" SSSD
;     184,320 bytes  (180K) c=40 h=1 s=9     5.25" SSSD
;     327,680 bytes  (320K) c=40 h=2 s=8     5.25" DSDD
;     368,640 bytes  (360K) c=40 h=2 s=9     5.25" DSDD
;     655,360 bytes  (640K) c=80 h=2 s=8     3.5"  DSDD
;     737,280 bytes  (720K) c=80 h=2 s=9     3.5"  DSDD
;   1,222,800 bytes (1200K) c=80 h=2 s=15    5.25" DSHD
;   1,474,560 bytes (1440K) c=80 h=2 s=18    3.5"  DSHD
;   1,638,400 bytes (1600K) c=80 h=2 s=20    3.5"  DSHD (extended)
;   1,720,320 bytes (1680K) c=80 h=2 s=21    3.5"  DSHD (extended)
;   1,763,328 bytes (1722K) c=82 h=2 s=21    3.5"  DSHD (extended)
;   1,784,832 bytes (1743K) c=83 h=2 s=21    3.5"  DSHD (extended)
;   1,802,240 bytes (1760K) c=80 h=2 s=22    3.5"  DSHD (extended)
;   1,884,160 bytes (1840K) c=80 h=2 s=23    3.5"  DSHD (extended)
;   1,966,080 bytes (1920K) c=80 h=2 s=24    3.5"  DSHD (extended)
;   2,949,120 bytes (2880K) c=80 h=2 s=36    3.5"  DSED
;   3,194,880 bytes (3120K) c=80 h=2 s=39    3.5"  DSED (extended)
;   3,276,800 bytes (3200K) c=80 h=2 s=40    3.5"  DSED (extended)
;   3,604,480 bytes (3520K) c=80 h=2 s=44    3.5"  DSED (extended)
;   3,932,160 bytes (3840K) c=80 h=2 s=48    3.5"  DSED (extended)
; https://www.syslinux.org/wiki/index.php?title=MEMDISK

[org 0x7c00]                 ; tell the assembler our offset is bootsector code

; -----------------------------------------------------------------------------
; Bootloader constants
; -----------------------------------------------------------------------------
BOOT_SEGMENT    equ 0x0000  ; Boot segment
BOOT_OFFSET     equ 0x7C00
STACK_SEGMENT   equ 0x07E0  ; Set the stack segment to the top of our bootloader
STACK_OFFSET    equ 4096    ; Give a 4k stack size
DATA_SEGMENT    equ 0x0000  ; Set data segment to where we're loaded so we can
                            ; implicitly access all 64K
; NOTE - KERNEL_SEGMENT:KERNEL_OFFSET must match value used with linker
KERNEL_SEGMENT  equ 0x0050  ; Segement used to load kernel
KERNEL_OFFSET   equ 0x0000  ; Offset used to load kernel
KERNEL_SECTOR   equ 0x02    ; Disk sector where kernel is located
KERNEL_CYLINDER equ 0x00    ; Disk cylinder where kernel is located
KERNEL_HEAD     equ 0x00    ; Disk head where kernel is located
SECTORS_TO_READ equ 59      ; Number of sectors from disk to read (512b each)

; -----------------------------------------------------------------------------
; Bootloader
; -----------------------------------------------------------------------------

; Canonicalize CS:IP
jmp BOOT_SEGMENT:canonicalized
canonicalized:

; Save the boot drive set by the bios on boot
mov [BOOT_DRIVE], dl

; Set segment registers. These values are only for the bootloader. We'll reset
; them once in the kernel.
cli                         ; Clear interrupts
mov ax, STACK_SEGMENT       ; Set the stack segment and offset
mov ss, ax
mov bp, STACK_OFFSET
mov sp, bp
mov ax, DATA_SEGMENT        ; Set the data segment
mov ds, ax
mov ax, KERNEL_SEGMENT      ; Set the kernel segment (uses ES register when loading)
mov es, ax
sti

; Print bootloader message
call b_clrscr               ; Clear the screen
; mov  bx, MSG_BOOT           ; Print the boot message
mov  ax, MSG_BOOT           ; Print the boot message
call b_print

; TODO: Print the available memory

; Load kernel
; mov  bx, MSG_LOAD_KERNEL
mov  ax, MSG_LOAD_KERNEL
call b_print
mov  bx, KERNEL_OFFSET       ; Read from disk and store in 0x1000
mov  dh, SECTORS_TO_READ     ; Read 2 sectors from disk (1024 bytes)
mov  dl, [BOOT_DRIVE]        ; Read from drive provided earlier by the BIOS
call disk_load
call KERNEL_SEGMENT:KERNEL_OFFSET ; Give control to the kernel
jmp  $                       ; Stay here when the kernel returns control to us
                             ; (if ever)

; -----------------------------------------------------------------------------
; load 'dh' sectors from drive 'dl' into ES:BX
;
; Note: Since this OS is for PC/XT systems we can't use Disk functions > 05h as
; those functions are only available for ATs. This makes things difficult.
;
; PARAMETERS:
;   BX - Memory location to write to (ES:BX)
;   DH - Load 'dh' sectors from drive 'dl'
; RETURN:
;   none
; -----------------------------------------------------------------------------
disk_load:
    push ax
    push cx
    push dx

    mov cx, 3                    ; countdown of read attempts
    readloop:
        push cx
        ; Reset disk (dl - boot device is passed in)
        mov  ah, 0               ; ah <- int 0x13 function. 0x00 = 'reset'
        stc                      ; Set carry bit, needed for some bios'
        int  0x13                ; BIOS interrupt

        ; Read sectors
        mov  ah, 0x02            ; ah <- int 0x13 function. 0x02 = 'read'
        mov  al, dh              ; al <- number of sectors to read (0x01 .. 0x80)
        mov  cl, KERNEL_SECTOR   ; cl <- sector (0x01 .. 0x11)
                                 ; 0x01 is our boot sector, 0x02 is the first
                                 ; 'available' sector
        mov  ch, KERNEL_CYLINDER ; ch <- cylinder (0x0 .. 0x3FF, upper 2 bits in 'cl')
                                 ; dl <- drive number. Our caller sets it as a
                                 ; parameter and gets it from BIOS
                                 ; (0 = floppy, 1 = floppy2, 0x80 = hdd, 0x81 = hdd2)
        mov  dh, KERNEL_HEAD     ; dh <- head number (0x0 .. 0xF)

        ; [es:bx] <- pointer to buffer where the data will be stored
        ; caller sets it up for us, and it is actually the standard location for int 13h
        stc                      ; Set carry bit, needed for some bios'
        int  0x13                ; BIOS interrupt
        pop cx
        jnc disk_load_continue   ; if not error (stored in the carry bit)
        loop readloop            ; If there's an error try again, up to 3 times
        jc   disk_error          ; Finally, if error print message

        disk_load_continue:
        pop  dx                  ; Retrieve the dl and dh parameters passed
        ; TODO: I'm not getting # of sectors read back from the BIOS. Look into this
        ;cmp  al, dh              ; BIOS also sets 'al' to the # of sectors read. Compare it.
        ;jne  sectors_error

    pop cx
    pop ax
    ret

    disk_error:
        ; mov  bx, DISK_ERROR
        mov  ax, DISK_ERROR
        call b_print
        call b_printnl
        mov  dh, ah          ; ah = error code, dl = disk drive that dropped
                             ; the error
        call b_print_hex     ; check out the code at
                             ; http://stanislavs.org/helppc/int_13-1.html
        jmp  disk_loop

    ;sectors_error:
    ;    mov  bx, SECTORS_ERROR
    ;    call b_print

    disk_loop:
        jmp $

%include 'vid_bios_funcs.s'

; -----------------------------------------------------------------------------
; Data
; -----------------------------------------------------------------------------
DISK_ERROR:      db "Disk read error", LF, CR, EOL
;SECTORS_ERROR:   db "Incorrect number of sectors read", LF, CR, EOL
BOOT_DRIVE:      db 0
MSG_LOAD_KERNEL: db "Loading the kernel...", LF, CR, EOL
MSG_BOOT:
    db LF, CR
    db 'C-OS-86 0.1 07-15-2018', LF, CR
    db 'Copyright (C) 2018, Chad Rempp', CR, LF
    db LF, CR, LF, CR, EOL


; -----------------------------------------------------------------------------
; Padding and magic number
; -----------------------------------------------------------------------------
times 510-($-$$) db 0
dw 0xaa55                    ; Magic number identifing this as a boot sector
