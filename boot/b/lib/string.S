.section .text 

.globl memcpy

memcpy:
    pushl   %ebp
    mov     %esp, %ebp

    pushl   %esi
    pushl   %edi
    pushl   %ecx

    mov     8(%ebp), %edi    /* Destination */
    mov     12(%ebp), %esi   /* Source */
    mov     16(%ebp), %ecx   /* Counter */
memcpy.1:
    cmp     $0, %ecx  /* Loop counter */
    jz      memcpy.2
    movb    %ds:(%esi), %al
    inc     %esi
    movb    %al, %es:(%edi)
    inc     %edi
    dec     %ecx
    jmp     memcpy.1
memcpy.2:
    mov     8(%ebp), %eax
    pop     %ecx
    pop     %edi
    pop     %esi
    mov     %ebp, %esp
    pop     %ebp

    ret

