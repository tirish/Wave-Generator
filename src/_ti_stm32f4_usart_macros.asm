@; USART macros

.macro ENABLE_USARTx USARTx_INDEX
	MOV_imm32 r0, (1 << \USARTx_INDEX)
	MOV_imm32 r1, RCC_APB1ENR

	ldr r2, [r1]
	orr r2, r0
	str r2, [r1]
.endm
