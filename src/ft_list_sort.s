section .text
	global ft_list_sort
	extern ft_list_size

	struc s_item
		.data:  resq 1
		.next:  resq 1
	endstruc

	ft_list_sort:
		cmp rdi, 0
		je .ret

		push rdi
		mov rdi, [rdi]
		call ft_list_size
		pop rdi

		cmp rax, 1
		jb .ret

		mov r10, [rdi]
		mov r11, r10 ; la tete de la liste
		mov r12, rsi ; la fonction de comparaison
		.loop:
			cmp qword [r10 + s_item.next], 0
			je .ret

			mov rdi, [r10]	
			mov r14, [r10 + s_item.next]
			mov rsi, [r14]

			push r10
			push r11
			sub rsp, 8
			call r12
			add rsp, 8
			pop r11
			pop r10

			cmp eax, 0
			jg .swap
			jmp .loop_end

			.swap:
				mov r15, [r10]
				mov r13, [r14]
				mov [r10], r13
				mov [r14], r15
				mov r10, r11
				jmp .loop
				

			.loop_end:
				mov r10, [r10 + s_item.next]
				jmp .loop

		.ret:
			ret
