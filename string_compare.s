section .text
global string_compare


string_compare:
        push ebp
        mov ebp, esp
        push esi
        push edi
        mov esi, dword [ebp+0x8]
        mov edi, dword [ebp+0xc]
loop:
        mov al, byte [esi]
        mov dl, byte [edi]
        sub al, dl
        cmp al, 0
        jne string_compare_ret
        cmp dl, 0
        je string_compare_ret
        inc esi
        inc edi
        jmp loop
string_compare_ret:
        pop edi
        pop esi
        mov esp, ebp
        pop ebp
        ret