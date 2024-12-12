section .data
    result db "Fibonacci: %d", 10, 0         ; Format string for printing Fibonacci number
    threshold dq 3600000000                  ; 3.6 billion cycles = 1 second (3.6 GHz)

section .bss
    fib_0 resq 4                             ; Store four Fibonacci numbers (f0, f1, f2, f3)
    fib_4 resq 4                             ; Store the next four Fibonacci numbers

section .text
    global _start

_start:
    ; Initialize the first 4 Fibonacci numbers
    mov rax, 0                               ; f0 = 0
    mov [fib_0], rax
    mov rbx, 1                               ; f1 = 1
    mov [fib_0 + 8], rbx
    mov rcx, 1                               ; f2 = 1
    mov [fib_0 + 16], rcx
    mov rdx, 2                               ; f3 = 2
    mov [fib_0 + 24], rdx

    ; Start measuring time (before Fibonacci calculation loop)
    rdtsc                                      ; Get time-stamp counter (in EDX:EAX)
    mov rsi, rax                               ; Store initial timestamp in rsi

    ; Fibonacci computation loop (AVX2)
compute_fib:
    ; Load 4 Fibonacci numbers from memory into YMM registers (AVX2 registers)
    vmovdqu ymm0, [fib_0]                     ; Load 4 Fibonacci numbers (f0, f1, f2, f3)
    vmovdqu ymm1, [fib_0 + 8]                 ; Load next 4 Fibonacci numbers (f4, f5, f6, f7)
    
    ; Perform Fibonacci calculation: f2 = f0 + f1, f3 = f1 + f2, f4 = f2 + f3, f5 = f3 + f4
    vaddps ymm2, ymm0, ymm1                   ; f0+f1 -> ymm2, f1+f2 -> ymm3, f2+f3 -> ymm4, f3+f4 -> ymm5
    vaddps ymm3, ymm0, ymm2                   
    vaddps ymm4, ymm2, ymm1
    vaddps ymm5, ymm3, ymm4

    ; Store results back into memory
    vmovdqu [fib_0], ymm2                    ; Store new Fibonacci numbers in fib_0
    vmovdqu [fib_0 + 8], ymm3                ; Store new Fibonacci numbers in fib_0
    vmovdqu [fib_0 + 16], ymm4               ; Store new Fibonacci numbers in fib_0
    vmovdqu [fib_0 + 24], ymm5               ; Store new Fibonacci numbers in fib_0

    ; Increment Fibonacci index (used for future debug/output if needed)
    add rcx, 4                                ; Since we computed 4 numbers, increment by 4

    ; Check elapsed time
    rdtsc                                      ; Get time-stamp counter (in EDX:EAX)
    sub rax, rsi                               ; Subtract initial timestamp to get elapsed time

    ; Compare elapsed time with threshold (3.6 billion cycles for 1 second)
    cmp rax, [threshold]                       ; Compare with 3.6 billion (1 second in cycles)
    jl compute_fib                             ; If time hasn't passed, keep calculating Fibonacci

    ; End program when 1 second has passed
end_program:
    ; Output the last Fibonacci number (stored in [fib_0])
    mov rdi, result                           ; Load address of the result string
    mov rsi, [fib_0]                          ; Load the last Fibonacci number
    xor rax, rax                               ; Clear rax (used by printf)
    call printf                                ; Call printf to output the result

    ; Exit the program
    mov rax, 60                                ; syscall for exit
    xor rdi, rdi                               ; status code 0
    syscall

; Simple printf wrapper (requires linking with libc)
extern printf