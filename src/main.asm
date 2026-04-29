
%include "macro.asm"
%include "constants.asm"

extern strsearch, strconcat, strcopy, strtoi, itostr, strcmp, strlen, input, read, open, print, exit, getcwd, open_dir, fchdir, chdir, close


section .data
	CSTR	file, "text.txt"

	CSTR	c_cat, "cat"
	CSTR	c_ls, "ls"
	CSTR	c_echo, "echo"
	CSTR	c_pwd, "pwd"
	CSTR	c_cd, "cd"
	CSTR	c_exit, "exit"

	CSTR	caret, " $ "

	CSTR	nl, `\n`

	CSTR	null, ""

	CSTR	parentDir, ".."

section .bss
	curPath		resb BUFSIZE

	c_input		resb BUFSIZE

	command		resb BUFSIZE

	num		resb BUFSIZE

	saved_envp	resb 8

section .text

global _start

_start:
	;; argv
	mov	rbx, [rsp]
	;; argc
	mov	rsi, [rsp + 8]

	;; envp
	mov	rcx, rbx
	inc	rcx
	shl	rcx, 3
	add	rcx, rsp

	mov	[saved_envp], rcx

	CALL	getcwd, curPath, BUFSIZE

	loop:

	PRINT	curPath
	PRINT	caret

	INPUT	c_input

	CALL	c_parse, c_input

	jmp loop

;; rdi -> command
c_parse:
	
	mov	rsi, rdi
	CALL	space_strcopy, command, rsi

	cmp	byte [rsi], 0
	je	parse_not_space
	inc	rsi
	parse_not_space:

	push	rsi
	CALL	strcmp, command, c_pwd
	test	rax, rax
	jz	parse_ls

	CALL	pwd
	pop rsi
	ret

	parse_ls:
	CALL	strcmp, command, c_ls
	test	rax, rax
	jz	parse_cd

	pop	rsi
	CALL	ls, rsi
	ret

	parse_cd:
	CALL	strcmp, command, c_cd
	test	rax, rax
	jz	parse_cat

	pop	rsi
	CALL	cd, rsi
	ret

	parse_cat:
	CALL	strcmp, command, c_cat
	test	rax, rax
	jz	parse_exit

	pop	rsi
	CALL	cat, rsi
	ret

	parse_exit:
	CALL	strcmp, command, c_exit
	test	rax, rax
	jz	parse_exec

	pop	rsi
	EXIT

	parse_exec:

	CALL	fork

	test	rax, rax
	jnz	console

	CALL	execve, command

	console:

	CALL	wait4

	pop	rsi

	ret

cat:
	CALL	open, rsi
	sub	rsp, 1024

	mov r10, rax

    .loop:
		CALL	read, r10, rsp, 1024
		mov	r9, rax

		PRINT	rsp

		cmp	r9, 1024
		je	.loop

	PRINT	nl
	add	rsp, 1024

	CALL	close, rsi

	ret

space_strcopy:
	
	;; Get the length to the next space
	push	rsi
	push	rdi
	CALL	strsearch, rsi, ' '
	pop	rdi
	pop	rsi

	mov	rcx, rax
	
	cld
	rep	movsb
	
	mov	byte [rdi], 0	; null terminate

	ret

;; rdi -> path
cd:
	;; TODO: Check if path exists

	CALL	chdir, rdi
	CALL	getcwd, curPath, BUFSIZE

	ret

pwd:
	PRINT	curPath
	PRINT	nl

	ret

;; rdi -> path
ls:
	STRLEN	rdi
	test	rax, rax
	jz	ls_default

	CALL	open_dir, rdi
	push	rax

	CALL	getdents64, rax

	pop	rax
	CALL	close, rax

	ret

	ls_default:

	CALL	open_dir, curPath
	CALL	getdents64, rax
	CALL	close, curPath

	ret

;; rdi -> directory descriptor
getdents64:
	sub	rsp, 8192

	read_loop:
		mov	rax, SYS_GETDENTS64
		;; rdi -> fd
		mov	rsi, rsp
		mov	rdx, 8192
		syscall

		test	rax, rax
		jz	getdents64_done
		js	getdents64_err

		xor	rcx, rcx

	parse:
		cmp	rcx, rax
		jge	read_loop

		lea	rbx, [rsp + rcx]

		movzx	rdx, word [rbx + 16]
		lea	rsi, [rbx + 19]

		push	rax
		push	rcx
		push	rdx
		push	rdi

		PRINT	rsi
		PRINT	nl

		pop	rdi
		pop	rdx
		pop	rcx
		pop	rax

		add	rcx, rdx

		jmp parse

getdents64_err:
getdents64_done:

	add	rsp, 8192
	
	ret

;; rdi -> path
execve:
	mov	rax, SYS_EXECVE
	;; rdi
	xor	rsi, rsi	;; TODO: Actually pass argv
	mov	rdx, [saved_envp]
	syscall

	ret

wait4:
	mov	rax, SYS_WAIT4
	mov	rdi, -1
	xor	rsi, rsi
	xor	rdx, rdx
	xor	r10, r10
	syscall

	ret

fork:
	mov	rax, SYS_FORK
	syscall
	ret
