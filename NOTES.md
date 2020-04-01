## CSCI 221, Spring 2020
# Lecture 08-2: memory access in MIPS

---

## Overview

In this lecture we continue looking at using the load and store
instructions to read and write to memory in MIPS. We start by
examining my solutions to the exercises from the last lecture.
Then we look at code samples that read and modify an array
laid out in memory. Finally we end with code that builds
and then traverses a linked list.

A Homework 08 assignment is then assigned.

---

## Outline

    0. Questions? Office hours and Thursday "lab" hours.
    I. More load/store instruction examples
     A. `LW`/`SW` and `LB`/`SB` instructions; `.data` directives
     B. input of an array, summing an array
     C. output of the character codes of a string
     D. solution to Lecture 08-1 Exercise 1
    II. Using offsets in load/store instructions
     A. LW/SW and LB/SB instructions using an offset
     B. solution to Lecture 08-1 Exercise 2
     C. offset use in accessing stack frame data
     D. layout of structs in memory
   III. MIPS linked lists
     B. making linked list nodes in MIPS .data
     C. making a linked list
     D. traversing a linked list
   IV. Homework 08 overview

---

## Logistics update

1. I will try a "hands up" protocol today, and stop every 12-15 minutes for questions

2. Before I begin, any questions?

3. I will be assigning Homework 08 today. Look over it and give it a
try tonight/tomorrow...

4. The TAs and I will be holding lab office hours Thursday, from
1:30-4:30pm. I will email you links to Zoom meetings for each of
the four 45-minute sessions. You can join a meeting if you have 
a question for us, and we'll work to answer it. We'll set up that
meeting with a "waiting room" in Zoom, so you'll get your turn to
speak with us.

5. I'm also about to send a poll to find times for my own office hours.
Respond to that pool and then I'll email you a schedule of Zoom meetings.

6. I'm also setting up a Slack group for this course. I'll set up Slack
channels for asking questions, and for course discussion.

---

## Reading and writing to memory in MIPS

Let's look more at the load/store instructions in MIPS.

Recall the following:

* You can set up areas in your program image to hold data.

    01    .data
    02 string_ptr:	.asciiz "Here is a null-terminated string."
    03 int_ptr:    .word 101, 42, 18
    04 area_ptr:   .space 20

• The first line tells SPIM that the subsequent lines will be data directives.  
• The second line tells SPIM to reserve 34 bytes to hold that string's characters.  
• The third line tells SPIM to reserve 12 bytes to hold the data of those three
particular integers.  
• The fourth line tells SPIM to reserve 20 bytes (with unspecified initial values).  

* You can use the *load address* instruction `LA` to put the address of any
labelled data item into a register. For example:

    la $a0, int_ptr

puts the address of the word containing 101 into register `a0`.

* You can use the *load* and *store* instructions to access and modify the 
data stored at an address in memory. For example, the code

    la $a0, int_ptr
    la $a1, area_ptr
    lw $t0, ($a0)
    addiu $t0, $t0, 50
    sw $t0, ($a1)

fetches 101 from memory, adds 50 to it within register `t0`, and then
stores that result of 151 into the first four bytes of the space
reserved as `area_ptr`. The `LW` and `SW` instructions fetch/store
4 byte quantities (a MIPS32 word, wither and integer or an address,
typically). The `LB` and `SB` instructions transfer an individual 
byte to/from memory into/from a register.

### Treating memory as an array

With that in mind, here is code that reads five integers from the console
and then puts them into the space designated with `area_ptr`:

        la $s0, area_ptr
        li $t1, 5         # Count out 5 inputs.
    input_loop:
        beqz $t1, input_done

        li $v0, 5         #
        syscall           # Get an integer input.
    
        sw $v0,($s0)      # Store it in the array.
	addiu $s0,$s0,4   # Advance the pointer by 4 bytes.    
        addiu $t1,$t1,-1  # Decrement the count.
        b input_loop
    
    input_done:

The key lines are 

        sw $v0,($s0)      # Store it in the array.
	addiu $s0,$s0,4   # Advance the pointer by 4 bytes.    

The first of these takes the integer entered during handling of the
system call and stores it out to the address referenced by register
`s0`. And then the next line moves the pointer past those four bytes
in memory to the next spot reserved for another integer. (NOTE: I've
decided for today's lecture to use the registers `t0` through `t9`
for integer values, and registers `s0` through `s7` for address/pointer
values. This is not a standard convention, I just thought it would help
your reading of my code.) 

