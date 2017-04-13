#ifndef INCLUDE_VIDEO_H
#define INCLUDE_VIDEO_H

void v_clrscr();

void v_mvcurs(char row, char col);

void v_print(char *message);

void v_printhex(unsigned int num);

void v_printnl();

#endif /* INCLUDE_VIDEO_H */
