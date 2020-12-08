#.section .text
#.global	calc_expr
.text
.global main
main:
	# rdi stores the address in memory to string_convert (will be saved in r14)
	# rsi stores the address in memory to result_as_string (will be saved in r15)
	movq %rdi, %r14
	movq %rsi, %r15
	# STEPS:
	# take string as input from STDIN and use the number of characters taken as input, to figure out length (func)
	# call split on the input string, using the provided len, and specifying start as 0 (func)
	# extra functions:
	# convert_leaf - will receive start, end and expr, will create a new char array and send it to string_convert func, and eventually return the numeric result
	# convert_no_para - will recieve i, start and expr, will create a new char array and send it to string_convert func, and eventually return the numeric result
	# determine_operator - will receive an ASCII character as input and will return an int to determine which operator to use (func)
	# is_arithmetic_operator - will receive an ASCII character as input and will return 1 if it is, and 0 otherwise (func)

	# implementation order:
    # 1. determine_operator (V)
    # 2. convert_leaf (V?)
    # 3. convert_non_para (V?)
    # 4. read_from_input (V)
    # 5. split (and PRAY)

read_from_input:
    # r12 will store the base address where the input string is stored
    movq (%rsp), %r12
    # counter for string length
    xor %r13, %r13
read_another_char:
    movq $0, %rax
    movq $0, %rdi
    movq $CHAR_FROM_INPUT, %rsi
    movq $1, %rdx
    syscall
    
    movq (NULL_TERM), %rax
    movq (CHAR_FROM_INPUT), %rbx
    cmp %rax, %rbx
    ### if these are equal, that means we finished taking the string as input, need to add to the stack, but not increment counter
    je finish_string_input
    push $CHAR_FROM_INPUT
    inc %r13
    jmp read_another_char

finish_string_input:
    push $CHAR_FROM_INPUT
    # prepare for split
    movq %r12, %rdi # saving the address of char * expr in rdi
    movq $0, %rsi # saving start in rsi
    movq %r13, %rdx # saving the length of the string in rdx
#    call split

#    ret
  movq $60, %rax
  movq $0, %rdi
  syscall



convert_leaf:
    # rdi stores the address of the string
    # rsi stores the start index
    # rdx stores the end index
    # prologue
    push %rbp
    mov %rsp, %rbp
    # rbx stores int end
    movq %rdx, %rbx
    sub %rsi, %rbx # should do rbx - rsi and save in rbx
    add $2, %rbx # rbx should now store len = end - start + 2
    movq %rbx, %r9
    dec %r9 # r9 stores len - 1
    # r10 saves the number of characters pushed onto the stack
    xor %r10, %r10
load_expr_loop:
    # now r8 stores the value from (rdi+rsi*1) == expr[j]
    movq (%rdi, %rsi, 1), %r8
    push %r8
    inc %r10
    inc %rsi
    cmp %rsi, %r9
    jne load_expr_loop
    movq $0, %r8
    push %r8 # pushes null terminator to the end of the stack
    inc %r10
    movq %rbp, %rdi
    add $8, %rdi
    call *%r14
    # now rax stores return value, which should be a long long number we wanted to convert from string
    # increasing stack size to delete old values pushed to the stack
    leaq (%rsp, %r10, 8), %rsp
    leave
    ret
    # need to push onto the stack the number we want to convert and (probably) pass a register storing the address to the conversion function
    # need to push null terminator to the end of the stack so that the function can stop converting


convert_non_para:
    # rdi stores the address of the string
    # rsi stores the start index
    # rdx stores the end index (i)
    # prologue
    push %rbp
    mov %rsp, %rbp
    # rbx stores int end
    movq %rdx, %rbx # rbx <- i
    dec %rbx # rbx <- i-1
    movq %rbx, %r9
    dec %r9 # r9 <- i-2
    # r10 saves the number of characters pushed onto the stack
    xor %r10, %r10
load_expr_conv_loop:
    # now r8 stores the value from (rdi+rsi*1) == expr[j]
    movq (%rdi, %rsi, 1), %r8
    push %r8
    inc %r10
    inc %rsi
    cmp %rsi, %rbx
    jne load_expr_conv_loop
    movq $0, %r8
    push %r8 # pushes null terminator to the end of the stack
    inc %r10
    movq %rbp, %rdi
    add $8, %rdi
    call *%r14
    # now rax stores return value, which should be a long long number we wanted to convert from string
    # increasing stack size to delete old values pushed to the stack
    leaq (%rsp, %r10, 8), %rsp
    leave
    ret
    # need to push onto the stack the number we want to convert and (probably) pass a register storing the address to the conversion function
    # need to push null terminator to the end of the stack so that the function can stop converting


determine_operator:
    # rdi stores the character to check
    # prologue
    push %rbp
    mov %rsp, %rbp
    cmp $PLUS, %rdi
    jne check_minus
    movq $0, %rax
    jmp det_op_end
check_minus:
    cmp $MINUS, %rdi
    jne check_multi
    movq $1, %rax
    jmp det_op_end
check_multi:
    cmp $MULTI, %rdi
    jne check_divide
    movq $2, %rax
    jmp det_op_end
check_divide:
    cmp $DIVIDE, %rdi
    jne not_operator
    movq $3, %rax
    jmp det_op_end
not_operator:
    movq $4, %rax
det_op_end:
    # epilogue
    leave
    ret


.section .data
#PLUS: .ascii "+"
#MINUS: .ascii "-"
#MULTI: .ascii "*"
#DIVIDE: .ascii "/"
#OPEN_PAR: .ascii "("
#CLOSE_PAR: .ascii ")"
#NULL_TERM: .ascii "\0"
PLUS: .quad 43
MINUS: .quad 45
MULTI: .quad 42
DIVIDE: .quad 47
OPEN_PAR: .quad 40
CLOSE_PAR: .quad 41
# todo: change this to actual null terminator
NULL_TERM: .quad 10
CHAR_FROM_INPUT: .fill 1, 1, 0
