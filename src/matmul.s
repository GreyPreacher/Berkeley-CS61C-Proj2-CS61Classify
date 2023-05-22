.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

	# Error checks
    li t0, 1
	blt a1, t0, error
    blt a4, t0, error
    blt a2, t0, error
    blt a5, t0, error
    bne a2, a4, error

	# Prologue


outer_loop_start:
    li t1, 0 # t = 0
    mv t2, a3 # int *p = a3 
    li t3, 0 # i = 0
    
outer_loop:
    bge t3, a1, outer_loop_end

inner_loop_start:
    li t4, 0 # j = 0

inner_loop:
    bge t4, a5, inner_loop_end
    addi sp, sp, -60
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    sw t0, 28(sp)
    sw t1, 32(sp)
    sw t2, 36(sp)
    sw t3, 40(sp)
    sw t4, 44(sp)
    sw t5, 48(sp)
    sw t6, 52(sp)
    sw ra, 56(sp)

    mv a1, t2
    li a3, 1
    mv a4, a5
    jal ra, dot # call dot function as with arguments a0, t2(p/a1), a2, 1, a4(a5/columns of m1), 
    
    lw t1, 32(sp) # restore t
    lw a6, 24(sp) # restore d 
    slli t1, t1, 2 # byte addressing
    add t5, a6, t1 # t5 = &m1[t]
    sw a0, 0(t5) # m1[t] = a0 = dot (a0, p, a2, 1, a5)
    srli t1, t1, 2 # restore t
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw t0, 28(sp)
    lw t2, 36(sp)
    lw t3, 40(sp)
    lw t4, 44(sp)
    lw t5, 48(sp)
    lw t6, 52(sp)
    lw ra, 56(sp)
    addi sp, sp 60
    
    addi t1, t1, 1 # t = t + 1
    addi t4, t4, 1 # j = j + 1
    addi t2, t2, 4 # p = p + 4
    j inner_loop

inner_loop_end:
    slli a2, a2, 2 # get the offset of m0
    add a0, a0, a2
    srli a2, a2, 2
    mv t2, a3 # reset *p = a3
    addi t3, t3, 1 # i = i + 1
    j outer_loop

outer_loop_end:
	# Epilogue
	ret

error:
    li a0, 38
    j exit