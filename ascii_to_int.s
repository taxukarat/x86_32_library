section .text

global ascii_to_int
extern is_num

ascii_to_int:
        push ebp
        mov ebp, esp
        push ebx
        push edi
        mov edi, 1
        mov eax, 0
        mov ecx, [ebp+0x8]
        mov bl, byte [ecx]
        cmp bl, 45
        jne num_positive
        mov edi, -1
        inc ecx
        mov ebx, 0
num_positive:
        mov bl, byte [ecx]
        push eax
        push ecx
        push ebx
        call is_num
        cmp eax, 0
        je ascii_to_int_ret
        pop ebx
        pop ecx
        pop eax
        sub bl, 48
        push ecx
        mov ecx, 10
        mul ecx
        pop ecx
        add eax, ebx
        inc ecx
        jmp num_positive
ascii_to_int_ret:
        pop ebx
        pop ecx
        pop eax
        mul edi
        pop edi
        pop ebx
        mov esp, ebp
        pop ebp
        ret