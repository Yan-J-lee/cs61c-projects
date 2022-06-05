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
    li t0, 1
    blt a2, t0, error1
    blt a3, t0, error2
	blt a4, t0, error2

loop_start:
	li t0, 0  # sum = 0
    li t1, 0  # i = 0
    li t2, 0  # j = 0
	li t3, 0  # k = 0
    
loop:
	bge t1, a2, loop_end
	slli t2, t2, 2  # byte addressing
	add t4, a0, t2
	lw t4, 0(t4)  # a0[j]
	srli t2, t2, 2  # restore t2
	slli t3, t3, 2  # byte addressing
	add t5, a1, t3
	lw t5, 0(t5)  # a1[k]
	srli t3, t3, 2  # restore t3
    mul t6, t4, t5
	add t0, t0, t6
    add t2, t2, a3
    add t3, t3, a4
    addi t1, t1, 1
    j loop
    
loop_end:
	# Epilogue
	mv a0, t0
	ret

error1:
	li a0, 36
    j exit

error2:
	li a0, 37
    j exit