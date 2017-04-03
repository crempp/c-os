//#include "video.h"

int do_a_thing(int foo) {
    return foo * 7;
}

//void main() {
void _cstart() {
    int a = 1;
    int b = a + 1;

    do_a_thing(b);

//    clear_screen();
//
//    b_print("Hello, this is the kernel\n");
}
