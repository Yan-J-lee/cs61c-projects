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

outer_loop_start:
	li t1, 0  # t = 0
    mv t2, a3  # int *p = a3
	li t3, 0  # i = 0

outer_loop:
	bge t3, a1, outer_loop_end
    
inner_loop_start:
	li t4, 0  # j = 0

inner_loop:
	bge t4, a5, inner_loop_end
    addi sp, sp, -52
    sw ra, 0(sp)
   	sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw t3, 16(sp)
    sw t4, 20(sp)
    sw a0, 24(sp)
    sw a1, 28(sp)
    sw a2, 32(sp)
    sw a3, 36(sp)
    sw a4, 40(sp)
    sw a5, 44(sp)
    sw a6, 48(sp)
    
	mv a1, t2
	li a3, 1
	mv a4, a5
	jal ra, dot  # call dot with arguments: a0, p, a2, 1, a5; return sum
    lw t1, 8(sp)  # restore t1
    lw t2, 12(sp)  # restore t2
    lw a6, 48(sp)  # restore a6
	slli t1, t1, 2  # byte addressing
	add t5, a6, t1  # t5 = &a6[t]
	sw a0, 0(t5)  # a6[t] = dot(a0, p, a2, 1, a5)
    srli t1, t1, 2  # restore t1
    
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t3, 16(sp)
    lw t4, 20(sp)
    lw a0, 24(sp)
    lw a1, 28(sp)
    lw a2, 32(sp)
    lw a3, 36(sp)
    lw a4, 40(sp)
    lw a5, 44(sp)
    addi sp, sp, 52
    
    addi t1, t1, 1  # ++t
    addi t2, t2, 4  # ++p
    addi t4, t4, 1  # j++
    j inner_loop
    
inner_loop_end:
	slli a2, a2, 2  # byte addressing
	add a0, a0, a2
    srli a2, a2, 2  # restore a2
    mv t2, a3
	addi, t3, t3, 1  # i++
	j outer_loop

outer_loop_end:
# Epilogue
	ret

error:
	li a0, 38
    j exit