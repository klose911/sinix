#include "type.h"
#include "const.h"
#include "protect.h"
#include "proc.h"
#include "proto.h"
#include "global.h"

PRIVATE void init_idt_desc(unsigned char vector, u8 desc_type, 
		int_handler handler, unsigned char privilege); 

PRIVATE void init_descriptor(DESCRIPTOR *p_desc, 
		u32 base, u32 limit, u16 attribute); 

EXTERN void divide_error(); 
EXTERN void single_step_exception(); 
EXTERN void nmi(); 
EXTERN void breakpoint_exception(); 
EXTERN void overflow(); 
EXTERN void bounds_check(); 
EXTERN void inval_opcode(); 
EXTERN void copr_not_available(); 
EXTERN void double_fault(); 
EXTERN void copr_seg_overrun(); 
EXTERN void inval_tss(); 
EXTERN void segment_not_present(); 
EXTERN void stack_exception();
EXTERN void general_protection(); 
EXTERN void page_fault(); 
EXTERN void copr_error();

EXTERN void hwint00();
EXTERN void hwint01();
EXTERN void hwint02();
EXTERN void hwint03();
EXTERN void hwint04();
EXTERN void hwint05();
EXTERN void hwint06();
EXTERN void hwint07();
EXTERN void hwint08();
EXTERN void hwint09();
EXTERN void hwint10();
EXTERN void hwint11();
EXTERN void hwint12();
EXTERN void hwint13();
EXTERN void hwint14();
EXTERN void hwint15();

PUBLIC u32 seg2phys(u16 seg) 
{
	DESCRIPTOR *p_desc = &gdt[seg >> 3];
	return (p_desc->base_high << 24 ) | 
		(p_desc->base_mid << 16 )  | 
		(p_desc->base_low); 
}

PUBLIC void init_protect() 
{
	init_8259A(); 

	init_idt_desc(INT_VECTOR_DIVIDE, DA_386IGate,
			divide_error, PRIVILEGE_KRNL); 
	init_idt_desc(INT_VECTOR_DEBUG, DA_386IGate, 
			single_step_exception, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_NMI, DA_386IGate, 
			nmi, PRIVILEGE_KRNL); 
	init_idt_desc(INT_VECTOR_BREAKPOINT, DA_386IGate,
			breakpoint_exception, PRIVILEGE_USER); 
	init_idt_desc(INT_VECTOR_OVERFLOW, DA_386IGate, 
			overflow, PRIVILEGE_USER); 
	init_idt_desc(INT_VECTOR_BOUNDS, DA_386IGate, 
			bounds_check, PRIVILEGE_KRNL); 
	init_idt_desc(INT_VECTOR_INVAL_OP, DA_386IGate, 
			inval_opcode, PRIVILEGE_KRNL); 
	init_idt_desc(INT_VECTOR_COPROC_NOT, DA_386IGate, 
			copr_not_available, PRIVILEGE_KRNL); 
	init_idt_desc(INT_VECTOR_DOUBLE_FAULT, DA_386IGate, 
			double_fault, PRIVILEGE_KRNL); 
	init_idt_desc(INT_VECTOR_COPROC_SEG, DA_386IGate, 
			copr_seg_overrun, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_INVAL_TSS, DA_386IGate, 
			inval_tss, PRIVILEGE_KRNL); 
	init_idt_desc(INT_VECTOR_SEG_NOT, DA_386IGate, 
			segment_not_present, PRIVILEGE_KRNL); 
	init_idt_desc(INT_VECTOR_STACK_FAULT, DA_386IGate, 
			stack_exception, PRIVILEGE_KRNL); 
	init_idt_desc(INT_VECTOR_PROTECTION, DA_386IGate, 
			general_protection, PRIVILEGE_KRNL); 
	init_idt_desc(INT_VECTOR_PAGE_FAULT, DA_386IGate, 
			page_fault, PRIVILEGE_KRNL); 
	init_idt_desc(INT_VECTOR_COPROC_ERR, DA_386IGate, 
			copr_error, PRIVILEGE_KRNL);

	init_idt_desc(INT_VECTOR_IRQ0, DA_386IGate,
			hwint00, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 1, DA_386IGate,
			hwint01, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 2, DA_386IGate,
			hwint02, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 3, DA_386IGate,
			hwint03, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 4, DA_386IGate,
			hwint04, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 5, DA_386IGate,
			hwint05, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 6, DA_386IGate,
			hwint06, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ0 + 7, DA_386IGate,
			hwint07, PRIVILEGE_KRNL);

	init_idt_desc(INT_VECTOR_IRQ8, DA_386IGate,
			hwint08, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 1, DA_386IGate,
			hwint09, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 2, DA_386IGate,
			hwint10, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 3, DA_386IGate,
			hwint11, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 4, DA_386IGate,
			hwint12, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 5, DA_386IGate,
			hwint13, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 6, DA_386IGate,
			hwint14, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_IRQ8 + 7, DA_386IGate,
			hwint15, PRIVILEGE_KRNL);

	memset(&tss, 0, sizeof(tss)); 
	tss.ss0 = SELECTOR_KERNEL_DS;
	init_descriptor(&gdt[INDEX_TSS], 
			vir2phys(seg2phys(SELECTOR_KERNEL_DS), &tss), 
			sizeof(tss) - 1, DA_386TSS); 
	tss.iobase = sizeof(tss); 


	PROCESS *p_proc = proc_table;
	//u16 selector_ldt = SELECTOR_LDT_FIRST * 8; 
	u16 index_ldt = INDEX_LDT_FIRST;
	int i; 
	for(i = 0; i < NR_TASKS; i++) {
		init_descriptor(&gdt[index_ldt], 
				vir2phys(seg2phys(SELECTOR_KERNEL_DS), proc_table[i].ldts),
				LDT_SIZE * sizeof(DESCRIPTOR) - 1, DA_LDT);
		p_proc++;
		index_ldt++;
	}
}

