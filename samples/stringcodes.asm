	# Solution to Lecture 08-1 Exercise 1
	#
	# CSCI 221 S20
	#
	# This program asks the user to enter a string.
	# It then reports the ASCII code of each letter
	# of the string.

        .data
prompt:		.asciiz "Enter a string: "
string_ptr:	.space 80     # reserve space for a null-terminated string of 79 or fewer characters
eoln_ptr:	.asciiz "\n"
report:		.asciiz "Below I give the codes of each character...\n"

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
	
erase_eoln:	
	la	$s0, string_ptr # The string includes the end-line
erase_loop:			# character at the end, so we loop
	lb	$t0, ($s0)	# to find it (character 10) and...
	beq	$t0,10,erase
	addiu	$s0,$s0,1
	b	erase_loop
erase:
	li	$t0,0		# ...we replace it with character 0. 
	sb	$t0,($s0)       #

list_suffixes:	
	la	$a0, report     # Output the start of the report
	li	$v0, 4		
	syscall
	
	la	$s0, string_ptr	# Point to the start of the string.
check_if_empty:
	lb	$t0, ($s0)      # See if it points to the null character (i.e. to
	beqz	$t0, end_main   # the end of the original string.
output_if_not:
	move    $a0, $t0        # If not, print it using system call #1.
	li	$v0, 1		
	syscall			
	la	$a0, eoln_ptr	
	li	$v0, 4		
	syscall
advance_ptr:
	addiu	$s0,$s0,1       # Now advance the pointer.
	b	check_if_empty  # And run the loop again.
	
end_main:
	li	$v0, 0		# return 0
	jr	$ra		#
