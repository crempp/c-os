#ifndef INCLUDE_CPU_H
#define INCLUDE_CPU_H

/**
 * Suspend the CPU
 */
char suspend();

int  farpeek(int offset, int addr);
void farpoke(int offset, int addr, int value);
char inb(int port);
int  inw(int port);
void outb(char val, int port);
void outw(int val, int port);


#endif /* INCLUDE_CPU_H */
