// palinfinder.s, provided with Lab1 in TDT4258 autumn 2025
.global _start

_end_string_loop:
	ldrb r3, [r1] 			// Load 1 byte from the string (r1 points into input)
	cmp r3, #0				// Compare byte to zero (if check_word == '\0')
	beq _check_palindrome
	add r1, r1, #1			// String address: Increment r1 by 1 (i++)
	b _end_string_loop

skip_left:
	sub r1, r1, #1
	b palindrome_loop
skip_right:
	add r0, r0, #1
	b palindrome_loop

_start:
	ldr r0, =input		// r0 = address of input string (char* word = input)
	mov r1, r0			// r1 = copy of r0 (r1 will walk through the string)
	b _end_string_loop 	// Branch to length loop
	
	
_check_palindrome:
	sub r1, r1, #1		// Decrement r1 by 1 to get end of string and not null terminator
	
	palindrome_loop:
		ldrb r2, [r0]		// Load byte from r0 into r2, start of string
		ldrb r3, [r1] 		// Load byte from r1 into r3, end of string
		check_space:
		cmp r2, #32			// Compares r2 to space
		beq skip_right
		cmp r3, #32	
		beq skip_left
		normalize_lower_case:  // Checks if r2 or r3 are upper case
		cmp r2, #'A'
		blt check_end_string
		cmp r2, #'Z'
		bgt check_end_string
		
		add r2, r2, #32			// if r2 == upper case, make lower case
	check_end_string:
		cmp r3, #'A'
		blt is_lower_case
		cmp r3, #'Z'
		bgt is_lower_case
		
		add r3, r3, #32 		// if r3 == upper case, make lower case
		is_lower_case:
		cmp r0, r1			// Compare r0 and r1 to know when to stop checking
		bhs is_palindrome
		
		cmp r2, r3 			// Compare byte in r2 and r3
		bne check_wildcard	// If they arent equal check for wildcard
		is_equal:			// else increment r0 and decrement r0
			sub r1, r1, #1
			add r0, r0, #1
			beq palindrome_loop
	
	check_wildcard: // if r2 or r3 has # or ?, move 1 to r4
		mov r4, #0
		cmp r2, #35
		moveq r4, #1
		cmp r2, #63
		moveq r4, #1
		cmp r3, #35
		moveq r4, #1
		cmp r3, #63
		moveq r4, #1
		cmp r4, #1
		beq is_equal 		// Go back to palindrome_loop if r4 == 1
		bne not_palindrome	// else not_palindrome
		
	is_palindrome:
		ldr r0, =led_offset // Load address of led_offset in r0 (*r0 = &led_offset)
		ldr r0, [r0]		// Point to address stored at value of led_offset(r0 = (uint32_t *) *r0)
		mov r1, #0x01F		// Move 0b11111 into r1
		str r1, [r0]		// Store r1 in r0
		
		ldr r0, =uart_offset	// Load address of uart_offset in r0
		ldr r0, [r0]			// Point to address stored at value of uart_offset
		ldr r1, =palindrome_string	 // Load address of palindrome_string in r1
		palindrome_to_uart_loop:	// Loop to write to UART
			ldrb r2, [r1]	// Load 1 byte from r1 into r2
			add r1, r1, #1		// Move pointer to next byte of r1
			cmp r2, #0		// Check for null terminator in r2
			beq _exit		// if null exit
			str r2, [r0]	// Store byte in r2 in first byte of r0 to write to uart
			bne palindrome_to_uart_loop	// Loop
	
	not_palindrome:			// Same as is_palindrome
		ldr r0, =led_offset
		ldr r0, [r0]
		mov r1, #0x3E0
		str r1, [r0]
		ldr r0, =uart_offset
		ldr r0, [r0]
		ldr r1, =not_palindrome_string
		not_palindrome_to_uart_loop:
			ldrb r2, [r1]
			add r1, r1, #1
			cmp r2, #0
			beq _exit
			str r2, [r0]
			bne not_palindrome_to_uart_loop
		
	
_exit:
	b .
	
.data
	led_offset: .word 0xFF200000
	uart_offset: .word 0xFF201000
	palindrome_string: .asciz "Palindrome detected"
	not_palindrome_string: .asciz "Not a palindrome"

.align
	// This is the input you are supposed to check for a palindrom
	// You can modify the string during development, however you
	// are not allowed to change the name 'input'!
	input: .asciz "Grav ned den varg"
.end
