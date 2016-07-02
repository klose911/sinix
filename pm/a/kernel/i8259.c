#include "type.h"
#include "const.h"
#include "proto.h" 
#include "protect.h"

PUBLIC void init_8259A(void) 
{
    out_byte(INT_M_CTL, 0x11); 
	out_byte(INT_S_CTL, 0x11); 

	out_byte(INT_M_CTLMASK, INT_VECTOR_IRQ0);
	out_byte(INT_S_CTLMASK, INT_VECTOR_IRQ8); 

	out_byte(INT_M_CTLMASK, 0x04);
	out_byte(INT_S_CTLMASK, 0x02);

	out_byte(INT_M_CTLMASK, 0x01);
	out_byte(INT_S_CTLMASK, 0x01);

	out_byte(INT_M_CTLMASK, 0xFD);
	out_byte(INT_S_CTLMASK, 0xFF);
}

PUBLIC void spurius_irq(int irq) 
{
	disp_str("SPURIOUS_IRQ: ");
	disp_int(irq); 
	disp_str("\n");
}
