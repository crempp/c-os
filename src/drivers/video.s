bits 16

global b_get_mode_
global b_set_mode_
global b_clrscr_
global b_mvcurs_
global b_print_
global b_printhex_
global b_printnl_

%define b_get_mode b_get_mode_
%define b_set_mode b_set_mode_
%define b_clrscr b_clrscr_
%define b_mvcurs b_mvcurs_
%define b_print b_print_
%define b_printhex b_printhex_
%define b_printnl b_printnl_

segment _TEXT public align=1 use16 class=CODE

; -----------------------------------------------------------------------------
; Get video mode
;
; PARAMETERS:
;   none
; RETURN:
;   AL - Video mode
; -----------------------------------------------------------------------------
b_get_mode:
    push ax
    push cx
    push dx
    push bx
    push sp
    push bp
    push si
    push di

    mov ah, 0Fh         ; Get video mode
    int 10h

    pop di
    pop si
    pop bp
    pop sp
    pop bx
    pop dx
    pop cx
    pop ax
    ret

b_set_mode:
    nop

%include 'vid_bios_funcs.s'

;segment _DATA public align=1 use16 class=DATA
;HEX_OUT: db '0x0000', EOL
