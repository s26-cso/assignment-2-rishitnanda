    .text
    .globl main

# a0 = argc, a1 = argv
main:
    addi sp, sp, -80
    sd ra, 72(sp)
    sd s0, 64(sp)
    sd s1, 56(sp)
    sd s2, 48(sp)
    sd s3, 40(sp)
    sd s4, 32(sp)
    sd s5, 24(sp)
    sd s6, 16(sp)
    sd s7, 8(sp)
    
    mv s0, a0 # argc
    mv s1, a1 # argv
    addi s2, s0, -1 # n = argc - 1
    
    # if n<=0, exit
    blez s2, main_exit
    
    # malloc space for result array (n * 4 bytes)
    slli a0, s2, 2
    call malloc
    mv s5, a0 # s5 = res
    
    # malloc space for stack array (n * 4 bytes)
    slli a0, s2, 2
    call malloc
    mv s4, a0 # s4 = stack
    
    # malloc space for input elements (n * 4 bytes)
    slli a0, s2, 2
    call malloc
    mv s3, a0 # s3 = arr
    
    # initialize result array with -1
    li t0, -1
    li t1, 0
init_res_loop:
    bge t1, s2, load_args
    slli t2, t1, 2
    add t3, s5, t2
    sw t0, 0(t3)      # res[i] = -1
    addi t1, t1, 1
    j init_res_loop

load_args:
    # parse argv strings to integers
    li s6, 0          # i = 0
load_args_loop:
    bge s6, s2, solve
    # argv[i+1] -> call atoi
    addi t0, s6, 1
    slli t0, t0, 3    # pointers are 8 bytes
    add t1, s1, t0
    ld a0, 0(t1)      # a0 = argv[i+1]
    
    call atoi
    
    # arr[i] = atoi(argv[i+1])
    slli t2, s6, 2
    add t3, s3, t2
    sw a0, 0(t3)
    
    addi s6, s6, 1
    j load_args_loop
    
solve:
    li s7, 0          # stack_top = 0
    
    addi s6, s2, -1   # i = n - 1
nge_loop:
    bltz s6, print_res
    
    # while(!stack.empty() && arr[stack.top()] <= arr[i])
pop_loop:
    beqz s7, pop_done
    
    # top = stack[stack_top - 1]
    addi t0, s7, -1
    slli t0, t0, 2
    add t1, s4, t0
    lw t2, 0(t1)      # t2 = top index
    
    # Get arr[top]
    slli t3, t2, 2
    add t4, s3, t3
    lw t5, 0(t4)      # t5 = arr[top]
    
    # Get arr[i]
    slli t3, s6, 2
    add t4, s3, t3
    lw t6, 0(t4)      # t6 = arr[i]
    
    # if arr[top] > arr[i], stop popping
    bgt t5, t6, pop_done 
    
    # stack.pop()
    addi s7, s7, -1   
    j pop_loop
    
pop_done:
    # if (!stack.empty())  res[i] = stack.top()
    beqz s7, do_push
    
    addi t0, s7, -1
    slli t0, t0, 2
    add t1, s4, t0
    lw t2, 0(t1)      # t2 = top index
    
    slli t3, s6, 2
    add t4, s5, t3
    sw t2, 0(t4)      # res[i] = top index
    
do_push:
    # stack.push(i)
    slli t0, s7, 2
    add t1, s4, t0
    sw s6, 0(t1)      # stack[stack_top] = i
    addi s7, s7, 1    # stack_top++
    
    addi s6, s6, -1   # i--
    j nge_loop

print_res:
    # print the resulting indices
    li s6, 0          # i = 0
print_loop:
    bge s6, s2, print_done
    
    slli t0, s6, 2
    add t1, s5, t0
    lw a1, 0(t1)      # a1 = res[i]
    
    addi t2, s6, 1
    bge t2, s2, print_last
    
    la a0, fmt_space
    call printf
    j print_next
    
print_last:
    # don't print trailing space for the last element
    la a0, fmt_nospace
    call printf
    
print_next:
    addi s6, s6, 1
    j print_loop

print_done:
    # finish with a newline
    la a0, fmt_newline
    call printf

main_exit:
    li a0, 0
    ld s7, 8(sp)
    ld s6, 16(sp)
    ld s5, 24(sp)
    ld s4, 32(sp)
    ld s3, 40(sp)
    ld s2, 48(sp)
    ld s1, 56(sp)
    ld s0, 64(sp)
    ld ra, 72(sp)
    addi sp, sp, 80
    ret

    .section .rodata
fmt_space:
    .string "%d "
fmt_nospace:
    .string "%d"
fmt_newline:
    .string "\n"