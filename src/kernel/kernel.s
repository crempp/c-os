; C-OS Kernel entry point
;
; The C-OS kernel entry
;   * Sets up the kernel stack
;   * calls the main kernel function
;
; If the main kernel function ever returns (it shouldn't) we halt the machine
cpu 8086
bits 16

STACK_SEGMENT equ 0x07C0
STACK_OFFSET  equ 4096          ; Give a 4k stack size
DATA_SEGMENT  equ 0x0050
EXTRA_SEGMENT equ 0x0050

global start_

extern install_keyboard_driver
extern v_set_page
extern v_clr_screen
extern v_print
extern v_print_nl
extern poll_kbd_buffer
extern v_putch
extern v_get_mode
extern v_print_hex

; -----------------------------------------------------------------------------
; Call the kernel entry point
; -----------------------------------------------------------------------------
segment _TEXT public align=1 use16 class=CODE

start_:
    ; Set segment registers. It is assumed CS is set by a proper far jump in the
    ; bootloader.
    cli                             ; Clear interrupts
    mov  ax, STACK_SEGMENT          ; Set the stack segment and offset
    mov  ss, ax
    mov  bp, STACK_OFFSET
    mov  sp, bp
    mov  ax, DATA_SEGMENT           ; Set the data segment
    mov  ds, ax
    mov  ax, EXTRA_SEGMENT          ; Set the kernel segment
    mov  es, ax
    sti

    call main

main:
  call install_keyboard_driver

  mov  bl, 0
  call v_set_page

  call v_clr_screen

  mov  ax, shell_msg
  call v_print

  call v_print_nl

  mov  ax, shell_prompt
  call v_print

  kernel_loop:
    call poll_kbd_buffer
    cmp ax, 0
    je no_key
      call v_putch
    no_key:
    jmp kernel_loop

suspend:
    cli
    hlt
    jmp  suspend

debug_info:
  call v_print_nl
  mov  ax, debug_vmode_msg
  call v_print
  call v_get_mode
  call v_print_hex
  call v_print_nl

segment _DATA public align=1 use16 class=DATA
  shell_msg:       db 'c-os version 0.1', 0
  shell_prompt:    db '> ', 0
  debug_vmode_msg: db 'Video Mode: ', 0
