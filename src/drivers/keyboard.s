;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [ c-os ] keyboard.s                        (c) Chad Rempp 2018 - MIT License
;   Keyboard driver
;
; Much of this was heavily inspired by the Snowdrop OS
;   http://sebastianmihai.com/snowdrop/
;
; References:
;   * https://stackoverflow.com/a/51694601/1436323
;   * http://inglorion.net/documents/tutorials/x86ostut/keyboard/
;   * https://en.wikipedia.org/wiki/Code_page_437
;   * https://wiki.osdev.org/PS/2_Keyboard
;   * https://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cpu 8086
bits 16

global keyboard_initialize_
%define keyboard_initialize keyboard_initialize_

global poll_kbd_buffer_
%define poll_kbd_buffer poll_kbd_buffer_

KBD_BUFSIZE equ 32                 ; Keyboard Buffer length. **Must** be a power of 2
                                   ;     Maximum buffer size is 2^15 (32768)
KBD_IVT_OFFSET equ 9*4             ; Base address of keyboard interrupt (IRQ) in IVT

; driver modes
MODE_PASS_THROUGH	equ 0	; off - delegate everything to previous handler
MODE_LOCAL_ONLY		equ 1	; on - ignore previous handler

KEY_STATE_NOT_PRESSED	equ 0
KEY_STATE_PRESSED 		equ 1
; First byte is delay value (00h = 250ms to 03h = 1000ms)
; Second byte is repeat rate (00h=30/sec to 0Ch=10/sec [def] to 1Fh=2/sec)
KEY_RATE_AND_DELAY    equ 0x0000

KEY_RELEASED_EVENT_FLAG equ 80h	; when this bit is set, the key was released

segment _TEXT public align=1 use16 class=CODE

; -----------------------------------------------------------------------------
; Install the keyboard handler
;
; PARAMETERS:
;   None
; RETURN:
;   None
; -----------------------------------------------------------------------------
keyboard_initialize:
  push es
  push ax
  push dx
  push bx

  ; Configure keyboard typematic rate
	mov  ax, 0x0305                    ; function 03, sub-function 05
	mov  bx, KEY_RATE_AND_DELAY
	int  16h

  ; Set driver mode to passthrough by default
  ;mov  word [keyboard_driver_mode], MODE_PASS_THROUGH
  mov  word [keyboard_driver_mode], MODE_LOCAL_ONLY

  ; Interupts are in segment 0x0000
  xor  ax, ax
  mov  es, ax

  ; Save old handler address, so our handler can invoke it
  mov  bx, [es:KBD_IVT_OFFSET]
  mov  dx, [es:KBD_IVT_OFFSET+2]
	mov  word [keyboard_handler_passthrough_off], bx
	mov  word [keyboard_handler_passthrough_seg], dx

  ; Install the new interrupt
  cli                               ; Don't interupt us while updating IVT
  mov  word [es:KBD_IVT_OFFSET], keyboard_handler
  mov  word [es:KBD_IVT_OFFSET+2], 0x0050
  sti                               ; Enable interrupts

  pop  bx
  pop  dx
  pop  ax
  pop  es
  ret


; -----------------------------------------------------------------------------
; Changes the way the keyboard driver functions
;
; PARAMETERS:
;   AX - driver mode
;        0 - off; delegate everything to previous handler (BIOS usually)
;			   1 - on; ignore previous handler
; RETURN:
;   None
; -----------------------------------------------------------------------------
keyboard_set_driver_mode:
	push si
	pushf

	sti							                       ; need hardware intrps to still fire

  keyboard_set_driver_mode_wait:
	  call keyboard_clear_bios_buffer
    mov  si, key_state_table					   ; start from first key
  keyboard_set_driver_mode_wait_loop:
    cmp  byte [si], KEY_STATE_PRESSED    ; if we found a pressed key
    je   keyboard_set_driver_mode_wait   ; restart loop

    inc  si                              ; next key
    cmp  si, key_state_table_after_end   ; are we at the end?
    jb   keyboard_set_driver_mode_wait_loop	; no, move to next key
    ; we're past the end and no keys were pressed, so we're done
  keyboard_set_driver_mode_wait_done:
    popf						                      ; restore interrupt state

    mov word [keyboard_driver_mode], ax	  ; store mode

    pop si
    ret

