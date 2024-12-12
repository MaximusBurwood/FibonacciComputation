section .data
    result db "Fibonacci: %d", 10, 0
    threshold dq 3600000000

section .bss
    fib_0 resq 4
    fib_4 resq 4

section .text
    global _start
