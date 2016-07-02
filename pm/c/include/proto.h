#ifndef _WUNIX_PROTO_H
#define _WUNIX_PROTO_H
PUBLIC void disp_str(char *kernel_message); 
PUBLIC void disp_color_str(char *kernel_message, int color); 

PUBLIC void out_byte(u16 port, u8 value); 
PUBLIC u8  in_byte(u16 port);      

PUBLIC void init_protect(); 
PUBLIC void init_8259A();

PUBLIC u32 seg2phys(u16 seg);

PUBLIC void delay(int time);

void restart(void);

void testA(void); 
void testB(void); 
void testC(void); 

#endif
