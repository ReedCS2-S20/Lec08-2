	# sample MIPS32 assembly program
	#
	# CSCI 221 S20
	#
	# This scans through an integer array in the data
	# segment, computing its sum.
	#
	
        .data
array:  .word 123, 1000, 2001, 20, 1102, 321 
size:   .word 6
eoln:	.asciiz "\n"
	
    .globl main
    .text

main:
    la      $s0, array      # load the "base" address of the array
    li      $t0, 0          # use $t0 to track the integer index
    lw      $t1, size
    li      $t2, 0          # this will be the sum
	
loop:
    bge     $t0, $t1, end   # check if index isn't larger than the array size
	
    lw      $t3, ($s0)      # get the next item in the array
    addu    $t2, $t2, $t3   # add it to the sum
    addiu   $t0, $t0, 1
    addiu   $s0, $s0, 4
    b       loop

end:
    li      $v0, 1
    move    $a0, $t2
    syscall
    li      $v0, 4
    la      $a0, eoln
    syscall
	
    li      $v0, 0
    jr      $ra
	
