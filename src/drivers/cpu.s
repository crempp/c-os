cpu 8086
bits 16

global farpeek_
%define farpeek farpeek_

global farpoke_
%define farpoke farpoke_

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
; Receives an 8-bit value from an I/O location
;
; PARAMETERS:
;   AX - I/O port address
; RETURN:
;   AL - Value from port
; -----------------------------------------------------------------------------
inb:
  push dx
  mov  dx, ax
  in   al, dx
  pop  dx
  ret


; -----------------------------------------------------------------------------
; Receives an 16-bit value from an I/O location
;
; PARAMETERS:
;   AX - I/O port address
; RETURN:
;   AX - Value from port
; -----------------------------------------------------------------------------
inw:
  push dx
  mov  dx, ax
  in   ax, dx
  pop  dx
  ret


; -----------------------------------------------------------------------------
; Sends an 8-bit value on a I/O location.
;
; PARAMETERS:
;   AX - Value to write to port
;   DX - I/O port address
; RETURN:
;   None
; -----------------------------------------------------------------------------
outb:
  out dx, al
  ret


; -----------------------------------------------------------------------------
; Sends an 16-bit value on a I/O location.
;
; PARAMETERS:
;   AX - Value to write to port
;   DX - I/O port address
; RETURN:
;   None
; -----------------------------------------------------------------------------
outw:
  out dx, ax
  ret


; -----------------------------------------------------------------------------
; Put the CPU into a permanent suspended state
;
; PARAMETERS:
;   None
; RETURN:
;   None
; -----------------------------------------------------------------------------
global suspend_
%define suspend suspend_
suspend:
  cli
  hlt
  jmp  suspend
