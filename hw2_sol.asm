.section .text
.global	calc_expr
calc_expr:
#.text
#.global main
#main:
    # calc_expr prologue
    # rdi stores address of string_convert
    # rsi stores address of result_as_string
    pushq %rbp
    movq %rsp, %rbp
	push %rdi
	push %rsi # rsp points to the value of rsi now

	call input_loop_func

    popq %rsi
    popq %rdi
    # now rax stores the numeric result, need to conver to string
    movq %rax, %rdi

    #movq %rax, %rdi
    call *%r15 # invoke result_as_string with rdi as input number

    movq %rax, %rdx # rax now stores the number of bytes to print (received from result_as_string)
    movq $what_to_print, %rsi # address of the global variable containing the result string
    #movb (%rsi), %r8b
    #movb 1(%rsi), %r9b
    #movb 2(%rsi), %r10b
    movq $1, %rax # using write syscall
    movq $1, %rdi # using stdout as output device
    #movq $msg, %rsi
    #movq (msg_len), %rdx
    syscall
    leave
    ret

# maximum size of a numeric size is 20 bytes (including the minus character)
# size of operand for calculation is 1 byte
# total stack for specific expression block is 41 -> 1+1


# input_loop_func(long long *(string_convert)), string convert func is saved in rdi register
input_loop_func:
    # input_loop_func prologue
    pushq %rbp
    movq %rsp, %rbp

    # the frame stack looks like this
    # left side (20 bytes) <- pointed by r8
    # operand (1 byte) <- pointed by r9
    # right side (20 bytes) <- pointed by r10
    # left not empty (1 byte) <- pointed by r11
    # left_pos <- r12
    # right_pos <- r13
    # is_left_number <- r14
    # is_right_number <- r15
    # is_left_empty <- rcx

    # assign space for left side
    subq $20, %rsp
    # r8 saves the start of the left side
    movq %rsp, %r8
    # saving the stack pos for left side
    movq %r8, %r12
    subq $1, %rsp
    # r9 saves the byte containing the operand
    movq %rsp, %r9
    movb $35, (%r9) # operand = '#'
    subq $20, %rsp
    # r10 saves the start of the right side
    movq %rsp, %r10
    # saving the stack pos for right side
    movq %r10, %r13
    subq $1, %rsp
    movq %rsp, %r11
    # r11 is 0 to note that the left side is still empty
    movb $0, (%r11)
    # this is the initialization of the recursion so left and right are not numbers yet
    movq $0, %r14
    movq $0, %r15
    movq $0, %rcx

begin_read_char:
    pushq %rdi
    movq $0, %rax # syscall type is read
    movq $0, %rdi # input is stdin
    movq $CHAR_FROM_INPUT, %rsi # output will be written to $CHAR_FROM_INPUT
    movq $1, %rdx # read only 1 character
    pushq %r11
    pushq %rcx
    syscall
    popq %rcx
    popq %r11
    popq %rdi

    # %rbx stores the character we recevied from STDIN
    movb (CHAR_FROM_INPUT), %bl

    # need to check if this is the line feed (newline marker), if it is, that means the input has reached it's end
    cmp $10, %rbx
    je restore_result_and_return

    cmp $40, %rbx
    jne check_is_closing_para
    # input is (
    # need to check whether we already have a left side or no (by checking if operand is set to # or not)
    cmp $35, (%r9)
    jne operator_is_defined
    # operand is not yet set, meaning this is the left part of an expression (for example: ( '1...'+111)
    # need to call another recursion to get the real left side number
    # backing up registers storing addresses for current frame
    pushq %r8
    pushq %r9
    pushq %r10
    pushq %r11
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    pushq %rcx
    pushq %rdi
    call input_loop_func
    # restoring registers for current frame
    popq %rdi
    popq %rcx
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %r11
    popq %r10
    popq %r9
    popq %r8
    # now rax stores the result of the left side
    # saving the result of the left side onto the stack
    movq %rax, (%r8)
    # left is now a number and not a string
    movq $1, %r14
    jmp begin_read_char
operator_is_defined:
    # operand id set, meaning this is the right part of an expression (for example: (1+'1...')
    # need to call another recursion to get the real right side number
    # backing up registers storing addresses for current frame
    pushq %r8
    pushq %r9
    pushq %r10
    pushq %r11
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    pushq %rcx
    pushq %rdi
    call input_loop_func
    # restoring registers for current frame
    popq %rdi
    popq %rcx
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %r11
    popq %r10
    popq %r9
    popq %r8
    # now rax stores the result of the left side
    # saving the result of the right side onto the stack
    movq %rax, (%r9)
    # right is now a number and not a string
    movq $1, %r15
    jmp begin_read_char
check_is_closing_para:
    #cmp $41, (%r9)
    cmp $41, %rbx
    jne check_is_operator
    # this is a closing bracket, meaning we reached the ending of an arithmetic expression
    pushq %r8
    pushq %r9
    pushq %r10
    pushq %r11
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    pushq %rcx
    # saving the address of string_convert func
    pushq %rdi
    # pointer to string_convert function in rdi
    # address of left side in rsi
    movq %r8, %rsi
    # is left side a number in rdx
    movq %r14, %rdx
    # address of right side in rcx
    movq %r10, %rcx
    # is right side a number in r8
    movq %r15, %r8
    # operator character in r9
    xor %r10, %r10
    movb (%r9), %r10b
    movq %r10, %r9
    call calculate_result
    # now rax stores the result of the entire calculation of this branch
    popq %rdi
    popq %rcx
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %r11
    popq %r10
    popq %r9
    popq %r8
    jmp rec_loop_end
