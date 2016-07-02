#ifndef _WUNIX_PROTECT_H
#define _WUNIX_PROTECT_H

typedef struct s_descriptor 
{
	t_16 limit_low; 
	t_16 base_low; 
	t_8  base_mid; 
	t_8  attr1; 
	t_8  limit_high_attr2; 
	t_8  base_high;
} DESCRIPTOR;

#endif 
