bits 16

global clear_screen_
global os_move_cursor
global b_print_
;global print_nl

%define clear_screen clear_screen_
%define b_print b_print_

segment _TEXT public align=1 use16 class=CODE
; -----------------------------------------------------------------------------
; Clears the screen to background
;
; PARAMETERS:
;   none
; RETURN:
;   none
; -----------------------------------------------------------------------------
clear_screen:
    push bp
    pusha               ; push general-purpose registers onto the stack

    mov dx, 0           ; Position cursor at top-left
    call os_move_cursor

    mov ah, 6           ; Scroll full-screen
    mov al, 0           ; Normal white on black
    mov bh, 7           ;
    mov cx, 0           ; Top-left
    mov dh, 24          ; Bottom-right
    mov dl, 79

    int 10h

    popa
    pop bp
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
    push bp
    pusha

    mov bh, 0
    mov ah, 2
    int 10h             ; BIOS interrupt to move cursor

    popa
    pop bp
    ret

; -----------------------------------------------------------------------------
; Print string currently pointed to by register BX
;
; PARAMETERS:
;   AX - Pointer to start of string to print
; RETURN:
;   none
; -----------------------------------------------------------------------------
b_print:
    pusha

    mov bx, ax               ; get the parameter address

    start:
        mov al, [bx]         ; 'bx' is the base address for the string

        ; If 0 (null)
        cmp al, 0
        je done              ; done printing

        ; elseif not 10 (LF)
        cmp al, 10
        jne do_print         ; print the character

        ; else
        call print_nl        ; print newline
        add bx, 1            ; increment pointer
        jmp start            ; and do next loop

    do_print:
        mov ah, 0x0e         ; Set BIOS Int function to Teletype output
        int 0x10             ; Call Int 10h - BIOS video services
        add bx, 1            ; increment pointer
        jmp start            ; and do next loop

    done:
        popa
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

    mov ah, 0x0e
    mov al, 0x0a ; newline char
    int 0x10
    mov al, 0x0d ; carriage return
    int 0x10

    popa
    ret
