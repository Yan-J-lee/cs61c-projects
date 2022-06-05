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

loop_start:
	lw t1, 0(a0)  # max = a[0]
    li t2, 0  # max_idx = 0
    li t3, 1  # i = 1

loop:
	bge t3, a1, loop_end
    slli t4, t3, 2
    add s0, a0, t4  # s0 = &a[i]
    lw t5, 0(s0)
    bge t1, t5, loop_continue
    mv t1, t5
    mv t2, t3

loop_continue:
	addi t3, t3, 1
    j loop

loop_end:
	# Epilogue
    mv a0, t2
    lw s0, 0(sp)
	addi sp, sp, 4
	ret

error:
	li a0, 36
    j exit