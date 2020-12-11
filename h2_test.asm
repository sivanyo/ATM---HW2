.section .text

.global	calc_expr
calc_expr:

    pushq %rbp # prolog
    movq %rsp, %rbp
    pushq %rbx

    movq %rdi, string_convert_func # need to be backup to somthing
    #movq %rdi, %r14 # need to be backup to somthing
    #movq %rsi, result_as_string_func
    movq %rsi, %r15

    sub $21, %rsp
    movq $0, %r13

    movq %r13, %r12
    addq %rsp, %r12
    movb $50, (%r12) # 50 == '2'
    inc %r13

    movq %r13, %r12
    addq %rsp, %r12
    movb $51, (%r12) # 51 == '3'
    inc %r13

    movq %r13, %r12
    addq %rsp, %r12
    movb $52, (%r12) # 52 == '4'
    inc %r13

    movq %r13, %r12
    addq %rsp, %r12
    movb $53, (%r12) # 53 == '5'
    inc %r13

    movq %r13, %r12
    addq %rsp, %r12
    movb $54, (%r12) # 54 == '6'
    inc %r13

    movq %r13, %r12
    addq %rsp, %r12
    movb $55, (%r12) # 55 == '7'
    inc %r13

    movq %r13, %r12
    addq %rsp, %r12
    movb $56, (%r12) # 56 == '8'
    inc %r13

    movq %r13, %r12
    addq %rsp, %r12
    movb $57, (%r12) # 57 == '9'
    inc %r13

    movq %r13, %r12
    addq %rsp, %r12
    movb $49, (%r12) # 49 == '1'
    inc %r13

    movq %r13, %r12
    addq %rsp, %r12
    movb $48, (%r12) # 48 == '0'
    inc %r13

    movq %r13, %r12
    addq %rsp, %r12
    movb $0, (%r12) # end of string-number

    movq %rsp, %rdi # address to start reading from


bpoint1:
    #call *%r14
    call *string_convert_func
bpoint2:
    movq %rax, %rdi
    call *%r15
bpoint3:
    movq %rax, %rdx # len of str
    movq $what_to_print, %rsi
    movq $1, %rax
    movq $1, %rdi
    syscall

    movq -8(%rbp), %rbx  # epilogue
    leave
    ret


.section .data
    #cur: .byte 0
    string_convert_func: .quad
    result_as_string_func: .quad
