@; TIMx Registers (TIM2 - TIM5) General Purpose


@; RCC_BASE defined in IO constants
.equ RCC_APB1ENR, 	(RCC_BASE + 0x40)

@; enable offsets
.equ TIM2_EN, 0
.equ TIM3_EN, 1
.equ TIM4_EN, 2
.equ TIM5_EN, 3


@; Base addresses

.equ TIM2_Base, 0x40000000
.equ TIM3_Base, 0x40000400
.equ TIM4_Base, 0x40000800
.equ TIM5_Base, 0x40000C00



@; Control Register One (CR); 16 bits
.equ CR1, 0x00 @;offset
	@; Bit positions within Control Register
	.equ CKD, 	8 	@; Clock Division; 2 Bits
	.equ APRE, 	7	@; Auto-Reload preload enable; 1 Bit
	.equ CMS,	5	@; Center-align mode selection; 2 bits
	.equ DIR,	4	@; Direction; 1 bit
	.equ OPM,	3	@; One-pulse mode; 1 bit
	.equ URS,	2	@; Update request source; 1 bit
	.equ UDIS,	1	@; Update disable; 1 bit
	.equ CEN,	0	@; Counter Enable; 1 bit
	
.equ CR1_CLR_BITMASK, 0xfc00 @; clear least significant 9 bits
	
	
@; DMA/Interrupt Enable (DIER) pg 617; 16 bits
.equ DIER, 0x0C @;offset
	@; Bit positions within DIER
	.equ TDE, 	14 	@; Trigger DMA Enable; 1 bit
	.equ CC4DE, 12	@; Capture/Compare 4 DMA request enable; 1 bit
	.equ CC3DE, 11	@; Capture/Compare 3 DMA request enable; 1 bit
	.equ CC2DE, 10	@; Capture/Compare 2 DMA request enable; 1 bit
	.equ CC1DE, 9	@; Capture/Compare 1 DMA request enable; 1 bit
	.equ UDE, 	8	@; Update DMA request enable; 1 bit
	.equ TIE,	6	@; Trigger Interrupt Enable; ; 1 bit
	.equ CC4IE,	4	@; Capture/Compare 4 interrupt enable; 1 bit
	.equ CC3IE,	3	@; Capture/Compare 3 interrupt enable; 1 bit
	.equ CC2IE,	2	@; Capture/Compare 2 interrupt enable; 1 bit
	.equ CC1IE,	1	@; Capture/Compare 1 interrupt enable; 1 bit
	.equ UIE,	0	@; Update interrupt enable; 1 bit

.equ DIER_CLR_BITMASK, (1<<15)|(1<<13)|(1<<7)|(1<<5) @; bits 15, 13, 7, 5 reserved
	
@; Status Register (SR); 16 bits
.equ SR, 0x10 @;offset

	@; Bit positions within SR
	.equ CC4OF,	12	@; Capture/Compare 4 overcapture flag; 1 bit
	.equ CC3OF,	11	@; Capture/Compare 3 overcapture flag; 1 bit
	.equ CC2OF,	10	@; Capture/Compare 2 overcapture flag; 1 bit
	.equ CC1OF,	9	@; Capture/Compare 1 overcapture flag; 1 bit
	.equ TIF,	6	@; Trigger interrupt flag; 1 bit
	.equ CC4IF,	4	@; Capture/Compare 4 interrupt flag; 1 bit
	.equ CC3IF,	3	@; Capture/Compare 3 interrupt flag; 1 bit
	.equ CC2IF,	2	@; Capture/Compare 2 interrupt flag; 1 bit
	.equ CC1IF,	1	@; Capture/Compare 1 interrupt flag; 1 bit
	.equ UIF,	0	@; Update interrupt flag; 1 bit

.equ SR_CLR_BITMASK, (1<<15)|(1<<14)|(1<<13)|(1<<8)|(1<<7)|(1<<5)


@; Even Generation Reg (EGR); 16 bits
.equ EGR, 0x14
	
	@;Bit positions within EGR
	.equ UG, 	0	@; Update generation; 1 bit

@; Counter (CNT); 16 bits
.equ CNT, 0x24 @;offset

	
@; Prescaler (PSC); 16 bits
.equ PSC, 0x28 @;offset

	
@; Auto-Reload Register (ARR); 16 bits
.equ ARR, 0x2C @; offset

	

	.equ NVIC_ISERbase,0xE000E100		@;Interrupt Set-Enable register base; registers 0-7 at offsets 0-0x1C w step=4 (ref: DDI0439D trm pg 64)
	.equ NVIC_ISER0,NVIC_ISERbase+0		@;Interrupt Set-Enable bits for interrupts 0-31
	.equ NVIC_ISER1,NVIC_ISERbase+4		@;Interrupt Set-Enable bits for interrupts 32-63
	.equ NVIC_IPRbase,0xE000E400		@;Interrupt Priority register base; registers 0-7 at offsets 0-0xEC step=32 (ref: DDI0439D trm pg 64)

	
	