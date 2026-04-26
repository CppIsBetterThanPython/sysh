
%include "macro.asm"
%include "constants.asm"

global strsearch, strconcat, strcopy, strtoi, itostr, strcmp, strlen, input, read, open, print, exit, getcwd, open_dir, fchdir, chdir, close

section .text

;; rdi -> string, sil -> character
strsearch:
	push	rdi
	push	rsi
	STRLEN	rdi
	pop	rsi
	pop	rdi

	mov	rcx, rax
	inc	rcx
	movzx	rax, sil
	mov	rsi, rdi

	cld
	repne	scasb

	sub	rdi, 1
	sub	rdi, rsi

	mov	rax, rdi
	mov	rdi, rsi

	ret

;; Concatinates rsi into rdi, rdi must be a buffer of size BUFSIZE
strconcat:
	xor	rax, rax
	xor	rcx, rcx
	xor	rdx, rdx

	mov	r8, rdi
	mov	r9, rsi

	STRLEN	rdi
	mov	r10, rax
	mov	rsi, r9

	STRLEN	rsi
	mov	r11, rax
	mov	rdi, r8

	mov	rdx, r11
	add	rdx, r10
	cmp	rdx, BUFSIZE
	ja	strconcat_ret		; Make sure the strings will not surpass the standard buffer size
	
	add	rdi, r10		; Pointer to the end of the string

	mov	rcx, r11
	cld
	rep	movsb

	mov	byte [rdi], 0	; Null terminate

	strconcat_ret:

	ret

;; Copies rsi into rdi, rdi must be large enough to contain rsi
strcopy:

	mov	r8, rdi
	STRLEN	rsi
	mov	rdi, r8
	
	add	rax, 1
	mov	rcx, rax

	cld
	rep	movsb

	ret


;; Takes a pointer to a null terminated string and attempts to convert to int
;; Not safe at all
strtoi:
	xor rax, rax
	xor rbx, rbx

	strtoi_loop:
		
		mov	bl, [rdi]
		test	bl, bl
		jz	strtoi_end
		imul	rax, rax, 10
		add	rax, rbx
		sub	rax, '0'
		inc	rdi
		jmp	strtoi_loop

	strtoi_end:
	
	ret

;; itostr(num, inputBuffer)
;; Only works for unsigned ints
itostr:
	mov	rax, rdi
	
	sub	rsp, 16

	mov	rdi, rsp

	itostr_loop:
		xor	rdx, rdx
		mov	rbx, 10
		div	rbx
		add	dl, '0'
		mov	byte [rdi], dl
		inc	rdi
		test	rax, rax
		jnz	itostr_loop

	; Rewrite buffer in correct order

	mov	rax, rdi
	sub	rax, rsp		; Calculate str size

	reverse_loop:
		
		dec	rax
		mov	cl, [rsp + rax]
		mov	byte [rsi], cl
		inc rsi
		test rax, rax
		jnz reverse_loop

	add	rsp, 16

	ret

;; Takes 2 addresses of strings and compares byte by byte until null terminator
strcmp:

	strcmp_loop:

	mov	al, [rsi]
	cmp	al, [rdi]
	jne	strcmp_notequal
	cmp	al, 0
	je	strcmp_equal
	inc	rsi
	inc	rdi
	jmp	strcmp_loop

	strcmp_equal:
		mov	rax, 1
		ret

	strcmp_notequal:
		mov	rax, 0
		ret

strcmp2:
	
	mov	rcx, [rdi + 255] ; Gets string length
	repe	cmpsb

	test	rcx, rcx
	jz	strcmp2_equal

	mov	rax, 0
	ret

	strcmp2_equal:
		mov	rax, 1
		ret

strlen:
	
	mov	rsi, rdi
	xor	rax, rax

	mov	rcx, -1
	cld
	repne	scasb

	sub	rdi, 1
	sub	rdi, rsi
	
	mov	rax, rdi
	mov	rdi, rsi

	ret

;; rdi -> path
chdir:
	mov	rax, SYS_CHDIR
	;; rdi
	syscall

	ret

;; rdi -> fd
close:
	mov	rax, SYS_CLOSE
	;; rdi
	syscall

	ret

;; rdi -> file descriptor
fchdir:
	mov	rax, SYS_FCHDIR
	;; rdi
	syscall

	ret

;; rdi -> path
open_dir:
	mov	rax, SYS_OPEN
	;; rdi
	mov	rsi, O_RDONLY
	or	rsi, O_DIRECTORY
	syscall
	ret


;; rdi -> buffer, rsi -> size
getcwd:
	mov	rax, SYS_CWD
	;; rdi
	;; rsi
	syscall

	ret

input:
	mov	rax, SYS_READ
	mov	rsi, rdi	; Input buffer
	mov	rdi, STDIN
	mov	rdx, 256
	syscall
	
	test rax, rax
	jz input_empty

	mov	byte [rsi + rax - 1], 0

	ret

	input_empty:
		mov	byte [rsi], 0

	ret

;; print(buffer, len)
print:
	mov	rax, SYS_WRITE	; Perform write
	mov	rdx, rsi	; Length
	mov	rsi, rdi	; Buffer
	mov	rdi, STDOUT	; Write to STDOUT
	syscall
	ret

open:
	mov	rax, SYS_OPEN
	;; rdi passed already
	mov	rsi, 0
	syscall
	ret

;; rdi -> fd, rsi -> buffer, rdx -> bufferLength
read:
	mov	rax, SYS_READ
	;; rdi passed already
	;; rsi passed already
	;; rdx passed already
	syscall

	test rax, rax
	jz read_empty

	mov	byte [rsi + rax - 1], 0

	ret

	read_empty:
		mov	byte [rsi], 0
		ret

exit:
	mov	rax, SYS_FINISH
	mov	rdi, 0
	syscall
