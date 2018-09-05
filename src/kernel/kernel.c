#include "../drivers/video.h"
#include "../drivers/cpu.h"

#define OS_IDENT "c-os";
#define VERSION "0.1";

// Prototypes
void init_screen();
void debug_info();
void wait();

void _cstart() {
  run_kernel();
}

void run_kernel() {
  // Intialize screen
  v_set_page(0);
  v_clr_screen();

  v_print("c-os version 0.1\0");
  v_print_nl();
  debug_info();

  v_print("> \0");

  wait();
}

void debug_info() {
  int mode;
  mode = v_get_mode();
  v_print_nl();
  v_print("Video Mode: \0");
  v_print_hex(mode);
  v_print_nl();
}

void wait() {
  while (1) {}
}
