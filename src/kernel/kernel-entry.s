; -----------------------------------------------------------------------------
; Call the kernel entry point
; -----------------------------------------------------------------------------
[bits 16]
[extern _cstart_]            ; Define calling point. Must have same name as
                             ; kernel.c 'main' function
segment code
call _cstart_                ; Calls the C function. The linker will know where
                             ; it is placed in memory
jmp $

segment data

; This fixes the warning
; Warning! W1014: stack segment not found
; but I'm not sure... I should already have a stack from bootsect, right?
segment stack class=stack
;        resb 512 ; 64 is too little for interrupts
        resb 64 ; 64 is too little for interrupts
