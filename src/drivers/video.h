#ifndef INCLUDE_VIDEO_H
#define INCLUDE_VIDEO_H

/**
 *
 * @return
 */
char b_get_mode();


/**
 * Clear the screen
 */
void b_clrscr();

/**
 * Move the cursor to a row, column on the screen
 *
 * @param row
 * @param col
 */
void b_mvcurs(char row, char col);

/**
 * Print a message to the screen at the current cursor location
 *
 * @param message
 */
void b_print(char *message);

/**
 * Print a number in hexadecimal form at the current cursor location
 *
 * @param num
 */
void b_printhex(unsigned int num);

/**
 * Print a newline at the current cursor location
 */
void b_printnl();

#endif /* INCLUDE_VIDEO_H */
