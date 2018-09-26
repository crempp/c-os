; Video Driver Functions
;
; References:
;   * https://www.seasip.info/VintagePC/mda.html

cpu 8086
bits 16

global v_clr_screen_
%define v_clr_screen v_clr_screen_

global v_get_mode_
%define v_get_mode v_get_mode_

global v_mv_cursor_
%define v_mv_cursor v_mv_cursor_

global v_print_
%define v_print v_print_

global v_print_hex_
%define v_print_hex v_print_hex_

global v_print_nl_
%define v_print_nl v_print_nl_

global v_putch_
%define v_putch v_putch_

global v_set_mode_
%define v_set_mode v_set_mode_

global v_set_page_
%define v_set_page v_set_page_

; Basic Constants
LF  equ 0x0A
CR  equ 0x0D
EOL equ 0x00
FOREGROUND_COLOR equ 0x07


segment _TEXT public align=1 use16 class=CODE


; -----------------------------------------------------------------------------
; Clears the screen to background using BIOS
;
; PARAMETERS:
;   none
; RETURN:
;   none
; -----------------------------------------------------------------------------
v_clr_screen:
  push ax
  push cx
  push dx
  push bx
  push bp                           ; Some implementations (including the orig
                                    ; IBM PC) have a bug which destroys BP.

  mov  ah, 6                        ; scroll window function
  mov  al, 0                        ; scroll full-screen
  mov  bh, 0x7                      ; fill attribute
  mov  cx, 0                        ; Top-left
  mov  dh, 24                       ; Bottom
  mov  dl, 79                       ; Right
  int  0x10

  mov  ax, 0                        ; Position cursor at top
  mov  dx, 0                        ; Position cursor at left
  call v_mv_cursor

  pop bp
  pop bx
  pop dx
  pop cx
  pop ax
  ret


