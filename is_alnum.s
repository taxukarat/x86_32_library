%define true 1
%define false 0
section .text
global is_alnum
extern is_num
extern is_alpha

is_alnum:
        push ebp
        mov ebp, esp
        sub esp, 4
        mov al, byte [ebp+0x8]
        mov [esp], al
        call is_num
        cmp eax, true
        je is_true
        call is_alpha
        cmp eax, true
        je is_true
        mov eax, false
is_alnum_ret:
        mov esp, ebp
        pop ebp
        ret
is_true:
        mov eax, true
        jmp is_alnum_ret