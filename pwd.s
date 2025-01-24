# written by me and moth @ warsaw hackerspace

.global _start

.section .bss
path:
    .space 4096

.section .text

_start:
    # getcwd
    mov $79, %rax
    mov $path, %rdi
    mov $4096, %rsi
    syscall

    # fixup \0 to \n
    xor %al, %al
    mov $-1, %ecx
    repne scasb
    dec %rdi
    movb $'\n', (%rdi)

    # write
    mov $1, %rax
    mov %rdi, %rdx
    sub $path - 1, %rdx
    mov $1, %rdi
    mov $path, %rsi
    syscall

    # exit
    mov $60, %rax
    xor %rdi, %rdi
    syscall
