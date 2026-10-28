section .text
	global ft_list_size

	struc s_item
		.data:  resq 1
		.next:  resq 1
	endstruc

	ft_list_size:
		mov rax, 0

		mov r10, rdi
		.loop:
			cmp r10, 0
			je .ret

			inc rax

			mov r10, [r10 + s_item.next]
			jmp .loop

		.ret:
			ret
