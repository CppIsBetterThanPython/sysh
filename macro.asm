

%macro STRTOI 1
	mov	rdi, %1
	call	strtoi
%endmacro

%macro ITOSTR 2
	mov	rdi, %1
	mov	rsi, %2
	call	itostr
%endmacro

%macro STRCMP 2
	mov	rsi, %1
	mov	rdi, %2
	call	strcmp
%endmacro

%macro INPUT 1
	mov	rdi, %1
	call	input
%endmacro

%macro STRLEN 1
	MOVN	rdi, %1
	call	strlen
%endmacro

%macro PRINT 1
	MOVN	rdi, %1

	call	strlen

	mov	rsi, rax
	call	print
%endmacro

%macro PRINTL 2
	mov	rdi, %1
	mov	rsi, %2
	call	print
%endmacro

%macro EXIT 0
	jmp	exit
%endmacro

%macro IFEQU 3
	%ifidn %2, 0
		test	%1, %1
		jz	%3
	%else
		cmp	%1, %2
		je	%3
	%endif
%endmacro

%macro CSTR 2
%1:
	db %2, 0
%endmacro

%macro MOVN 2
	%ifnidn	%1, %2
		mov	%1, %2
	%endif
%endmacro

%macro CALL 1-7
	%if %0 >= 2
		MOVN	rdi, %2
	%endif
	%if %0 >= 3
		MOVN	rsi, %3
	%endif
	%if %0 >= 4
		MOVN	rdx, %4
	%endif
	%if %0 >= 5
		MOVN	rcx, %5
	%endif
	%if %0 >= 6
		MOVN	r8, %6
	%endif
	%if %0 >= 7
		MOVN	r9, %7
	%endif

	call %1
%endmacro
