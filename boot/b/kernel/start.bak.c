#include "type.h"
#include "const.h"
#include "protect.h"

PUBLIC void *memcpy(void *p_dst, void *p_src, int s_size); 

PUBLIC t_8         gdt_ptr[8]; 
PUBLIC DESCRIPTOR gdt[GDT_SIZE]; 

PUBLIC void cstart(void) 
{
	memcpy(&gdt, 
			(void*) (*((t_32 *)(&gdt_ptr[2]))), 
			*((t_16 *)(&gdt_ptr[0])) + 1 
		  );
	t_16 *p_gdt_limit = (t_16 *)(&gdt_ptr[0]);
	t_32 *p_gdt_base = (t_32 *)(&gdt_ptr[32]); 

	*p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR); 
	*p_gdt_base  = (t_32) &gdt; 
}

