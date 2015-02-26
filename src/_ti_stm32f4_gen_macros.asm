@; Thomas Irish
@; General - Macros


	@;.macro setbit addr bit
@;	ldr	r2,=\addr	@;read word-data at addr (assumes target addr is read/write
@;	ldr r1,[r2]		@;  ..
@;	or	r1,#1<<\bit	@;set bit in word
@;	str r1,[r2]		@;	and save it back
@;.endm

@;.macro OR addr word
@;	ldr	r2,=\addr	@;read word-data at addr (assumes target addr is read/write
@;	ldr r1,[r2]		@;  ..
@;	or	r1,#1<<\bit	@;set bit in word
@;	str r1,[r2]		@;	and save it back
@;.endm

@;.macro clearbit addr bit
@;	ldr	r2,=\addr	@;read word at addr (assumes target addr is read/write
@;	ldr r1,[r2]		@;  ..
@;	mvn r0,#1<<\bit @;get bit-complement
@;	and	r1,r0		@;clear bit in word
@;	str r1,[r2]		@;	and save it back
@;.endm
	
.macro	INVERT reg
	eor \reg, 0xffffffff
.endm	
	
.macro MOV_imm32 reg val

	movw \reg, #(\val & 0x0000ffff)
	movt \reg, #(\val >> 16)

.endm



.macro SATURATE regCheck regMax

	cmp \regCheck, \regMax
	it gt
	movgt \regCheck, \regMax
	
.endm

.macro SET_bit addr bit @;logical OR position 'bit' at 'addr' with 1 
	MOV_imm32 r2,(\addr)
	ldr r1,[r2]
	ORR r1,#(1<<\bit)
	str r1,[r2]	
.endm

.macro CLR_bit addr bit @;logical AND position 'bit' at 'addr' with 0 
	MOV_imm32 r2,(\addr)
	ldr r1,[r2]
	BIC r1,#(1<<\bit)
	str r1,[r2]	
.endm

