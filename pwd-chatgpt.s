# written by chatgpt when asked about a "principal/staff engineer version" of pwd.s from this repo

.global _start

.section .bss
path_buffer:
    .space 1024               # Buffer for the path (adjustable)

.section .rodata
err_getcwd: .asciz "Error: Failed to get current working directory\n"
err_write:  .asciz "Error: Failed to write to stdout\n"

.section .text

# Define constants directly in assembly
.equ EXIT_SYSCALL, 60
.equ WRITE_SYSCALL, 1
.equ GETCWD_SYSCALL, 79
.equ STDERR_FD, 2
.equ STDOUT_FD, 1

# Syscall: exit
# Inputs: %rdi = Exit code
syscall_exit:
    mov $EXIT_SYSCALL, %rax   # exit syscall
    syscall

# Syscall: write
# Inputs: %rdi = File descriptor, %rsi = Buffer pointer, %rdx = Length
syscall_write:
    mov $WRITE_SYSCALL, %rax  # write syscall
    syscall
    test %rax, %rax           # Check for failure
    js handle_error_write
    ret

# Helper: Write String
# Inputs: %rdi = File descriptor, %rsi = Buffer pointer
write_string:
    push %rdx                 # Preserve %rdx
    mov %rsi, %rcx            # Copy pointer to %rcx
strlen_loop:
    cmpb $0, (%rcx)           # Check for null terminator
    je strlen_done
    inc %rcx
    jmp strlen_loop
strlen_done:
    sub %rsi, %rcx            # Calculate length
    mov %rcx, %rdx            # Store length in %rdx
    call syscall_write        # Call write syscall
    pop %rdx                  # Restore %rdx
    ret

# Error Handler
# Inputs: %rsi = Error message pointer
handle_error:
    mov $STDERR_FD, %rdi      # File descriptor: stderr
    call write_string         # Write error message
    mov $1, %rdi              # Exit code 1
    jmp syscall_exit

handle_error_write:
    lea err_write(%rip), %rsi # Use predefined write error message
    jmp handle_error

# Helper: Append Newline
# Inputs: %rdi = Pointer to string, %rdx = String length
append_newline:
    add %rdx, %rdi            # Move to the end of the string
    movb $'\n', (%rdi)        # Append newline character
    inc %rdx                  # Increment length
    ret

# Entry Point
_start:
    # Syscall: getcwd
    mov $GETCWD_SYSCALL, %rax # getcwd syscall
    lea path_buffer(%rip), %rdi # Pointer to buffer
    mov $1024, %rsi           # Buffer size
    syscall
    test %rax, %rax           # Check for failure
    js getcwd_error           # Jump to error handler

    # Append newline to the path
    lea path_buffer(%rip), %rdi # Pointer to buffer
    mov %rax, %rdx            # Path length from %rax
    call append_newline       # Append newline

    # Syscall: write
    mov $STDOUT_FD, %rdi      # File descriptor: stdout
    lea path_buffer(%rip), %rsi # Buffer pointer
    call syscall_write        # Write to stdout

    # Exit successfully
    xor %rdi, %rdi            # Exit code 0
    jmp syscall_exit

getcwd_error:
    lea err_getcwd(%rip), %rsi # Use predefined getcwd error message
    jmp handle_error
