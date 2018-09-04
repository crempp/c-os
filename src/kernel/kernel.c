#include "../drivers/video.h"
#include "../drivers/cpu.h"

#define OS_IDENT "c-os";
#define VERSION "0.1";

// Prototypes
void init_screen();

void _cstart() {
  run_kernel();
}

void run_kernel() {
  // Intialize screen
  int mode;

  mode = v_get_mode();

  v_set_page(0);
  v_clr_screen();
  v_print("c-os version 0.2\0");
  v_print_nl();
  v_print("> \0");

  suspend();
}
