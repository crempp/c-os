; C-OS Single-Stage Bootloader
;
; The C-OS bootloader is fairly simple.
;   * Identify boot drive
;   * Setup stack
;   * Print boot messages
;   * Load the kernel into memory
;   * Transfer control to the kernel
;
; Notes:
;   * Since this OS is for PC/XT systems we can't use Disk functions > 05h as
;     those functions are only available for ATs. This makes things difficult.
cpu 8086
org 0x7c00                     ; bootsector loads at offset 0x7c00

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
DATA_SEGMENT      equ BOOT_SEGMENT  ; Set data segment to where we're loaded so
                                    ; we can implicitly access all 64K
KERNEL_SEGMENT    equ 0x0050        ; Segement used to load kernel
KERNEL_OFFSET     equ 0x0000        ; Offset used to load kernel
KERNEL_SECTORS    equ 59            ; Number of sectors the kernel consumes.
                                    ; This is how many sectors will be loaded
DISK_RETRIES      equ 3             ; The number of retries on a read failure
; The following are dependent on the floppy disk used. See the Disk Geometries
; document in the docs folder.
DISK_HEADS        equ 1             ; Total number of heads on the disk
DISK_SPT          equ 8             ; Total sectors per track on the disk
; KERNEL_SIZE       equ 0x78FF        ; 30975 bytes of kernel
; DISK_CYLINDERS    equ 40
; DISK_SECTOR_SIZE  equ 512
; DISK_BUFFER       equ KERNEL_OFFSET
; DISK_TRACK_BYTES  equ (DISK_SECTORS * DISK_SECTOR_SIZE)
; DISK_BUFFER_END   equ DISK_BUFFER + KERNEL_SIZE

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

; Print boot messages
mov  bx, msg_boot
call print
call printmem
mov  bx, msg_load_kernel
call print

; Load kernel
mov  bx, KERNEL_OFFSET          ; Read from disk and store in 0x1000
call kernel_load
call KERNEL_SEGMENT:KERNEL_OFFSET ; Give control to the kernel
jmp  suspend                    ; suspend if the kernel returns control to us

; -----------------------------------------------------------------------------
; Load kernel from disk
;
; PARAMETERS:
;   BX - Offset to load to (loads to ES:BX)
; RETURN:
;   none
; -----------------------------------------------------------------------------
kernel_load:
  push ax
  push bx
  push cx
  push dx

  read:
    cmp  byte [disk_retry], DISK_RETRIES
    je   loadfail
    push bx                     ; save our current destination offset on the
                                ; stack, in case a buggy BIOS destroys BX
    mov  ah, 2
    mov  al, 1
    mov  dl, [disk_drive]
    mov  cl, [disk_sector]
    mov  ch, [disk_cyl]
    mov  dh, [disk_head]
    int  13h
    pop  bx                     ; Pop offset back into BX
    inc  byte [disk_retry]
    jc   read
    mov  byte [disk_retry], 0   ; If successful read, reset the retry count

    push bx
    mov  ah, 0Eh                ; Print a dot after each sector is read
    mov  al, '.'
    xor  bx, bx                 ; Set page 0 (bh), color 0 (bl)
    int  10h
    pop  bx

    add  bx, 512                ; Increase destination offset with each new
                                ; Sector read
    dec  byte [disk_sect_rdcount]
    cmp  byte [disk_sect_rdcount], 0 ; Have we read all the sectors we wanted?
    jz   done                   ; then finished with disk reads...

    inc  byte [disk_sector]     ; Increment current sector
    mov  al, byte [disk_sector]
    cmp  al, DISK_SPT           ; Is it now higher than our max sector value?
    ja   inchead                ; Then go wrap it around and increment the head
    jmp  read                   ; Otherwise, read next sector

  inchead:

    mov  byte [disk_sector], 1  ; reset current sector number
    inc  byte [disk_head]       ; increment current head
    mov  al, byte [disk_head]
    cmp  al, DISK_HEADS         ; has it reached the maximum?
    je   inccyl                 ; go wrap it around and increment the cylinder
    jmp  read                   ; otherwise, read next sector

  inccyl:
    mov  byte [disk_head], 0    ; reset current head
    inc  byte [disk_cyl]        ; increment cylinder
    jmp  read                   ; read next sector

  loadfail:
    mov  bx, msg_disk_error
    call print
    jmp  suspend

  done:
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret

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
; -----------------------------------------------------------------------------
mem_str_buffer    times 4 db 0
mem_str_end       db 0
disk_sector       db 2          ; The current sector disk load routine is on
disk_head         db 0          ; The current head disk load routine is on
disk_cyl          db 0          ; The current cylinder disk load routine is on
disk_retry        db 0          ; The current number of disk load retries
disk_sect_rdcount db KERNEL_SECTORS ; Number of sectors left to read when loading
disk_drive        db 0
hex_out           db `0x0000\n\r`, 0
;newline           db `\n\r`, 0
msg_boot:
    db `C-OS v0.1 07-15-2018\n\r`
    db `Copyright (C) 2018, Chad Rempp\n\r`
    db `\n\r`, 0
msg_load_kernel   db `Loading the kernel\n\r`, 0
msg_memory        db `KB base memory\n\r\n\r`, 0
msg_disk_error    db `Disk read error\n\r\n\r`, 0
msg_sectors_error db `Incorrect number of sectors read\n\r\n\r`, 0


; -----------------------------------------------------------------------------
; Padding and magic number
; -----------------------------------------------------------------------------
times 510-($-$$) db 0
dw 0xaa55                       ; Magic number identifing this as a boot sector
