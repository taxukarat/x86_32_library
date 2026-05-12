%define true 1
%define false 0
section .text
global is_num

is_num:
        push ebp
        mov ebp, esp
        mov al, [ebp+0x8]
        cmp al, 48
        jb err
        cmp al, 57
        ja err
        mov eax, true
is_num_ret:
        mov esp, ebp
        pop ebp
        ret
err:
        mov eax, 0
        jmp is_num_ret