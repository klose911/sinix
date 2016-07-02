//.section .bss 
//.comm  StackSpace, 2048

.section .data 

.set SELECTOR_KERNEL_CS, 8

StackSpace: 
.space 2048, 0
StackTop:


.text 

.globl _start

.extern cstart 
.extern gdt_ptr 
_start: 
    mov $(StackTop), %esp
    sgdtl (gdt_ptr)
	call  cstart 
	lgdtl (gdt_ptr) 
    ljmpl $SELECTOR_KERNEL_CS, $csinit 

csinit: 
    push $0 
	popfl 
	hlt
