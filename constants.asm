
;; Open options
%define O_RDONLY	0
%define O_WRONLY	1
%define O_RDWR		2

%define O_CREAT		64
%define O_EXCL		128
%define O_TRUNC		512
%define O_APPEND	1024

%define O_DIRECTORY  65536
%define O_CLOEXEC    524288

;; Standard streams
%define STDIN		0
%define STDOUT		1


;; syscalls
%define SYS_READ	0
%define SYS_WRITE	1
%define SYS_OPEN	2
%define SYS_CLOSE	3
%define SYS_FORK	57
%define SYS_EXECVE	59
%define SYS_FINISH	60
%define SYS_WAIT4	61
%define SYS_CWD		79
%define SYS_CHDIR	80
%define SYS_FCHDIR	81
%define SYS_GETDENTS64	217

;; My arbirtrary buffer size
%define BUFSIZE		256
