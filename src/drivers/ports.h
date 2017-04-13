#ifndef INCLUDE_PORTS_H
#define INCLUDE_PORTS_H

unsigned char port_byte_in (unsigned short port);
#pragma aux port_byte_in = \
        "in al, dx"        \
        parm  [ dx ]       \
        value [ al ];

void port_byte_out (unsigned short port, unsigned char data);
#pragma aux port_byte_out =  \
        "out dx, al"        \
        parm  [ dx ] [ al ];

unsigned short port_word_in (unsigned short port);
#pragma aux port_word_in = \
        "in ax, dx"        \
        parm  [ dx ]       \
        value [ ax ];

void port_word_out (unsigned short port, unsigned short data);
#pragma aux port_word_out =  \
        "out dx, ax"        \
        parm  [ dx ] [ ax ];

#endif /* INCLUDE_VIDEO_H */
