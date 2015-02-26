@; Thomas Irish
@; General - Functions



	@; r0 = 32-bit binary/bcd (becomes most significant bits)
	@; r1 = 32-bit binary/bcd
	@; r2 = num bits to merge (max 16)
	.global MergeBits
	.thumb_func
MergeBits:
	@; make sure r2 is less than or equal to 16
	MOV_imm32 r3, 16
	SATURATE r2, r3
	
	MOV_imm32 r3, 0xffffffff
	lsl r3, r2
	INVERT r3
	
	@; remove extra bits
	and r0, r0, r3
	and r1, r1, r3
	
	@;shift and combine
	lsl r0, r2
	orr r0, r0, r1

	bx lr






	@; r0 = 32-bit binary
	@; RETURN r0 = 32-bit BCD
	.global bin2BCDv2
	.thumb_func
bin2BCDv2:		
	push {r7,lr}	@; Save frame pointer (r7) and link register

	push {r4, r5}
	
	mov r4, #0	@; result
	mov r5, #0	@; offset
	
bin2BCDv2_begin:	
	mov r2, #10
	udiv r3, r0, r2	@; r3 = r0 / r2 = binary value / 10 = quotient
	mul r2, r3, r2	@; r2 = r3 * r2 = quotient * 10
	subs r2, r0, r2 @; r2 = r0 - r2 = binary value - (quotient * 10) = remainder
	
	
	lsl r2, r5
	orr r4, r2
	
	add r5, #4
	
	
	cmp r3, #0
	beq bin2BCDv2_end	@; If quotient is zero, exit
	mov r0, r3		@; update binary number to the previous quotient
	b bin2BCDv2_begin

bin2BCDv2_end:	

	mov r0, r4

	pop {r4, r5}
	pop {r7,lr}		@; Restore frame pointer (r7) and link register
	bx lr			@; Return