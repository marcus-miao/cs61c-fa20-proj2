.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    ble a1, x0, invalid_array_length_exception

    add t0, x0, x0 # initialize t0 with zero as loop index
loop:
    bge t0, a1, done

    slli t1, t0, 2 # convert array index to byte offset
    add t2, a0, t1 # store address of current array element to t2
    lw t3, 0(t2)   # load current array element to t3

    bge t3, x0, loop_next_iter # if t3 >= 0, continue
    sw x0, 0(t2)               # else, change value to zero and store it
loop_next_iter:
    addi t0, t0, 1
    j loop
invalid_array_length_exception:
    li a0, 78
done:
	ret
