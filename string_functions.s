##############################################################################
#
#  KURS: 1DT038 2022.  Computer Architecture
#
# DATUM: 2022-03-28
#
#  NAMN: William Forslund
#
#  NAMN: Viktor Kangasniemi
#
#  NAMN: David Ohanjanian
#
##############################################################################

	.data

ARRAY_SIZE:
	.word	10	# Change here to try other values (less than 10)
FIBONACCI_ARRAY:
	.word	1, 1, 2, 3, 5, 8, 13, 21, 34, 55
STR_str:
	.asciiz "Hunden, Katten, Glassen"

	.globl DBG
	.text

##############################################################################
#
# DESCRIPTION:  For an array of integers, returns the total sum of all
#		elements in the array.
#
# INPUT:        $a0 - address to first integer in array.
#		$a1 - size of array, i.e., numbers of integers in the array.
#
# OUTPUT:       $v0 - the total sum of all integers in the array.
#
##############################################################################
integer_array_sum:

DBG:	##### DEBUGG BREAKPOINT ######

  addi    $v0, $zero, 0           # Initialize Sum to zero.
	add	$t0, $zero, $zero						# Initialize array index i to zero.


for_all_in_array:

	#### Append a MIPS-instruktion before each of these comments

	beq $t0, $a1, end_for_all  			# Done if i == N


	sll $t7, $t0, 2									# 4*i
	add $t5, $a0, $t7								# address = ARRAY + 4*i
	lw $t6, 0($t5)									# n = A[i]
	add $v0, $v0, $t6								# Sum = Sum + n
	addi $t0, $t0, 1								# i++


	j for_all_in_array							# next element

end_for_all:

	jr	$ra													# Return to caller.

##############################################################################
#
# DESCRIPTION: Gives the length of a string.
#
#       INPUT: $a0 - address to a NUL terminated string.
#
#      OUTPUT: $v0 - length of the string (NUL excluded).
#
#    EXAMPLE:  string_length("abcdef") == 6.
#
##############################################################################

string_length:

	lb $t1, 0($a0)									# Load the first byte on adress $a0 to $t1
	beq $t1, $zero, end_string
	addi $v0, $v0, 1
	addi $a0, $a0, 1

	j string_length

end_string:

	addi $v0, $v0, -4
	jr	$ra

##############################################################################
#
#  DESCRIPTION: For each of the characters in a string (from left to right),
#		call a callback subroutine.
#
#		The callback suboutine will be called with the address of
#	        the character as the input parameter ($a0).
#
#        INPUT: $a0 - address to a NUL terminated string.
#
#		$a1 - address to a callback subroutine.
#
##############################################################################
string_for_each:

	addi	$sp, $sp, -4		# PUSH return address to caller
	sw	$ra, 0($sp)

	add $s1, $a0, $zero


loop:
	add $a0, $s1, $zero
	lb $s0, 0($a0)
	beq $s0, $zero, end_for_each
	addi $s1, $s1, 1
	jal $a1

	j loop

end_for_each:

	lw	$ra, 0($sp)		# Pop return address to caller
	addi	$sp, $sp, 4
	jr	$ra

##############################################################################
#
#  DESCRIPTION: Transforms a lower case character [a-z] to upper case [A-Z].
#
#        INPUT: $a0 - address of a character
#
##############################################################################
to_upper:

    lb $t1, 0($a0)
    bge $t1, 97, and_check # OM LOWERCASE
    jr $ra

and_check:

		ble $t1, 122, convert_case
		jr $ra

convert_case:

    addi $t1, $t1, -32
    sb $t1 0($a0)
    jr $ra

##############################################################################
#
# Reverse_string subroutine
# a1 is adress for test string
##############################################################################

reverse_string:

		add $t0, $a1, $zero
		add $t2, $sp, $zero
		add $t6, $a1, $zero

insert:

		lb $t1, 0($a1)
		beq $t1, $zero, pop_stack
		addi $sp, $sp, -1
		sb $t1, 0($sp)
		addi $a1, $a1, 1

		j insert

