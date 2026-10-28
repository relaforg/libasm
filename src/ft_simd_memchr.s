section .text
	global ft_simd_memchr

	ft_simd_memchr:
		mov rax, 0
		cmp rdx, 0
		je .ret

		mov r10, 0

		mov rcx, rdi
		and rcx, 15
		and rdi, -16

		mov r8, 1
		shl r8, cl
		dec r8
		not r8

		movd xmm1, esi
		punpcklbw xmm1, xmm1
		punpcklwd xmm1, xmm1
		punpckldq xmm1, xmm1
		punpcklqdq xmm1, xmm1

		.loop:
			movdqa xmm0, [rdi + r10]
			pcmpeqb xmm0, xmm1
			pmovmskb r11d, xmm0

			and r11, r8
			xor r8, r8
			not r8

			bsf r11d, r11d
			jnz .result

			add r10, 16
			mov r9, r10
			sub r9, rcx
			cmp r9, rdx
			jb .loop
			jmp .ret

		.result:
			add r10, r11
			sub r10, rcx
			cmp r10, rdx
			jae .error
			add rdi, r10
			add rdi, rcx
			mov rax, rdi
			jmp .ret

		.error:
			mov rax, 0

		.ret:
			ret
