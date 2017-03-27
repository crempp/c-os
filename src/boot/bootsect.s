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

KERNEL_OFFSET equ 0x1000     ; The memory location of the kernel. This is the
                             ; same location we use when linking the kernel
mov [BOOT_DRIVE], dl         ; The BIOS sets the boot drive in 'dl' on boot
mov bp, 0x9000               ; set the stack safely away from us
mov sp, bp

; Print 16 bit header
call clear_screen            ; Clear the screen
mov bx, BIOS_HEAD            ; Print the BIOS header
call print
call print_nl
call print_nl


; Load kernel and enter protected mode
call load_kernel             ; read the kernel from disk
call KERNEL_OFFSET           ; Give control to the kernel
jmp $                        ; Stay here when the kernel returns control to us
                             ; (if ever)


; remember to include subroutines below the hang
%include "src/boot/print.s"
%include "src/boot/disk.s"


load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print
    mov bx, KERNEL_OFFSET    ; Read from disk and store in 0x1000
    mov dh, 2                ; Read 2 sectors from disk (1024 bytes)
    mov dl, [BOOT_DRIVE]     ; Read from drive provided earlier by the BIOS
    call disk_load
    ret


; data
BOOT_DRIVE: db 0             ; It is a good idea to store it in memory because
                             ; 'dl' may get overwritten
MSG_LOAD_KERNEL: db "Loading kernel into memory", 0
BIOS_HEAD:
    db 'C-OS-86 0.1', 10
    db 'Copyright (C) 2017, Chad Rempp', 10
    db '16-bit Real Mode', 0


; padding and magic number
times 510-($-$$) db 0
dw 0xaa55                    ; Magic number identifing this as a boot sector