check_is_operator:
    # need to check if left side is set, if not, then the character is part of left side and not operator (even if it is '-')
    cmp $0, %rcx
    # left side is not set, so we add to it now
    je set_left_no_operator
    # need to check if the current character is a airthmetic operator (+,-,/,*)
    # saving the address of string_convert func
    # chcking if operator is set
    xor %rax, %rax
    movb (%r9), %al
    cmp $35, %rax
    #cmp $35, (%r9)
    jne add_to_right_string
    # the operator not set
    # checking if the current character is an operator, if not, we will add the characters to the left side (because we have no operator, and the current is not an operator)
    pushq %rdi
    movq %rbx, %rdi
    call determine_operator
    popq %rdi
    # rax now stores 4 if the current character is not an operator
    cmp $4, %rax
    je set_left_no_operator
    # the current character is an operator
    movb %bl, (%r9)
    jmp begin_read_char
set_left_no_operator:
    # the left side is not set, so we are setting it now
    movb %bl, (%r12)
    inc %r12
    # setting null terminator, in case this is the end of the string
    movb $0, (%r12)
    # marking that the left side has values
    movb $1, (%r11)
    movq $1, %rcx
    jmp begin_read_char

add_to_right_string:
    # we already have an operator set, so we can only add to the right string
    # adding to the right side since we already have an operator set
    movb %bl, (%r13)
    inc %r13
    # setting null terminator, in case this is the end of the string
    movb $0, (%r13)
    jmp begin_read_char

restore_result_and_return:
    # getting value of calculation from (%r8) and placing in rax
    mov (%r8), %rax

rec_loop_end:
    leave
    ret


calculate_result:
    # will receive:
    # pointer to string_convert function in rdi
    # address of left side in rsi
    # is left side a number in rdx
    # address of right side in rcx
    # is right side a number in r8
    # operator character in r9
    # caclulcate_result prologue
    pushq %rbp
    movq %rsp, %rbp

    # need to check operator
    pushq %rdi
    pushq %rsi
    pushq %rdx
    pushq %rcx
    pushq %r8
    pushq %r9
    xor %rdi, %rdi
    movb %r9b, %dil
    call determine_operator
    popq %r9
    popq %r8
    popq %rcx
    popq %rdx
    popq %rsi
    popq %rdi
    # storing the result in r15
    movq %rax, %r15
    # need to check if left is a number and if not convert
    cmp $1, %rdx
    jne convert_left

    # need to check if right is a number and if not convert
check_need_convert_right:
    cmp $1, %r8
    jne convert_right
    jmp perform_calc
convert_left:
    pushq %rdi
    pushq %rsi
    pushq %rdx
    pushq %rcx
    pushq %r8
    pushq %r9
    movq %rdi, %r10
    movq %rsi, %rdi
    #movb (%rdi), %r8b
    #movb 1(%rdi), %r9b
    # invoke string_covert which his address is stored at r10, with parameter rsi, which is the address where left string starts
    call *%r10
    popq %r9
    popq %r8
    popq %rcx
    popq %rdx
    popq %rsi
    popq %rdi
    # saving left number as int in rsi
    movq %rax, %rsi
    jmp check_need_convert_right
convert_right:
    pushq %rdi
    pushq %rsi
    pushq %rdx
    pushq %rcx
    pushq %r8
    pushq %r9
    movq %rdi, %r10
    movq %rcx, %rdi
    # invoke string_covert which his address is stored at r10, with parameter rcx, which is the address where right string starts
    call *%r10
    popq %r9
    popq %r8
    popq %rcx
    popq %rdx
    popq %rsi
    popq %rdi
    # saving right number as int in rcx
    movq %rax, %rcx
    # need to perform calc based on op
perform_calc:
    cmp $0, %r15
    jne check_sub
    # the operator is +
    add %rsi, %rcx
    jmp store_result
check_sub:
    cmp $1, %r15
    jne check_mul
    # the operator is -
    sub %rsi, %rcx
    jmp store_result
check_mul:
    cmp $2, %r15
    jne check_div
    imul %rsi, %rcx
    jmp store_result
check_div:
    movq %rsi, %rax
    xor %rdx, %rdx
    idiv %rcx
store_result:
    movq %rcx, %rax

    # calculate_result epilogue
    leave
    ret

# int determine_operator(char op);
determine_operator:
    # rdi stores the character to check
    # prologue
    pushq %rbp
    movq %rsp, %rbp
    cmp $43, %rdi
    jne check_minus
    movq $0, %rax
    jmp det_op_end
check_minus:
    cmp $45, %rdi
    jne check_multi
    movq $1, %rax
    jmp det_op_end
check_multi:
    cmp $42, %rdi
    jne check_divide
    movq $2, %rax
    jmp det_op_end
check_divide:
    cmp $47, %rdi
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
PLUS: .byte 43
MINUS: .byte 45
MULTI: .byte 42
DIVIDE: .byte 47
OPEN_PAR: .byte 40
CLOSE_PAR: .byte 41
NULL_TERM: .byte 10
CHAR_FROM_INPUT: .byte 0
msg: .ascii "test"
msg_len: .quad msg_len - msg
string_convert_func: .quad
result_as_string_func: .quad
