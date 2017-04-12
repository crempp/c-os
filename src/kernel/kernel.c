#include "video.h"

int do_a_thing(int foo) {
    return foo * 7;
}

void _cstart() {
    int a = 1;
    int b = a + 1;
    char *message = "Hello, this is the kernel\0";

    do_a_thing(b);

    v_print("This text should not display");

    v_clrscr();

    v_mvcurs(15, 12); // row, col

    v_print(message);

    v_printnl();

    v_printhex(0xBABE);
}
