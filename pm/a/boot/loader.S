.code16
.text
	jmp LABEL_START


#include "fat12.h"
#include "loader.h"
#include "pm.h"


/* GDT */
LABEL_GDT:          Descriptor        0,                  0, 0
LABEL_DESC_FLAT_C:  Descriptor        0,            0xfffff, (DA_CR|DA_32|DA_LIMIT_4K)
LABEL_DESC_FLAT_RW: Descriptor        0,            0xfffff, (DA_DRW|DA_32|DA_LIMIT_4K)
LABEL_DESC_VIDEO:   Descriptor  0xB8000,             0xffff, (DA_DRW | DA_DPL3)

/* Gdt register */
.set GdtLen, (. - LABEL_GDT)  /* GDT Length */
GdtPtr: .2byte  (GdtLen - 1)  /* GDT Limit */
        .4byte  (BaseOfLoaderPhyAddr + LABEL_GDT)             /* GDT Base */

/*GDT Selector*/
.set    SelectorFlatC,  (LABEL_DESC_FLAT_C - LABEL_GDT)
.set    SelectorFlatRW, (LABEL_DESC_FLAT_RW - LABEL_GDT)
.set    SelectorVideo,  (LABEL_DESC_VIDEO  - LABEL_GDT + SA_RPL3) 

.set BaseOfStack, 0x0100
.set OffsetOfPMstart, (BaseOfLoaderPhyAddr + LABEL_PM_START)

LABEL_START: 
    mov %cs, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %ss

	mov $BaseOfStack, %sp

    movb $0, %dh
	call DispStrRealMode

    /* Get System Address Map */
    xor     %ebx, %ebx             /* EBX: Continuation, 0 */
    mov     $(_AddrMapBuf), %di    /* ES:DI: Buffer Pointer, _AddrMapBuf */
BEGIN.loop:
    mov     $0xe820, %eax          /* EAX: Function code, E820h */
    mov     $20, %ecx              /* ECX: Buffer size, 20 */
    mov     $0x534d4150, %edx      /* EDX: Signature 'SMAP' */
    int     $0x15                  /* INT 15h */
    jc      BEGIN.getAMfail
    add     $20, %di               /* Increase buffer pointer by 20(bytes) */
    incl    (_AMECount)            /* Inc Address Map Entry Counter by 1 */
    cmp     $0, %ebx               /* End of Address Map? */
    jne     BEGIN.loop
    jmp     BEGIN.getAMok
BEGIN.getAMfail:                   /* Failed to get system address map */
    movl    $0, (_AMECount)
BEGIN.getAMok:                     /* Got system address map */
    
    movw $SecNoOfRootDir, (wSectorNo)
	xor  %ah, %ah
	xor  %dl, %dl
	int  $0x13

LABEL_SEARCH_IN_ROOT_DIR_BEGIN: 
    cmpw $0, (wRootDirSizeForLoop)
	jz   LABEL_NO_KERNELBIN
	decw (wRootDirSizeForLoop)

	mov $BaseOfKernelFile, %ax
	mov %ax, %es 
	mov $OffsetOfKernelFile, %bx
    mov (wSectorNo), %ax

	mov $1, %cl
	call ReadSector

	mov $KernelFileName, %si 
    mov $OffsetOfKernelFile, %di 

	cld 
	mov $0x10, %dx

LABEL_SEARCH_FOR_KERNELBIN:
    cmp $0, %dx
	jz  LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR
	dec %dx
	mov $11, %cx

LABEL_CMP_FILENAME: 
    cmp $0, %cx
	jz  LABEL_FILENAME_FOUND
	dec %cx
	lodsb
	cmp %es:(%di), %al
	jz LABEL_GO_ON
	jmp LABEL_DIFFERENT

LABEL_GO_ON: 
    inc %di
	jmp LABEL_CMP_FILENAME

LABEL_DIFFERENT: 
    and  $0xFFE0, %di

	add  $0x20,   %di
	mov  $KernelFileName, %si 
	jmp  LABEL_SEARCH_FOR_KERNELBIN
    	
LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR: 
    addw  $1, (wSectorNo)
	jmp   LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_KERNELBIN: 
    mov $2, %dh 
	call DispStrRealMode 
	jmp . 

