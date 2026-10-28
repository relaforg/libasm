section .text
	global ft_list_push_front
	extern malloc

	struc s_item
		.data:  resq 1
		.next:  resq 1
	endstruc

	ft_list_push_front:
		push rdi
		mov rdi, s_item_size
		call malloc
		pop rdi

		cmp rax, 0
		je .ret

		mov [rax], rsi
		mov r8, [rdi]
		mov [rax + s_item.next], r8

		mov [rdi], rax

		.ret:
			ret
