bits 16
; -----------------------------------------------------------------------------
; Call the kernel entry point
; -----------------------------------------------------------------------------
segment _TEXT public align=1 use16 class=CODE
extern _cstart_              ; Define calling point. Must have same name as
                             ; kernel.c 'main' function
call _cstart_                ; Calls the C function. The linker will know where
                             ; it is placed in memory
jmp $

