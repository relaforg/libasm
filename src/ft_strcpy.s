section	.text
global	ft_strcpy

ft_strcpy:
	mov r10, -1
	.loop:
		inc r10
		mov al,  [rsi + r10]
		mov [rdi + r10], al
		cmp al, 0
		jne .loop
		mov rax, rdi
		ret
