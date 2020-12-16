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
  pushq %r8
  pushq %r9
  pushq %r10
  pushq %r11
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15
  pushq %rdi
  pushq %rdx
  # if we are here, that means a divide by zero exception has occured, we need to try and send the divided part to what_to_do
  # since the issue is with divison, the divided is in rax
  movq %rax, %rdi
  call what_to_do
  movq %rax, %rdx
  cmp $0, %rax
  # the result of what to do is 0, so we let the old handler handle
  je old_handler
  # now rax holds the val of what to do
  # set rcx to be 1, so the result of the division will be rax
  # restore user register values
  popq %rdx
  popq %rdi
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %r11
  popq %r10
  popq %r9
  popq %r8
  movq $1, %rcx
  cqo
  leave
  iretq


old_handler:
      popq %rdx
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
      jmp * old_de_handler

