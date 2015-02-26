



@; TIM3 Initial settings:
@; Control Register One (CR): Page 611 of 1710 pg manual
.equ TIM3_CKD, 		0x00<<CKD 	@; Clock Division; 2 Bits;
.equ TIM3_APRE, 	1	<<APRE	@; Auto-Reload preload enable; 1 Bit
.equ TIM3_CMS,		0x00<<CMS	@; Center-align mode selection; 2 bits
.equ TIM3_DIR,		0	<<DIR	@; Direction; 1 bit (Count down)
.equ TIM3_OPM,		0	<<OPM	@; One-pulse mode; 1 bit
.equ TIM3_URS,		1	<<URS	@; Update request source; 1 bit
.equ TIM3_UDIS,		0	<<UDIS	@; Update disable; 1 bit
.equ TIM3_CEN,		1	<<CEN	@; Counter Enable; 1 bit

@; first 9 bits of a 16 bit register
.equ TIM3_CR1_Settings, TIM3_CKD|TIM3_APRE|TIM3_CMS|TIM3_DIR|TIM3_OPM|TIM3_URS|TIM3_UDIS|TIM3_CEN


@; DMA/Interrupt enable
.equ TIM3_DIER_Settings, (1<<UIE)
	
@; Counter (CNT)
.equ TIM3_CNT, 		0x0000 @; 16 bits
	
@; Prescaler (PSC)@;RM0090 pg 530 - 168mHZ/(99+1)=1680kHz at the prescaler
.equ TIM3_PSC, 		0x0063 @; 16 bits;
	
@; Auto-Reload Register (ARR)
.equ TIM3_ARR, 		0x00A8@; 16 bits; RM0090 pg 530 -- 168kHz/168 = 10 kHz ? but actually 1khz?


	
	@; Initialize Timer3 registers
	.global TIM3_init
	.thumb_func
TIM3_init:
	
	@; NVIC stuff (doesn't set priority, only enables)
	mov r1,#(1<<29)				@;enable bit for TIM3 at interrupt position 29
	MOV_imm32 r2,NVIC_ISER0		@;interrupt enable register for interrupt 0-31
	str r1,[r2]
	
	@; enable clock
	ENABLE_TIMx TIM3_EN
	TIMx_Config TIM3_Base TIM3_CR1_Settings, TIM3_DIER_Settings, TIM3_CNT, TIM3_PSC, TIM3_ARR
	bx lr


	@; Initialize Timer3 registers
	.global TIM4_init
	.thumb_func
TIM4_init: 
	@; NVIC stuff (doesn't set priority, only enables)
	mov r1,#(1<<30)				@;enable bit for TIM3 at interrupt position 29
	MOV_imm32 r2,NVIC_ISER0		@;interrupt enable register for interrupt 0-31
	str r1,[r2]
	
	@; enable clock
	ENABLE_TIMx TIM4_EN
	
	
	.global TIM4_Set_To_Default
	.thumb_func
TIM4_Set_To_Default:
	TIMx_Config TIM4_Base TIM3_CR1_Settings, TIM3_DIER_Settings, TIM3_CNT, TIM3_PSC, TIM3_ARR
		
		
		
	.global TIM4_Set_UG
	.thumb_func
TIM4_Set_UG:
	@; says there is an update
	MOV_imm32 r0, TIM4_Base
	MOV_imm32 r1, EGR
	MOV_imm32 r2, (1<<UG)
	
	strh r2, [r0, r1]
	bx lr
	

	
	
	.global TIM4_Debug_Test
	.thumb_func
TIM4_Debug_Test:
	DISABLE_TIMx TIM4_EN
	ENABLE_TIMx TIM4_EN
	b TIM4_Set_To_Default
	

	

	@; doesn't work
	.global TIM4_Clear_SR
	.thumb_func
TIM4_Clear_SR:
	@;TIMx_CLEAR_SR TIM4_Base
	
	MOV_imm32 r0, TIM4_Base
	MOV_imm32 r1, SR
	
	MOV_imm32 r2, SR_CLR_BITMASK
	
	ldrh r3, [r0, r1]
	and r3, r2
	strh r3, [r0, r1]
	
	bx lr

	.global TIM4_Clear_SR2
	.thumb_func
TIM4_Clear_SR2:
	@;TIMx_CLEAR_SR TIM4_Base
	
	MOV_imm32 r0, TIM4_Base
	MOV_imm32 r1, SR
	
	MOV_imm32 r2, 0
	
	strh r2, [r0, r1]
	
	bx lr

	


/*	.global TIM3_Handler
	.thumb_func
TIM3_Handler:
*/


	
	

