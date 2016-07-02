#include"sconst.h"

.extern disp_pos 

.section .text 

.globl  disp_str
.globl  disp_color_str
.globl  out_byte
.globl  in_byte 
.globl  enable_irq 
.globl  disable_irq

/* void disp_str(char *kernel_message) */

disp_str:
    pushl   %ebp
    movl    %esp, %ebp
    pushl   %ebx
    pushl   %esi
    pushl   %edi
    movl    8(%ebp), %esi
    movl    (disp_pos), %edi
    movb    $0xF, %ah
disp_str.1:
    lodsb
    testb   %al, %al
    jz      disp_str.2
    cmpb    $0xA, %al
    jnz     disp_str.3
    pushl   %eax
    movl    %edi, %eax
    movb    $160, %bl
    divb    %bl
    andl    $0xFF, %eax
    incl    %eax
    movb    $160, %bl
    mulb    %bl
    movl    %eax, %edi
    popl    %eax
    jmp     disp_str.1
disp_str.3:
    movw    %ax, %gs:(%edi)
    addl    $2, %edi
    jmp     disp_str.1
disp_str.2:
    movl    %edi, (disp_pos)
    popl    %edi
    popl    %esi
    popl    %ebx
    popl    %ebp
    ret

/* void disp_color_str(char *kernel_message, int color)*/ 

disp_color_str:
    pushl   %ebp
    movl    %esp, %ebp
    pushl   %ebx
    pushl   %esi
    pushl   %edi
    movl    8(%ebp), %esi
    movl    (disp_pos), %edi
    movb    12(%ebp), %ah
disp_color_str.1:
    lodsb
    testb   %al, %al
    jz      disp_color_str.2
    cmpb    $0xA, %al
    jnz     disp_color_str.3
    pushl   %eax
    movl    %edi, %eax
    movb    $160, %bl
    divb    %bl
    andl    $0xFF, %eax
    incl    %eax
    movb    $160, %bl
    mulb    %bl
    movl    %eax, %edi
    popl    %eax
    jmp     disp_color_str.1
disp_color_str.3:
    movw    %ax, %gs:(%edi)
    addl    $2, %edi
    jmp     disp_color_str.1
disp_color_str.2:
    movl    %edi, (disp_pos)
    popl    %edi
    popl    %esi
    popl    %ebx
    popl    %ebp
    ret

/*void out_byte(u16 port, u8 value)*/ 

out_byte: 
    mov 4(%esp), %edx  
	mov 8(%esp), %al 
	outb %al, %dx
	nop 
	nop 
	ret 

/*u8  in_byte(u16 port)*/

in_byte: 
    mov 4(%esp), %edx 
	xor %eax, %eax 
	inb %dx, %al 
	nop 
	nop 
	ret

/* void disable_irq(int irq)*/

disable_irq: 
   mov 4(%esp), %ecx
   pushf
   cli 
   mov $1, %ah
   rol %cl, %ah  //ah = (1 << (irq % 8))
   cmp 8, %cl
   jae disable_8 // irq >= 8 at the slave i8529 

disable_0:
   inb $INT_M_CTLMASK, %al 
   test %ah, %al 
   jnz   disable_already
   or   %ah, %al 
   outb %al, $INT_M_CTLMASK
   popf 
   mov $1, %eax    //disabled by this function
   ret

disable_8: 
   inb $INT_S_CTLMASK, %al 
   test %ah, %al 
   jnz   disable_already
   or   %ah, %al 
   outb %al, $INT_S_CTLMASK
   popf 
   mov $1, %eax    //disabled by this function
   ret
   
disable_already: 
   popf
   xor %eax, %eax 
   ret 

/* void enable_irq(int irq) */

enable_irq: 
   mov 4(%esp), %ecx 
   pushf 
   cli 
   mov $0xfe, %ah 
   rol %cl, %ah
   cmp $8, %cl
   jae enable_8 

enable_0: 
   inb $INT_M_CTLMASK, %al 
   and %ah, %al 
   out %al, $INT_M_CTLMASK
   popf 
   ret

enable_8: 
   inb $INT_S_CTLMASK, %al 
   and %ah, %al 
   out %al, $INT_S_CTLMASK
   popf 
   ret



