#include "const.h"
#include "type.h"
#include "protect.h"
#include "proc.h" 
#include "proto.h"
#include "string.h"
#include "global.h"

PUBLIC void schedule(void) 
{
	PROCESS *p; 
	int greatest_ticks = 0; 
	while(!greatest_ticks) {
		for(p = proc_table; p < proc_table + NR_TASKS; p++) {
			if(p->ticks > greatest_ticks) {
				//disp_str("<");
				//disp_int(p->ticks);
				//disp_str(">");
				greatest_ticks = p->ticks;
				p_proc_ready = p; 
			}
		}	

		if(!greatest_ticks) {
			for(p = proc_table; p < proc_table + NR_TASKS; p++) {
				p->ticks = p->priority;
			}

		}
	}
}

PUBLIC int sys_get_ticks(void) 
{
	return ticks;
}
