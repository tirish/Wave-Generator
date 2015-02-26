@; Thomas Irish
@; IO - Macros


.macro ENABLE_GPIOx GPIOx_INDEX
	MOV_imm32 r0, (1 << \GPIOx_INDEX)
	MOV_imm32 r1, RCC_AHB1ENR

	ldr r2, [r1]
	orr r2, r0
	str r2, [r1]
.endm

.macro SET_GPIOx_REG REG_OFFSET, GPIOx_BASE, PIN, VAL, VAL_WIDTH

	MOV_imm32 r0, \GPIOx_BASE
	.if (\VAL_WIDTH == 1)
	MOV_imm32 r1, (\VAL << \PIN)
	MOV_imm32 r2, (1 << \PIN)
	.elseif(\VAL_WIDTH == 2)
	MOV_imm32 r1, (\VAL << (2*\PIN))
	MOV_imm32 r2, (3 << (2*\PIN))
	.elseif(\VAL_WIDTH == 4)
	MOV_imm32 r1, (\VAL << (4*\PIN))
	MOV_imm32 r2, (0xf << (4*\PIN))
	.endif
	
	INVERT r2
	
	ldr r3, [r0, \REG_OFFSET] @; r3 contains OTYPER reg
	and r3, r2 			@; clear out 1 bit of OTYPER for pin
	orr r1, r3			@; set the 1 bit of OTYPER for pin
	str r1, [r0, \REG_OFFSET]

.endm




.macro PORTBIT_init CONFIG GPIOx_BASE PIN

	.if (\CONFIG == STD_OUTPIN)
	@; SET_GPIOx_REG REG_OFFSET, GPIOx_BASE, PIN, VAL, VAL_WIDTH
	SET_GPIOx_REG 	MODER, 		\GPIOx_BASE, \PIN, 1, 2
	SET_GPIOx_REG 	OTYPER, 	\GPIOx_BASE, \PIN, 0, 1
	SET_GPIOx_REG 	OSPEEDR, 	\GPIOx_BASE, \PIN, 2, 2
	SET_GPIOx_REG 	PUPDR,	 	\GPIOx_BASE, \PIN, 1, 2

	.elseif(\CONFIG == PULLUP_INPIN)
	SET_GPIOx_REG 	MODER, 		\GPIOx_BASE, \PIN, 0, 2
	@;SET_GPIOx_REG 	OTYPER, 	\GPIOx_BASE, \PIN, 0, 1
	SET_GPIOx_REG 	OSPEEDR, 	\GPIOx_BASE, \PIN, 2, 2
	SET_GPIOx_REG 	PUPDR,	 	\GPIOx_BASE, \PIN, 1, 2

	.elseif(\CONFIG == ALT_PIN)
	SET_GPIOx_REG 	MODER,		\GPIOx_BASE, \PIN, 2, 2	
	SET_GPIOx_REG 	OTYPER, 	\GPIOx_BASE, \PIN, 0, 1
	SET_GPIOx_REG 	OSPEEDR, 	\GPIOx_BASE, \PIN, 2, 2
	SET_GPIOx_REG 	PUPDR,	 	\GPIOx_BASE, \PIN, 1, 2
	
	.elseif(\CONFIG == PULLDOWN_INPIN)
	SET_GPIOx_REG 	MODER, 		\GPIOx_BASE, \PIN, 0, 2
	@;SET_GPIOx_REG 	OTYPER, 	\GPIOx_BASE, \PIN, 0, 1
	SET_GPIOx_REG 	OSPEEDR, 	\GPIOx_BASE, \PIN, 2, 2
	SET_GPIOx_REG 	PUPDR,	 	\GPIOx_BASE, \PIN, 2, 2
	
	.endif


.endm
	

.macro PORTBIT_write GPIOx_BASE PIN VAL

MOV_imm32 r0, \GPIOx_BASE
.if (\VAL == 1)
@;MOV_imm32 r2, BSRRL	@; SET PIN
ldr r1, [r0, BSRRL]
.else 
@;MOV_imm32 r2, BSRRH	@;	CLEAR PIN
ldr r1, [r0, BSRRH]
.endif

@;ldr r1, [r0, r2]
MOV_imm32 r3, (1 << \PIN)
orr r1, r3
@;str rl, [r0, r2]

	.if (\VAL == 1)
		str r1, [r0, BSRRL]
	.else 
		str r1, [r0, BSRRH]
	.endif


.endm




@;ANODE_write X,R,G,D4,D3,D2,D1,P	: R(ed),G(rn),D(igit)4,-3,-2,-1,P(unctuation)
.macro ANODE_write X R G D4 D3 D2 D1 P
	@; PORTBIT_write GPIOx_BASE PIN VAL
	PORTBIT_write GPIOB_BASE, 11, \R
	PORTBIT_write GPIOB_BASE, 0, \G
	PORTBIT_write GPIOB_BASE, 1, \D4
	PORTBIT_write GPIOC_BASE, 4, \D3
	PORTBIT_write GPIOA_BASE, 1, \D2
	PORTBIT_write GPIOC_BASE, 2, \D1
	PORTBIT_write GPIOC_BASE, 5, \P

	@; UPDATE LATCHS (pulse AN clk)
	PORTBIT_write GPIOC_BASE, 11, 0
	PORTBIT_write GPIOC_BASE, 11, 1
	
.endm

@; UPDATE LATCHS (pulse CA clk)
.macro CATHODE_save

	PORTBIT_write GPIOD_BASE, 2, 0
	PORTBIT_write GPIOD_BASE, 2, 1

.endm

@; CATHODE_write A,B,C,D,E,F,G,DP
.macro CATHODE_write A B C D E F G DP
	@; PORTBIT_write GPIOx_BASE PIN VAL
	PORTBIT_write GPIOC_BASE, 5, \A
	PORTBIT_write GPIOB_BASE, 1, \B
	PORTBIT_write GPIOA_BASE, 1, \C
	PORTBIT_write GPIOB_BASE, 5, \D
	PORTBIT_write GPIOB_BASE, 11, \E
	PORTBIT_write GPIOC_BASE, 2, \F
	PORTBIT_write GPIOC_BASE, 4, \G
	PORTBIT_write GPIOB_BASE, 0, \DP
	
	CATHODE_save

.endm

@; preserves regs: r0-r3
.macro CATHODE_write_safe A B C D E F G DP
	push {r0, r1, r2, r3}
	CATHODE_write \A, \B, \C, \D, \E, \F, \G, \DP
	pop {r0,r1,r2,r3}
.endm


@; Returns pin value in r0
@; taints r1
.macro PORTBIT_read GPIOx_BASE PIN

	MOV_imm32 r0, \GPIOx_BASE
	
	ldr r1, [r0, #(IDR)] @; r1 contains IDR reg
	
	MOV_imm32 r0, (1 << \PIN)
	and r1, r1, r0 @;isolate bit for input PIN
	
	lsr r1, #(\PIN) @;move isolated bit to beginning of word
	mov r0, r1

.endm

@; Returns pin value in r0
@; preserves r1
.macro PORTBIT_read_safe GPIOx_BASE PIN
	push{r1}
	PORTBIT_read \GPIOx_BASE, \PIN
	pop{r1}
.endm

