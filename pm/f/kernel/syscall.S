.data
.set _NR_get_ticks, 0 
.set INT_VECTOR_SYS_CALL, 0x90

.globl get_ticks

.text

get_ticks: 
    mov $_NR_get_ticks, %eax
	int $INT_VECTOR_SYS_CALL
	ret
