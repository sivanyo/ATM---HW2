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
  push %rdi
  push %rsi
  push %rbx
  push %rdx
  push %r8
  push %r9
  push %r10
  push %r11
  push %r12
  push %r13
  push %r14
  push %r15
  # if we are here, that means a divide by zero exception has occured, we need to try and send the divided part to what_to_do
  # since the issue is with divison, the divided is in rax
  movq %rax, %rdi
  call what_to_do
  cmp $0, %rax
  # the result of what to do is 0, so we let the old handler handle
  je old_hanlder
  # now rax holds the val of what to do
  # set rcx to be 1, so the result of the division will be rax
  movq $1, %rcx
  # restore user register values
  pop %r15
  pop %r14
  pop %r13
  pop %r12
  pop %r11
  pop %r10
  pop %r9
  pop %r8
  pop %rdx
  pop %rbx
  pop %rsi
  pop %rdi
  jmp return_from_what
old_handler:
# the old rax is 0, which means we tried to perform 0/0, letting cpu handle normally
      pop %r15
      pop %r14
      pop %r13
      pop %r12
      pop %r11
      pop %r10
      pop %r9
      pop %r8
      pop %rdx
      pop %rbx
      pop %rsi
      pop %rdi
      jmp *old_de_handler

return_from_what:
    leave
    iretq
