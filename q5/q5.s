    .text
    .globl main

main:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp) # fd
    sd s1, 24(sp) # size (n)
    sd s2, 16(sp) # lo
    sd s3, 8(sp)  # hi
    # bytes 0 and 1 of stack are used as a buffer for read calls
    
    # open("input.txt", 0)
    la a0, filename
    li a1, 0      # O_RDONLY
    li a2, 0      # mode
    call open
    
    # Check if open failed
    bltz a0, print_no
    mv s0, a0     # store fd in s0
    
    # get file size: lseek(fd, 0, SEEK_END)
    mv a0, s0
    li a1, 0      # offset
    li a2, 2      # SEEK_END
    call lseek
    mv s1, a0     # store size in s1
    
    # If size is 0 or 1, it's a trivially valid palindrome
    li t0, 1
    ble s1, t0, print_yes
    
    # lo = 0, hi = size - 1
    li s2, 0
    addi s3, s1, -1
    
check_loop:
    # If pointers crossed or met, all chars matched so it is a palindrome
    bge s2, s3, print_yes 
    
    # lseek to lo
    mv a0, s0
    mv a1, s2     # offset = lo
    li a2, 0      # SEEK_SET
    call lseek
    
    # read char at lo into 0(sp)
    mv a0, s0
    mv a1, sp     # buf at sp
    li a2, 1      # read 1 byte
    call read
    
    # lseek to hi
    mv a0, s0
    mv a1, s3     # offset = hi
    li a2, 0      # SEEK_SET
    call lseek
    
    # read char at hi into 1(sp)
    mv a0, s0
    addi a1, sp, 1 # buf at sp+1
    li a2, 1      # read 1 byte
    call read
    
    # compare the two characters
    lb t0, 0(sp)
    lb t1, 1(sp)
    bne t0, t1, print_no_close
    
    # move pointers inward
    addi s2, s2, 1 # lo++
    addi s3, s3, -1 # hi--
    j check_loop

print_yes:
    # close file and print Yes
    mv a0, s0
    call close
    la a0, yes_str
    call puts
    j main_exit
    
print_no_close:
    # mismatch found: close file before printing No
    mv a0, s0
    call close
print_no:
    la a0, no_str
    call puts
    
main_exit:
    li a0, 0
    # epilogue
    ld s3, 8(sp)
    ld s2, 16(sp)
    ld s1, 24(sp)
    ld s0, 32(sp)
    ld ra, 40(sp)
    addi sp, sp, 48
    ret
    
    .section .rodata
filename:
    .string "input.txt"
yes_str:
    .string "Yes"
no_str:
    .string "No"
