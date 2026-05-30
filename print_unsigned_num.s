%define sys_write 4
%define stdout 1
%define ascii_zero 48
section .text

global print_unsigned_num

print_unsigned_num:
        push ebp
        mov ebp, esp
        mov eax, 1000000000
        mov ecx, [ebp+0x8]
        push ebx
        push edi
        mov edi, 0
        mov ebx, 10
loop:
        mov edx, 0
        div ebx
        cmp eax, ecx
        ja loop
print_loop:
        push eax
        mov eax, ecx
        pop ecx
        mov edx, 0
        div ecx
        add eax, ascii_zero
        push ecx
        push edx
        push eax
        mov eax, sys_write
        mov ebx, stdout
        mov ecx, esp
        mov edx, 1
        int 0x80
        inc edi
        pop eax
        pop edx
        pop ecx
        mov eax, ecx
        mov ebx, 10
        mov ecx, edx
        mov edx, 0
        div ebx
        cmp eax, 0
        jne print_loop
        mov eax, edi
        pop edi
        pop ebx
        mov esp, ebp
        pop ebp
        ret