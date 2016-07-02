#include "type.h"
#include "const.h"
#include "proto.h" 
#include "protect.h"
#include "global.h"

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

	out_byte(INT_M_CTLMASK, 0xFF);
	out_byte(INT_S_CTLMASK, 0xFF);

	/*initalize irq_table 
	 * register the irq_handler function for each hardware irq
	 */
	int i;
	for(i = 0; i < NR_IRQ; i++) 
		irq_table[i] = spurius_irq;
}

PUBLIC void spurius_irq(int irq) 
{
	disp_str("SPURIOUS_IRQ: ");
	disp_int(irq); 
	disp_str("\n");
}

PUBLIC void put_irq_handler(int irq, irq_handler handler) 
{
	disable_irq(irq); 
	irq_table[irq] = handler;
}
