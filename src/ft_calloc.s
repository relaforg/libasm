section .text
	global ft_calloc
	extern malloc
	extern __errno_location

	ft_calloc:
		mov rax, rdi
		mul rsi
		mov rdi, rax
		mov rax, 0
		jo error
		push rdi

		call malloc
		pop rdi
		cmp rax, 0
		je .ret


		mov r10, 0
		.loop:
			cmp r10, rdi
			jae .ret
			mov byte [rax + r10], 0
			inc r10
			jmp .loop

		.ret:
			ret

	error:
		mov rdi, 12
		call __errno_location
		mov [rax], rdi
		mov rax, 0
		ret
