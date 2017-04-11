; C-OS Single-Stage Bootloader
;
; The C-OS bootloader is fairly simple.
;   * Identify boot drive
;   * Setup stack
;   * Print boot messages
;   * Bring the kernel (and all the kernel needs to bootstrap) into memory
;   * Provide the kernel with the information it needs to work correctly
;   * Switch to 32-bit protected mode
;   * Transfer control to the kernel
[org 0x7c00]                 ; tell the assembler our offset is bootsector code

; Basic Constants
LF  equ 0x0A
CR  equ 0x0D
EOL equ 0x00

; We will use 0x07c0 as the segment used for the bootloarder data, 0x9000 for
; the segment used for the loaded kernel
;
; NOTE - KERNL_SEG:KERNL_OFFSET must match value used with linker
BOOT_SEG        equ 0x0000 ; Bootloader segment
DATA_SEG        equ 0x0200 ; Data segment
STACK_SEG       equ 0x07E0 ; Stack segment
KERNEL_SEG      equ 0x0000 ; Segement used to load kernel
STACK_OFFSET    equ 0x9000 ; Stack offset
KERNEL_OFFSET   equ 0x1000 ; Offset used to load kernel
KERNEL_SECTOR   equ 0x02
KERNEL_CYLINDER equ 0x00
KERNEL_HEAD     equ 0x00
SECTORS_TO_READ equ 9      ; Number of sectors from disk to read (512b each)

; Certain odd BIOSes actually begin execution at 07c0:0000. To deal with this
; discrepancy, the first task the bootloader is to canonicalize CS:EIP to a
; known segment:offset pair that the rest of the code depends on.
; Simultaneously setting %CS:%EIP is accomplished with an absolute long jump
; instruction to a label that represents the next line of code.
;ljmp 0x0, 0x0;$+1
;jmp [0x0000:0x0000]

; Save the boot drive set by the bios on boot
mov [BOOT_DRIVE], dl

; Set stack segment registers
; TODO Use BOOT_SEG, STACK_SEG, KERNEL_SEG from above
cli                          ; Clear interrupts
;mov  ax, BOOT_SEG
mov  ax, DATA_SEG
mov  ds, ax
mov  ax, KERNEL_SEG
mov  es, ax
mov  ss, ax
mov  bp, STACK_OFFSET
mov  sp, STACK_OFFSET
sti

; Print bootloader message
call clear_screen            ; Clear the screen
mov  bx, BIOS_HEAD           ; Print the BIOS header
call print
call print_nl
call print_nl


; Load kernel
mov  bx, MSG_LOAD_KERNEL
call print
mov  bx, KERNEL_OFFSET       ; Read from disk and store in 0x1000
mov  dh, SECTORS_TO_READ     ; Read 2 sectors from disk (1024 bytes)
mov  dl, [BOOT_DRIVE]        ; Read from drive provided earlier by the BIOS
call disk_load
call KERNEL_OFFSET           ; Give control to the kernel
jmp  $                       ; Stay here when the kernel returns control to us
                             ; (if ever)


; -----------------------------------------------------------------------------
; Clears the screen to background
;
; PARAMETERS:
;   none
; RETURN:
;   none
; -----------------------------------------------------------------------------
clear_screen:
    pusha                    ; push general-purpose registers onto the stack

    mov  dx, 0               ; Position cursor at top-left
    call os_move_cursor

    mov  ah, 6               ; Scroll full-screen
    mov  al, 0               ; Normal white on black
    mov  bh, 7               ;
    mov  cx, 0               ; Top-left
    mov  dh, 24              ; Bottom-right
    mov  dl, 79
    int  10h

    popa
    ret


; -----------------------------------------------------------------------------
; Moves cursor in text mode
;
; PARAMETERS:
;   DH - Row
;   DL - Column
; RETURN:
;   none
; -----------------------------------------------------------------------------
os_move_cursor:
    pusha

    mov  bh, 0
    mov  ah, 2
    int  10h                 ; BIOS interrupt to move cursor

    popa
    ret


; -----------------------------------------------------------------------------
; Print string currently pointed to by register BX
;
; PARAMETERS:
;   BX - Pointer to string to print
; RETURN:
;   none
; -----------------------------------------------------------------------------
print:
    pusha                    ; push general-purpose registers onto the stack

    start:
        mov  al, [bx]        ; 'bx' is the base address for the string

        ; If 0 (null)
        cmp  al, 0
        je   done            ; done printing

        ; elseif not LF
        cmp  al, LF
        jne  do_print         ; print the character

        ; else
        call print_nl        ; print newline
        add  bx, 1           ; increment pointer
        jmp  start           ; and do next loop

    do_print:
        mov  ah, 0x0e        ; Set BIOS Int function to Teletype output
        int  0x10            ; Call Int 10h - BIOS video services
        add  bx, 1           ; increment pointer
        jmp  start           ; and do next loop

    done:
        popa                 ; pop general-purpose registers from the stack
        ret                  ; return to calling IP


