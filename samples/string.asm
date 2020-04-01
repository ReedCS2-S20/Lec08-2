	# Sample Program Lecture 08-1
	#
	# CSCI 221 S20
	#
	# This program reads and then outputs a string.
	#
	# You can use this code to solve the two exercises
	# in their BONUS form.

        .data
string_ptr:	.space 80     # reserve space for a null-terminated string of 79 or fewer characters
eoln_ptr:	.asciiz "\n"

	.globl main
	.text

main:

get_a_string:
	la	$a0, string_ptr	# This uses system call #8 to
	li	$a1, 80		# read up to 79 characters of
	li 	$v0, 8		# a string.
	syscall
erase_eoln:	
	la	$a0, string_ptr # The string includes the end-line
erase_loop:			# character at the end, so we loop
	lb	$t0, ($a0)	# to find it (character 10) and...
	beq	$t0,10,erase
	addiu	$a0,$a0,1
	b	erase_loop
erase:
	li	$t0,0		# ...we replace it with character 0. 
	sb	$t0,($a0)       #
	
output_a_string:
	li	$v0, 4		# print(string_ptr)
	la	$a0, string_ptr	# 
	syscall			#
	li	$v0, 4		# print(eoln_ptr)
	la	$a0, eoln_ptr	# 
	syscall			#
	
end_main:
	li	$v0, 0		# return 0
	jr	$ra		#
