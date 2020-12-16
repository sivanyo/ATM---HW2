.globl my_de_handler
.extern what_to_do, old_de_handler

.data

.text
.align 4, 0x90
my_de_handler:
  # prologue
  push %rbp
  movq %rsp, %rbp
  # backing up all the registers that have been in use at calc.c
  pushq %rdi
  pushq %rsi
  pushq %rbx
  pushq %rdx
  pushq %r8
  pushq %r9
  pushq %r10
  pushq %r11
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15
  # if we are here, that means a divide by zero exception has occured, we need to try and send the divided part to what_to_do
  # since the issue is with divison, the divided is in rax
  movq %rax, %rdi
  call what_to_do
  cmp $0, %rax
  # the result of what to do is 0, so we let the old handler handle
  je old_handler
  # now rax holds the val of what to do
  # set rcx to be 1, so the result of the division will be rax
  movq $1, %rcx
  # restore user register values
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %r11
  popq %r10
  popq %r9
  popq %r8
  popq %rdx
  popq %rbx
  popq %rsi
  popq %rdi
  cqo
  leave
  iretq


old_handler:
# the old rax is 0, which means we tried to perform 0/0, letting cpu handle normally
      popq %r15
      popq %r14
      popq %r13
      popq %r12
      popq %r11
      popq %r10
      popq %r9
      popq %r8
      popq %rdx
      popq %rbx
      popq %rsi
      popq %rdi
      jmp * old_de_handler

