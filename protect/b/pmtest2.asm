%include	"pm.inc"	; 常量, 宏, 以及一些说明

org	0100h
	jmp	LABEL_BEGIN

[SECTION .gdt]
LABEL_GDT:	       Descriptor        0,                0, 0           ; 空描述符
LABEL_DESC_NORMAL:      Descriptor   0,          0FFFFh,   DA_DRW     ;
LABEL_DESC_CODE32: Descriptor        0, SegCode32Len - 1, DA_C + DA_32; 非一致代码段
LABEL_DESC_CODE16:  Descriptor       0,           0FFFFh,  DA_C
LABEL_DESC_DATA:   Descriptor        0,      DataLen - 1,  DA_DRW
LABEL_DESC_STACK:  Descriptor        0,       TopOfStack,  DA_DRWA + DA_32
LABEL_DESC_TEST:   Descriptor 0500000h,         0FFFFh,    DA_DRW   
LABEL_DESC_VIDEO:  Descriptor  0B8000h,           0ffffh,  DA_DRW	     ; 显存首地址

GdtLen		equ	$ - LABEL_GDT	; GDT长度
GdtPtr		dw	GdtLen - 1	; GDT界限
		    dd	0		; GDT基地址

; GDT 选择子
SelectorNormal      equ LABEL_DESC_NORMAL   - LABEL_GDT
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorCode16      equ LABEL_DESC_CODE16   - LABEL_GDT
SelectorData        equ LABEL_DESC_DATA     - LABEL_GDT
SelectorStack       equ LABEL_DESC_STACK    - LABEL_GDT
SelectorTest        equ LABEL_DESC_TEST     - LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT
; END of [SECTION .gdt]

[SECTION .data1]
ALIGN     32
[BITS     32]
LABEL_DATA:   
     SP_Value_In_Real_Mode     dw    0
	 PM_Message                db    "In Protect Mode now. ^-^", 0
	 Offset_PM_Message         equ   PM_Message - $$ 
	 Str_Test                  db    "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
	 Offset_Str_Test           equ   Str_Test   - $$ 
     DataLen                   equ   $ - LABEL_DATA 
; END of [SECTION .data1]

[SECTION  .gs]
ALIGN      32
[BITS      32]
LABEL_STACK:  
       times    512  db    0
       TopOfStack    equ   $ - LABEL_STACK  - 1
; END of [SECTION .gs]

[SECTION .s16]
[BITS	16]
LABEL_BEGIN:
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0100h

    mov [LABEL_GO_BACK_TO_REAL + 3], ax
	mov [SP_Value_In_Real_Mode], sp 

	; 初始化 32 位代码段描述符
	mov ax, cs 
	movzx  eax, ax 
	shl eax, 4 
	add eax, LABEL_SEG_CODE16
	mov word [LABEL_DESC_CODE16 + 2], ax 
	shr eax, 16
	mov byte [LABEL_DESC_CODE16 + 4], al
	mov byte [LABEL_DESC_CODE16 + 7], ah 

	; 初始化 32 位代码段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE32
	mov	word [LABEL_DESC_CODE32 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE32 + 4], al
	mov	byte [LABEL_DESC_CODE32 + 7], ah

	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_DATA
	mov	word [LABEL_DESC_DATA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_DATA + 4], al
	mov	byte [LABEL_DESC_DATA + 7], ah

	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK
	mov	word [LABEL_DESC_STACK + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK + 4], al
	mov	byte [LABEL_DESC_STACK + 7], ah

	; 为加载 GDTR 作准备
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt 基地址
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt 基地址

	; 加载 GDTR
	lgdt	[GdtPtr]

	; 关中断
	cli

	; 打开地址线A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	; 准备切换到保护模式
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	; 真正进入保护模式
	jmp	dword SelectorCode32:0	; 执行这一句会把 SelectorCode32 装入 cs,
					; 并跳转到 Code32Selector:0  处

LABEL_REAL_ENTRY: 
    mov ax, cs 
	mov ds, ax
	mov es, ax
	mov ss, ax 
	
	mov sp, [SP_Value_In_Real_Mode]

	in al, 92h 
	and al, 11111101b
	out 92h, al

	sti

	mov ax, 4C00H
	int 21H
; END of [SECTION .s16]


[SECTION .s32]; 32 位代码段. 由实模式跳入.
[BITS	32]

LABEL_SEG_CODE32:
    mov ax, SelectorData
	mov ds, ax 
	mov ax, SelectorTest
	mov es, ax 
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子(目的)
	
	mov ax, SelectorStack
	mov es, ax 
	
	mov esp, TopOfStack

	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	xor esi, esi
	xor edi, edi 
	mov esi, Offset_PM_Message
	mov	edi, (80 * 10 + 0) * 2	; 屏幕第 11 行, 第 79 列。
	cld 

.1: 
    lodsb
	test al, al 
	jz .2 
	mov	[gs:edi], ax
	add edi, 2 
	jmp .1 

.2: 
    call DispReturn

	call TestRead
	call TestWrite
	call TestRead

	; 到此停止
	jmp	SelectorCode16:0 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestRead: 
    xor esi, esi 
	mov ecx, 8 
.loop: 
    mov al, [es:esi]
    call DispAL
	inc esi 
	loop .loop

	call DispReturn 

	ret
; End of TestRead

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TestWrite: 
    push esi
	push edi 
	xor esi, esi 
	xor edi, edi 
	mov esi, Offset_Str_Test
	cld 

.TestWrite_1: 
    lodsb 
	test al, al 
	jz .TestWrite_2
	mov [es:edi], al 
	inc edi
	jmp .TestWrite_1

.TestWrite_2: 
    pop edi
	pop esi 

	ret 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DispAL: 
    push ecx 
	push edx 

	mov ah, 0Ch
	mov dl, al 
	shr al, 4 
	mov ecx, 2

.DispAL_begin: 
    and al, 01111b 
	cmp al, 9 
	ja .DispAL_1
	add al, '0'
	jmp .DispAL_2

.DispAL_1: 
    sub al, 0Ah
	add al, 'A'

.DispAL_2: 
    mov [gs:edi], ax 
	add edi, 2 

	mov al, dl
	loop .DispAL_begin
	add edi, 2 

	pop edx
	pop ecx 

	ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DispReturn: 
    push eax
	push ebx 
	mov eax, edi 
	mov bl, 160 
	div bl 
	and eax, 0FFh
	inc eax 
	mov bl, 160 
	mul bl 
	mov edi, eax 
	pop ebx
	pop eax 

	ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SegCode32Len	equ	$ - LABEL_SEG_CODE32
; END of [SECTION .s32]

[SECTION .s16code]
ALIGN           32
[BITS           16]

LABEL_SEG_CODE16: 
      mov ax, SelectorNormal
	  mov ds, ax 
	  mov es, ax 
	  mov fs, ax 
	  mov gs, ax 
	  mov ss, ax 

	  mov eax, cr0 
	  and al,  11111110b
	  mov cr0, eax 

LABEL_GO_BACK_TO_REAL: 
      jmp 0:LABEL_REAL_ENTRY

Code16Len     equ   $ - LABEL_SEG_CODE16

; END of [SECTION .s16code]