LABEL_FILENAME_FOUND: 
    mov $RootDirSectors, %ax
	and $0xFFF0, %di

	/*push %eax 
    movl %es:$0x01C(,%di,4), %eax
	movl %eax, (dwKernelSize)
	pop  %eax*/

	add $0x01A, %di 
	movw %es:(%di), %cx
	push %cx
	add  %ax, %cx
	add  $DeltaSecNo, %cx

    mov  $BaseOfKernelFile, %ax 
	mov  %ax, %es 
	mov  $OffsetOfKernelFile, %bx 
	mov  %cx, %ax 

/* Load LOADER.BIN's sector's to memory. */
LABEL_GOON_LOADING_FILE:
    push    %ax
    push    %bx
    mov     $0x0e,%ah
    mov     $'.',%al    /* Char to print */
    mov     $0x0f,%bl   /* Front color: white */
    int     $0x10       /* BIOS int 10h, ah=0xe: Print char */
    pop     %bx
    pop     %ax

    mov     $1,%cl
    call    ReadSector
    pop     %ax             /* Got index of this sector in FAT */
    call    GetFATEntry
    cmp     $0x0fff,%ax
    jz      LABEL_FILE_LOADED
    push    %ax             /* Save index of this sector in FAT */
    mov     $RootDirSectors,%dx
    add     %dx,%ax
    add     $DeltaSecNo,%ax
    add     (BPB_BytsPerSec),%bx
    jmp     LABEL_GOON_LOADING_FILE

LABEL_FILE_LOADED:
    call    KillMoter 

    mov     $1,%dh 

    call    DispStrRealMode        /* Display string(index 1) */
    
    /* Load GDTR(Global Descriptor Table Register) */
    lgdtw   GdtPtr

    /* Clear Interrupt Flags */
    cli

    /* Open A20 line. */
    inb     $0x92, %al
    orb     $0b00000010, %al
    outb    %al, $0x92

    /* Enable protect mode, PE bit of CR0. */
    movl    %cr0, %eax
    orl     $1, %eax
    movl    %eax, %cr0

    ljmpl $SelectorFlatC, $OffsetOfPMstart       


/*******************************************************************/

/* ==================================================================
   Variable table
*/
wRootDirSizeForLoop:    .2byte  RootDirSectors
wSectorNo:              .2byte  0       /* Sector number to read */
bOdd:                   .byte   0       /* odd or even? */
dwKernelSize:           .4byte  0 

/* ==================================================================
   String table
*/
KernelFileName:     .asciz  "KERNEL  BIN"        /* File name */
.set    MessageLength,9
LoadMessage:        .ascii    "Loading**"        /* index 0 */
Message1:           .ascii    "Loaded in"        /* index 1 */
Message2:           .ascii    "No KERNEL"        /* index 2 */

/* ==================================================================
   Routine: DispStrRealMode
   Action: Display a string, string index stored in %dh
*/
DispStrRealMode: 
    mov     $MessageLength, %ax
    mul     %dh
    add     $LoadMessage,%ax
    mov     %ax,%bp               /* String address */
    mov     %ds,%ax
    mov     %ax,%es
    mov     $MessageLength,%cx    /* String length */
    mov     $0x1301,%ax           /* ah = 0x13, al = 0x01(W) */
    mov     $0x07,%bx             /* PageNum 0(bh = 0), bw(bl= 0x07)*/
    mov     $0,%dl                /* Start row and column */
	add     $3,%dh
    int     $0x10                 /* BIOS INT 10h, display string */
    ret

/* ==================================================================
   Routine: ReadSector
   Action: Read %cl Sectors from %ax sector(floppy) to %es:%bx(memory) 
     Assume sector number is 'x', then:
       x/(BPB_SecPerTrk) = y,
       x%(BPB_SecPerTrk) = z.
     The remainder 'z' PLUS 1 is the start sector number;
     The quotient 'y' divide by BPB_NumHeads(RIGHT SHIFT 1 bit)is cylinder
       number;
     AND 'y' by 1 can got magnetic header.
*/
ReadSector:
    push    %ebp
    mov     %esp,%ebp
    sub     $2,%esp        /* Reserve space for saving %cl */
    mov     %cl,-2(%ebp)
    push    %bx            /* Save bx */
    mov     (BPB_SecPerTrk), %bl    /* %bl: the divider */
    div     %bl            /* 'y' in %al, 'z' in %ah */
    inc     %ah            /* z++, got start sector */
    mov     %ah,%cl        /* %cl <- start sector number */
    mov     %al,%dh        /* %dh <- 'y' */
    shr     $1,%al         /* 'y'/BPB_NumHeads */
    mov     %al,%ch        /* %ch <- Cylinder number(y>>1) */
    and     $1,%dh         /* %dh <- Magnetic header(y&1) */
    pop     %bx            /* Restore %bx */
    /* Now, we got cylinder number in %ch, start sector number in %cl, magnetic
       header in %dh. */
    mov     (BS_DrvNum), %dl
