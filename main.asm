.intel_syntax noprefix      # Enable Intel syntax
.section .data              # Data section

msg:    .asciz "Hello, World!\n"  # Null-terminated string

.section .text              # Code section
.global _start              # Entry point for the linker

_start:
    mov rax, 1              # syscall: write (1 = sys_write)
    mov rdi, 1              # file descriptor: stdout
    lea rsi, [msg]          # Load the address of the string
    mov rdx, 14             # Length of the string
    syscall                 # Make the syscall

    mov rax, 60             # syscall: exit (60 = sys_exit)
    xor rdi, rdi            # Exit code 0
    syscall                 # Make the syscall
