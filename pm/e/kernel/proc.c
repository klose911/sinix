#include "const.h"
#include "type.h"
#include "protect.h"
#include "proc.h" 
#include "proto.h"
#include "string.h"
#include "global.h"

PUBLIC int sys_get_ticks(void) 
{
	//disp_str("+"); 
	//return 0;
	return ticks;
}