GoOnReading:
    mov     $2,%ah
    mov     -2(%ebp),%al    /* Read %al sectors */
    int     $0x13
    jc      GoOnReading     /* If CF set 1, mean read error, reread. */
    add     $2,%esp
    pop     %ebp
    ret

/* ==================================================================
   Routine: GetFATEntry
   Action: Find %ax sector's index in FAT, save result in %ax 
*/
GetFATEntry:
    push    %es
    push    %bx
    push    %ax
    mov     $BaseOfKernelFile, %ax
    sub     $0x0100,%ax
    mov     %ax,%es           /* Left 4K bytes for FAT */
    pop     %ax
    mov     $3,%bx
    mul     %bx               /* %dx:%ax = %ax*3 */
    mov     $2,%bx
    div     %bx               /* %dx:%ax/2 */
    movb    %dl, (bOdd)       /* store remainder %dx in label bOdd. */

LABEL_EVEN:
    xor     %dx,%dx           /* Now %ax is the offset of FATEntry in FAT */
    mov     (BPB_BytsPerSec),%bx
    div     %bx               /* %dx:%ax/BPB_BytsPerSec */
    push    %dx
    mov     $0,%bx
    add     $SecNoOfFAT1,%ax  /* %ax <- FATEntry's sector */
    mov     $2,%cl            /* Read 2 sectors in 1 time, because FATEntry */
    call    ReadSector        /* may be in 2 sectors. */
    pop     %dx
    add     %dx,%bx
    mov     %es:(%bx),%ax     /* read FAT entry by word(2 bytes) */
    cmpb    $0,(bOdd)         /* remainder %dx(see above) == 0 ?*/
    jz      LABEL_EVEN_2      /* NOTE: %ah: high address byte, %al: low byte */
    shr     $4,%ax

LABEL_EVEN_2:
    and     $0x0fff,%ax

LABEL_GET_FAT_ENTRY_OK:
    pop     %bx
    pop     %es
    ret

KillMoter: 
    pushw %dx
	movw  $0x3F2, %dx
	movb  $0, %al 
	outb  %al, %dx
	popw %dx
	ret

.code32
.text
LABEL_PM_START:
    mov     $(SelectorFlatRW), %ax
    mov     %ax, %ds                /* Data segment selector */
    mov     %ax, %es                /* Data segment selector */
    mov     %ax, %fs                /* Data segment selector */
    mov     %ax, %ss                /* Stack segment selector */
    mov     $(TopOfStack), %esp

    mov     $(SelectorVideo), %ax
    mov     %ax, %gs                /* Video segment selector(dest) */

    //pushl    $(PMMessage)
    //call    DispStr
    //add     $4, %esp


    //push    $(ARDSTitle)           /* Display addr range descriptor struct title */
    //call    DispStr
    //add     $4, %esp
    call    DispAddrMap           /* Display system address map */

    call    SetupPaging            /* Setup and enable paging */
	
	call InitKernel

    ljmpl $SelectorFlatC, $KernelEntryPointPhyAddr
	//jmp .

SetupPaging:
/* Directly map linear addresses to physical addresses for simplification */
    /* Get usable PDE number from memory size. */
    xor     %edx, %edx
    mov     (MemSize), %eax         /* Memory Size */
    mov     $0x400000, %ebx         /* Page table size(bytes), 1024*1024*4 */
    div     %ebx                    /* temp = MemSize/4M */
    mov     %eax, %ecx
    test    %edx, %edx
    jz      SP.no_remainder
    inc     %ecx
SP.no_remainder:
    push    %ecx                    /* number of PDE = ceil(temp) */

    /* Init page table directories, %ecx entries. */
    mov     $(SelectorFlatRW), %ax
    mov     %ax, %es
	mov     $(PageDirBase), %edi
    xor     %eax, %eax
    mov     $(PageTblBase | PG_P | PG_USU | PG_RWW), %eax
SP.1:
    stosl                  
    add     $4096, %eax     
    loop    SP.1            

    pop     %eax             
	mov     $1024, %ebx
	mul     %ebx
	mov     %eax, %ecx
	mov     $(PageTblBase), %edi
	xor     %eax, %eax
    /* Set PTE attributes(flags): P:1, U/S: 1， R/W: 1. */
    mov     $(PG_P | PG_USU | PG_RWW), %eax
