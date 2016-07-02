#include "const.h"
#include "type.h"
#include "protect.h"
#include "proc.h" 
#include "proto.h"
#include "string.h"
#include "global.h"


void testA(void) 
{
	int i = 0; 

	while(TRUE) {
		disp_str("A"); 
		disp_int(i++); 
		disp_str("."); 
		delay(1);
	}
}

PUBLIC int kernel_main(void) 
{

	PROCESS *p_proc = proc_table; 

	/* initialize the ldt selector for process A*/
	p_proc->ldt_sel = SELECTOR_LDT_FIRST; 

	/*initialize two ldt desciptors for process A
	 * the code desciptor equals to kernel code desciptor
	 * the data desciptor equals to the kernel data desciptor*/
	memcpy(&p_proc->ldts[0], &gdt[SELECTOR_KERNEL_CS >> 3], 
			sizeof(DESCRIPTOR)); 
	p_proc->ldts[0].attr1 = DA_C | PRIVILEGE_TASK << 5; 
	memcpy(&p_proc->ldts[1], &gdt[SELECTOR_KERNEL_DS >> 3], 
			sizeof(DESCRIPTOR)); 
	p_proc->ldts[1].attr1 = DA_DRW | PRIVILEGE_TASK << 5; 

	/*initialize the segment registers for process A*/ 
	p_proc->regs.cs = ((8 * 0) & SA_RPL_MASK & SA_TI_MASK ) | 
		SA_TIL | RPL_TASK;
	p_proc->regs.ds = ((8 * 1) & SA_RPL_MASK & SA_TI_MASK ) | 
		SA_TIL | RPL_TASK;
	p_proc->regs.es = ((8 * 1) & SA_RPL_MASK & SA_TI_MASK ) | 
		SA_TIL | RPL_TASK;
	p_proc->regs.fs = ((8 * 1) & SA_RPL_MASK & SA_TI_MASK ) | 
		SA_TIL | RPL_TASK;
	p_proc->regs.ss = ((8 * 1) & SA_RPL_MASK & SA_TI_MASK ) | 
		SA_TIL | RPL_TASK;
	p_proc->regs.gs = (SELECTOR_KERNEL_GS & SA_RPL_MASK ) | RPL_TASK;

	/* initialize eip address for process A 
	 * eip will point to function testA*/
	p_proc->regs.eip = (u32) testA;

	/* process A will use a new stack */
	p_proc->regs.esp = (u32) task_stack + STACK_SIZE_TOTAL; 

	p_proc->regs.eflags = 0x1202; //IF =1, IOFL =1 => unblock interrupt and 
								 // process can use io ports 
	
	//disp_str("-----\"kernel_main\" begins-----\n");
	
	/*jump to new process*/
	p_proc_ready = proc_table;
	restart();

	while(TRUE) {} 
	return 0;
}