The important take-away here is how we advanced the pointer. We moved 
it by 4 locations, and that is because we are treating the memory
referenced with `area_ptr` as an array of 4-byte integer values.

Now that we've got this data sitting in memory, now we can just compute
with it. For example, this code snippet sums the integer data now stored
at  `area_ptr`:

        la $s0, area_ptr
        li $t1, 5         # Count out 5 inputs.
        li $t2, 0         # sum = 0
    sum_loop:
        beqz $t1, sum_done

        lw $t3,($s0)      # Fetch an integer from the array.
        addu $t2,$t2,$t3  # Add it to the sum.
    
	addiu $s0,$s0,4   # Advance the pointer by 4 bytes.    
        addiu $t1,$t1,-1  # Decrement the count.
        b sum_loop
    
    sum_done:

The key lines are 

        lw    $t3,($s0)      # Fetch an integer from the array.
        addu  $t2,$t2,$t3    # Add it to the sum.
	addiu $s0,$s0,4      # Advance the pointer by 4 bytes.    

The first line reads an array value at the current location of
the pointer and the third advances the pointer by 4 byte locations.
The middle one updates the sum with that fetched value. 

This full code is given as `sum_array.asm` in the `samples` folder.

### Output the character codes of a string

Here is another example where we traverse a sequence of data items stored
in memory. In this case, we are instead reading the bytes of a string.
With each character's byte we read, we output its ASCII code.

        la $s0,string_ptr
    loop:
        lb $t0,($s0)    # Fetch the next character.
        beqz $t0,done   # See if it's the null character.
                        # If it's not,
	move $a0,$t0    # output the character's code.
        li $v0,1
        syscall
        
        addiu $s0,$s0,1
        b loop
    done:

There are two key parts here. The three lines under the `loop` label
grab the next character from the string in memory, and then output
its ASCII code, but only if we haven't reached the end of the string.

Recall that strings can have any length, and so there is always a "hidden"
last character, and follows the last readable character of the string. It
has an ASCII code of 0, and is sometimes called the "null termination
character." And so the `BEQ` line is checking whether or not the character
just fetched is character 0. If so, we've reached the end of the string
and we end the loop and exit the program.

The other key part is `addiu $s0,$s0,1`. We advance the pointer by only one
byte because characters are only one byte long.

This code is a sample named `stringcodes.asm`.

---

### Solution to Lecture 08-1 Exercise 1

I gave you two exercises at the end of the last lecture, each one having to
do with this kind of pointer access to a string stored in the data segment.
The first exercise asked you, when given a pointer to a character string
in memory, to output all the suffixes of that string. So, for the string
`hello`, I wanted the program to output

    hello
    ello
    llo
    lo
    o

Recall that system call #4 outputs a character string to the console when given
a pointer to the start of that string. That means that the kernel of the solution
to that code is roughly the following:

        la $s0,string_ptr
    loop:
        lb $t0,($s0)    # Fetch the first character at that pointer.next character.
        beqz $t0,done   # See if it's the null character.
	move $a0,$s0    # If not,output the characters starting at that pointer.
        li $v0,4
        syscall
        addiu $s0,$s0,1
        b loop
    done:

This is nearly the same code as previously discussed, only we're calling #4 on
the pointer, instead of calling #1 on the character's code.

Check out the actual solution under `suffix.asm`.

---

## Offsets within load/store instructions

It's fairly common, in MIPS programming, to have a register holding a
pointer to an area of memory, and then to make modifications to
several of the bytes near that location.

For example, suppose we want to swap two neighboring integers within an array.
Suppose `s1` holds the address of the first of those two integers. So then, if
you allow the notation, address `s1+4` holds the second of those integers. To
swap their values, you might write code like this:

    addiu $s2,$s1,4
    lw    $t1,($s1)
    lw    $t2,($s2)
    sw    $t2,($s1)
    sw    $t1,($s2)

We load the first integer into `t1`. We compute the address of the second 
integer (adding 4 to `s1`) into `t2`. We then store `t2` where the first
sat, and `t1` where the second sat. This swaps them in memory.

### Rephrased using offsets