pop_stack:

		beq $t2, $sp, reverse_end
		lb $t4, 0($sp)
		sb $t4, 0($t0)
		addi $sp, $sp, 1
		addi $t0, $t0, 1

		j pop_stack

reverse_end:

		jr $ra



##############################################################################
#
# Strings used by main:
#
##############################################################################

	.data

NLNL:	.asciiz "\n\n"

STR_sum_of_fibonacci_a:
	.asciiz "The sum of the "
STR_sum_of_fibonacci_b:
	.asciiz " first Fibonacci numbers is "

STR_string_length:
	.asciiz	"\n\nstring_length(str) = "

STR_for_each_ascii:
	.asciiz "\n\nstring_for_each(str, ascii)\n"

STR_for_each_to_upper:
	.asciiz "\n\nstring_for_each(str, to_upper)\n\n"

STR_reverse_string:
	.asciiz "\n\nreverse_string(str)\n\n"

	.text
	.globl main

##############################################################################
#
# MAIN: Main calls various subroutines and print out results.
#
##############################################################################
main:
	addi	$sp, $sp, -4	# PUSH return address
	sw	$ra, 0($sp)

	##
	### integer_array_sum
	##

	li	$v0, 4
	la	$a0, STR_sum_of_fibonacci_a
	syscall

	lw 	$a0, ARRAY_SIZE
	li	$v0, 1
	syscall

	li	$v0, 4
	la	$a0, STR_sum_of_fibonacci_b
	syscall

	la	$a0, FIBONACCI_ARRAY
	lw	$a1, ARRAY_SIZE
	jal 	integer_array_sum

	# Print sum
	add	$a0, $v0, $zero
	li	$v0, 1
	syscall

	li	$v0, 4
	la	$a0, NLNL
	syscall

	la	$a0, STR_str
	jal	print_test_string

	##
	### string_length
	##

	li	$v0, 4
	la	$a0, STR_string_length
	syscall

	la	$a0, STR_str
	jal 	string_length

	add	$a0, $v0, $zero
	li	$v0, 1
	syscall

	##
	### string_for_each(string, ascii)
	##

	li	$v0, 4
	la	$a0, STR_for_each_ascii
	syscall

	la	$a0, STR_str
	la	$a1, ascii
	jal	string_for_each

	##
	### string_for_each(string, to_upper)
	##

	li	$v0, 4
	la	$a0, STR_for_each_to_upper
	syscall

	la	$a0, STR_str
	la	$a1, to_upper
	jal	string_for_each

	la	$a0, STR_str
	jal	print_test_string

	la	$a0, STR_reverse_string
	syscall

	la	$a1, STR_str
	jal reverse_string


	add $a0, $t6, $zero
	jal print_test_string

	lw	$ra, 0($sp)	# POP return address
	addi	$sp, $sp, 4

	jr	$ra


##############################################################################
#
#  DESCRIPTION : Prints out 'str = ' followed by the input string surronded
#		 by double quotes to the console.
#
#        INPUT: $a0 - address to a NUL terminated string.
#
##############################################################################
print_test_string:

	.data
STR_str_is:
	.asciiz "str = \""
STR_quote:
	.asciiz "\""

	.text

	add	$t0, $a0, $zero

	li	$v0, 4
	la	$a0, STR_str_is
	syscall

	add	$a0, $t0, $zero
	syscall

	li	$v0, 4
	la	$a0, STR_quote
	syscall

	jr	$ra


##############################################################################
#
#  DESCRIPTION: Prints out the Ascii value of a character.
#
#        INPUT: $a0 - address of a character
#
##############################################################################
ascii:
	.data
STR_the_ascii_value_is:
	.asciiz "\nAscii('X') = "

	.text

	la	$t0, STR_the_ascii_value_is

	# Replace X with the input character

	add	$t1, $t0, 8	# Position of X
	lb	$t2, 0($a0)	# Get the Ascii value
	sb	$t2, 0($t1)

	# Print "The Ascii value of..."

	add	$a0, $t0, $zero
	li	$v0, 4
	syscall

	# Append the Ascii value

	add	$a0, $t2, $zero
	li	$v0, 1
	syscall


	jr	$ra