SP.2:
    stosl                   /* Store %eax to %es:%edi consecutively. */
    add     $4096, %eax     /* Pages are in sequential format. */
    loop    SP.2            /* %ecx loops. */

    mov     $(PageDirBase), %eax
    mov     %eax, %cr3 /* Store base address of page table dir to %cr3. */
    mov     %cr0, %eax
    or      $0x80000000, %eax
    mov     %eax, %cr0 /* Enable paging bit in %cr0. */
	jmp     SP.3

SP.3: 
    nop

	ret
/* Display system address map. */
DispAddrMap:
    push    %esi
    push    %edi
    push    %ecx

    mov     $(AddrMapBuf), %esi  /* int *p = AddrMapBuf;                     */
    mov     (AMECount), %ecx     /* for (int i=0; i<AMECount; i++) {         */
DMS.loop:
    mov     $5, %edx             /*   int j = 5;                             */
    mov     $(ARDStruct), %edi   /*   int *q = (int *)ARDStruct;             */
DMS.1:
    push    (%esi)               /*   do {                                   */
    call    DispInt              /*     printf("%xh", *p);                   */
    pop     %eax
    stosl                        /*     *q++ = *p;                           */
    add     $4, %esi             /*     p++;                                 */
    dec     %edx                 /*     j--;                                 */
    cmp     $0, %edx
    jnz     DMS.1                /*   } while(j != 0);                       */
    call    DispLF               /*   printf("\n");                          */
    cmpl    $1, (Type)           /*   if (Type == AddressRangMemory){        */
    jne     DMS.2
    mov     (BaseAddrLow), %eax  /*     if(ARDStruct.BaseAddrLow             */
    add     (LengthLow), %eax    /*        + ARDStruct.LengthLow             */
    cmp     (MemSize), %eax      /*        > MemSize){                       */
    jb      DMS.2                /*       MemSize = BaseAddrLow + LengthLow; */
    mov     %eax, (MemSize)      /*     }                                    */
DMS.2:                           /*   }                                      */
    loop    DMS.loop             /* }                                        */

    call    DispLF               /* printf("\n");                            */
    push    $(RAMSizeMes)
    call    DispStr              /* printf("%s", RAMSizeMes);                */
    add     $4, %esp

    pushl   (MemSize)
    call    DispInt              /* printf("%x", MemSize);                   */
    add     $4, %esp
    call    DispLF               /* printf("\n");                            */

    pop     %ecx
    pop     %edi
    pop     %esi
    ret

InitKernel: 
    xor %esi, %esi
	movw (E_PHNUM_PhyAddr), %cx
	movzwl %cx, %ecx
    mov  (E_PHOFF_PhyAddr), %esi
	add  $(BaseOfKernelFilePhyAddr), %esi 

InitKernel.Begin: 
    mov     (%esi), %eax 
	cmp     $0, %eax 
	jz  InitKernel.NoAction 
	pushl   0x10(%esi)
	mov     0x4(%esi), %eax 
	add     $(BaseOfKernelFilePhyAddr), %eax 
	push    %eax 
	pushl   0x8(%esi) 
	call    MemCpy
	add     $12, %esp 

InitKernel.NoAction: 
    add     $0x20, %esi 
	dec     %ecx 
	jnz     InitKernel.Begin

	ret 


DispAL:
    push   %ecx
    push   %edx
    push   %edi
    mov    (CursorPos), %edi
    mov    $0xf, %ah
    mov    %al, %dl
    shrb   $4, %al
    mov    $2, %ecx
DispAL.begin:
    and    $0xf, %al
    cmp    $9, %al
    ja     DispAL.1
    add    $'0', %al
    jmp    DispAL.2
DispAL.1:
    sub    $0xA, %al
    add    $'A', %al
DispAL.2:
    mov    %ax, %gs:(%edi)
    add    $2, %edi
    mov    %dl, %al
    loop   DispAL.begin
    mov    %edi, (CursorPos)
    pop    %edi
    pop    %edx
    pop    %ecx
    ret

DispInt:
    movl    4(%esp), %eax
    shr     $24, %eax
    call    DispAL
    movl    4(%esp), %eax
    shr     $16, %eax
    call    DispAL
    movl    4(%esp), %eax
    shr     $8, %eax
    call    DispAL
    movl    4(%esp), %eax
    call    DispAL
    movb    $0x7, %ah
    movb    $'h', %al
    pushl   %edi
    movl    (CursorPos), %edi
    movw    %ax, %gs:(%edi)
    addl    $4, %edi
    movl    %edi, (CursorPos)
    popl    %edi
    ret

