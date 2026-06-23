%define sys_brk 45
%define heap_chunk 1000
%define free 102
%define reserved 114
section .data
original_brk dd 0
current_brk dd 0
section .text
global tax_malloc
global final_free
global tax_free

tax_free:
	push ebp
	mov ebp, esp
	push ebx
	push esi
	push edi
	mov edi, 0
	mov ebx, [ebp+0x8]
	mov ecx, [original_brk]
	mov eax, [current_brk]
search_for_free_before:
	add ecx, 5
	cmp ecx, ebx
	je tax_free_modify_header ;check if we have reached our pointer
	sub ecx, 1
	cmp [ecx], byte free 
	je tax_free_found_free ;check if the space is free 'f'
	sub ecx, 4 ;we continue if it is not the pointer or free 'f' space
	mov esi, [ecx]
	add ecx, esi
	jmp search_for_free_before
tax_free_modify_header:
	cmp edi, 0
	je tax_free_no_free_before ;if we dont have extra heap to add we jump to the next label
	sub ecx, 5
	mov esi, [ecx] ;if we have extra free heap we store the original amount to be freed in esi
	sub ecx, edi ;then we go to the header that the last free was in
	add edi, esi ;we add every free space together so that we can proceed
	mov [ecx], edi ;we store the free space in the last header
	add ecx, 4
	mov [ecx], byte free
	sub ecx, 4
	add ecx, edi ;we go to next header of our requested free header
	jmp search_for_free_after
tax_free_no_free_before:
	sub ecx, 1
	mov [ecx], byte free ;if there was no free space before header we make header free and continue
	sub ecx, 4
	mov edi, [ecx] ;we put in edi the amount of space we need to free
	mov esi, [ecx] 
	add ecx, esi ;we go to the next header to check if we will add more free space or not
search_for_free_after:
	add ecx, 4
	cmp [ecx], byte free ;we check if the next header is free 'f'
	je found_free_after 
	jmp tax_free_ret ;if the next header is not free that means we are done
found_free_after:
	sub ecx, 4
	mov esi, [ecx] ;we store the amount of free space to esi
	sub ecx, edi ;we go back to the header we have first freed
	add edi, esi ;we add the free space to the header
	mov [ecx], edi
	jmp tax_free_ret ;if the head was the big free header then we can return
tax_free_found_free:
	sub ecx, 4
	add edi, dword [ecx] ;in edi we store the possible extra heap (if there is any)
	mov esi, [ecx]
	add ecx, esi
	add ecx, 5
	cmp ecx, ebx ;we check if we have reached our pointer
	je tax_free_modify_header
	sub ecx, 1
	cmp [ecx], byte free ;we check if the next is not free 'f' so that we can make the right modifications
	jne tax_free_no_extra_heap
	sub ecx, 4
	add edi, dword [ecx] ;in edi we store the possible extra heap (if there is any)
	mov esi, [ecx]
	add ecx, esi
	jmp search_for_free_before
tax_free_no_extra_heap:
	sub ecx, 4 ;we get ecx to the right place so that we can continue
	mov edi, 0 ;we put zero in edi because everything we have consumed till now needs to be erased
	jmp search_for_free_before ;we continue searching for our pointer or free space
tax_free_ret:
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
final_free:
	push ebp
	mov ebp, esp
	push ebx
	mov ebx, [original_brk]
	mov eax, sys_brk
	int 0x80
	pop ebx
	pop ebp
	ret
get_heap:
	push ebp
	mov ebp, esp
	push ebx
	mov eax, sys_brk
	mov ebx, 0
	int 0x80
	jc get_heap_error ;jc means jump if carry flag which means jump if there was an error
	mov [original_brk], eax ;store the original brkpoint
	mov [current_brk], eax ;original is also current at this point
	add eax, heap_chunk ;add the amount of heap we want to eax to ask for it
	mov ebx, eax
	mov eax, sys_brk
	int 0x80
	jc get_heap_error
	mov [current_brk], eax ;store the current heap
	mov eax, [original_brk]
	mov [eax], dword heap_chunk
	add eax, 4
	mov [eax], byte free
	mov eax, 1
	pop ebx
	pop ebp
	ret
