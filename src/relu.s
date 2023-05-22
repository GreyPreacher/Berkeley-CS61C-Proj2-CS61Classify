.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
	# Prologue
    addi sp, sp -4
    sw s0, 0(sp)
    li t0, 1
    blt a1, t0, error
    
prepare:
    li t1, 0 # i = 0

loop_start:
    bge t1, a1, loop_end
    slli t2, t1, 2
    add s0, a0, t2 # s0 = &a[i]
    lw t3, 0(s0)
    bge t3, x0, loop_continue
    sw x0, 0(s0)

loop_continue:
    addi t1, t1, 1 # i += 1
    jal x0, loop_start

loop_end:
    lw s0, 0(sp)
    addi sp, sp, 4
	# Epilogue
	ret
    
error:
    li a0, 36
    j exit