cpu 8086
bits 16

global farpeek
global farpoke
global suspend

segment _TEXT public align=1 use16 class=CODE

; -----------------------------------------------------------------------------
; Read a 16-bit value at a given memory location using another segment than the
; default C data segment.
;
; PARAMETERS:
;   AX - Offset
;   DX - Address
; RETURN:
;   AX - Peeked value
; -----------------------------------------------------------------------------
farpeek:
  push es
  push bx

  mov  bx, dx                       ; We can only use BX as a mem index
  mov  es, ax                       ; Set segment to passed offset
  mov  ax, [es:bx]                  ; Peek-a-boo

  pop  bx
  pop  es
  ret


; -----------------------------------------------------------------------------
; Write a 8/16/32-bit value to a segment:offset address too. Note that much like
; in farpeek, this version of farpoke saves and restore the segment register
; used for the access.
;
; PARAMETERS:
;   AX - Offset
;   DX - Address
;   BX - Value
; RETURN:
;   none
; -----------------------------------------------------------------------------
farpoke:
  push es

  xchg bx, dx                       ; We need the mem index in BX
  mov  es, ax                       ; Set segment to passed offset
  mov  [es:bx], dx                  ; Poke-a-roo

  pop  es
  ret


; -----------------------------------------------------------------------------
; Put the CPU into a permanent suspended state
;
; PARAMETERS:
;   None
; RETURN:
;   None
; -----------------------------------------------------------------------------
suspend:
  cli
  hlt
  jmp  suspend
