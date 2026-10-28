section .text
	global ft_list_remove_if
	extern free

	struc s_item
		.data:  resq 1
		.next:  resq 1
	endstruc
	
	ft_list_remove_if:
		cmp rdi, 0
		je .ret

		mov r12, rdx ; fonction de comparaison
		mov r13, rcx ; fonction de free
		mov r14, rdi ; pointeur vers l'adresse de debut de list

		mov r10, [rdi]
		test r10, r10
		je .ret


		mov rdi, [r10]

		push rsi
		push r10
		push r11
		call r12
		pop r11
		pop r10
		pop rsi

		cmp rax, 0
		je .remove_first
		jmp .loop

		.remove_first:
			mov r8, [r10 + s_item.next]
			mov [r14], r8

			mov rdi, [r10]
			push rsi
			push r10
			push r11
			call r13
			pop r11
			pop r10
			pop rsi

			mov rdi, r10
			push rsi
			push r10
			push r11
			call free
			pop r11
			pop r10
			pop rsi

			mov r10, [r14]
			cmp r10, 0
			je .ret


		.loop:
			cmp qword [r10 + s_item.next], 0
			je .ret

			mov r11, [r10 + s_item.next]

			mov rdi, [r11]

			push rsi
			push r10
			push r11
			call r12
			pop r11
			pop r10
			pop rsi


			cmp rax, 0
			je .remove
			jmp .loop_end

			.remove:
				mov r8, [r11 + s_item.next]
				mov [r10 + s_item.next], r8
				mov rdi, [r11]

				push rsi
				push r10
				push r11
				call r13
				pop r11
				pop r10
				pop rsi

				mov rdi, r11

				push rsi
				push r10
				push r11
				call free
				pop r11
				pop r10
				pop rsi

				jmp .loop

			.loop_end:
				mov r10, [r10 + s_item.next]
				jmp .loop

		.ret:
			ret
