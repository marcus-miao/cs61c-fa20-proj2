.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    ble a2, x0, invalid_vector_len

    ble a3, x0, invalid_stride
    ble a4, x0, invalid_stride

    mv t0, a0 # store the start of v0 since a0 will be modified to store the dot product
    mv t1, x0 # t1 as the array index, init with 0
    mv a0, x0 # a0 used to store the dot product, init with 0
loop:
    bge t1, a2, done

    mul t2, t1, a3 # t2 stores the actual index to get the i-th element of array v0
    mul t3, t1, a4 # t3 stores the actual index to get the i-th element of array v0
    slli t2, t2, 2
    slli t3, t3, 2
    add t2, t0, t2
    add t3, a1, t3
    lw t2, 0(t2)
    lw t3, 0(t3)

    mul t2, t2, t3
    add a0, t2, a0
    
    addi t1, t1, 1
    j loop
invalid_vector_len:
    li a1, 75
    j exit2
invalid_stride: 
    li a1, 76
    j exit2
done:
    ret
