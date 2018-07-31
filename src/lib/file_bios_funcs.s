cpu 8086
bits 16


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
