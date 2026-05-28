%define sys_write 4
%define std_out 1

section .text
global print_num

print_num:
    push ebp
    mov ebp, esp
        mov eax, [ebp+0x8]
        push edi
        mov edi, 0
        cmp eax, 0
        jl negative
        je print_zero
    mov eax, 1000000000
loop:
        mov edx, 0
    mov ecx, 10
    div ecx
    mov ecx, [ebp+0x8]
    cmp eax, ecx
    ja loop
    mov ecx, eax
    mov eax, [ebp+0x8]
print:
    mov edx, 0
    div ecx
    add al, 48
    push ecx
    push edx
    push ebx
    push eax
    mov eax, sys_write
    mov ebx, std_out
    mov ecx, esp
    mov edx, 1
    int 0x80
        add edi, eax
    pop eax
    pop ebx
    pop eax
    pop ecx
    push eax
    mov eax, ecx
    mov ecx, 10
        mov edx, 0
    div ecx
    mov ecx, eax
    pop eax
    cmp ecx, 0
    ja print
        jmp exit
negative:
        mov al, 45
        push eax
    mov eax, sys_write
    mov ebx, std_out
    mov ecx, esp
    mov edx, 1
    int 0x80
        add edi, eax
    pop eax
    mov eax, -1000000000
loop_negative:
        mov edx, 0
        cdq
    mov ecx, 10
    idiv ecx
    mov ecx, [ebp+0x8]
    cmp eax, ecx
    jl loop_negative
    mov ecx, eax
    mov eax, [ebp+0x8]
print_negative:
    mov edx, 0
        cdq
    idiv ecx
    add al, 48
    push ecx
    push edx
    push ebx
    push eax
    mov eax, sys_write
    mov ebx, std_out
    mov ecx, esp
    mov edx, 1
    int 0x80
        add edi, eax
    pop eax
    pop ebx
    pop eax
    pop ecx
    push eax
    mov eax, ecx
    mov ecx, 10
        mov edx, 0
        cdq
    idiv ecx
    mov ecx, eax
    pop eax
    cmp ecx, 0
    ja print_negative
        jmp exit
print_zero:
        mov al, 48
        push eax
    mov eax, sys_write
    mov ebx, std_out
    mov ecx, esp
    mov edx, 1
    int 0x80
        add edi, eax
    pop eax
exit:
        mov eax, edi
        mov edi, [ebp-0x4]
    mov esp, ebp
    pop ebp
    ret