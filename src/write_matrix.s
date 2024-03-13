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
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:
    # prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp) # s4 used for file descriptor
    sw s5, 24(sp) # s5 stores total number of elements in the array

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    # open file and get file descriptor
    mv a1, s0
    li a2, 1
    jal fopen
    li t0, -1
    beq a0, t0, fopen_error
    mv s4, a0

    # write number of rows and cols
    mv a1, s4
    # put a size-known array buffer which contains row number and col number
    # on stack
    addi sp, sp, -8
    sw s2, 0(sp)
    sw s3, 4(sp)
    mv a2, sp
    li a3, 2
    li a4, 4
    jal fwrite
    li t0, 2
    blt a0, t0, fwrite_error
    addi sp, sp, 8

    mul s5, s2, s3

    # write the matrix
    mv a1, s4
    mv a2, s1
    mv a3, s5
    li a4, 4
    jal fwrite
    blt a0, s5, fwrite_error

    # close file
    mv a1, s4
    jal fclose
    li t0, -1
    bne a0, x0, fclose_error

    # epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)

    addi sp, sp, 28

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

fopen_error:
    li a1, 93
    j exit2
fwrite_error:
    li a1, 94
    j exit2
fclose_error:
    li a1, 95
    j exit2
