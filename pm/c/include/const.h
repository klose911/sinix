#ifndef _WUNIX_CONST_H
#define _WUNIX_CONST_H

#define PUBLIC 
#define EXTERN  extern
#define PRIVATE static 

#define TRUE  1
#define FALSE 0

/*size of gdt & idt table */
#define GDT_SIZE 128 
#define IDT_SIZE 256 

/* DPL */
#define PRIVILEGE_KRNL  0 
#define PRIVILEGE_TASK  1 
#define PRIVILEGE_USER  3

/* RPL */
#define RPL_KRNL        SA_RPL0
#define RPL_TASK        SA_RPL1
#define RPL_USER        SA_RPL3

/*in & out port of 8259A master and slave controller */
#define INT_M_CTL       0x20 
#define INT_M_CTLMASK   0x21
#define INT_S_CTL       0xA0 
#define INT_S_CTLMASK   0xA1

#endif
