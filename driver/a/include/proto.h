#ifndef _WUNIX_PROTO_H
#define _WUNIX_PROTO_H
/*lib/klib.S*/
PUBLIC void disp_str(char *kernel_message); 
PUBLIC void disp_color_str(char *kernel_message, int color); 
PUBLIC void out_byte(u16 port, u8 value); 
PUBLIC u8  in_byte(u16 port);      

/*kernel/protect.c*/
PUBLIC void init_protect(void); 
PUBLIC u32 seg2phys(u16 seg);

/*kernel/i8259.c*/
PUBLIC void init_8259A(void);
PUBLIC void put_irq_handler(int irq, irq_handler handler);
PUBLIC void spurius_irq(int irq); 

/*kernel/clock.c*/
PUBLIC void clock_handler(int irq);


/*lib/klib.c*/
PUBLIC void delay(int time);
PUBLIC void milli_delay(int milli_sec); 

/*kernel/kernel.S*/
void restart();
PUBLIC int sys_call();

/*kernel/syscall.S*/
PUBLIC int get_ticks();

/*kernel/proc.c*/
PUBLIC void schedule(void);
PUBLIC int sys_get_ticks(void);

/*kernel/main.c*/
void testA(void); 
void testB(void); 
void testC(void); 


#endif
