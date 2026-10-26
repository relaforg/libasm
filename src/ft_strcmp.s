section .text
global ft_strcmp

ft_strcmp:
	mov r10, -1
	.loop:
		inc r10
		movzx eax, byte [rdi + r10]
		movzx ecx, byte [rsi + r10]
		cmp al, 0
		je .ret
		cmp cl, 0
		je .ret

		cmp al, cl
		je .loop

	.ret:
		sub rax, rcx
		ret
