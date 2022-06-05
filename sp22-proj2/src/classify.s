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
classify:
	# Prologue
	addi sp, sp, -72
	sw a0, 8(sp)
	sw a1, 12(sp)
	sw a2, 16(sp)
	sw s0, 20(sp)
	sw s1, 24(sp)
	sw s2, 28(sp)
	sw s3, 32(sp)
	sw s4, 36(sp)
	sw s5, 40(sp)
	sw s6, 44(sp)
	sw s7, 48(sp)
	sw s8, 52(sp)
	sw s9, 56(sp)
	sw s10, 60(sp)
	sw s11, 64(sp)
	sw ra, 68(sp)
	# Epilogue

	li t0, 5
	bne a0, t0, classify_error

	# Read pretrained m0
	li a0, 4
	jal ra, malloc  # return the pointer to the num of rows of m0
	beqz a0, malloc_error
	mv s0, a0  # s0 saves the copy of a0
	li a0, 4
	jal ra, malloc  # return the pointer to the num of cols of m0
	beqz a0, malloc_error
	mv s1, a0  # s1 saves the copy of a0
	lw a1, 12(sp)  # restore char ** a1
	lw a0, 4(a1)  # a0 = char * a1[1]
	mv a1, s0
	mv a2, s1
	jal ra, read_matrix  # return the pointer to m0
	mv s2, a0  # s2 = int * m0

	# Read pretrained m1
	li a0, 4
	jal ra, malloc
	beqz a0, malloc_error
	mv s3, a0
	li a0, 4
	jal ra, malloc
	beqz a0, malloc_error
	mv s4, a0
	lw a1, 12(sp)  # restore char ** a1
	lw a0, 8(a1)  # a0 = char * a1[2]
	mv a1, s3
	mv a2, s4
	jal ra, read_matrix
	mv s5, a0  # s5 = int * m1

	# Read input matrix
	li a0, 4
	jal ra, malloc
	beqz a0, malloc_error
	mv s6, a0
	li a0, 4
	jal ra, malloc
	beqz a0, malloc_error
	mv s7, a0
	lw a1, 12(sp)  # restore char ** a1
	lw a0, 12(a1)  # a0 = char * a1[3]
	mv a1, s6
	mv a2, s7
	jal ra, read_matrix
	mv s8, a0  # s8 = int * input

	# malloc space for matrix h
	lw t1, 0(s0)  # t1 = the # of rows of m0
	lw t2, 0(s7)  # t2 = the # of cols of input
	mul t3, t1, t2
	sw t3, 0(sp)  # store the # of elements in h
	slli t3, t3, 2
	mv a0, t3
	jal ra, malloc
	beqz a0, malloc_error
	mv s9, a0  # s9 saves the memory address of h

	# Compute h = matmul(m0, input)
	mv a0, s2  # m0
	lw a1, 0(s0)
	lw a2, 0(s1)
	mv a3, s8  # input
	lw a4, 0(s6)
	lw a5, 0(s7)
	mv a6, s9  # h
	jal ra, matmul

	# Compute h = relu(h)
	mv a0, s9
	lw a1, 0(sp)
	jal ra, relu

	# malloc space for matrix o
	lw t4, 0(s3)  # t4 = the # of rows of m1
	lw t5, 0(s7)  # t5 = the # of cols of h
	mul t6, t4, t5
	sw t6, 4(sp)  # store the # of elements in o
	slli t6, t6, 2
	mv a0, t6
	jal ra, malloc
	beqz a0, malloc_error
	mv s10, a0  # s10 saves the memory address of o

	# Compute o = matmul(m1, h)
	mv a0, s5
	lw a1, 0(s3)
	lw a2, 0(s4)
	mv a3, s9
	lw a4, 0(s0)
	lw a5, 0(s7)
	mv a6, s10
	jal ra, matmul

	# Write output matrix o
	lw a1, 12(sp)
	lw a0, 16(sp)  # a0 = char * a1[4]
	mv a1, s10
	lw a2, 0(s3)
	lw a3, 0(s7)
	jal ra, write_matrix

	# Compute and return argmax(o)
	mv a0, s10
	lw a1, 4(sp)
	jal ra, argmax
	mv s11, a0  # s11 saves the 1st index of the largest element in o

	# If enabled, print argmax(o) and newline
	lw a2, 16(sp)  # if this is 0, print out the classification and new line
	beqz a2, print
	j done

	ret

print:
	mv a0, s11
	jal print_int

	li a0, '\n'
	jal print_char

done:
	mv a0, s0
	jal free

	mv a0, s1
	jal free

	mv a0, s2
	jal free

	mv a0, s3
	jal free

	mv a0, s4
	jal free

	mv a0, s5
	jal free

	mv a0, s6
	jal free

	mv a0, s7
	jal free

	mv a0, s8
	jal free

	mv a0, s9
	jal free

	mv a0, s10
	jal free

	lw a0, 8(sp)
	lw a1, 12(sp)
	lw a2, 16(sp)
	lw s0, 20(sp)
	lw s1, 24(sp)
	lw s2, 28(sp)
	lw s3, 32(sp)
	lw s4, 36(sp)
	lw s5, 40(sp)
	lw s6, 44(sp)
	lw s7, 48(sp)
	lw s8, 52(sp)
	lw s9, 56(sp)
	lw s10, 60(sp)
	lw s11, 64(sp)
	lw ra, 68(sp)
	addi sp, sp, 72

classify_error:
	li a0, 31
	j exit

malloc_error:
	li a0, 26
	j exit
