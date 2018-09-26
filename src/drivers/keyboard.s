; Keyboard Driver Functions
;
; References:
;   * https://stackoverflow.com/a/51694601/1436323
;   * http://inglorion.net/documents/tutorials/x86ostut/keyboard/

cpu 8086
bits 16

global install_keyboard_driver_
%define install_keyboard_driver install_keyboard_driver_

global poll_kbd_buffer_
%define poll_kbd_buffer poll_kbd_buffer_

KBD_BUFSIZE equ 32                 ; Keyboard Buffer length. **Must** be a power of 2
                                   ;     Maximum buffer size is 2^15 (32768)
KBD_IVT_OFFSET equ 9*4             ; Base address of keyboard interrupt (IRQ) in IVT

segment _TEXT public align=1 use16 class=CODE

; -----------------------------------------------------------------------------
; Install the keyboard handler
;
; PARAMETERS:
;   None
; RETURN:
;   None
; -----------------------------------------------------------------------------
install_keyboard_driver:
  push es
  push ax

  xor  ax, ax
  mov  es, ax
  cli                               ; Don't interupt us while updating IVT
  mov word [es:KBD_IVT_OFFSET], keyboard_handler
                                    ; DS set to 0x0000 above. These MOV are
                                    ; relative to DS
                                    ; 0x0000:0x0024 = IRQ1 offset in IVT
  mov word [es:KBD_IVT_OFFSET+2], 0x0050 ; 0x0000:0x0026 = IRQ1 segment in IVT
  sti                               ; Enable interrupts

  pop  ax
  pop  es
  ret

; -----------------------------------------------------------------------------
; Handle keyboard interrupt
;
; PARAMETERS:
;   None
; RETURN:
;   None
; -----------------------------------------------------------------------------
keyboard_handler:
  push ax                           ; Save all registers we modify
  push si
  push cx

  in   al, 0x60                     ; Get keystroke

  mov  cx, [kbd_write_pos]
  mov  si, cx
  sub  cx, [kbd_read_pos]
  cmp  cx, KBD_BUFSIZE              ; If (write_pos-read_pos)==KBD_BUFSIZE
  je .keyboard_handler_end          ; then buffer full, we're finished

  lea cx, [si+1]                    ; Index of next write (tmp = write_pos + 1)
  and si, KBD_BUFSIZE-1             ; Normalize write_pos to be within 0 to KBD_BUFSIZE
  mov [kbd_buffer+si], al           ; Save character to buffer
  mov [kbd_write_pos], cx           ; write_pos++ (write_pos = tmp)

  .keyboard_handler_end:
    mov al, 0x20
    out 0x20, al                    ; Send EOI to Master PIC

    pop cx                          ; Restore all modified registers
    pop si
    pop ax
    iret


; -----------------------------------------------------------------------------
; Check if there's data in the keyboard buffer, if so return it's address, else
; return 0
;
; PARAMETERS:
;   None
; RETURN:
;   AX - keyboard buffer address if data, else 0
; -----------------------------------------------------------------------------
poll_kbd_buffer:
  push si
  push cx
  push bx

  mov  si, [kbd_read_pos]
  cmp  si, [kbd_write_pos]
  je  .poll_kbd_buffer_end_null     ; If (read_pos == write_pos) then buffer empty and
                                    ;     we're finished

  lea  cx, [si+1]                   ; Index of next read (tmp = read_pos + 1)
  and  si, KBD_BUFSIZE-1            ; Normalize read_pos to be within 0 to KBD_BUFSIZE
  mov  al, [kbd_buffer+si]          ; Get next scancode
  mov  [kbd_read_pos], cx           ; read_pos++ (read_pos = tmp)
  test al, 0x80                     ; Is scancode a key up event?
  jne  .poll_kbd_buffer_end_null    ;     If so we are finished

  mov  bx, keyboard_map
  xlat                              ; Translate scancode to ASCII character
  jmp  .poll_kbd_buffer_end

  .poll_kbd_buffer_end_null:
    ; TODO - once we switch to full assembly let's change this to AL
    xor  ax, ax                       ; set return to null

  .poll_kbd_buffer_end:
    pop  bx
    pop  cx
    pop  si
    ret

segment _DATA public align=1 use16 class=DATA

align 2
kbd_read_pos:  dw 0
kbd_write_pos: dw 0
kbd_buffer:    times KBD_BUFSIZE db 0

; TODO: Move this to _CONST

; Scancode to ASCII character translation table
keyboard_map:
    db  0,  27, '1', '2', '3', '4', '5', '6', '7', '8'    ; 9
    db '9', '0', '-', '=', 0x08                           ; Backspace
    db 0x09                                               ; Tab
    db 'q', 'w', 'e', 'r'                                 ; 19
    db 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0x0a       ; Enter key
    db 0                                                  ; 29   - Control
    db 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';'   ; 39
    db "'", '`', 0                                        ; Left shift
    db "\", 'z', 'x', 'c', 'v', 'b', 'n'                  ; 49
    db 'm', ',', '.', '/', 0                              ; Right shift
    db '*'
    db 0                                                  ; Alt
    db ' '                                                ; Space bar
    db 0                                                  ; Caps lock
    db 0                                                  ; 59 - F1 key ... >
    db 0,   0,   0,   0,   0,   0,   0,   0
    db 0                                                  ; < ... F10
    db 0                                                  ; 69 - Num lock
    db 0                                                  ; Scroll Lock
    db 0                                                  ; Home key
    db 0                                                  ; Up Arrow
    db 0                                                  ; Page Up
    db '-'
    db 0                                                  ; Left Arrow
    db 0
    db 0                                                  ; Right Arrow
    db '+'
    db 0                                                  ; 79 - End key
    db 0                                                  ; Down Arrow
    db 0                                                  ; Page Down
    db 0                                                  ; Insert Key
    db 0                                                  ; Delete Key
    db 0,   0,   0
    db 0                                                  ; F11 Key
    db 0                                                  ; F12 Key
    times 128 - ($-keyboard_map) db 0                     ; All other keys are undefined
