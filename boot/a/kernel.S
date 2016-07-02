.text 

.global _start

_start: 
    mov $0x0C, %ah
	mov $'K',  %al
	mov %ax, %gs:((80*18 + 39)*2)
	jmp . 
