	# sample MIPS32 assembly program
	#
	# CSCI 221 S20
	#
	# This takes an allocated array of link list nodes,
	# stored separately (with "next" fields set to the
	# nullptr). It inserts them into a linked list 
	# structure, by order of their "data" field. It then
	# traverses that structure and outputs their values
	# (in sorted order, as a result).
	#
	# Since both the "data" and "next" fields are 32 bits
	# in the MIPS32 architecture, they are both of type
	# .word. So the nodes are laid out in the .data segment
	# contiguously.
	#
	# Thus, a linked list node is just 4 bytes of an integer
	# data value, and then 4 bytes of a next pointer value.
	#
	
        .data
eoln:           .asciiz "\n"
num_nodes:      .word   5
nodes:          .word   35, 0x0000, 6, 0x0000, 17, 0x0000, 3, 0x0000, 20 0x0000

        .globl main
        .text

main:
        la      $s0, nodes		# first = the first node in the array
        addiu   $s3, $s0, 8		# others = first + sizeof(llist_node)
        lw      $t0, num_nodes		# 
        addiu   $t0, $t0, -1		# to_insert = num_nodes-1

insert_each:
        beqz    $t0, done_insert	# if to_insert == 0 go to done_insert

insert_in_order:	
        lw      $t3, ($s3)		# load node->data
        move    $s1, $s0		# curr  = first
        li      $s2, 0x0000		# prev  = null
find_place:
        beqz    $s1, insert		# if curr == nullptr goto insert
        lw      $t1, ($s1)		# load curr->data
        ble     $t3, $t1, insert	# if node->data < curr->data goto insert
        move    $s2, $s1		# prev = curr
        lw      $s1, 4($s1)		# curr = curr->next
        b       find_place
insert:
        addiu   $t0, $t0, -1		# to_insert -= 1	
        sw      $s1, 4($s3)		# node->next = curr
        beqz    $s2, insert_in_front	# if prev == nullptr goto insert_at_front
insert_middle:
        sw      $s3, 4($s2)		# prev->next = node
        b       bump_node
insert_in_front:
        move    $s0, $s3		# first = node
bump_node:
        addiu   $s3, $s3, 8		# node = next node in the node array
        b       insert_each
done_insert:

	
print:
        move    $s1, $s0		# curr = first
print_loop:	
        beqz    $s1, done_print		# if curr == nullptr go to done_traverse
print_data:	
        lw      $a0, ($s1)		#
        li      $v0, 1			# print(curr->data)
        syscall
        la      $a0, eoln		#
        li      $v0, 4			# print("\n")
        syscall
	
        lw	$s1, 4($s1)		# curr = curr->next
        b       print_loop
done_print:

end:	
        li      $v0, 0			# return 0
        jr      $ra			#
	
