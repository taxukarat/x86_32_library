section .text
global strlen

strlen:
        push ebp
        mov ebp, esp
        mov edx, ebp
        add edx, 0x8
        mov ecx, [ebp+8]
        mov eax, 0
loop:
        mov dl, byte [ecx]
        cmp dl, 0
        je strlen_ret
        inc eax
        inc ecx
        jmp loop
strlen_ret:
        mov esp, ebp
        pop ebp
        ret