; -----------------------------------------------------------------------------
; Get video mode
;
; The BIOS function returns
;   AH = number of character columns
;   AL = display mode (see #00010 at AH=00h)
;   BH = active page (see AH=05h)
;
; PARAMETERS:
;   none
; RETURN:
;   AL - Video mode
; -----------------------------------------------------------------------------
v_get_mode:
  mov  ah, 0x0F
  int  0x10
  ret


; -----------------------------------------------------------------------------
; Moves cursor in text mode using BIOS
;
; PARAMETERS:
;   AX - Row
;   DX - Column
; RETURN:
;   none
; -----------------------------------------------------------------------------
v_mv_cursor:
  push ax
  push bx
  push dx

  mov  bx, active_page            ; Get the address for the active page value
  mov  dh, [bx]                   ; Retrieve the value
  mov  bh, dh                     ; Set BH to the active page number

  mov  dh, al                     ; Row - move from parameter AX to DH
                                  ; Column - DL is already passed from param

  mov  ah, 0x02
  int  0x10

  pop  dx
  pop  bx
  pop  ax
  ret


; -----------------------------------------------------------------------------
; Print string currently pointed to by register BX using BIOS
;
; TODO:
;   * Refactor so I don't need mov  bx, ax
;   * Use v_putch to save on code
;
; PARAMETERS:
;   AX - Pointer to string to print
; RETURN:
;   none
; -----------------------------------------------------------------------------
v_print:
  push ax
  push cx
  push bx
  push dx
  push bp

  mov  bx, ax
  start:
    mov  al, [bx]                   ; 'bx' is the base address for the string

    cmp  al, 0                      ; If 0 (null)
    je   done                       ; done printing

    jne  do_print                   ; print the character
    jmp  start                      ; and do next loop

  do_print:
    push bx
    mov  bx, active_page            ; Get the address for the active page value
    mov  dh, [bx]                   ; Retrieve the value
    mov  bh, dh                     ; Set BH to the active page number
    mov  bl, FOREGROUND_COLOR
    mov  ah, 0x0e                   ; Set BIOS Int function to Teletype output
    int  0x10                       ; Call Int 10h - BIOS video services
    pop  bx
    add  bx, 1                      ; increment pointer
    jmp  start                      ; and do next loop

  done:
    pop  bp
    pop  dx
    pop  bx
    pop  cx
    pop  ax
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
;   AX - Hex value to print
; RETURN:
;   none
; -----------------------------------------------------------------------------
v_print_hex:
  push ax
  push cx
  push dx
  push bx

  mov  cx, 0                        ; our index variable
  mov  dx, ax                       ; DX will be the numerical value
  hex_loop:
    cmp  cx, 4                      ; loop 4 times
    je   end

    ; 1. convert last char of 'dx' to ascii
    mov  ax, dx                     ; we will use 'ax' as our working register
    and  ax, 0x000f                 ; 0x1234 -> 0x0004 by masking first 3 to 0s
    add  al, 0x30                   ; add 0x30 to N to convert it to ASCII "N"
    cmp  al, 0x39                   ; if > 9, add 8 to represent 'A' to 'F'
    jle  step2
    add  al, 7                      ; 'A' is ASCII 65 instead of 58, so 65-58=7

  step2:
    ; 2. get the correct position of the string to place our ASCII char
    ; bx <- base address + string length - index of char
    mov  bx, hex_out + 5            ; base + length
    sub  bx, cx                     ; our index variable
    mov  [bx], al                   ; copy the ASCII char on 'al' to the position
                                    ; pointed by 'bx'
    push cx
    mov  cl, 4
    ror  dx, cl                     ; 0x1234 -> 0x4123 -> 0x3412 -> 0x2341 -> 0x1234
    pop  cx

    add  cx, 1                      ; increment index
    jmp  hex_loop                   ; and loop

  end:
    mov  ax, hex_out                ; prepare the parameter
    call v_print                    ; and call the print function

  pop bx
  pop dx
  pop cx
  pop ax
  ret


; -----------------------------------------------------------------------------
; Print newline using BIOS
;
; PARAMETERS:
;   none
; RETURN:
;   none
; -----------------------------------------------------------------------------
v_print_nl:
  push ax
  mov  ax, newline                ; prepare the parameter
  call v_print                    ; and call the print function
  pop  ax
  ret


; -----------------------------------------------------------------------------
; Print a single character at the cursor location
;
; PARAMETERS:
;   AL - Character to print
; RETURN:
;   none
; -----------------------------------------------------------------------------
v_putch:
  push bx
  push dx
  mov  bx, active_page              ; Get the address for the active page value
  mov  dh, [bx]                     ; Retrieve the value
  mov  bh, dh                       ; Set BH to the active page number
  mov  bl, FOREGROUND_COLOR
  mov  ah, 0x0e                     ; Set BIOS Int function to Teletype output
  int  0x10                         ; Call Int 10h - BIOS video services
  pop  dx
  pop  bx
  ret


; -----------------------------------------------------------------------------
; Set the BIOS video mode
;
; TODO: Error checking. To determine whether the requested page actually exists,
;       use AH=0Fh to query the current page after making this call
;
; PARAMETERS:
;   BL - Mode
; RETURN:
;   none
; -----------------------------------------------------------------------------
v_set_mode:
  nop

; -----------------------------------------------------------------------------
; Set the BIOS video page
;
; TODO: Error checking. To determine whether the requested page actually exists,
;       use AH=0Fh to query the current page after making this call
;
; PARAMETERS:
;   BL - Page
; RETURN:
;   none
; -----------------------------------------------------------------------------
v_set_page:
  push ax
  push cx

  mov  cl, bl
  mov  bx, active_page
  mov  [bx], cl

  mov  ah, 0x05                     ; Select active display page function
  int  0x10

  pop cx
  pop ax
  ret


segment _DATA public align=1 use16 class=DATA
hex_out:     db '0x0000', EOL
active_page: db 0x0
newline:     db CR, LF, EOL
