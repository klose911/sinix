.section .data 

disp_pos: .long 0 

.section .text 

.global  disp_str

disp_str:
    movl    %ss:(%esp), %esi
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
