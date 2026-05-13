%define true 1
%define false 0
section .text
global is_alpha

is_alpha:
        push ebp
        mov ebp, esp
        mov al, [esp+0x8]
        cmp al, 122
        ja err
        cmp al, 91
        jb cap
        cmp al, 97
        jb err
        jmp correct
cap:
        cmp al, 65
        jb err
correct:
        mov eax, 1
is_alpha_ret:
        mov esp, ebp
        pop ebp
        ret
err:
        mov eax, 0
        jmp is_alpha_ret