DispStr:
    movl    %ss:(%esp), %esi
    pushl   %ebp
    movl    %esp, %ebp
    pushl   %ebx
    pushl   %esi
    pushl   %edi
    movl    8(%ebp), %esi
    movl    (CursorPos), %edi
    movb    $0xF, %ah
DispStr.1:
    lodsb
    testb   %al, %al
    jz      DispStr.2
    cmpb    $0xA, %al
    jnz     DispStr.3
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
    jmp     DispStr.1
DispStr.3:
    movw    %ax, %gs:(%edi)
    addl    $2, %edi
    jmp     DispStr.1
DispStr.2:
    movl    %edi, (CursorPos)
    popl    %edi
    popl    %esi
    popl    %ebx
    popl    %ebp
    ret

DispLF:
    pushl  $(LFMes)
    call    DispStr
    addl    $4, %esp
    ret

MemCpy:
    pushl   %ebp
    mov     %esp, %ebp

    pushl   %esi
    pushl   %edi
    pushl   %ecx

    mov     8(%ebp), %edi    /* Destination */
    mov     12(%ebp), %esi   /* Source */
    mov     16(%ebp), %ecx   /* Counter */
MemCpy.1:
    cmp     $0, %ecx  /* Loop counter */
    jz      MemCpy.2
    movb    %ds:(%esi), %al
    inc     %esi
    movb    %al, %es:(%edi)
    inc     %edi
    dec     %ecx
    jmp     MemCpy.1
MemCpy.2:
    mov     8(%ebp), %eax
    pop     %ecx
    pop     %edi
    pop     %esi
    mov     %ebp, %esp
    pop     %ebp
    ret

.align 32
LABEL_DATA:
	_PMMessage:     .ascii "Welcome to protect mode! ^-^\n\0"
	_ARDSTitle:     .ascii "BaseAddrLo BaseAddrHi LengthLo LengthHi   Type\n\0"
	_RAMSizeMes:    .ascii "RAM Size:\0"
	_LFMes:         .ascii "\n\0"   /* Line Feed Message(New line) */
	_AMECount:      .4byte 0        /* Address Map Entry Counter */
	_CursorPos:     .4byte (80*10+0)*2  /* Screen Cursor position for printing */
	_MemSize:       .4byte 0        /* Usable Memory Size */
	_ARDStruct:                     /* Address Range Descriptor Structure */
	  _BaseAddrLow:     .4byte 0    /* Low 32 bits of base address */
	  _BaseAddrHigh:    .4byte 0    /* High 32 bits of base address */
	  _LengthLow:       .4byte 0    /* Low 32 bits of length in bytes */
	  _LengthHigh:      .4byte 0    /* High 32 bits of length in bytes */
	  _Type:            .4byte 0    /* Address type of this range: 0, 1, other */
	_AddrMapBuf:  .space 256, 0      /* Address map buffer */
	
	.set    PMMessage,        (BaseOfLoaderPhyAddr + _PMMessage)
	.set    ARDSTitle,        (BaseOfLoaderPhyAddr + _ARDSTitle )
	.set    RAMSizeMes,       (BaseOfLoaderPhyAddr + _RAMSizeMes )
	.set    LFMes,            (BaseOfLoaderPhyAddr + _LFMes )
	.set    AMECount,         (BaseOfLoaderPhyAddr + _AMECount )
	.set    CursorPos,        (BaseOfLoaderPhyAddr + _CursorPos )
	.set    MemSize,          (BaseOfLoaderPhyAddr + _MemSize )
	.set    ARDStruct,        (BaseOfLoaderPhyAddr + _ARDStruct )
	  .set  BaseAddrLow,      (BaseOfLoaderPhyAddr + _BaseAddrLow )
	  .set  BaseAddrHigh,     (BaseOfLoaderPhyAddr + _BaseAddrHigh )
	  .set  LengthLow,        (BaseOfLoaderPhyAddr + _LengthLow )
	  .set  LengthHigh,       (BaseOfLoaderPhyAddr + _LengthHigh )
	  .set  Type,             (BaseOfLoaderPhyAddr + _Type )
	.set    AddrMapBuf,       (BaseOfLoaderPhyAddr + _AddrMapBuf )

LABEL_STACK:
.space  1024, 0
.set  TopOfStack, (BaseOfLoaderPhyAddr + .)
