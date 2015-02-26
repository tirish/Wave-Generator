@; TIM2 - TIM5


.macro ENABLE_TIMx TIMx_INDEX
	MOV_imm32 r0, (1 << \TIMx_INDEX)
	MOV_imm32 r1, RCC_APB1ENR

	ldr r2, [r1]
	orr r2, r0
	str r2, [r1]
.endm

.macro DISABLE_TIMx TIMx_INDEX

	MOV_imm32 r0, ~(1 << \TIMx_INDEX)
	MOV_imm32 r1, RCC_APB1ENR

	ldr r2, [r1]
	and r2, r0
	str r2, [r1]


.endm


.macro TIMx_CLEAR_SR TIMx_Base
	push {r0, r1, r2, r3}
	
	MOV_imm32 r0, \TIMx_Base
	MOV_imm32 r1, SR
	
	MOV_imm32 r2, SR_CLR_BITMASK
	
	ldrh r3, [r0, r1]
	and r3, r2
	strh r3, [r0, r1]
	
	
	pop {r0, r1, r2, r3}

.endm

.macro UPDATE Base Off Val RegSize ClrBitMask

	MOV_imm32 r0, \Base		@; load base
	
	MOV_imm32 r1, \Off 			@; load offset (CR1)
	
	
	.if \RegSize < 32
	
	ldrh r2, [r0, r1]			
	
	.else
	
	ldr r2, [r0, r1]
	
	.endif
	
	@; clear area
	MOV_imm32 r3, (\ClrBitMask)
	and r2, r3
	
	@; update area
	MOV_imm32 r3, \Val
	orr r2, r3
	
	
	.if \RegSize < 32
	
	strh r2, [r0, r1]			@; store value
	
	.else
	
	str r2, [r0, r1]
	
	.endif

.endm



.macro TIMx_Config TIMx_Base CR1_Val DIER_Val CNT_Val PSC_Val ARR_Val
	push {r0,r1,r2,r3}
	
	
	UPDATE \TIMx_Base, CNT, \CNT_Val, 16, 0x0000
	UPDATE \TIMx_Base, PSC, \PSC_Val, 16, 0x0000
	UPDATE \TIMx_Base, ARR, \ARR_Val, 16, 0x0000

	
	UPDATE \TIMx_Base, DIER, \DIER_Val, 16, DIER_CLR_BITMASK
	UPDATE \TIMx_Base, CR1, \CR1_Val, 16, CR1_CLR_BITMASK
	
	pop {r0,r1,r2,r3}
.endm