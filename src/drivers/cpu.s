cpu 8086
bits 16

global suspend_

%define suspend suspend_

segment _TEXT public align=1 use16 class=CODE

suspend:
  cli
  hlt
  jmp  suspend
