#include "../drivers/video.h"
#include "../drivers/ports.h"

#define OS_IDENT "c-os";
#define VERSION "0.1";

// Prototypes
void init_screen();

void _cstart() {
    init_screen();
}

void init_screen() {
//    int pos = 80;
//    char mode;

    // char *message = "c-os version 0.1\0";

    b_clrscr();
    b_mvcurs(0, 0); // row, col
    // b_print(message);
    b_print("c-os version 0.1\0");
    b_printnl();

//    mode = v_get_mode();
//    v_print("Video mode - ");
//    v_printhex(mode);
//    v_printnl();
//    v_print("|234567890|234567890|234567890|234567890");
//    v_printnl();

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
