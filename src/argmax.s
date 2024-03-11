.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    ble a1, x0, invalid_array_length_exception

    addi t0, x0, 1 # init t0 with 1 as loop index
    mv t1, a0      # store the start of the array
    lw t2, 0(t1)   # init largest value as the first element of the array
loop:
    bge t0, a1, done

    slli t3, t0, 2 # convert array index to byte offset
    add t3, t1, t3 # store address of current array element to t3
    lw t3, 0(t3)   # load current array element to t3

    ble t3, t2, loop_next_iter
    mv a0, t0 # stores the new index of the largest element
    mv t2, t3 # stores the new largest element
loop_next_iter:
    addi t0, t0, 1
    j loop
invalid_array_length_exception:
    li a0, 77
done:
    ret
