#include "../drivers/video.h"
#include "../drivers/ports.h"

// Prototypes
void test_video();
int do_a_thing(int foo);


int do_a_thing(int foo) {
    return foo * 7;
}

void _cstart() {
     test_video();
}

void test_video() {
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

    /**
     * Video TODO
     *
     *  http://www.ousob.com/ng/asm/ng6f862.php
     *  http://www.seasip.info/VintagePC/mda.html#memmap
     *  http://www.minuszerodegrees.net/oa/OA%20-%20IBM%20Monochrome%20Display%20and%20Printer%20Adapter.pdf
     *
     * - Change video mode
     * - Scroll up
     * - Scroll down
     * -
     */


}
