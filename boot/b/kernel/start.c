#include "type.h"
#include "const.h"
#include "protect.h"

void cstart();

PUBLIC	void*	memcpy(void* pDst, void* pSrc, int iSize);

PUBLIC  void    disp_str(char *kernel_message); 

PUBLIC	t_8			gdt_ptr[6];	// 0~15:Limit  16~47:Base

PUBLIC	DESCRIPTOR	gdt[GDT_SIZE];

PUBLIC void cstart()
{
	disp_str("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
					 "-----\"cstart\" begins-----\n");
	memcpy(&gdt,				  
	       (void*)(*((t_32*)(&gdt_ptr[2]))),   
	       *((t_16*)(&gdt_ptr[0])) + 1  
		);
	t_16* p_gdt_limit = (t_16*)(&gdt_ptr[0]);
	t_32* p_gdt_base  = (t_32*)(&gdt_ptr[2]);
	*p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR) - 1;
	*p_gdt_base  = (t_32)&gdt;

	disp_str("-----\"cstart\" ends-----\n");
}