; -----------------------------------------------------------------------------
; Print newline
;
; PARAMETERS:
;   none
; RETURN:
;   none
; -----------------------------------------------------------------------------
print_nl:
    pusha

    mov  ah, 0x0e
    mov  al, LF
    int  0x10
    mov  al, CR
    int  0x10

    popa
    ret


; -----------------------------------------------------------------------------
; Print hexadecimal value
;
; Strategy: get the last char of 'dx', then convert to ASCII
; Numeric ASCII values: '0' (ASCII 0x30) to '9' (0x39), so just add 0x30 to
; byte N.
; For alphabetic characters A-F: 'A' (ASCII 0x41) to 'F' (0x46) we'll add 0x40
; Then, move the ASCII byte to the correct position on the resulting string
;
; PARAMETERS:
;   DX - Hex value to print
; RETURN:
;   none
; -----------------------------------------------------------------------------
print_hex:
    pusha

    mov  cx, 0               ; our index variable

    hex_loop:
        cmp  cx, 4           ; loop 4 times
        je   end

        ; 1. convert last char of 'dx' to ascii
        mov  ax, dx          ; we will use 'ax' as our working register
        and  ax, 0x000f      ; 0x1234 -> 0x0004 by masking first three to zeros
        add  al, 0x30        ; add 0x30 to N to convert it to ASCII "N"
        cmp  al, 0x39        ; if > 9, add extra 8 to represent 'A' to 'F'
        jle  step2
        add  al, 7           ; 'A' is ASCII 65 instead of 58, so 65-58=7

    step2:
        ; 2. get the correct position of the string to place our ASCII char
        ; bx <- base address + string length - index of char
        mov  bx, HEX_OUT + 5 ; base + length
        sub  bx, cx          ; our index variable
        mov  [bx], al        ; copy the ASCII char on 'al' to the position
                             ; pointed by 'bx'
        ror  dx, 4           ; 0x1234 -> 0x4123 -> 0x3412 -> 0x2341 -> 0x1234

        add  cx, 1           ; increment index
        jmp  hex_loop        ; and loop

    end:

        mov  bx, HEX_OUT     ; prepare the parameter
        call print           ; and call the print function

        popa
        ret


; -----------------------------------------------------------------------------
; load 'dh' sectors from drive 'dl' into ES:BX
;
; PARAMETERS:
;   BX - Memory location to write to (ES:BX)
;   DH - Load 'dh' sectors from drive 'dl'
; RETURN:
;   none
; -----------------------------------------------------------------------------
disk_load:
    pusha
    push dx                  ; save dx which will be overwritten

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
    int  0x13                ; BIOS interrupt
    jc   disk_error          ; if error (stored in the carry bit)

    pop  dx
    cmp  al, dh              ; BIOS also sets 'al' to the # of sectors read. Compare it.
    jne  sectors_error
    popa
    ret

    disk_error:
        mov  bx, DISK_ERROR
        call print
        call print_nl
        mov  dh, ah          ; ah = error code, dl = disk drive that dropped
                             ; the error
        call print_hex       ; check out the code at
                             ; http://stanislavs.org/helppc/int_13-1.html
        jmp  disk_loop

    sectors_error:
        mov  bx, SECTORS_ERROR
        call print

    disk_loop:
        jmp $


; -----------------------------------------------------------------------------
; Data
; -----------------------------------------------------------------------------
DISK_ERROR:      db "Disk read error", EOL
SECTORS_ERROR:   db "Incorrect number of sectors read", EOL
HEX_OUT:         db '0x0000', EOL
BOOT_DRIVE:      db 0
MSG_LOAD_KERNEL: db "Loading kernel into memory", EOL
BIOS_HEAD:
    db 'C-OS-86 0.1', LF
    db 'Copyright (C) 2017, Chad Rempp', LF
    db '16-bit Real Mode', EOL


; -----------------------------------------------------------------------------
; Padding and magic number
; -----------------------------------------------------------------------------
times 510-($-$$) db 0
dw 0xaa55                    ; Magic number identifing this as a boot sector
