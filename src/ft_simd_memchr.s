section .text
	global ft_simd_memchr

	ft_simd_memchr:
		mov rax, 0
		cmp rdx, 0 ; n == 0 : ne rien lire, s peut etre invalide
		je .ret

		mov r10, 0

		mov rcx, rdi ; rcx = off (s % 16)
		and rcx, 15
		and rdi, -16 ; rdi = bloc aligne contenant s

		mov r8, 1 ; r8 = masque du premier bloc
		shl r8, cl
		dec r8
		not r8

		movd xmm1, esi
		punpcklbw xmm1, xmm1
		punpcklwd xmm1, xmm1
		punpckldq xmm1, xmm1
		punpcklqdq xmm1, xmm1

		; do ... while : le premier bloc contient forcement s[0] puisque n > 0
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
			mov r9, r10 ; position du bloc suivant depuis s
			sub r9, rcx ; r10 >= 16 > off : pas de passage sous zero
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
