.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
#
# Registers:
#       s1, argument pointer (a1)
#
#       s2, m0 matrix address
#       s11, m0 rows address
#       s10, m0 columns address
#
#       s3, m1 matrix address
#       s9, m1 rows address
#       s8, m1 columns address
#
#       s4, input matrix address
#       s7, input rows address
#       s6, input columns address
classify:
    # Prologue
    addi    sp, sp, -64
    sw      s0, 12(sp)
    sw      s1, 16(sp)
    sw      s2, 20(sp)
    sw      s3, 24(sp)
    sw      s4, 28(sp)
    sw      s5, 32(sp)
    sw      s6, 36(sp)
    sw      s7, 40(sp)
    sw      s8, 44(sp)
    sw      s9, 48(sp)
    sw      s10, 52(sp)
    sw      s11, 56(sp)
    sw      ra, 60(sp)
    
    # Argument check
    li s0, 5
    bne a0, s0, argument_error
    
    mv s1, a1 # store the argument pointer
    mv s0, a2 # store is_print_out
    
	# Read pretrained m0, located address (a1 + 4)
    li a0, 4
    jal ra, malloc # malloc m0 row number
    beqz a0, malloc_error
    mv s11, a0 # s11 stores m0's row pointer address
    li a0, 4
    jal ra, malloc # malloc m0 column number
    beqz a0, malloc_error
    mv s10, a0 # s10 stores m0's column pointer address
    lw a0, 4(s1) # a0 = a1[1]
    mv a1, s11 # row address
    mv a2, s10 # column address
    jal ra, read_matrix
    mv s2, a0 # s2 store m0's data pointer address

	# Read pretrained m1, located address (a1 + 8)
    li a0, 4
    jal ra, malloc # malloc m1 row number
    beqz a0, malloc_error
    mv s9, a0 # s9 stores m1's row pointer address
    li a0, 4
    jal ra, malloc # malloc m1 column number
    beqz a0, malloc_error
    mv s8, a0 # s8 stores m1's column pointer address
    lw a0, 8(s1) # a0 = a1[2]
    mv a1, s9 # row address
    mv a2, s8 # column address
    jal ra, read_matrix
    mv s3, a0 # s3 store m1's data pointer address

	# Read input matrix
    li a0, 4
    jal ra, malloc # malloc imput matrix row number
    beqz a0, malloc_error
    mv s7, a0 # s7 stores input matrix's row pointer address
    li a0, 4
    jal ra, malloc # malloc imput matrix column number
    beqz a0, malloc_error
    mv s6, a0 # s6 stores input matrix's column pointer address
    lw a0, 12(s1) # a0 = a1[3]
    mv a1, s7 # row address
    mv a2, s6 # column address
    jal ra, read_matrix
    mv s4, a0 # s4 store the input matrix's data pointer address

	# Compute h = matmul(m0, input)
    lw t0, 0(s11) # m0 row
    lw t3, 0(s6)  # imput matrix column
    # malloc
    mul t4, t0, t3 # the size of h
    sw t4, 8(sp)
    slli a0, t4, 2 # offset by 4-byte
    jal ra, malloc # malloc h
    beqz a0, malloc_error
    sw a0, 0(sp)
    
    # matmul
    lw a6, 0(sp) # store result in h
    mv a0, s2 # get m0's pointer address to a0
    lw a1, 0(s11)
    lw a2, 0(s10)
    mv a3, s4 # get input matrix's pointer address [s4] to a3
    lw a4, 0(s7)
    lw a5, 0(s6)
    jal ra, matmul

	# Compute h = relu(h)
    lw a0, 0(sp) # h
    lw a1, 8(sp) # h size
    jal ra, relu

	# Compute o = matmul(m1, h)
    lw t0, 0(s9) # m1 row
    lw t3, 0(s6)  # h column
    # malloc
    mul t4, t0, t3 # the size of o = (s9,s8)x(s11,s6) = (s9,s6)
    sw t4, 8(sp)   # store the size of o to sp + 8
    slli a0, t4, 2 # offset by 4-byte
    jal ra, malloc # malloc 'o'
    beqz a0, malloc_error
    sw a0, 4(sp) # 'o'
    
    # matmul
    lw a6, 4(sp)
    mv a0, s3 # get m1's pointer address to a0
    lw a1, 0(s9)
    lw a2, 0(s8)
    lw a3, 0(sp)
    lw a4, 0(s11)
    lw a5, 0(s6)
    jal ra, matmul

	# Write output matrix o
    lw a0, 16(s1) # a1[4]
    lw a1, 4(sp)
    lw a2, 0(s9)
    lw a3, 0(s6)
    jal ra, write_matrix

	# Compute and return argmax(o)
    lw a0, 4(sp)
    lw a1, 8(sp)
    jal ra, argmax
    sw a0, 8(sp) # save return value of argmax

	# If enabled, print argmax(o) and newline
    bne s0, x0, done
    lw a0, 8(sp)
    jal ra, print_int
    li a0, '\n'
    jal ra, print_char

done:
    # free pointer 'h'
    lw      a0, 0(sp)
    jal     ra, free
    
    # free pointer 'o'
    lw      a0, 4(sp)
    jal     ra, free

    # free matrix m0
    mv      a0, s2
    jal     ra, free
    
    # free matrix m1
    mv      a0, s3
    jal     ra, free
    
    # free matrix input
    mv      a0, s4
    jal     ra, free

    mv      a0, s11
    jal     ra, free
    
    mv      a0, s10
    jal     ra, free

    mv      a0, s9
    jal     ra, free

    mv      a0, s8
    jal     ra, free

    mv      a0, s7
    jal     ra, free

    mv      a0, s6
    jal     ra, free
    
    #Epilogue
    lw      a0, 8(sp)
    lw      s0, 12(sp)
    lw      s1, 16(sp)
    lw      s2, 20(sp)
    lw      s3, 24(sp)
    lw      s4, 28(sp)
    lw      s5, 32(sp)
    lw      s6, 36(sp)
    lw      s7, 40(sp)
    lw      s8, 44(sp)
    lw      s9, 48(sp)
    lw      s10, 52(sp)
    lw      s11, 56(sp)
    lw      ra, 60(sp)
    addi    sp, sp, 64
    
	ret

malloc_error:
    li a0, 26
    j exit
    
argument_error:
    li a0, 31
    j exit