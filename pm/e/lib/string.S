.section .text 

.globl memcpy
.globl memset
.globl strcpy

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

memset:
    pushl   %ebp
    mov     %esp, %ebp

    pushl   %esi
    pushl   %edi
    pushl   %ecx

    mov     8(%ebp), %edi    /* Destination */
    mov     12(%ebp), %edx   /* Char to be put */
    mov     16(%ebp), %ecx   /* Counter */
memset.1:
    cmp     $0, %ecx  /* Loop counter */
    jz      memset.2
    movb    %al, (%edi)
    inc     %edi

    dec     %ecx
    jmp     memset.1
memset.2:
    pop     %ecx
    pop     %edi
    pop     %esi
    mov     %ebp, %esp
    pop     %ebp

    ret

strcpy: 
    pushl   %ebp
    mov     %esp, %ebp
   
    mov 12(%ebp), %esi
	mov 8(%ebp), %edi

strcpy.1: 
    mov (%esi), %al
	inc %esi 

	movb %al, (%edi)
	inc %edi

	cmp $0, %al
	jnz strcpy.1 

	mov 8(%ebp), %eax

	pop %ebp 
    ret 
