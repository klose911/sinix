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

/*Hardware interrupts*/
#define NR_IRQ          16

#define CLOCK_IRQ       0
#define KEYBOARD_IRQ    1 
#define CASCADE_IRQ     2 /* cascade enable for 2nd AT controller */
#define ETHER_IRQ       3 
#define SECONDARY_IRQ   3 /* RS232 interrupt vector for port 2 */
#define RS232_IRQ       4 /* RS232 interrupt vector for port 1 */
#define XT_WINI_IRQ     5 /* xt winchester */
#define FLOPPY_IRQ      6
#define PRINTER_IRQ     7 

#define AT_WINI_IRQ    14 /* at winchester */

#endif
