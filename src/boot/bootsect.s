[org 0x7c00]                    ; bootsector loads at offset 0x7c00

; -----------------------------------------------------------------------------
; Bootloader constants
;
; NOTE - KERNEL_SEGMENT:KERNEL_OFFSET must match value used with linker
; -----------------------------------------------------------------------------
BOOT_SEGMENT      equ 0x0000
BOOT_OFFSET       equ 0x7C00
STACK_SEGMENT     equ ((BOOT_OFFSET + 512) / 16) ; Set the stack segment to the
                                                 ; top of our bootloader
STACK_OFFSET      equ 4096          ; Give a 4k stack size
DATA_SEGMENT      equ BOOT_SEGMENT  ; Set data segment to where we're loaded so we
                                    ; can implicitly access all 64K
KERNEL_SEGMENT    equ 0x0050        ; Segement used to load kernel
KERNEL_OFFSET     equ 0x0000        ; Offset used to load kernel
KERNEL_SIZE       equ 0x78FF        ; 30975 bytes of kernel
DISK_RETRIES      equ 3
DISK_CYLINDERS    equ 40
DISK_HEADS        equ 1
DISK_SECTORS      equ 8
DISK_SECTOR_SIZE  equ 512
DISK_BUFFER       equ KERNEL_OFFSET
DISK_TRACK_BYTES  equ (DISK_SECTORS * DISK_SECTOR_SIZE)
DISK_BUFFER_END   equ DISK_BUFFER + KERNEL_SIZE

; -----------------------------------------------------------------------------
; Bootloader
; -----------------------------------------------------------------------------

; Canonicalize CS:IP
jmp  BOOT_SEGMENT:canonicalized
canonicalized:

; Save the boot drive set by the bios on boot
mov  [disk_drive], dl

; Set segment registers. These values are only for the bootloader.
cli                             ; Clear interrupts
mov  ax, STACK_SEGMENT          ; Set the stack segment and offset
mov  ss, ax
mov  bp, STACK_OFFSET
mov  sp, bp
mov  ax, DATA_SEGMENT           ; Set the data segment
mov  ds, ax
mov  ax, KERNEL_SEGMENT         ; Set the kernel segment
mov  es, ax
sti

; Print memory message
call printmem

; Load kernel
mov  bx, KERNEL_OFFSET          ; Read from disk and store in 0x1000
;call disk_load
;call KERNEL_SEGMENT:KERNEL_OFFSET ; Give control to the kernel
jmp  suspend                    ; suspend if the kernel returns control to us


; -----------------------------------------------------------------------------
; Print available memory
;
; PARAMETERS:
;   DX - Hex value to print
; RETURN:
;   none
; -----------------------------------------------------------------------------
printmem:
  push bx
  push dx
  push cx

  mov  ax, [0x0413]
  call hex_2_dec
  mov  bx, mem_str_buffer
  skip_nulls:
    mov  al, [bx]
    cmp  al, 0
    jne  nulls_skipped
    inc  bx
    jmp  skip_nulls
  nulls_skipped:
    call print
    mov  bx, msg_memory
    call print

  pop  cx
  pop  dx
  pop  bx
  ret

; -----------------------------------------------------------------------------
; Convert a hex number to decimal (ASCII)
; https://stackoverflow.com/a/7865387/1436323
;
; PARAMETERS:
;   AX - Number to be converted
; RETURN:
;   SI - Start of NUL-terminated buffer containing the converted number in
;        ASCII represention.
; -----------------------------------------------------------------------------
hex_2_dec:
  push ax            ; Save modified registers
  push bx
  push dx
  mov  si, mem_str_end  ; Start at the end
.convert:
  xor  dx, dx         ; Clear dx for division
  mov  bx, 10
  div  bx             ; Divide by base
  add  dl, '0'        ; Convert to printable char
  cmp  dl, '9'        ; Hex digit?
  jbe  .store         ; No. Store it
  add  dl, 'A'-'0'-10 ; Adjust hex digit
.store:
  dec  si             ; Move back one position
  mov  [si], dl       ; Store converted digit
  and  ax, ax         ; Division result 0?
  jnz  .convert       ; No. Still digits to convert
  pop  dx             ; Restore modified registers
  pop  bx
  pop  ax
  ret

; -----------------------------------------------------------------------------
; Print string currently pointed to by register BX using BIOS
;
; PARAMETERS:
;   BX - Pointer to string to print
; RETURN:
;   none
; -----------------------------------------------------------------------------
print:
  push ax
  push bx

  do_print:
    mov  al, [bx]               ; 'bx' is the base address for the string
    cmp  al, 0                  ; if the character is a null (0x0) then...
    je   print_done             ; done printing
    push bx                     ; Save bx, it has our message address
    xor  bx, bx                 ; Set color (bl) and page (bh) to 0
    mov  ah, 0x0E               ; function 0x0E (Teletype output)
    int  0x10
    pop  bx                     ; restore message address
    inc  bx
    jmp  do_print

  print_done:
    pop bx
    pop ax
    ret


; -----------------------------------------------------------------------------
; Suspend
;
; PARAMETERS:
;   none
; RETURN:
;   none
; -----------------------------------------------------------------------------
suspend:
    cli
    hlt
    jmp  suspend

; -----------------------------------------------------------------------------
; Data
;
; Order matters. Cylinder/sector and head/drive are packed into words together.
; -----------------------------------------------------------------------------
;mem_out           db '0', 0
mem_str_buffer    times 4 db 0
mem_str_end       db 0
sectors_to_read   db 0x00
chs_sector        db 0x02
chs_cylinder      db 0x00
disk_drive        db 0x00
chs_head          db 0x00
disk_dest_offset  dw KERNEL_OFFSET
msg_memory        db `KB base memory\n\r\n\r`, 0
msg_disk_error    db `Disk read error\n\r\n\r`, 0
msg_sectors_error db `Incorrect number of sectors read\n\r\n\r`, 0

; -----------------------------------------------------------------------------
; Padding and magic number
; -----------------------------------------------------------------------------
times 510-($-$$) db 0
dw 0xaa55                       ; Magic number identifing this as a boot sector
