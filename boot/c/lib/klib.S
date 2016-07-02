.extern disp_pos 

.section .text 

.globl  disp_str
.globl  disp_color_str
.globl  out_byte
.globl  in_byte 

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

out_byte: 
    mov 4(%esp), %edx  
	mov 8(%esp), %al 
	outb %al, %dx
	nop 
	nop 
	ret 

in_byte: 
    mov 4(%esp), %edx 
	xor %eax, %eax 
	inb %dx, %al 
	nop 
	nop 
	ret
