%define sys_write 4
section .text
global print_capital

print_capital:
        push ebp
        mov ebp, esp
        mov eax, 0
        mov ecx, [ebp+0x8]
_loop:
        mov dl, byte [ecx]
        cmp dl, 0
        je print_capital_ret
        cmp dl, 97
        jb print_char
        cmp dl, 122
        ja print_char
        sub dl, 32
print_char:
        push ebx
        push eax
        push ecx
        push edx
        mov eax, sys_write
        mov ebx, 1
        mov ecx, esp
        mov edx, 1
        int 0x80
        cmp eax, 0
        jl error
        pop edx
        pop ecx
        pop eax
        pop ebx
        inc eax
        inc ecx
        jmp _loop
error:
        mov eax, -1
print_capital_ret:
        mov esp, ebp
        pop ebp
        ret