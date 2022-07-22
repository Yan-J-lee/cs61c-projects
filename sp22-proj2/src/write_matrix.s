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
	addi sp, sp, -36
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	sw s4, 20(sp)
	sw s5, 24(sp)
	sw s6, 28(sp)
	sw ra, 32(sp)
	# Epilogue

	mv s0, a1  # backup a1 (pointer to matrix)
	mv s1, a2  # backup a2 (num of rows)
	mv s2, a3  # backup a3 (num of columns)
	li a1, 1
	jal ra, fopen  # return a0 (file pointer)
	li t0, -1
	beq a0, t0, fopen_error

	sw a0, 0(sp)  # store the file pointer
	li a0, 8  # num of rows, num of cols
	jal ra, malloc
	beqz a0, malloc_error

	mv s3, a0  # s3 saves the address of the allocated memory
	sw s1, 0(s3)  # store the num of rows
	sw s2, 4(s3)  # store the num of cols
	lw a0, 0(sp)  # restore the file pointer
	mv a1, s3  # a1 = the address of the allocated memory
	li a2, 2
	mv s4, a2  # backup a2
	li a3, 4
	jal ra, fwrite  # write the number of rows to the file
	bne a0, s4, fwrite_error

	lw a0, 0(sp)  # restore the file pointer
	mv a1, s0  # a1 = pointer to the matrix
	mul a2, s1, s2  # a2 = num of rows * num of cols
	mv s5, a2  # backup a2
	li a3, 4
	jal ra, fwrite
	bne a0, s5, fwrite_error

	lw a0, 0(sp)  # restore the file pointer
	jal fclose
	bnez a0, fclose_error

	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw s4, 20(sp)
	lw s5, 24(sp)
	lw s6, 28(sp)
	lw ra, 32(sp)
	addi sp, sp, 36
	ret

fopen_error:
	li a0, 27
	j exit

malloc_error:
	li a0, 26
	j exit

fclose_error:
	li a0, 28
	j exit

fwrite_error:
	li a0, 30
	j exit