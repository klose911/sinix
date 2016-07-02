#ifndef _WUNIX_PROTECT_H
#define _WUNIX_PROTECT_H

typedef struct s_descriptor 
{
	u16 limit_low; 
	u16 base_low; 
	u8  base_mid; 
	u8  attr1; 
	u8  limit_high_attr2; 
	u8  base_high;
} DESCRIPTOR;

typedef struct s_gate 
{
    u16 offset_low; 
	u16 selector; 
	u8  p_count;
    u8  attr; 
	u16 offset_high; 
} GATE; 

#define INDEX_DUMMY       0 
#define INDEX_FLAT_C      1
#define INDEX_FLAT_RW     2 
#define INDEX_VIDEO       3 

#define SELECTOR_DUMMY    0 
#define SELECTOR_FLAT_C   0x08
#define SELECTOR_FLAT_RW  0x10 
#define SELECTOR_VIDEO    (0x18 + 0x3) 

#define SELECTOR_KERNEL_CS SELECTOR_FLAT_C
#define SELECTOR_KERNEL_DS SELECTOR_FLAT_RW

/* Descriptor privilege level */
#define DA_32        0x4000  /* 32-bit segment */
#define DA_LIMIT_4K  0x8000     /* 4K */
#define DA_DPL0      0x00  /* DPL = 0 */
#define DA_DPL1      0x20  /* DPL = 1 */
#define DA_DPL2      0x40  /* DPL = 2 */
#define DA_DPL3      0x60  /* DPL = 3 */

/* GDT Code- and Data-Segment Types */
#define DA_DR   0x90   /* Read-Only */
#define DA_DRW  0x92   /* Read/Write */
#define DA_DRWA 0x93   /* Read/Write, accessed */
#define DA_C    0x98   /* Execute-Only */
#define DA_CR   0x9A   /* Execute/Read */
#define DA_CCO  0x9C   /* Execute-Only, conforming */
#define DA_CCOR 0x9E   /* Execute/Read-Only, conforming */

/* GDT System-Segment and Gate-Descriptor Types */
#define DA_LDT      0x82    /* LDT */
#define DA_TaskGate 0x85    /* Task Gate */
#define DA_386TSS   0x89    /* 32-bit TSS(Available) */
#define DA_386CGate 0x8C    /* 32-bit Call Gate */
#define DA_386IGate 0x8E    /* 32-bit Interrupt Gate */
#define DA_386TGate 0x8F    /* 32-bit Trap Gate */

#define INT_VECTOR_DIVIDE          0x0
#define INT_VECTOR_DEBUG           0x1
#define INT_VECTOR_NMI             0x2
#define INT_VECTOR_BREAKPOINT      0x3
#define INT_VECTOR_OVERFLOW        0x4
#define INT_VECTOR_BOUNDS          0x5
#define INT_VECTOR_INVAL_OP        0x6
#define INT_VECTOR_COPROC_NOT      0x7
#define INT_VECTOR_DOUBLE_FAULT    0x8
#define INT_VECTOR_COPROC_SEG      0x9
#define INT_VECTOR_INVAL_TSS       0xA
#define INT_VECTOR_SEG_NOT         0xB
#define INT_VECTOR_STACK_FAULT     0xC
#define INT_VECTOR_PROTECTION      0xD
#define INT_VECTOR_PAGE_FAULT      0xE
#define INT_VECTOR_COPROC_ERR      0x10

#define INT_VECTOR_IRQ0            0x20 
#define INT_VECTOR_IRQ8            0x28 

#endif 