It's a bit cumbersome to compute that second address. After all it is
only a fixed offset from the first one. This is such a common thing to
want to do---to access items at a fixed offset from a "base"
address---that MIPS has instructions for "loading at a fixed offset"
and "storing at a fixed offset" from an address. Here is the swap code
again, using those instructions instead:

    lw    $t1,0($s1)
    lw    $t2,4($s1)
    sw    $t2,4($s1)
    sw    $t1,0($s1)

The notation `lw $r,k($a)` is saying, grab me the four consecutive
bytes at addresses `a+k`, `a+k+1`, `a+k+2`, `a+k+3` and store them in
register `r`.

The notation `sw $r,k($a)` is saying, write the four bytes held in
register `r` out to the addresses `a+k`, `a+k+1`, `a+k+2`, `a+k+3`.

Note that the offset `k` *must be a constant*.

### LOAD/STORE AT OFFSET

instruction summary

### Solution to Lecture 08-1 Exercise 2

Exercise 2 from the last lecture asked you to rotate the string
`hello`.  Here is code that does that, and using the `LB` and `SB`
instructions with fixed offsets. It modified the contents of the 0-th
through 4th bytes of the string's storage.

        la $t4,hello_ptr
        lb $t3,0($t4) # save the 'h'
        lb $t6,1($t4)
        sb $t6,0($t4) # move the 'e' left
        lb $t6,2($t4)
        sb $t6,1($t4) # move the 'l' left
        lb $t6,3($t4)
        sb $t6,2($t4) # move the 'l' left
        lb $t6,4($t4)
        sb $t6,3($t4) # move the 'o' left
        sb $t3,4($t4) # place the 'h'

We're able to do this because we know the string is five characters
long.

You can see another example of using offsets in last lecture's
sample code `hellobye-offset.asm`, an alternative to `hellobye.asm`.

### Actual Solution to Exercise 08-1 Exercise 2

Check out the actual solution under `rotate.asm`. Rather than working
for only `hello`, it works for any string in memory. As a result, it
does not use offsets in this way. Rather it uses them to shift
characters one to the left with the instructions

        lb      $t6,1($t4)	# shift a character one spot left 
        sb      $t6,0($t4)	#
 
In that solution, `t4` holds a pointer into the middle of the string.
And we're moving the character just to the right of that spot into
that spot.

### Offsets in compiled code

Offsets get used a lot in the code that compilers generate when
compiling C++.  On Friday we'll see their use in managing stack frames
that live in memory.  Here's a preview. Consider the C++ code for a
function named `fcn`:

void fcn(int a, int b) {
    ...
    int x = a - b;
    int y = b + 10;
    ...
}

It would be reasonable (and somewhat typical) for a compiler to
generate code that looks like this, in place of those two assignment
statements:

    fcn:
        ...
        lw    $t0, 0($fp)
        lw    $t1, -4($fp)
        subu  $t2,$t0,$t1
        sw    $t2, -8($fp)
        addiu $t3,$t1,10
        sw    $t3, -12($fp)
        ...

Here is what the compiler might have generated as code above those 6
lines.  Before these lines, it sets up a pointer in memory to hold the
stack frame for the variables used by `fcn`. It uses register `fp` as
that pointer. This is an actual named register in MIPS32. It stands
for "frame pointer." The compiler, then, has also decided to keep the
integer variables `a`, `b`, `x`, and `y` in the 16 bytes at and below
that stack frame's pointer.

That means, for example, that adding `a` to `b` means fetching the
words at `0($fp)` and `-4($fp)`.  And updating `x` and `y` means
changing the words at `-8($fp)` and `-12($fp)`.

### Offsets for accessing struct data

Consider this C++ struct definition:

    struct coord {
        int x;
        int y;
        int z;
    };

and then consider this code:

    coord* p1;
    coord* p2;
    ...
    p2->x = 17;
    p2->y = p1->y;
    p2->z++;

These lines might then get compiled into the MIPS code:

    ...
    li    $t1,17
    sw    $t1,0($s2)
    
    lw    $t2,4($s1)
    sw    $t2,4($s2)
    
    lw    $t3,8($s2)
    addiu $t3,$t3,1
    sw    $t3,8($s2)
    
Here is what is being done: above these 7 lines, the code sets up
registers `s1` and `s2` to hold the addresses where the structs `p1`
and `p2` live in memory. Furthermore, the compiler has chosen to
layout a `coord` struct as a sequence of 12 bytes, 4 bytes for each
component `x`, `y`, and `z`.  Arbitrarily (and reasonably) it has them
laid out in that order.

