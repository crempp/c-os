#ifndef INCLUDE_VIDEO_H
#define INCLUDE_VIDEO_H

/**
 *
 * @return
 */
unsigned char v_get_mode();


/**
 * Clear the screen
 */
void v_clr_screen();

/**
 * Move the cursor to a row, column on the screen
 *
 * @param row
 * @param col
 */
void v_mv_curs(char row, char col);

/**
 * Print a message to the screen at the current cursor location
 *
 * @param message
 */
void v_print(char *message);

/**
 * Print a number in hexadecimal form at the current cursor location
 *
 * @param num
 */
void v_print_hex(unsigned int num);

/**
 * Print a newline at the current cursor location
 */
void v_print_nl();

/**
 * Print a single character at the cursor location
 */
void v_putch(char character);

/**
 * Set the BIOS video mode
 */
void v_set_mode(unsigned char mode);

/**
 * Set the BIOS video page
 */
void v_set_page(unsigned char page);

#endif /* INCLUDE_VIDEO_H */
