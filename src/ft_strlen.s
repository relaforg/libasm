section .text
	global  ft_strlen

	ft_strlen:
		mov r10, -1
		.loop:
			inc r10
			mov al, [rdi + r10]
			cmp al, 0
			jne .loop
		mov rax, r10
		ret