So that means, for example, that `0($s2)` is referencing the `x`
component of `p2`. And, for example, `8($s2)` is referencing the `z`
componnent of `p1`. The `4($s1)` is referencing the `y` component of
`p1`. And so forth.

In general, what we're seeing in this example is that, when we have a
pointer to a struct in memory, we can access the struct's components
with this kinds of offset accesses.

---

## MIPS linked lists

With all this talk about structs, now seems like a good time to think 
about how linked lists can be easily represented in low level coding.
Consider this C++ program code:

    struct node {
        int data;
        struct node* next;
    };
    ...
       node nodes[3];
       node* n1 = &nodes[0];
       node* n2 = &nodes[1];
       node* n3 = &nodes[2];

       n1->data = 32;
       n2->data = 57;
       n3->data = 11;

       n1->next = n2;
       n2->next = n3;
       n3->next = nullptr;

This constructs a linked list that holds the sequence 3,5,1.
In MIPS32, both integers and pointers are 4-bytes, and so that means
that a `node` struct is 8 bytes.  That means that the array `nodes`
uses 24 bytes of storage.

We can mimic this C++ code with this MIPS code:

        .data
    nodes: space 24
        .text
    ...
        la    $s1,nodes
        addiu $s2,$s1,8
        addiu $s3,$s2,8

        li    $t0,32
        sw    $t0,($s1)
        li    $t0,57
        sw    $t0,($s2)
        li    $t0,11
        sw    $t0,($s3)
        
        sw    $s2,4($s1)
        sw    $s3,4($s2)
	li    $t0,0
        sw    $t0,4($s3)


In the first three lines below `.text`, we set up three addresses
`s1`, `s2`, and `s3` that are equivalent to the pointers `n1`, `n2`,
`n3`. We offset them by 8 bytes because `node` requires 8 bytes of
space.

The next six lines do the equivalent of setting the `data` fields of
those three nodes. We choose to have `data` held in the first 4 bytes
of that 8 byte sequence for a `node`.  That means that the `next`
components are at offset 4 from each pointer.

That sets up our thinking for the last four lines. Here we set the
`next` field of each of the three structs. For example, we are storing
the address of the second struct `s2` into the `next` component of the
first struct `s1`. Thus

        sw    $s2,4($s1)

The last two lines are setting the `next` field of the third struct
(the third node in the linked list) to the null pointer value,
i.e. address 0.

### Linked list traversal

The linked list in the prior section happens to have its nodes in
the same order that they are laid out in memory. In general, though,
linked lists can be linked in all sorts of orders. That arbitrary
to reorder and relink is exactly why they're used as a data structure.

I've included a sample program `inorder.asm` that reads a series of
integers and builds a linked list holding their values. In building
that linked list, actually places them in sorted order. This means,
then, that their order will generally differ from the order that
they are laid out in the reserved space under `.data`.

I'll let you take a look at that full code on your own. I especially 
recommend you look at the traversal code. Here it is below. In the
below, I've removed the code that printe the `\n` character just to
keep it short:

    print:
            move    $s1, $s0		
    print_loop:	
            beqz    $s1, done_print	
    print_data:	
            lw      $a0, ($s1)		
            li      $v0, 1		
            syscall
            lw	    $s1, 4($s1)		
            b       print_loop
    done_print:

In the above, the register `s0` is a pointer to the first node
in the linked list. And register `s1` is used like the variable
`current` is often used, namely, as a traversal pointer. That 
means that the line

            lw      $a0, ($s1)		

is where we access the `data` component to print. And then the
line

            lw	    $s1, 4($s1)		

is how we advance the pointer to the next node in the list. It
is equivalent to the C++ statement:

            current = current->next;

And then the line

            beqz    $s1, done_print	

is simply checking whether `current == nullptr`. If it is, then
we are done traversing the list.

This is probably quite close to what a compiler might generate
for the C++ code:

    node* current = first;
    while (current != nullptr) {
        put_int(current->data);
        current = current->next;
    }

For those of you struggling with pointers, I hope this low-level
view of addressing and access to structs helps you think about
what is happening in the high-level C++ code that you write.

---

## Homework 08

Here is the direct link to [Homework 08](https://classroom.github.com/a/khWxB8As).

