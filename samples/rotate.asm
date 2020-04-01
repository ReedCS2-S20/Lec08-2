	# Solution to Lecture 08-1 Exercise 2
	#
	# CSCI 221 S20
	#
	# This program asks the user to enter a string.
	# It then reports each rotation of the string.
	#

        .data
prompt:		.asciiz "Enter a string: "
string_ptr:	.space 80     # reserve space for a null-terminated string of 79 or fewer characters
eoln_ptr:	.asciiz "\n"
report:		.asciiz "Below I list all its rotations...\n"

	.globl main
	.text

main:

get_a_string:
	la	$a0, prompt	# Request a string.
	li	$v0, 4		
	syscall
	la	$a0, string_ptr	# This uses system call #8 to
	li	$a1, 80		# read up to 79 characters of
	li 	$v0, 8		# a string.
	syscall
	
erase_eoln_and_compute_the_length:	
	li	$t1, 0		# length = 0
	#
	la	$a0, string_ptr # The string includes the end-line
erase_loop:			# character at the end, so we loop
	lb	$t0, ($a0)	# to find it (character 10) and...
	beq	$t0,10,erase
	addiu	$a0,$a0,1
	addiu	$t1,$t1,1	# length++
	b	erase_loop
erase:
	li	$t0,0		# ...we replace it with character 0. 
	sb	$t0,($a0)       #

	#
	# The lines below print out each rotation of the string entered,
	# one per line. It has a nested loop structure. The outer loop
	# counts up to the length of the string, printing one rotation
	# of the string for each count. After outputting one rotation
	# an inner loop runs that shifts each character, excepting the
	# first, one spot to the left. It then places the first character
	# to the far right.
	#
	
list_the_rotations:	
	la	$a0, report     # Output the start of the rotations report.
	li	$v0, 4		
	syscall

	#
	# Output each rotation of the string. This is the start of the "outer" loop
	#
	li	$t2, 0		# count = 0
	la	$t0, string_ptr	# Get the pointer to the start of the string.
check_if_done:
	bge	$t2, $t1, end   # if count >= length goto end
output_if_not:
	move    $a0, $t0        # If not done, print the string using system call #4.
	li	$v0, 4		
	syscall			
	la	$a0, eoln_ptr	
	li	$v0, 4		
	syscall

	#
	# Now rotate the string (this is the start of the "inner" loop.
	#
rotate_it:
	lb	$t3,($t0)	# Save the first character.

	move	$t4,$t0		# Set a pointer to the first character
	addiu	$t5,$t1,-1	# rotate_count = length-1

rotate_loop:	
	beqz	$t5,done_rotate	# if rotate_count = 0 goto done_rotate

	lb      $t6,1($t4)	# shift a character one spot left 
	sb      $t6,0($t4)	#
	
	addiu	$t4,$t4,1	# move pointer left
	addiu	$t5,$t5,-1	# rotate_count--
	b	rotate_loop

done_rotate:
	sb	$t3,($t4)	# place the first character in back
	addiu	$t2,$t2,1	# count++
	b	check_if_done	
	
end:
	li	$v0, 0		# return 0
	jr	$ra		#
