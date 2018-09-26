#include "../drivers/video.h"
#include "../drivers/cpu.h"
#include "../drivers/keyboard.h"

// Prototypes;
void debug_info();

void _cstart() {
  char c;
  char *kbd_buffer;

  install_keyboard_driver();

  // Intialize screen
  v_set_page(0);
  v_clr_screen();

  v_print("c-os version 0.1\0");
  v_print_nl();
  // debug_info();

  v_print("> \0");

  while(1) {
    // This is not how we should do this
    c = poll_kbd_buffer();
    if (c != 0) {
      v_putch(c);
    }
  }
}

void debug_info() {
  int mode;
  mode = v_get_mode();
  v_print_nl();
  v_print("Video Mode: \0");
  v_print_hex(mode);
  v_print_nl();
}
