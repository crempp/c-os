[org 0x7c00] ; tell the assembler that our offset is bootsector code


call clear_screen            ; Clear the screen

mov bx, BIOS_HEAD            ; Print the BIOS header
call print
call print_nl
call print_nl
mov dx, 0x12fe
call print_hex

jmp $                        ; Loop forever


; remember to include subroutines below the hang
%include "src/boot/print.s"


; data
BIOS_HEAD:
    db 'C-OS-86 0.1', 10
    db 'Copyright (C) 2017, Chad Rempp', 0


; padding and magic number
times 510-($-$$) db 0
dw 0xaa55
