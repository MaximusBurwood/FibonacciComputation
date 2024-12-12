section .data
    result db "Fibonacci: %d", 10, 0
    threshold dq 3600000000

section .bss
    fib_0 resq 4
    fib_4 resq 4

section .text
    global _start

_start:
    mov rax, 0
    mov [fib_0], rax
    mov rbx, 1
    mov [fib_0 + 8], rbx
    mov rcx, 1
    mov [fib_0 + 16], rcx
    mov rdx, 2
    mov [fib_0 + 24]

    rdtsc
    mov rsi, rax

compute_fib:
    vmovdqu ymm0, [fib_0]
    vmovdqu ymm1, [fib_0 + 8]

    vaddps ymm2, ymm0, ymm1
    vaddps ymm3, ymm0, ymm2
    vaddps ymm4, ymm2, ymm1
    vaddps ymm5, ymm3, ymm4

    vmovdqu [fib_0], ymm2
    vmovdqu [fib_0 + 8], ymm3
    vmovdqu [fib_0 + 16], ymm4
    vmovdqu [fib_0 + 24], ymm5

    add rcx, 4

    rdtsc
    sub rax, rsi

    cmp rax, [threshold]
    jl compute_fib

end_program:
    mov rdi, result
    mov rsi, [fib_0]
    xor rax, rax
    call printf

    mov rax, 60
    xor rdi, rdisyscall

extern printf