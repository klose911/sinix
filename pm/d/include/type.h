#ifndef _WUNIX_TYPE_H
#define _WUNIX_TYPE_H

typedef unsigned int u32;
typedef unsigned short u16;
typedef unsigned char u8;


typedef void (*int_handler) ();
typedef void (*t_pf_task) ();
typedef void (*irq_handler) (int irq);
#endif 
