.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
	# Prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    li t0, 1
    blt a2, t0, element_error
    blt a3, t0, stride_error
    blt a4, t0, stride_error

loop_prepare:
    li t0, 0 # sum = 0
    li t1, 0 # i = 0
    li t2, 0 # j = 0
    li t3, 0 # used = 0
    
loop_start:
    bge t3, a2, loop_end
    slli t1, t1, 2 # byte addressing
    slli t2, t2, 2 # byte addressing
    add s0, t1, a0 # s0 = &arr0[i]
    add s1, t2, a1 # s1 = &arr1[j]
    srli t1, t1, 2 # retore t1
    srli t2, t2, 2 # retore t2
    lw t4, 0(s0) # t4 = arr0[i]
    lw t5, 0(s1) # t5 = arr1[j]
    mul t6, t4, t5 # t6 = arr0[i] * arr1[j]
    add t0, t6, t0 # sum += t6
    add t1, t1, a3
    add t2, t2, a4
    addi t3, t3, 1
    j loop_start

loop_end:
	# Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
    add a0, t0, x0
	ret

element_error:
    li a0, 36
    j exit
    
stride_error:
    li a0, 37
    j exit