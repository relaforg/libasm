section .text
	global ft_simd_memchr

	ft_simd_memchr:
		mov rax, 0
		mov r10, 0

		movd xmm1, esi
		punpcklbw xmm1, xmm1
		punpcklwd xmm1, xmm1
		punpckldq xmm1, xmm1
		punpcklqdq xmm1, xmm1

		.loop:
			cmp r10, rdx
			jae .ret

			movdqu xmm0, [rdi + r10]
			pcmpeqb xmm0, xmm1
			pmovmskb r11d, xmm0
			bsf r11d, r11d
			jnz .result

			add r10, 16
			jmp .loop

		.result:
			add r10, r11
			cmp r10, rdx
			jge .error
			add rdi, r10
			mov rax, rdi
			jmp .ret

		.error:
			mov rax, 0

		.ret:
			ret
