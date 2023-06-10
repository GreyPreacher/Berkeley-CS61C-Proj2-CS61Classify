.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
# Prologue
    addi sp, sp, -32
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw ra, 28(sp)

    mv s0, a0 # copy the string in a0 to s0
    mv s1, a1 # copy the number in a1 to s1
    mv s2, a2 # copy the number in a2 to s2
    mv s3, a3 # copy the number in a3 to s3
    
    # open the file
    li a1, 1  # read for the fopen function, set a1 to 1 as write-only
    jal ra, fopen # open the file
    blt a0, x0, fopen_error # error detection
    
    mv s5, a0 # store the file descriptor to s5
    
    # write row
    sw s2, 0(sp) # store row into memory
    mv a0, s5
    mv a1, sp
    li s4, 1
    mv a2, s4 # element number
    li a3, 4  # element size
    jal ra, fwrite
    bne a0, s4, fwrite_error
    
    # write column
    sw s3, 0(sp) # store column into memory
    mv a0, s5
    mv a1, sp
    li s4, 1
    mv a2, s4 # element number
    li a3, 4  # element size
    jal ra, fwrite
    bne a0, s4, fwrite_error
    
    # write data
    mul s4, s2, s3 # get the total element number
    mv a0, s5
    mv a1, s1
    mv a2, s4
    li a3, 4
    jal ra, fwrite
    bne a0, s4, fwrite_error
    
    mv a0, s5
    jal ra, fclose
    bnez a0, fclose_error

	# Epilogue
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    
	ret

fopen_error:
    li a0, 27
    j exit
    
fclose_error:
    li a0, 28
    j exit
    
fwrite_error:
    li a0, 30
    j exit