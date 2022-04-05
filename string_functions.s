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
	add	$s0, $zero, $zero						# Initialize array index i to zero.


for_all_in_array:

	#### Append a MIPS-instruktion before each of these comments

	beq $s0, $a1, end_for_all  			# Done if i == N


	sll $s7, $s0, 2									# 4*i
	add $s5, $a0, $s7								# address = ARRAY + 4*i
	lw $s6, 0($s5)									# n = A[i]
	add $v0, $v0, $s6								# Sum = Sum + n
	addi $s0, $s0, 1								# i++


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

	lb $s1, 0($a0)									# Load the first byte on adress $a0 to $s1
	beq $s1, $zero, end_string			# If there is $zero loaded in $s1 (the end of the null terminated str), branch to end
	addi $v0, $v0, 1								# Add a one to the return value
	addi $a0, $a0, 1								# Move adress to the next letter

	j string_length									# Continue loop

end_string:

	addi $v0, $v0, -4								# Remove 4 from return value, because $v0 gets initiated as 4 in main
	jr	$ra													#

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

	addi	$sp, $sp, -4								# PUSH return address to caller
	sw	$ra, 0($sp)										#
	add $s1, $a0, $zero								#	Loads adress of str into $s1


loop:

	add $a0, $s1, $zero								# Loads $s1 into $a1, because it gets modified in later code
	lb $s0, 0($a0)										#	Loads the letter at position $a0 into $s0
	beq $s0, $zero, end_for_each			#	If there is $zero loaded in $s0 (the end of the null terminated str), branch to end
	addi $s1, $s1, 1									#	Move to next letter
	jal $a1														# Calling function that prints ascii value

	j loop														# Return to loop

end_for_each:

	lw	$ra, 0($sp)										# Pop return address to caller
	addi	$sp, $sp, 4									#
	jr	$ra														#

##############################################################################
#
#  DESCRIPTION: Transforms a lower case character [a-z] to upper case [A-Z].
#
#        INPUT: $a0 - address of a character
#
##############################################################################

to_upper:

    lb $s2, 0($a0)								# Loads the first character of the string
    bge $s2, 97, and_check 				# if the character is equal or larger than 97, jump to the label and_check
    jr $ra 												# return to caller

and_check:

		ble $s2, 122, convert_case 	  # if the character is equal or less than 122, jump to the label convert_case (Meaning that the character is a lowercase letter)
		jr $ra												# return to caller

convert_case:

    addi $s2, $s2, -32		# subtracts the characters binary representation with 32 to get its upper case character
    sb $s2 0($a0)					# stores the new uppercase character in the correct address
    jr $ra 								# return to caller

##############################################################################
#
# 		DESCRIPTION: Reverses a given string
# 			INPUT: $a1 - address for test string
#
##############################################################################

reverse_string:

		addi	$sp, $sp, -4  	# Moves the stack pointer down 4 bytes in memory
		add $s0, $a1, $zero   # stores the address of the first character of the string in $t0
		add $s2, $sp, $zero   # stores the value of the stack pointer that's pointing at the first character of the string in to $t2
		add $t6, $a1, $zero   # stores the address of the first character of the string in $t6

insert:

		lb $s1, 0($a1)  						# loads the character from the given address in to $t1
		beq $s1, $zero, pop_stack   # if $t1 is equal to $zero, jump to the label pop_stack (if the string has reached its end (NULL))
		addi $sp, $sp, -1   				# moves the stack pointer down one byte in the memory
		sb $s1, 0($sp) 							# stores the character in the stack memory where the stack pointer is pointing at
		addi $a1, $a1, 1						# Increment the address of the string by one byte (Moves to the next character in the string)

		j insert										# Jump to the label insert

pop_stack:

		beq $s2, $sp, reverse_end   # if the current character has the same address as $t2, jump to the label reverse_end ($sp is then pointing at the bottom of the stack)
		lb $s4, 0($sp)						  # loads the character that the stack pointer is pointing at in to $t4
		sb $s4, 0($s0)							# stores the character in $t4 in to the memory address $t0
		addi $sp, $sp, 1						# moves the stack pointer one byte
		addi $s0, $s0, 1						# increases the memory address by one byte

		j pop_stack									# jumpts to the label reverse_end

reverse_end:

		addi	$sp, $sp, 4		# moves the stack pointer up 4 bytes in the memory
		jr $ra 							# return to caller



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

	##
	### reverse_string(string)
	##

	la	$a0, STR_reverse_string  						# Prints a string to the terminal
	syscall

	la	$a1, STR_str												# Loads test string into $a1
	jal reverse_string											# Calls the function



	la	$a0, STR_str												# Loads adress of STR_str into $a0
	jal print_test_string										# Calls the function

	lw	$ra, 0($sp)													# POP return address
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
