	# sample MIPS32 assembly program
	#
	# CSCI 221 S20
	#
	# This scans through an integer array in the data
	# segment, outputting each array item's value.
	#
	
        .data
array:  .word 1, 7, 1, 2, 1, 3, 7, 3
size: .word 8
eoln:	.asciiz "\n"
	
    .globl main
    .text

main:
    la      $s0, array      # load the "base" address of the array
    li      $t0, 0          # use $t0 to track the integer index
    lw      $t1, size

loop:
    bge     $t0, $t1, end   # check if index isn't larger than the array size
	
    lw      $a0, ($s0)      # get the next item in the array
    li      $v0, 1
    syscall
    li      $v0, 4          # print it	
    la      $a0, eoln	
    syscall			
    addiu   $t0, $t0, 1
    addiu   $s0, $s0, 4
    b       loop

end:	
    li      $v0, 0
    jr      $ra
	