PRIVATE void init_idt_desc(
		unsigned char vector, u8 desc_type, 
		int_handler handler, unsigned char privilege) 
{
	GATE *p_gate = &idt[vector]; 
	u32 base = (u32) handler; 
	p_gate->offset_low = base & 0xFFFF;
	p_gate->selector = SELECTOR_KERNEL_CS; 
	p_gate->p_count = 0; 
	p_gate->attr = desc_type | (privilege << 5);
	p_gate->offset_high = (base >> 16) & 0xFFFF;
}

PUBLIC void exception_handler(int vec_no, int err_code, 
		int eip, int cs, int eflags) 
{
	int i; 
	int text_color = 0x74; 

	char *err_msg[] = {
		"#DE Divide Error",
		"#DB RESERVED",
		"--  NMI Interrupt",
		"#BP Breakpoint",
		"#OF Overflow",
		"#BR BOUND Range Exceeded",
		"#UD Invalid Opcode (Undefined Opcode)",
		"#NM Device Not Available (No Math Coprocessor)",
		"#DF Double Fault",
		"    Coprocessor Segment Overrun (reserved)",
		"#TS Invalid TSS",
		"#NP Segment Not Present",
		"#SS Stack-Segment Fault",
		"#GP General Protection",
		"#PF Page Fault",
		"--  (Intel reserved. Do not use.)",
		"#MF x87 FPU Floating-Point Error (Math Fault)",
		"#AC Alignment Check",
		"#MC Machine Check",
		"#XF SIMD Floating-Point Exception"
	};

	disp_pos = 0 ; 
	for(i = 0; i < 80 * 5; i++) {
		disp_str(" ");
	}
	disp_pos = 0; 

	disp_color_str("Exception! --> ", text_color); 
	disp_color_str(err_msg[vec_no], text_color); 
	disp_color_str("\n\n", text_color); 
	disp_color_str("EFLAGS:", text_color); 
	disp_int(eflags); 
	disp_color_str("CS: ", text_color); 
	disp_int(cs); 
	disp_color_str("EIP: ", text_color); 
	disp_int(eip); 

	if(err_code != 0xFFFFFFFF) { 
		disp_color_str("Error code: ", text_color); 
		disp_int(err_code);
	}
}


PRIVATE void init_descriptor(DESCRIPTOR *p_desc, 
		u32 base, u32 limit, u16 attribute)
{
	p_desc->limit_low = limit & 0x0FFFF; 
	p_desc->base_low = base & 0x0FFFF; 
	p_desc->base_mid = (base >> 16 ) & 0x0FF;
	p_desc->attr1 = attribute & 0xFF; 
	p_desc->limit_high_attr2 = ((limit >> 16) & 0x0F) | 
		(attribute >> 8) & 0xF0; 
	p_desc->base_high = (base >> 24) & 0x0FF; 
}

