.globl classify

.data
new_line: .string "\n"

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    li t0, 5
    bne a0, t0, invalid_usage

    # prologue
    addi sp, sp, -52
    sw s0, 0(sp) 
    sw s1, 4(sp)
    sw s2, 8(sp)

    sw s3, 12(sp) 
    sw s4, 16(sp) 
    sw s5, 20(sp) 

    sw s6, 24(sp) 
    sw s7, 28(sp) 
    sw s8, 32(sp) 

    sw s9, 36(sp) 
    sw s10, 40(sp) 
    sw s11, 44(sp) 

    sw ra, 48(sp)

    mv s1, a1
    mv s2, a2

	# =====================================
    # LOAD MATRICES
    # =====================================

    # when passing parameters to read_matrix call, stack is preferred than heap
    # here when creating pointers for rows and cols. this is because using malloc
    # to get heap memory is generally more expensive than stack memory.
    #
    # see:
    # https://stackoverflow.com/questions/2264969/why-is-memory-allocation-on-heap-much-slower-than-on-stack
    #
    # (doing malloc lab should help me realize this....)
    # (a lot of reference answers on the internet are using malloc...)

    # Load pretrained m0
    # s3 will store m0
    # s4 will store rows of m0
    # s5 will store cols of m0
    lw a0, 4(s1)
    addi sp, sp, -4
    mv a1, sp
    addi sp, sp, -4
    mv a2, sp
    jal read_matrix
    mv s3, a0
    lw s4, 4(sp)
    lw s5, 0(sp)
    addi sp, sp, 8

    # Load pretrained m1
    # s6 will store m1
    # s7 will store rows of m1
    # s8 will store cols of m1
    lw a0, 8(s1)
    addi sp, sp, -4
    mv a1, sp
    addi sp, sp, -4
    mv a2, sp
    jal read_matrix
    mv s6, a0
    lw s7, 4(sp)
    lw s8, 0(sp)
    addi sp, sp, 8

    # Load input matrix
    # s9 will store input
    # s10 will store rows of input 
    # s11 will store cols of input
    lw a0, 12(s1)
    addi sp, sp, -4
    mv a1, sp
    addi sp, sp, -4
    mv a2, sp
    jal read_matrix
    mv s9, a0
    lw s10, 4(sp)
    lw s11, 0(sp)
    addi sp, sp, 8


    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    mul t0, s4, s11
    slli t0, t0, 2
    mv a0, t0
    jal malloc
    beq a0, x0, malloc_error
    mv s0, a0

    # m0 * input
    mv a0, s3
    mv a1, s4
    mv a2, s5
    mv a3, s9
    mv a4, s10
    mv a5, s11
    mv a6, s0
    jal matmul
     
    # relu(m0 * input)
    mv a0, s0
    mul t0, s4, s11
    mv a1, t0
    jal relu

    mul t0, s7, s11
    slli t0, t0, 2
    mv a0, t0
    jal malloc
    beq a0, x0, malloc_error
    mv s5, a0 # s5 now stores the final matrix

    # m1 * relu(m0 * input)
    mv a0, s6
    mv a1, s7
    mv a2, s8
    mv a3, s0
    mv a4, s4
    mv a5, s11
    mv a6, s5
    jal matmul

    # now the intermediate matrix relu(m0 * input) is useless. free memory
    mv a0, s0
    jal free

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw a0, 16(s1)
    mv a1, s5
    mv a2, s7
    mv a3, s11
    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mul t0, s7, s11
    mv a0, s5
    mv a1, t0
    jal argmax
    bne s2, x0, done

print_classification:
    mv s0, a0
    mv a1, s0
    jal print_int

    # Print newline afterwards for clarity
    la a1, new_line
    jal print_str
    j done
done:
    mv a0, s0

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

    lw s9, 36(sp) 
    lw s10, 40(sp) 
    lw s11, 44(sp) 

    lw ra, 48(sp)
    
    addi sp, sp, 52
    ret

malloc_error:
    li a1, 88
    j exit2
invalid_usage:
    li a1, 89
    j exit2
