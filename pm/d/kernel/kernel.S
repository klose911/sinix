#include "sconst.h"


.data
	CLOCK_INT_MESSAGE: .ascii "^"

	StackSpace: 
		.space 2048, 0
	StackTop:

.code32
.text 

.extern cstart 
.extern exception_handler
.extern spurius_irq
.extern kernel_main
.extern disp_str
.extern delay
.extern clock_handler

.extern disp_pos

.extern gdt_ptr 
.extern idt_ptr

.extern tss
.extern p_proc_ready

.extern k_reenter

.extern irq_table

.globl _start

.globl restart

.globl divide_error
.globl single_step_exception
.globl nmi
.globl breakpoint_exception
.globl overflow
.globl bounds_check
.globl inval_opcode
.globl copr_not_available
.globl double_fault
.globl copr_seg_overrun
.globl inval_tss
.globl segment_not_present
.globl stack_exception
.globl general_protection
.globl page_fault
.globl copr_error

.globl hwint00
.globl hwint01
.globl hwint02
.globl hwint03
.globl hwint04
.globl hwint05
.globl hwint06
.globl hwint07
.globl hwint08
.globl hwint09
.globl hwint10
.globl hwint11
.globl hwint12
.globl hwint13
.globl hwint14
.globl hwint15

_start: 
    mov $(StackTop), %esp
    sgdtl (gdt_ptr)
	call  cstart 
	lgdtl (gdt_ptr) 

	lidtl (idt_ptr)

    ljmpl $SELECTOR_KERNEL_CS, $csinit 

csinit: 
	xor %eax, %eax 
	mov $(SELECTOR_TSS), %ax
	ltr %ax 
	jmp kernel_main
	;hlt


.macro hwint_master irq
    call save 
	in $INT_M_CTLMASK, %al
	or (1 << \irq), %al 
	out %al, $INT_M_CTLMASK
	mov $EOI, %al
	out %al, $INT_M_CTL
	sti
	push \irq
	call *irq_table + 4 * \irq
	pop %ecx
	cli 
	in $INT_M_CTLMASK, %al 
	movb (1 << \irq), %ah
	notb %ah
	and %ah, %al 
	out %al, $INT_M_CTLMASK
	ret
.endm

.align 16
hwint00: 
	hwint_master 0

.align 16
hwint01: 
    hwint_master  1 

.align 16
hwint02: 
    hwint_master  2 

.align 16
hwint03: 
    hwint_master  3 

.align 16
hwint04: 
    hwint_master  4

.align 16
hwint05: 
    hwint_master  5

.align 16
hwint06: 
    hwint_master  6 

.align 16
hwint07: 
    hwint_master  7 

.align 16
hwint08: 
    hwint_master  8 

.align 16
hwint09: 
    hwint_master  9 

.align 16
hwint10: 
    hwint_master  10 

.align 16
hwint11: 
    hwint_master  11 

.align 16
hwint12: 
    hwint_master  12 

.align 16
hwint13: 
    hwint_master  13 

.align 16
hwint14: 
    hwint_master  14 

.align 16
hwint15: 
    hwint_master  15 

divide_error: 
    push $0xFFFFFFFF /* no err code */
	push $0
	jmp exception

single_step_exception:
    push $0xFFFFFFFF /* no err code */
	push $1
	jmp exception

nmi:
    push $0xFFFFFFFF /* no err code */
	push $2
	jmp exception

breakpoint_exception:
    push $0xFFFFFFFF /* no err code */
	push $3
	jmp exception

overflow:
    push $0xFFFFFFFF /* no err code */
	push $4
	jmp exception

bounds_check:
    push $0xFFFFFFFF /* no err code */
	push $5
	jmp exception

inval_opcode:
    push $0xFFFFFFFF /* no err code */
	push $6
	jmp exception

copr_not_available:
    push $0xFFFFFFFF /* no err code */
	push $7
	jmp exception

double_fault:
	push $8
	jmp exception

copr_seg_overrun:
    push $0xFFFFFFFF /* no err code */
	push $9
	jmp exception

inval_tss:
	push $10
	jmp exception

segment_not_present:
	push $11
	jmp exception

stack_exception:
	push $12
	jmp exception

general_protection:
	push $13
	jmp exception

page_fault:
	push $14
	jmp exception

copr_error:
    push $0xFFFFFFFF /* no err code */
	push $16
	jmp exception

exception: 
    call exception_handler
	add $8, %esp
	nop 
	nop 
	nop 
	hlt

save: 

	pusha
	push %ds
	push %es
	push %fs
	push %gs

	mov %ss, %dx
	mov %dx, %ds
	mov %dx, %es	

	mov %esp, %eax 

	incl (k_reenter)
	cmpl $0, (k_reenter)
	jne  save.re_enter
	
    mov $(StackTop), %esp //change to kernel stack

	push $restart
	jmp  *RETADR - P_STACKBASE(%eax) 

save.re_enter:
    push $restart_re_enter
	jmp  *RETADR - P_STACKBASE(%eax) 

restart: 
   mov (p_proc_ready), %esp
   lldtw P_LDT_SEL(%esp)

   lea P_STACKTOP(%esp), %eax
   mov $tss, %ebx
   add $TSS3_S_SP0, %ebx
   movl %eax, (%ebx)

restart_re_enter: 
    decl (k_reenter)

	pop %gs
	pop %fs
	pop %es
	pop %ds
	popa
	add $4, %esp
	iret
