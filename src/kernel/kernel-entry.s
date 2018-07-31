; C-OS Kernel entry point
;
; The C-OS kernel entry
;   * Sets up the kernel stack
;   * calls the main kernel function (in C code)
;
; If the main kernel function ever returns (it shouldn't) we halt the machine
cpu 8086
bits 16

STACK_SEGMENT equ 0x07C0
STACK_OFFSET  equ 4096          ; Give a 4k stack size
DATA_SEGMENT  equ 0x0050
EXTRA_SEGMENT equ 0x0050

; -----------------------------------------------------------------------------
; Call the kernel entry point
; -----------------------------------------------------------------------------
segment _TEXT public align=1 use16 class=CODE
extern _cstart_                 ; Define calling point. Must have same name as
                                ; kernel.c 'main' function

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

call _cstart_                ; Calls the C function. The linker will know where
                             ; it is placed in memory
suspend:
    cli
    hlt
    jmp  suspend
