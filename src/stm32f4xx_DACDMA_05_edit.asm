@; Code provided by Prof. Hawkins. Minor modifications made by Thomas Irish; Unredacted to original state
@; stm32f4xx_DACDMA_05.asm wmh 2013-12-02 : DMA with interrupt -- working. DMA interrupt performs swtich of buffer pointers. 
@;  - the interrupt routine must check that the correct buffer pointer is being swapped out, otherwise the DMA is automatically
@; disabled.  
@; stm32f4xx_DACDMA_04.asm wmh 2013-12-02 : DMA pre-int -- update ping-pong buffer pointers by pooling terminal count interrupt flag TCIF
@;	- debugging dual-buffer DMA is made difficult by the fact that the code in which the DMA buffer pointers are updated is
@; a critical region wrt to the DMA controller. This is because any attempt to change DMA_SxM0AR/DMA_SxM1AR when that buffer is
@; simultaneously in use by the DMA controller disables the DMA controller (EN=0) and stops the DMA. Hence single-stepping the
@; debugger through such critical region while the DMA is running is certain to violate the non-simultaneous requirement and disable
@; the DMA.  
@; stm32f4xx_DACDMA_03.asm wmh 2013-11-30 : adding DMA to Timer 6/DAC2 initializations -- DMA working using circular double-buffer
@; stm32f4xx_DACDMA_02.asm wmh 2013-11-30 : debugging Timer6 and DAC2 initializations to get working DAC ramp generator
@; - changing Timer6 CR2.MMS=0 to CR2.MMS=2 gave some action from DAC2 (a slow up/down ramp with a hiccup)
@; - changing Timer6 ARR=1000 to ARR=100 increased ramp speed (still slow (~80msec/cycle) because its 2**13 steps for 1 wave, steps at 80kHz.
@;    Timer6 ARR=10 gave a nice triangle wave at about 45 Hz. 
@; - changing DAC DHR12R2 to 0x123 made the wave 'wrap around' at the top (a gap at the top of the trace and a small peak at the bottom)
@; - DAC CR.BOFF2 =0 (DAC2 output buffer _is_ enabled) gives greater amplitude and straighter sides on the triangle wave. 
@; stm32f4xx_DACDMA_01.asm wmh 2013-11-27 : goal -- generate analog output from DAC2 with data from DMA
@; may borrow from example DAC_SignalsGeneration/main.c in STM32F4-Discovery_FW_V1.1.0_stsw-stm32068
@; v01: program a TMR6 to trigger DAC2
@; RM0090 pg 307 fig 54: trigger to generate output can come from several different timers
@; if DMaENx is enabled then DACx will issue a DMA request
@; RM0090 pg 217 : DAC2 is on DMA1 Channel 7 Stream 6 

@; --- characterize target syntax, processor
	.syntax unified				@; ARM Unified Assembler Language (UAL). 
	.thumb						@; Use thumb instructions only


	.bss						@;start an uninitialized RAM data section
	.align						@;pad memory if necessary to align on a word boundary for word storage 
					
	.comm	PINGBUF,256			@;allocate 256 bytes/128 halfwords of static storage for uninitialized global storage			
	.comm	PONGBUF,256			@;allocate 256 bytes/128 halfwords of static storage for uninitialized global storage

	.global PINGPONG_count		@;used by DMAint_svc to determine which buffer will output next
	.comm PINGPONG_count,4
	.global PING_count			@;for debug
	.comm PING_count,4
	.global PONG_count			@;for debug
	.comm PONG_count,4
	
@;	.extern PINGPONG_count

	
@;*** definitions *** 
@;  .include "stm32f4xx_DMA_registers01.inc"			@;moved this to point-of-use to increase clarity 
@;  .include "stm32f4xx_TMR6&7_registers01.inc"			@; ""

@; from DM00031020.pdf Table 2. STM32F4xx register boundary addresses 
  .equ RCC_BASE, 0x40023800
  
@; from DM00031020.pdf Section 6.3 RCC registers (pp 123-)	!!??put these in a .include? 
  .equ RCC_APB1ENR, RCC_BASE+0x40
  .equ RCC_APB1RSTR,RCC_BASE+0x20
  .equ RCC_AHB1ENR,RCC_BASE+0x30
  .equ RCC_AHB1RSTR,RCC_BASE+0x10

 
  .equ GPIOA_BASE, 0x40020000	@; from DM00031020.pdf Table 2. STM32F4xx register boundary addresses 
@; from DM00031020.pdf section 7.4 GPIO registers (pp 198-) and Table 31. GPIO register map and reset values (pp 203--)
  .equ MODER, 0x00	@;!!should redo with 'rel-' prefix
  .equ OTYPER, 0x04
  .equ OSPEEDR, 0x08
  .equ PUPDR, 0x0C
  .equ IDR, 0x10
  .equ ODR, 0x14
  .equ BSRR, 0x18
  .equ LCKR, 0x1C
  .equ AFRL, 0x20
  .equ AFRH, 0x24	
  
@; 
 .equ DAC_BASE, 0x40007400 	@; from DM00031020.pdf Table 2. STM32F4xx register boundary addresses 
@; from DM00031020.pdf Table 57. DAC register map (pg 325)
  .equ DAC_CR,DAC_BASE + 0x00 		@;DAC control register
  .equ DAC_DHR12R1,DAC_BASE + 0x08	@;DAC channel1 12-bit right aligned data holding register 
  .equ DAC_DHR12R2,DAC_BASE + 0x14	@;DAC channel2 12-bit right aligned data holding register 

@;*** macros ***
@; desiderata : 
@;	- no side effects other than scratch registers
@;	- no local pool 'out of range' (i.e. use immediate values)

.macro MOV_imm32 reg val		@;example of use: MOV_imm32 r0,0x12345678 !!note: no '#' on immediate value
	movw \reg,#(0xFFFF & (\val))
	movt \reg,#((0xFFFF0000 & (\val))>>16)
.endm

.macro ORR_imm32 reg val		@;'bit set' -- example of use: ORR_imm32 r0,0x12345678 !!note: no '#' on immediate value	
	orr \reg,#(0x000000FF & (\val) )
	orr \reg,#(0x0000FF00 & (\val) )
	orr \reg,#(0x00FF0000 & (\val) )
	orr \reg,#(0xFF000000 & (\val) )
.endm	

.macro BIC_imm32 reg val		@;'bit clear' -- example of use: BIC_imm32 r0,0x12345678 !!note: no '#' on immediate value	
	bic \reg,#(0x000000FF & (\val) )
	bic \reg,#(0x0000FF00 & (\val) )
	bic \reg,#(0x00FF0000 & (\val) )
	bic \reg,#(0xFF000000 & (\val) )
.endm	

.macro PORTBIT_read GPIOx_BASE bit	@;read 'bit' of port GPIOx, return bit value in bit0 of r0 and 'Z' flag set/clear if bit=0/1
	MOV_imm32 r2,(\GPIOx_BASE)
	ldr r0,[r2,#IDR]
	ands r0,#(1<<\bit)
	lsr r0,#\bit
.endm	

.macro PORTBIT_write GPIOx_BASE bit value	@;set 'bit' of port GPIOx to value {0,1}
	MOV_imm32 r2,(\GPIOx_BASE)
	.ifeq \value	@;must write to upper 16 bits of BSSR to clear the bit
		mov r1,#( 1<<(16+\bit))
	.else			@;write to lower 16 bits of BSSR to set the bit
		mov r1,#( 1<<(\bit))
	.endif
	str r1,[r2,#BSRR]	
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

.macro TST_bit addr bit	@;read 'bit' at addr, return bit value in bit0 of r0 and 'Z' flag set/clear if bit=0/1
	MOV_imm32 r2,(\addr)
	ldr r0,[r2]
	ands r0,#(1<<\bit)
	lsr r0,#\bit
.endm

.equ STD_OUTPIN,0	@;port pin initialization code -- see macro 'PORTBIT_init'
.equ STD_INPIN,1	@; ""
.equ PULLUP_INPIN,2	@; ""

.macro PORTBIT_config bit, GPIOx_BASE, MODE, OTYPE, OSPEED, PUPD, AF

	MOV_imm32 r2,(\GPIOx_BASE)

	ldr r1,[r2,#MODER]
	bic r1,(3 << (2*\bit))
	orr r1,(\MODE << (2*\bit)) 
	str r1,[r2,#MODER]

	ldr r1,[r2,#OTYPER]
	bic r1,(1 << \bit)
	orr r1,(\OTYPE << (1*\bit)) 
	str r1,[r2,#OTYPER]
	
	ldr r1,[r2,#OSPEEDR]
	bic r1,(3 << (2*\bit))
	orr r1,(\OSPEED << (2*\bit))
	str r1,[r2,#OSPEEDR]
                
	ldr r1,[r2,#PUPDR]
	bic r1,(3 << (2*\bit))
	orr r1,(\PUPD << (2*\bit))	
	str r1,[r2,#PUPDR]

	.iflt (\bit - 8) @;use AFRLR for configuration
		ldr r1,[r2,#AFRL]
		bic r1,(0xF << (4*\bit))
		orr r1,(\AF << (4*\bit))	
		str r1,[r2,#AFRL]

	.else @;use AFRH for configuration
		ldr r1,[r2,#AFRH]
		bic r1,(0xF << (4*(\bit-8)))
		orr r1,(\AF << (4*(\bit-8)))	
		str r1,[r2,#AFRH]
	.endif

.endm
	

 
@; --- begin code memory
	.text						@;start the code section

@;*** DAC initialization !!not complete (no DMA)
	.global DAC1_init
	.thumb_func
DAC1_init:
	@;configure PA5 as DAC1_out (note: as an 'Additional function' rather than an 'Alternate Function' DAC does not have an AF code	
	@;				bit,GPIOx_BASE,	MODE,	OTYPE,	OSPEED,	PUPD,	AF
	PORTBIT_config 	4,	GPIOA_BASE,	3,		0,		0,		0,		0		@; mode=3 (analog), PUPD=0 (none). 
	@;configure DAC1 as simple analog out with no DMA or interrupts. 
	MOV_imm32 r2,0x00000001	@;(BOFF1=0 (output buffer enabled) and EN1=1 (DAC channel1 enabled)
	MOV_imm32 r1,DAC_CR
	str r2,[r1]

	bx lr

	.global DAC2_init
	.thumb_func
DAC2_init:
	@;configure PA5 as DAC2_out (note: as an 'Additional function' rather than an 'Alternate Function' DAC does not have an AF code
	@;				bit,GPIOx_BASE,	MODE,	OTYPE,	OSPEED,	PUPD,	AF
	PORTBIT_config 	5,	GPIOA_BASE,	3,		0,		0,		0,		0		@; mode=3 (analog), PUPD=0 (none). 
	@;configure DAC2 as simple analog out with no DMA or interrupts. 
	MOV_imm32 r2,0x00010000	@;BOFF2=0 (output buffer enabled) and EN2=1 (DAC channel2 enabled)
	MOV_imm32 r1,DAC_CR
	str r2,[r1]
	
	bx lr

	.global DAC2_TIM6_DMA1_init
	.thumb_func
DAC2_TIM6_DMA1_init: @;configure DAC2 to be triggered by TIM6, configure PA5 to convey DAC2 output, DMA1 to provide data to DAC2
		
@; --- DAC2 initialization
	@;initial testing -- configure DAC2 as triangle wave generator triggered by Timer 6 (RM0090 pages 317-318) 

	@;enable DAC2-relevant clocks 
	SET_bit RCC_AHB1ENR,0					@;enable clock for GPIOA (DAC2 output on PA.5)	@;RM0090 pg 145
	SET_bit RCC_APB1ENR,29					@;enable clock for DAC

	@;configure PA5 as DAC2_out (note: as an 'Additional function' rather than an 'Alternate Function' DAC does not have an AF code
	@;				bit,GPIOx_BASE,	MODE,	OTYPE,	OSPEED,	PUPD,	AF
	PORTBIT_config 	5,	GPIOA_BASE,	3,		0,		0,		0,		0		@; mode=3 (analog), PUPD=0 (none). 
	
	@;define DAC2 configuration values
	.equ DMAEN2,(1<<28)		@;DAC channel 2 DMA mode enabled
	.equ WAVE2,(0<<22) 		@;wave generation is disabled
	.equ MAMP2,(0xB<<24) 		@; with 12 bits unmasked
	.equ TSEL2,(0<<19) 		@;	triggered by TIM6
	.equ TEN2,(1<<18)			@;trigger is enabled,
	.equ BOFF2,(0<<17) 		@;output buffer is enabled
	.equ EN2,(1<<16) 			@;channel 2 is enabled
	.equ DAC2bits,(0xFFFF0000)	@;location of DAC2 configuration bits in DAC_CR

	MOV_imm32 r1,DAC_CR			@;get current configuration for DAC_CR	!!change .inc so DAC_DR1 is 'absDAC_CR1' etc. 
	ldr r2,[r1]					@; ..
	BIC_imm32 r2,DAC2bits		@;zero out upper 16 bits (DAC2 configuration)
	ORR_imm32 r2,DMAEN2|WAVE2|MAMP2|TSEL2|TEN2|BOFF2|EN2 @;replace with new DAC2 configuration
	str r2,[r1]					@; and save back

@; --- Timer 6 initialization
	.include "stm32f4xx_TMR6&7_registers01.inc"

	SET_bit RCC_APB1ENR,4						@;enable clock for TIM6		@; ""    pg 151

	
	
	@; configure Timer 6 to trigger DAC2 at ___ kHz 
	MOV_imm32 r1,absTIM6_CR1
	mov r2,#(1<<7 | 0 << 3 | 1<<2 | 0<<1 | 1<<0) @;RM0090 pg 527
	strh r2,[r1]
	MOV_imm32 r1,absTIM6_CR2
	mov r2,#(2<<4) 								@;RM0090 pg 528. Making CR2.MMS=2 gave some action from DAC2 (a slow up/down ramp with a hiccup) 
	strh r2,[r1]
	MOV_imm32 r1,absTIM6_DIER
	mov r2,#(1<<8) 								@;RM0090 pg 528
	strh r2,[r1]
	MOV_imm32 r1,absTIM6_PSC
	mov r2,#20 									@;RM0090 pg 530 - 168mHZ/(20+1)=8mHz at the prescaler
	strh r2,[r1]
	MOV_imm32 r1,absTIM6_ARR
	movw r2,#10 								@;RM0090 pg 530 -- 8mHz/10 = 800 kHz clock (!!check if we should use 9). wave is ~50Hz
	strh r2,[r1]
	
	
@;*** DMA1 channel 7 stream 6 (DAC2) initialization
@;follows the procedure described in RM0090 pg 231 "9.3.17 Stream configuration procedure"
	.include "stm32f4xx_DMA_registers01.inc"	
	.equ NVIC_ISERbase,0xE000E100		@;Interrupt Set-Enable register base; registers 0-7 at offsets 0-0x1C w step=4 (ref: DDI0439D trm pg 64)
	.equ NVIC_ISER0,NVIC_ISERbase+0		@;Interrupt Set-Enable bits for interrupts 0-31
	.equ NVIC_IPRbase,0xE000E400		@;Interrupt Priority register base; registers 0-7 at offsets 0-0xEC step=32 (ref: DDI0439D trm pg 64)


	@;restart DMA1 (not described in "Stream configuration procedure" but mentioned in one of the 'Peripherals Examples' 
	SET_bit RCC_AHB1ENR,21					@;enable clock for DMA1		@;RM0090 pg 145
	SET_bit RCC_AHB1RSTR,21					@;reset DMA1				@;RM0090 pg 132
	CLR_bit RCC_AHB1RSTR,21					@;end DMA1 reset			@;RM0090 pg 132

	@;step 1 of "Stream configuration procedure" -- turn off enable (EN)
1:	CLR_bit absDMA1_S6CR,0		@;attempt clearing EN bit 
	TST_bit absDMA1_S6CR,0		@;was it cleared?
	bne 1b						@; keep trying until succeed (EN cleared) !!might hang
	
	@;step 2 of "Stream configuration procedure" -- set the peripheral port register address
	MOV_imm32 r1,DAC_DHR12R2	@;DAC2 data register we want DMA data to be written to DAC2
	MOV_imm32 r2,absDMA1_S6PAR	@;where DMA1 will send its data
	str r1,[r2]

	@;step 3 of "Stream configuration procedure" -- set the memory address in DMA_S6MA0R and DMA_S6MA1R
	ldr r1,=PING_buf		@;first of two buffers which supply the data to be written to DAC2
	MOV_imm32 r2,absDMA1_S6M0AR	@;first buffer where DMA1 will get its data
	str r1,[r2]
	ldr r1,=PONG_buf		@;second of two buffers which supply the data to be written to DAC2
	MOV_imm32 r2,absDMA1_S6M1AR	@;second buffer where DMA1 will get its data
	str r1,[r2]

	.extern asm_ENTRIES_PER_BUF
	@;step 4 of "Stream configuration procedure" -- configure the total number of data items to be transferred (??16 or 32?)
	MOV_imm32 r2,absDMA1_S6NDTR	@;holds number of data to transfer
	@;mov r1,#16					@;16 half-words in a buffer (thre are two buffers but I think NDTR refers to the size of one)
	ldr r1, =asm_ENTRIES_PER_BUF
	ldr r1, [r1]
	str r1,[r2]
	
	@;steps 5 through 9 of "Stream configuration procedure" -- control register (DMA1_S6CR) settings
	@;DMA1_S6CR settings (ref RM0090 "9.5.5 DMA stream x configuration register")
	.equ CHSEL,		(7<<25)	@;channel=7: DAC2 is channel 7, stream 6 (RM0090 Table 33. DMA1 request mapping)
	.equ MBURST,	(0<<23)	@;single transfer from memory
	.equ PBURST,	(0<<21)	@;single-transfer to peripheral 
	.equ CT,		(0<<19)	@;current target of transfer is first buffer		
	.equ DBM,		(1<<18)	@;enable double buffer mode -- memory target switched at end of transfer
	.equ PL,		(0<<16)	@;DMA priority level -- lowest
	.equ PINCOS,	(0<<15)	@;peripheral increment -- none
	.equ MSIZE,		(1<<13)	@;memory data size = half-word
	.equ PSIZE,		(1<<11)	@;peripheral data size = half-word
	.equ MINC,		(1<<10)	@;memory address pointer increments 1 MSIZE per transfer
	.equ PINC,		(0<<9)	@;peripheral address pointer does not increment
	.equ CIRC,		(1<<8)	@;circular mode is enabled -- in reality this is 'don't care' when DBM=1
	.equ DIR,		(1<<6)	@;transfer direction is memory to peripheral
	.equ PFCTRL,	(0<<5)	@;DMA is the flow controller (necessary to get circular and/or double buffer?)
	.equ TCIE,		(1<<4)	@;transfer-complete interrupt is enabled
	.equ HTIE,		(0<<3)	@;half-transfer interrupt is disabled
	.equ TEIE,		(0<<2)	@;transfer-error interrupt is disabled
	.equ DMEIE,		(0<<1)	@;direct-mode-error interrupt is disabled
	.equ EN,		(0<<0)	@;stream enable = 0 while changing CR bits as protection 
	.equ DMA1_S6CR_settings,CHSEL|MBURST|PBURST|CT|DBM|PL|PINCOS|MSIZE|PSIZE|MINC|PINC|CIRC|DIR|PFCTRL|TCIE|HTIE|TEIE|DMEIE|EN
	MOV_imm32 r1,(DMA1_S6CR_settings)
	MOV_imm32 r2,absDMA1_S6CR
	str r1,[r2]

	@;extra step added to "Stream configuration procedure" -- uses direct mode (no fifo)  
	CLR_bit absDMA1_S6FCR,2		@;clear DMDIS bit of absDMA1_S6FCR for direct mode (no fifo) 

	@;extra step added for DMAint demo to keep track of how many times we've updated the ping-pong buffer addresses
	mov r1,#0
	ldr r2,=PINGPONG_count		@;initialize number of alternations between DMA buffers which have occurred
	str r1,[r2]
	ldr r2,=PING_count			@;initialize number of times PING buffer has been updated
	str r1,[r2]
	ldr r2,=PONG_count			@;initialize number of times PONG buffer has been updated
	str r1,[r2]

	@;extra step added to enable DMA interrupt in the NVIC
	mov r1,#(1<<17)				@;enable bit for DMA1 stream6 at interrupt position 17 (RM0090 pg 249)
	MOV_imm32 r2,NVIC_ISER0		@;interrupt enable register for interrupt 0-31
	str r1,[r2]

	@;step 10 of "Stream configuration procedure" -- set CR bit 0 (=enable bit 'EN') 
	MOV_imm32 r1,(DMA1_S6CR_settings | 1<<0)
	MOV_imm32 r2,absDMA1_S6CR
	str r1,[r2]

	bx lr


	
	@;new
	@; defined in _waves.h
	.extern PING_buf
	.extern PONG_buf
	
	
	.global DMAint_svc	@;void DMAint_scv(void)
	.thumb_func
DMAint_svc: @;copy DMADEMO_PINGBUF or DMADEMO_PONGBUF (above) into DMA1_PINGBUF and DMA1_PONGBUF in RAM (at top)

	.equ locTCIF6,	21	@;location of DMA stream 6  interrupt flag in DMA1_HISR _and_ location in DMA1_HIFCR to clear this flag
	.equ locHTIF6,	20	@; ""          				half-buffer interrupt flag  	""
	.equ locTEIF6,	19	@; ""          				transfer error interrupt flag 	 ""
	.equ locDMEIF6,	18	@; ""                       direct mode error interrupt  flag ""
	.equ locFEIF6,	16	@; ""                       fifo error interrupt flag          ""
	.equ locCT,		19	@;location of 'current target' (CT) status bit in DMA1 stream 6 control register DMA1_S6CR
	
	
	@;update PINGPONG_count
	ldr r2,=PINGPONG_count				@;
	ldr r1,[r2]							@; ..
	add r1,#1							@; ..
	str r1,[r2]							@; ..

	
	
	@;first version polls TCIF6 to detect switch between buffer, then copies new data into currently not-selected buffer
	TST_bit	absDMA1_HISR,locTCIF6		@;did a buffer swap occur
	beq 9f								@;	no -- noting to do, so go back
	
	@;here if DMA has switched to the other buffer
	SET_bit absDMA1_HIFCR,locTCIF6		@;reset the interrupt flag
	TST_bit absDMA1_S6CR,locCT			@;is buffer 0 now being processed?
	beq 2f								@;	yes -- so go update buffer 1

1:	@;here when its buffer 0's turn to have its address updated (ok because buffer1 is currently being used by DMA)

	@;!!testing only : set EXTI0 interrupt request fro each DMA transfer, confirm EXTI0 operation by matching EXTI0_count to PING_count
@;	.equ EXTIbase,0x40013C00			@;(RM0090 pg 54)
@;	.equ EXTI_SWIER,(EXTIbase+0x10)		@;software interrupt event  -- set bit 0 to trigger EXTI0 SWI (RM0090 pg 260) 
@;	ldr r2,=EXTI_SWIER					@;setting EXTI0 bit will generate an interrupt when priority falls 
@;	mov r1,#1							@;..
@;	str r1,[r2]							@;..


	@;debug -- count number of times we update 'ping' buffer
	ldr r2,=PING_count					@;update count of number of switches between DMA buffers which have occurred
	ldr r1,[r2]							@; ..
	add r1,#1							@; ..
	str r1,[r2]							@; ..

	@; ping buf
	ldr r1,=PING_buf				
	MOV_imm32 r2,absDMA1_S6M0AR			
	str r1,[r2]
	MOV_imm32 r0, 1						@; return 1 to indicate populate PING
	bx lr
	
	
2: 	@;here when it's buffer 1's turn to have its address updated (ok because buffer0 is currently being used by DMA)

	@;debug -- count number of times we update 'pong' buffer
	ldr r2,=PONG_count					@;update count of number of switches between DMA buffers which have occurred
	ldr r1,[r2]							@; ..
	add r1,#1							@; ..
	str r1,[r2]							@; ..


	ldr r1,=PONG_buf			
	MOV_imm32 r2,absDMA1_S6M1AR			
	str r1,[r2]
	MOV_imm32 r0, 2						@; return 2 to indicate populate PONG
	bx lr

	
9:	@;here when terminal count interrupt flag TCIF was not set ==> nothing to do

	MOV_imm32 r0, 0						@; return 0 to indicate do nothing
	bx lr
	
	
	
	
	@; new stuff added
	
	
	.global TIM6_Set_PSC
	.thumb_func
TIM6_Set_PSC:
	MOV_imm32 r1,absTIM6_PSC
	strh r0,[r1]
	bx lr
	
	.global TIM6_Set_ARR
	.thumb_func
TIM6_Set_ARR:
	MOV_imm32 r1,absTIM6_ARR
	strh r0,[r1]
	bx lr
	
	
	.global TIM6_Get_PSC
	.thumb_func
TIM6_Get_PSC:
	MOV_imm32 r1,absTIM6_PSC
	ldrh r0,[r1]
	bx lr
	
	.global TIM6_Get_ARR
	.thumb_func
TIM6_Get_ARR:
	MOV_imm32 r1,absTIM6_ARR
	ldrh r0,[r1]
	bx lr
	
	
	.global TIM6_Enable
	.thumb_func
TIM6_Enable:
	SET_bit RCC_APB1ENR,4						@;enable clock for TIM6		@; ""    pg 151
	bx lr
	
	.global TIM6_Disable
	.thumb_func
TIM6_Disable:
	CLR_bit RCC_APB1ENR,4						@;enable clock for TIM6		@; ""    pg 151
	bx lr
	
	
	.global TIM6_Unpause
	.thumb_func
TIM6_Unpause:
	SET_bit absTIM6_CR2, 0	@; CEN
	CLR_bit absTIM6_CR2, 1	@; UDIS
	bx lr
	
	.global TIM6_Pause
	.thumb_func
TIM6_Pause:
	CLR_bit absTIM6_CR2, 0	@; CEN
	SET_bit absTIM6_CR2, 1	@; UDIS
	bx lr
	
	.global TIM6_Update
	.thumb_func
TIM6_Update:
	SET_bit absTIM6_EGR, 0						
	bx lr	
	
		
	
	
	.align @;data tables for DMA/DAC example
DMADEMO_PINGBUF:	@;original buffer with up-ramp of triangle wave
DMADEMO_PINGBUF0:	@;alternate name (so we don't break earlier code
	.hword 0x000,0x100,0x200,0x300,0x400,0x500,0x600,0x700,0x800,0x900,0xA00,0xB00,0XC00,0xD00,0XE00,0xF00	@;up ramp, 16 entries
DMADEMO_PONGBUF:	@;original buffer with down-ramp of triangle wave
DMADEMO_PONGBUF0:	@;alternate name (so we don't break earlier code
	.hword 0xFFF,0xEFF,0xDFF,0xCFF,0xBFF,0xAFF,0x9FF,0x8FF,0x7FF,0x6FF,0x5FF,0x4FF,0x3FF,0x2FF,0x1FF,0x0FF	@;down ramp, 16 entries, 12 bits each; 192 bits total

DMADEMO_PINGBUF1:	@;new buffer with first half (positive step) of square wave
	.hword 0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0xFFF,0xFFF,0xFFF,0xFFF,0xFFF,0xFFF,0xFFF,0xFFF	@;+step, 16 entries
DMADEMO_PONGBUF1:	@;new buffer with second half (negative step) of square wave
	.hword 0xFFF,0xFFF,0xFFF,0xFFF,0xFFF,0xFFF,0xFFF,0xFFF,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000	@;-step, 16 entries