; -----------------------------------------------------------------------------
; Keyboard interrupt handler
;
; PARAMETERS:
;   None
; RETURN:
;   None
; -----------------------------------------------------------------------------
keyboard_handler:
  pushf
  push ax
  push dx
  push bx
  push ds
  push es

  cmp  word [keyboard_driver_mode], MODE_PASS_THROUGH ; do we perform at all?
  je   keyboard_handler_invoke_previous ; no

  in   al, 60h                      ; Get keystroke

  ; TEMP - remove this once the shell is implemented. This is only to view
  ;        keypresses for the moment
  mov  cx, [kbd_write_pos]
  mov  si, cx
  sub  cx, [kbd_read_pos]
  cmp  cx, KBD_BUFSIZE              ; If (write_pos-read_pos)==KBD_BUFSIZE
  je   keyboard_handler_temp_end    ; then buffer full, we're finished

  lea cx, [si+1]                    ; Index of next write (tmp = write_pos + 1)
  and si, KBD_BUFSIZE-1             ; Normalize write_pos to be within 0 to KBD_BUFSIZE
  mov [kbd_buffer+si], al           ; Save character to buffer
  mov [kbd_write_pos], cx           ; write_pos++ (write_pos = tmp)

  keyboard_handler_temp_end:
  ; END TEMP

  ; NOTE: the event is not acknowledged with the keyboard controller
  ;       so that the previous (most likely BIOS) interrupt handler has a
  ;       chance to also read this scan code
  mov  dl, KEY_STATE_PRESSED        ; DL := "this is a key press"

  test al, KEY_RELEASED_EVENT_FLAG  ; is it a released key?
  jz   keyboard_handler_store       ; no, so store the press (AL=scan code)
  mov  dl, KEY_STATE_NOT_PRESSED    ; yes, so DL := "this is a key release"
  xor  al, KEY_RELEASED_EVENT_FLAG	; clear pressed/release bit to set
                                    ; AL to the scan code of the key

  keyboard_handler_store:
    ; here, AL = scan code of the key
    ; here, DL = new state of the key
    mov  bh, 0
    mov  bl, al                        ; BX := AL
    mov  byte [key_state_table+bx], dl ; key_state_table[BX] := new state

    ; send EOI (End Of Interrupt) to the PIC, acknowledging that the
    ; hardware interrupt request has been handled
    ;
    ; when running in Real Mode, the PIC IRQs are as follows:
    ; MASTER: IRQs 0 to 7, interrupt numbers 08h to 0Fh
    ; SLAVE: IRQs 8 to 15, interrupt numbers 70h to 77h
    mov  al, 20h
    out  20h, al                    ; send EOI to master PIC

    jmp  keyboard_handler_done      ; we're done

  keyboard_handler_invoke_previous:
    ; the idea is to simulate calling the old handler via an "int" opcode
    ; this takes two steps:
    ;     1. pushing FLAGS, CS, and return IP (3 words)
    ;     2. far jumping into the old handler, which takes two steps:
    ;         2.1. pushing the destination segment and offset (2 words)
    ;         2.2. using retf to accomplish a far jump

    ; push registers to simulate the behaviour of the "int" opcode
    pushf                           ; FLAGS
    push cs                         ; return CS
    mov  ax, keyboard_handler_old_handler_return_address ; return IP
    push ax

    ; invoke previous handler
    ; use retf to simulate a
    ;     "jmp far [oldKeyboardHandlerSeg]:[oldKeyboardHandlerOff]"
    push word [keyboard_handler_passthrough_seg]
    push word [keyboard_handler_passthrough_off]
    retf                            ; invoke previous handler

    ; old handler returns to the address immediately below
  keyboard_handler_old_handler_return_address:
  keyboard_handler_done:
  	pop  es
  	pop  ds
    pop  bx
    pop  dx
    pop  ax
  	popf
  	iret


