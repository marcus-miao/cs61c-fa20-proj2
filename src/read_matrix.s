.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:
    # prologue
    addi sp, sp, -36

    # store arguments
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)

    sw s3, 12(sp) # store read buffer
    sw s4, 16(sp) # store file descriptor
    sw s5, 20(sp) # store loop index
    sw s6, 24(sp) # store total elements of the matrix
    sw s7, 28(sp) # store pointer to the matrix in memory

    sw ra, 32(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2

    # allocates 4 bytes buffer for per integer reading. the buffer address will
    # be in s3
    li a0, 4
    jal malloc
    beq a0, x0, malloc_error
    mv s3, a0

    # call fopen and get file descriptor. the file descriptor will be in s4
    mv a1, s0
    li a2, 0
    jal fopen
    li t0, -1
    beq a0, t0, fopen_error
    mv s4, a0

    # s6 will store total number of elements in the matrix
    li s6, 1

    # read number of rows
    mv a1, s4
    mv a2, s3
    li a3, 4
    jal fread
    li t0, 4
    bne a0, t0, fread_error
    lw t0, 0(s3)
    sw t0, 0(s1)
    mul s6, s6, t0

    # read number of cols
    mv a1, s4
    mv a2, s3
    li a3, 4
    jal fread
    li t0, 4
    bne a0, t0, fread_error
    lw t0, 0(s3)
    sw t0, 0(s2)
    mul s6, s6, t0

    # allocate memory for the matrix
    slli t0, s6, 2
    mv a0, t0
    jal malloc
    beq a0, x0, malloc_error
    mv s7, a0

    mv s5, x0 # init loop index
loop:
    bge s5, s6, done
    mv a1, s4
    mv a2, s3
    li a3, 4
    jal fread
    li t0, 4
    bne a0, t0, fread_error
    lw t0, 0(s3)

    slli t1, s5, 2
    add t1, s7, t1
    sw t0, 0(t1)

    addi s5, s5, 1
    j loop
done:
    # close file
    mv a1, s4
    jal fclose
    li t0, -1
    beq a0, t0, fclose_error

    # set return value
    mv a0, s7

    # epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw ra, 32(sp)
    addi sp, sp, 36

    ret

# ------------------------------------------------------------------------------
# Exception Handlers
# 
# note that there are no matching epilogues or memory frees when jumped to the
# following labels. this is written as such because the whole virtual address 
# space will be destroyed by the OS when the program exits. So restoring 
# registers and reclaiming memory seems not necessary.
# 
# see some discussions here: 
# https://www.linuxquestions.org/questions/programming-9/to-free-or-not-to-free-before-an-exit-458107/
# ------------------------------------------------------------------------------

malloc_error:
    li a1, 88
    j exit2
fopen_error:
    li a1, 90
    j exit2
fread_error:
    li a1, 91
    j exit2
fclose_error:
    li a1, 92
    j exit2