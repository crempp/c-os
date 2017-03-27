/* This will force us to create a kernel entry function instead of jumping to kernel.c:0x00 */
void dummy_test_entrypoint() {
}

void main() {
    int VIDEO_ROW = 8;
    char* video_memory = (char*) (0xb8000 + ((80 * 2) * VIDEO_ROW));
    *video_memory = 'X';
}
