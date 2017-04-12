bits 16

global v_clrscr_
global v_mvcurs_
global v_print_
global v_printhex_
global v_printnl_

%define v_clrscr v_clrscr_
%define v_mvcurs v_mvcurs_
%define v_print v_print_
%define v_printhex v_printhex_
%define v_printnl v_printnl_

; Basic Constants
LF  equ 0x0A
CR  equ 0x0D
EOL equ 0x00

segment _TEXT public align=1 use16 class=CODE
; -----------------------------------------------------------------------------
; Clears the screen to background
;
; PARAMETERS:
;   none
; RETURN:
;   none
; -----------------------------------------------------------------------------
v_clrscr:
    push bp
    pusha               ; push general-purpose registers onto the stack

    mov dx, 0           ; Position cursor at top-left
    call v_mvcurs

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
;   AX - Row
;   DX - Column
; RETURN:
;   none
; -----------------------------------------------------------------------------
v_mvcurs:
    push bp
    pusha

    ; move the parameters from the registers they were passed
    ; NOTE dl is already what it should be by col being passed through dx
    mov  dh, al

    mov  bh, 0
    mov  ah, 2
    int  10h            ; BIOS interrupt to move cursor

    popa
    pop  bp
    ret

; -----------------------------------------------------------------------------
; Print string currently pointed to by register BX
;
; PARAMETERS:
;   AX - Pointer to start of string to print
; RETURN:
;   none
; -----------------------------------------------------------------------------
v_print:
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
        call v_printnl       ; print newline
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
v_printnl:
    pusha

    mov ah, 0x0e
    mov al, LF
    int 0x10
    mov al, CR
    int 0x10

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
;   AX - Hex value to print
; RETURN:
;   none
; -----------------------------------------------------------------------------
v_printhex:
    pusha

    mov  dx, ax              ; move the params from the regs they were passed
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
        mov  [ds:bx], al     ; copy the ASCII char on 'al' to the position
                             ; pointed by 'bx'
        ror  dx, 4           ; 0x1234 -> 0x4123 -> 0x3412 -> 0x2341 -> 0x1234

        add  cx, 1           ; increment index
        jmp  hex_loop        ; and loop

    end:

        mov  ax, HEX_OUT     ; prepare the parameter
        call v_print         ; and call the print function

        popa
        ret

segment _DATA public align=1 use16 class=DATA
HEX_OUT: db '0x0000', EOL