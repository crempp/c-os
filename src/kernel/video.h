#ifndef INCLUDE_IO_H
#define INCLUDE_IO_H

/** clear_screen:
 *  Sends the given data to the given I/O port. Defined in io.s
 *
 *  @param port The I/O port to send the data to
 *  @param data The data to send to the I/O port
 */
void clear_screen();

#endif /* INCLUDE_IO_H */