get_heap_error:
	mov eax, 0
	pop ebx
	pop ebp
	ret
tax_malloc:
	push ebp
	mov ebp, esp
	push ebx
	push esi
	push edi
	cmp dword [original_brk], 0
	jne store_before_find_free ;jump to the pointer to store the original_brk and current_brk
	call get_heap
	cmp eax, 0 ;if eax returns with 0 from get_heap it means there was an error
	je tax_malloc_error
store_before_find_free:
	mov ecx, dword [original_brk]
	mov eax, dword [current_brk]
	mov ebx, [ebp+0x8]
	add ebx, 5
	mov edx, ecx
find_free:
	cmp ecx, eax
	jb find_free_continue
	pusha
	push dword [original_brk]
	call get_heap
	pop dword [original_brk]
	popa
	mov eax, dword [current_brk]
	cmp byte [edx+0x4], free
	jne find_free_continue
	add [edx], dword heap_chunk
	mov ecx, edx
find_free_continue:
	add ecx, 4
	cmp [ecx], byte free
	je check_if_free_fits ;jump to a label that checks if the heap amount requested can fit
	sub ecx, 4
	mov esi, [ecx]
	mov edx, ecx
	add ecx, esi ;we add the amount of the reserved heap to the pointer so that we can continue to find free space
	jmp find_free
get_ready_to_call_heap:
	mov ecx, current_brk ;we store the new pointer in ecx so that we start from the right place and the is no mismatch
	push ecx ;we preserve the pointer so that we dont need to start from the beginning again
	push original_brk ;we preserve the original_brk to know where our actual base is (where we start from)
	call get_heap
	pop edi
	mov [original_brk], edi
	pop ecx
	jmp find_free ;because we now have extended the heap we can continue
check_if_free_fits:
	sub ecx, 4
	cmp dword [ecx], ebx
	jae found_free_modify_header ;jumps if the requested heap amount fits in the free space
	mov esi, [ecx]
	mov edx, ecx
	add ecx, esi ;we add the amount of free heap to the pointer to check if we need to call get_heap
	jmp find_free
found_free_modify_header:
	mov esi, [ecx]
	add ecx, esi
	cmp [ecx], eax ;we need to know if we are modifying the last header
	jae tax_malloc_last_free
	sub ecx, esi ;because we know we are not modifying the last header we go back
	sub esi, ebx ;we need to check if we can fit another header in the free space that will be left
	cmp esi, 6
	jb tax_malloc_take_all
	mov [ecx], ebx ;because we are gonna make another header we store the reversed amount
	add ecx, 4
	mov [ecx], byte reserved ;we put the 'r' here
	inc ecx
	push ecx ;we store the pointer in the stack to return to the user
	sub ecx, 5
	add ecx, ebx ;we go to where the next header should start
	mov [ecx], esi ;we put the amount of heap that will be free here
	add ecx, 4
	mov [ecx], byte free
	jmp tax_malloc_ret
tax_malloc_take_all:
	add ecx, 4
	mov [ecx], byte reserved ;we take all the heap space that was in this header so we only change 'r'
	inc ecx ;store the pointer in the stack to return to the user
	push ecx
	jmp tax_malloc_ret
tax_malloc_last_free:
	sub ecx, esi
	sub esi, ebx ;we need to check if we can fit another header in the free space that will be left
	cmp esi, 6
	jb tax_malloc_take_all
	mov [ecx], ebx ;because we know that we are modifying the last free space we place the amount we will reserve to the header
	add ecx, 4
	mov [ecx], byte reserved ;we place the 'r'
	inc ecx ;we increment so that we can have the pointer to return to the user
	push ecx ;we store the pointer
	sub ecx, 5 ;we go back to the beginning of the header
	add ecx, ebx ;we go to where the next header is supposed to be
	mov [ecx], esi ;we put the amount of free heap into the header
	add ecx, 4 
	mov [ecx], byte free ;we store the 'f'
tax_malloc_ret:
	pop eax ;we pop the pointer and everything we have in the stack
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
tax_malloc_error:
	mov esp, ebp
	sub esp, 12
	pop edi
	pop esi
	pop ebx
	pop ebp
	mov eax, 0
	ret