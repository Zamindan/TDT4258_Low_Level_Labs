// palinfinder.s, provided with Lab1 in TDT4258 autumn 2025
.global _start

_len_loop:
	ldrb r3, [r1] 	// Load 1 byte from the string (r1 points into input)
	cmp r3, #0		// Compare byte to zero (if check_word == '\0')
	beq _check_palindrome		// If zero branch
	add r1, r1, #1	// String address: Increment r1 by 1 (i++)
	b _len_loop

_start:
	ldr r0, =input	// r0 = address of input string (char* word = input)
	mov r1, r0		// r1 = copy of r0 (r1 will walk through the string)
	mov r2, #0		// r2 = 0, will be used for length (int length = 0)
	b _len_loop 	// Branch to length loop
	
	
_check_palindrome:
	sub r1, #1		// Decrement r1 by 1 to get end of string and not null terminator
	
	palindrome_loop:
		ldrb r2, [r0]
		ldrb r3, [r1]
		bl check_space
		bl normalize_lower_case
		cmp r0, r1
		bhs is_palindrome
		
		cmp r2, r3
		bne check_wildcard
		is_equal:
			sub r1, r1, #1
			add r0, r0, #1
			beq palindrome_loop
		
	check_space:
		cmp r2, #32
		bne check_space_r3
		add r0, r0, #1
		beq palindrome_loop
		
		check_space_r3:
			cmp r3, #32
			bne not_space
			sub r1, r1, #1
			beq palindrome_loop
			
		not_space:
			bx lr
	
	check_wildcard:
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
		beq is_equal
		bne not_palindrome
		
	normalize_lower_case:
		cmp r2, #'A'
		blt check_end_string
		cmp r2, #'Z'
		bgt check_end_string
		
		add r2, #32
	check_end_string:
		cmp r3, #'A'
		blt is_lower_case
		cmp r3, #'Z'
		bgt is_lower_case
		
		add r3, #32
		is_lower_case:
			bx lr
		
	is_palindrome:
		ldr r0, =led_offset
		ldr r0, [r0]
		mov r1, #0x01F
		str r1, [r0]
		ldr r0, =uart_offset
		ldr r0, [r0]
		ldr r1, =palindrome_string
		palindrome_to_uart_loop:
			ldrb r2, [r1]
			add r1, #1
			cmp r2, #0
			beq _exit
			str r2, [r0]
			bne palindrome_to_uart_loop
	
	not_palindrome:
		ldr r0, =led_offset
		ldr r0, [r0]
		mov r1, #0x3E0
		str r1, [r0]
		ldr r0, =uart_offset
		ldr r0, [r0]
		ldr r1, =not_palindrome_string
		not_palindrome_to_uart_loop:
			ldrb r2, [r1]
			add r1, #1
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
