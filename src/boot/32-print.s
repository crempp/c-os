[bits 32] ; using 32-bit protected mode

VIDEO_MEMORY   equ 0xb8000   ; Video memory is located at 0xB8000
WHITE_ON_BLACK equ 0x0f      ; the color byte for each character
VIDEO_ROW      equ 6

; -----------------------------------------------------------------------------
; Print string (protected mode) currently pointed to by register BX
;
; PARAMETERS:
;   EBX - Pointer to string to print
; RETURN:
;   none
; -----------------------------------------------------------------------------
print_pm:
    pusha
    mov edx, VIDEO_MEMORY + ((80 * 2) * VIDEO_ROW)

    print_pm_loop:
        mov al, [ebx]        ; [ebx] is the address of our character
        mov ah, WHITE_ON_BLACK

        cmp al, 0            ; check if end of string
        je print_pm_done

        mov [edx], ax        ; store character + attribute in video memory
        add ebx, 1           ; next char
        add edx, 2           ; next video memory position

        jmp print_pm_loop

    print_pm_done:
        popa
        ret