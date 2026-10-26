section .text
	global ft_atoi_base

	ft_atoi_base:
		.validate_base:
			mov r10, 0
			.loop:
				mov bl, [rsi + r10]

				cmp bl, 43
				je .error
				cmp bl, 45
				je .error

				mov r11, 0
				.diff_loop:
					mov cl, [rsi + r11]
					cmp bl, cl
					je .error
					
					inc r11
					cmp r11, r10
					jb .diff_loop

				inc r10
				cmp bl, 0
				jne .loop
			cmp r10, 1
			jle .error

		mov rax, 1000 ; TEST
		jmp .ret


		.error:
			mov rax, 0

		.ret:
			ret

		
