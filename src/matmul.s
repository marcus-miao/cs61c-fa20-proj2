.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:
    # arg checks
    ble a1, x0, m0_dimension_error
    ble a2, x0, m0_dimension_error    

    ble a4, x0, m1_dimension_error
    ble a5, x0, m1_dimension_error

    bne a1, a4, dimension_mismatch

    # store arguments to s-registers here to reduce memory operations 
    # before and after dot call in following loop
    addi sp, sp, -40
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw ra, 36(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    mv s5, a5
    mv s6, a6

    mv s7, x0 # s7 as row idx
    mv s8, x0 # s8 as col idx

outer_loop:
    bge s7, s1, outer_loop_end
inner_loop:
    bge s8, s5, inner_loop_end

    # --------------------------------------------------------------------------
    # dot call begin
    # --------------------------------------------------------------------------

    # start of row_i of m0 as a0
    mul t0, s7, s2 # t0 = start_of_row_i = row_idx * col_width
    slli t0, t0, 2 # t0 represents offset for row_i
    add t0, s0, t0 # t0 represents the start address of row_i
    mv a0, t0

    # start of col_i of m1 as a1
    slli t0, s8, 2 # t0 represents offset for start of col_i
    add t0, s3, t0 # t0 represents start address of col_i
    mv a1, t0

    # vector length as a2
    mv a2, s2

    # stride of row vector is 1
    li t0, 1
    mv a3, t0

    # stride of col vector is width of m2
    mv a4, s5
    jal dot

    # --------------------------------------------------------------------------
    # dot call end
    # --------------------------------------------------------------------------

    mul t0, s7, s5
    add t0, t0, s8
    slli t0, t0, 2
    add t0, s6, t0
    sw a0, 0(t0)

    addi s8, s8, 1
    j inner_loop
inner_loop_end:
    addi s7, s7, 1
    mv s8, x0
    j outer_loop
outer_loop_end:
    # epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw ra, 36(sp)
    addi sp, sp, 40

    ret

m0_dimension_error:
    li a1, 72
    j exit2
m1_dimension_error:
    li a1, 73
    j exit2
dimension_mismatch:
    li a1, 74
    j exit2