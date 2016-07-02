.data 

.set SELECTOR_KERNEL_CS, 8


StackSpace: 
.space 2048, 0
StackTop:


.text 

.extern cstart 
.extern exception_handler

.extern disp_pos
.extern gdt_ptr 
.extern idt_ptr

.globl _start

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

_start: 
    mov $(StackTop), %esp
    sgdtl (gdt_ptr)
	call  cstart 
	lgdtl (gdt_ptr) 

	lidtl (idt_ptr)

    ljmpl $SELECTOR_KERNEL_CS, $csinit 

csinit: 
	ud2
	ljmpl $0x40, $0
	hlt

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
