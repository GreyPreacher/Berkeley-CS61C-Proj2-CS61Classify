.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
	# Prologue
    addi sp, sp, -4
    sw s0, 0(sp)
    li t0, 1
    blt a1, t0, error

loop_prepare:
    lw t1, 0(a0) # max_num = a[0]
    li t2, 0 # assign the index of the max number to 0
    li t3, 1 # i = 1

loop_start:
    bge t3, a1, loop_end
    slli t4, t3, 2
    add s0, t4, a0 # s0 = &a[i]
    lw t5, 0(s0) # t5 = a[i]
    ble t5, t1, loop_continue # if a[i] <= max, continue loop, else assign max = a[i]
    mv t1, t5 # max = a[i]
    mv t2, t3 # max_index = i
    
loop_continue:
    addi t3, t3, 1
    j loop_start

loop_end:
	# Epilogue
    lw s0, 0(sp)
    addi sp, sp, 4
    mv a0, t2
	ret

error:
    li a0, 36
    j exit