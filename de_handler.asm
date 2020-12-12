.globl my_de_handler
.extern what_to_do, old_de_handler

.data

.text
.align 4, 0x90
my_de_handler:
  # prologue
  push %rbp
  movq %rsp, %rbp
  # backing up the users' register values
  push %rdi
  push %rsi
  push %rdx
  push %rcx
  push %r8
  push %r9
  # if we are here, that means a divide by zero exception has occured, we need to try and send the divided part to what_to_do
  # since the issue is with divison, the divided is in rax
  movq %rax, %rdi
  # need to check if the divided is 0
  cmp $0, %rdi
  je old_handler

  call what_to_do

  # restore user register values
  push %r9
  push %r8
  push %rcx
  push %rdx
  push %rsi
  push %rdi
  jmp return_from_what
old_handler:
    # the old rax is 0, which means we tried to perform 0/0, letting cpu handle normally
    leave
    jmp* old_de_handler

return_from_what:
    leave
    iretq