; -----------------------------------------------------------------------------
; Clear keyboard buffer
;
; PARAMETERS:
;   None
; RETURN:
;   None
; -----------------------------------------------------------------------------
keyboard_clear_bios_buffer:
	push ax

	; wait for shift, ALT, CTRL keys to be released
  keyboard_clear_bios_buffer_special:
    mov  ah, 2
    int  16h                        ; AL := shift flags
    test al, 00001111b              ; are any shifts, CTRL, or ALT pressed?
    jnz  keyboard_clear_bios_buffer_special	; yes, so keep waiting
    ; wait for regular keypresses to be flushed out of the buffer
  keyboard_clear_buffer_loop:
    mov  ah, 1
    int  16h                        ; any keys still in the buffer?
    jz   keyboard_clear_buffer_done ; no, the buffer is now clear

    mov  ah, 0
    int  16h                        ; read the key, clearing it from the buffer

    jmp  keyboard_clear_buffer_loop ; see if there are more
                                    ; keys in the buffer
  keyboard_clear_buffer_done:
    pop  ax
    ret

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

; -----------------------------------------------------------------------------
; Data (variables)
; -----------------------------------------------------------------------------
segment _DATA public align=2 use16 class=DATA

; TEMP
kbd_read_pos:  dw 0
kbd_write_pos: dw 0
kbd_buffer:    times KBD_BUFSIZE db 0
; END TEMP

keyboard_handler_passthrough_seg: dw 0
keyboard_handler_passthrough_off: dw 0

keyboard_driver_mode: dw MODE_PASS_THROUGH

key_state_table: times 128 db KEY_STATE_NOT_PRESSED
key_state_table_after_end:


; -----------------------------------------------------------------------------
; Constants
; -----------------------------------------------------------------------------
segment CONST public align=2 use16 class=DATA

; Scancode to ASCII character translation table
keyboard_map:
  ;  0x00  0x01  0x02  0x03  0x04  0x05  0x06  0x07
  ;   ?    ESC
  db  0,   27,   '1',  '2',  '3',  '4',  '5',  '6'

  ;  0x08  0x09  0x0A  0x0B  0x0C  0x0D  0x0E  0x0F
  ;                                      BKSP  TAB
  db '7',  '8',  '9',  '0',  '-',  '=',  0x08, 0x09

  ;  0x10  0x11  0x12  0x13  0x14  0x15  0x16  0x17
  ;
  db 'q',  'w',  'e',  'r',  't',  'y',  'u',  'i'

  ;  0x18  0x19  0x1A  0x1B  0x1C  0x1D  0x1E  0x1F
  ;                          ENTR  LCTL
  db 'o',  'p',  '[',  ']',  0x0a, 0,    'a',  's'

  ;  0x20  0x21  0x22  0x23  0x24  0x25  0x26  0x27
  ;
  db 'd',  'f',  'g',  'h',  'j',  'k',  'l',  ';'

  ;  0x28  0x29  0x2A  0x2B  0x2C  0x2D  0x2E  0x2F
  ;              LSHF
  db "'",  '`',  0,    "\",  'z',  'x',  'c',  'v'

  ;  0x30  0x31  0x32  0x33  0x34  0x35  0x36  0x37
  ;                                      RSHF
  db 'b',  'n',  'm',  ',',  '.',  '/',  0,    '*'
  ;  0x38  0x39  0x3A  0x3B  0x3C  0x3D  0x3E  0x3F
  ;  LALT        CAPL  F1    F2    F3    F4    F5
  db 0,    ' ',  0,    0,    0,    0,    0,    0

  ;  0x40  0x41  0x42  0x43  0x44  0x45  0x46  0x47
  ;  F6    F7    F8    F9    F10   NUML  SCRL  7HOM
  db 0,    0,    0,    0,    0,    0,    0,    0

  ;  0x48  0x49  0x4A  0x4B  0x4C  0x4D  0x4E  0x4F
  ;  8UP   9PUP  KPD-  4LFT  KPD5  6RGT  KPD+  1END
  db 0,    0,    '-',  0,    0,    0,    '+',  0

  ;  0x50  0x51  0x52  0x53  0x54  0x55  0x56  0x57
  ;  2DWN  3PDN  0INS  KINS  SYSR
  db 0,    0,    0,    0,    0
