@; USART code




	.global USART2_init
	.thumb_func
USART2_init:

	@; Setup pins
	ENABLE_GPIOx GPIOA_INDEX					@;enable clock for GPIOA
	
	PORTBIT_init ALT_PIN, GPIOA_BASE, 3	@;RX
	PORTBIT_init ALT_PIN, GPIOA_BASE, 2	@;TX
	
	
	@; setup alternative mode
	SET_GPIOx_REG AFR1, GPIOA_BASE, 3, 7, 4
	SET_GPIOx_REG AFR1, GPIOA_BASE, 2, 7, 4
	
	
	@; Enable USART2
	
	ENABLE_USARTx USART2_Index
	
	@; Enable USART2 in NVIC
	
	@; NVIC stuff (doesn't set priority, only enables)
	mov r1,#(1<<(USART2_NVIC_NUM-32))
	MOV_imm32 r2,NVIC_ISER1		
	str r1,[r2]
	
	@; Configure USART2
	
	@; enable CTS/RTS
	@; 1 stop bit
	@; 8 data bits
	@; no parity
	@; baud rate = 9600 : USARTDIV = 104.1666667 : Mantissa = 104 : Fraction = 3 -> 2.666/16 = .16667
	@; enable both RX and TX
	@; interrupt enable
	

	
	.equ USART2_CR1_Settings, (1<<UE)|(0<<M)|(0<<PCE)|(0<<TXEIE)|(1<<RXNEIE)|(1<<TE)|(1<<RE)
	.equ USART2_CR2_Settings, (0x00<<STOP)
	.equ USART2_CR3_Settings, 0@;(1<<CTSIE)|(1<<CTSE)|(1<<RTSE)
	
	
	.equ USART2_DIV_Mantissa, 104
	.equ USART2_DIV_Fraction, 3
	.equ USART2_BRR_Settings, (USART2_DIV_Mantissa<<DIV_Mantissa)|(USART2_DIV_Fraction<<DIV_Fraction)
	
	MOV_imm32 r0, USART2_Base
	
	MOV_imm32 r1, USARTx_CR1
	MOV_imm32 r2, USART2_CR1_Settings
	str r2, [r0, r1] @; store CR1 settings
	
	MOV_imm32 r1, USARTx_CR2
	MOV_imm32 r2, USART2_CR2_Settings
	str r2, [r0, r1] @; store CR2 settings
	
	MOV_imm32 r1, USARTx_CR3
	MOV_imm32 r2, USART2_CR3_Settings
	str r2, [r0, r1] @; store CR3 settings
	
	MOV_imm32 r1, USARTx_BRR
	MOV_imm32 r2, USART2_BRR_Settings
	str r2, [r0, r1] @; store BRR settings
	
	
	
	bx lr
	
	
	
	.global USART2_Transmitter_Enable
	.thumb_func
USART2_Transmitter_Enable:

	@;SET_bit (USART2_Base+USARTx_CR1), TE		@; enable
	SET_bit (USART2_Base+USARTx_CR1), TXEIE		@; INT enable
	
	bx lr
	
	
	
	.global USART2_Transmitter_Disable
	.thumb_func
USART2_Transmitter_Disable:

	@;CLR_bit (USART2_Base+USARTx_CR1), TE		@; disable
	CLR_bit (USART2_Base+USARTx_CR1), TXEIE		@; INT disable
	
	bx lr
	
	
	.global USART2_Receiver_Enable
	.thumb_func
USART2_Receiver_Enable:

	SET_bit (USART2_Base+USARTx_CR1), RE		@; enable
	SET_bit (USART2_Base+USARTx_CR1), RXNEIE	@; INT enable
	
	bx lr
	
	.global USART2_Receiver_Disable
	.thumb_func
USART2_Receiver_Disable:

	CLR_bit (USART2_Base+USARTx_CR1), RE		@; disable
	CLR_bit (USART2_Base+USARTx_CR1), RXNEIE	@; INT disable
	
	bx lr
	
	
	.global USART2_Read_SR
	.thumb_func
USART2_Read_SR:
	MOV_imm32 r1, USART2_Base
	MOV_imm32 r2, USARTx_SR
	ldr r0, [r1, r2]
	bx lr
	
	
	
	.global USART2_Read_Data
	.thumb_func
USART2_Read_Data:
	MOV_imm32 r1, USART2_Base
	MOV_imm32 r2, USARTx_DR
	ldr r0, [r1, r2]
	bx lr
	
	.global USART2_Write_Data
	.thumb_func
USART2_Write_Data:
	MOV_imm32 r1, USART2_Base
	MOV_imm32 r2, USARTx_DR
	str r0, [r1, r2]
	bx lr