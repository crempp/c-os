cpu 8086
bits 16

; Basic Constants
LF  equ 0x0A
CR  equ 0x0D
EOL equ 0x00

; -----------------------------------------------------------------------------
; Clears the screen to background using BIOS
;
; PARAMETERS:
;   none
; RETURN:
;   none
; -----------------------------------------------------------------------------
b_clrscr:
    push ax
    push cx
    push dx
    push bx

    mov  dx, 0               ; Position cursor at top-left
    call b_mvcurs

    mov  ah, 6               ; Scroll full-screen
    mov  al, 0               ; Normal white on black
    mov  bh, 7               ;
    mov  cx, 0               ; Top-left
    mov  dh, 24              ; Bottom-right
    mov  dl, 79
    int  10h

    pop bx
    pop dx
    pop cx
    pop ax
    ret


; -----------------------------------------------------------------------------
; Moves cursor in text mode using BIOS
;
; PARAMETERS:
;   DH - Row
;   DL - Column
; RETURN:
;   none
; -----------------------------------------------------------------------------
b_mvcurs:
    push ax
    push bx

    mov  bh, 0
    mov  ah, 2
    int  10h                 ; BIOS interrupt to move cursor

    pop bx
    pop ax
    ret


; -----------------------------------------------------------------------------
; Print string currently pointed to by register BX using BIOS
;
; PARAMETERS:
;   BX - Pointer to string to print
; RETURN:
;   none
; -----------------------------------------------------------------------------
b_print:
    push ax
    push cx
    push bx

    mov  bx, ax
    start:
        mov  al, [bx]        ; 'bx' is the base address for the string

        ; If 0 (null)
        cmp  al, 0
        je   done            ; done printing

        jne  do_print        ; print the character
        jmp  start           ; and do next loop

    do_print:
        push bx
        mov  bh, 0           ; Set the color/page number
        mov  ah, 0x0e        ; Set BIOS Int function to Teletype output
        int  0x10            ; Call Int 10h - BIOS video services
        pop  bx
        add  bx, 1           ; increment pointer
        jmp  start           ; and do next loop

    done:
        pop bx
        pop cx
        pop ax
        ret                  ; return to calling IP


; -----------------------------------------------------------------------------
; Print newline using BIOS
;
; PARAMETERS:
;   none
; RETURN:
;   none
; -----------------------------------------------------------------------------
b_printnl:
    push ax
    push bx

    mov  bx, 0           ; Set the color/page number
    mov  ah, 0x0e        ;
    mov  al, LF
    int  0x10
    mov  al, CR
    int  0x10

    pop bx
    pop ax
    ret


; -----------------------------------------------------------------------------
; Print hexadecimal value using BIOS
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
b_print_hex:
  push ax
  push cx
  push dx
  push bx

  mov  cx, 0                    ; our index variable
  hex_loop:
    cmp  cx, 4                  ; loop 4 times
    je   end

    ; 1. convert last char of 'dx' to ascii
    mov  ax, dx                 ; we will use 'ax' as our working register
    and  ax, 0x000f             ; 0x1234 -> 0x0004 by masking first three to zeros
    add  al, 0x30               ; add 0x30 to N to convert it to ASCII "N"
    cmp  al, 0x39               ; if > 9, add extra 8 to represent 'A' to 'F'
    jle  step2
    add  al, 7                  ; 'A' is ASCII 65 instead of 58, so 65-58=7

  step2:
    ; 2. get the correct position of the string to place our ASCII char
    ; bx <- base address + string length - index of char
    mov  bx, hex_out + 5        ; base + length
    sub  bx, cx                 ; our index variable
    mov  [bx], al               ; copy the ASCII char on 'al' to the position
                                ; pointed by 'bx'
    push cx
    mov  cl, 4
    ror  dx, cl                 ; 0x1234 -> 0x4123 -> 0x3412 -> 0x2341 -> 0x1234
    pop  cx

    add  cx, 1                  ; increment index
    jmp  hex_loop               ; and loop

  end:
    mov  bx, hex_out            ; prepare the parameter
    call b_print                ; and call the print function

  pop bx
  pop dx
  pop cx
  pop ax
  ret

;segment _DATA public align=1 use16 class=DATA
hex_out: db '0x0000', EOL
;HEX_OUT: db '0x5544', EOL
