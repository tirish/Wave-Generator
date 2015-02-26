@; SVC & PendSV
@; code



.equ SVC_PRIO, 0x20		@; high
.equ PSV_PRIO, 0xf0		@; low

@; Following code from stm32f4xx_SYSINT_03.asm
@; some adapted/modified

@;SvcHandler interrupt hardware setup. !!Must also edit IRQ vector table 
	.global SvcHandler_init_ASM
	.thumb_func
SvcHandler_init_ASM: 	
	@;establish SVC priority
	MOV_imm32 r0, SVC_PRIO
	MOV_imm32 r3,SvcHandler_PR	@;byte-address of SVC priority register
	and r0,0xF0					@;only upper 4 bits of STM32F407 priority are used
	strb r0,[r3]				@;
	
	bx lr

	
	.extern SVC_Handler
	
	@; Get SVC # and return
	.global SvcHandler_ASM
	.thumb_func
SvcHandler_ASM: 	
	ldr r1,[sp,#24]			@;r1 gets program counter where SVC call was issued	
	ldrb r0,[r1,#-2]		@;r0 has SVC #num in low byte -- !!usually we dispatch something based on this value, but for the demo we just display it
	uxtb r0,r0				@; turn it into an int 
	
	ldr r1,=SVC_Handler	@; finish in C
	bx r1
	
	bx lr					@;automatic restore context and stack and resume program


@;PendSV interrupt hardware setup. !!Must also edit IRQ vector table 
	.global PendSV_init_ASM
	.thumb_func
PendSV_init_ASM: 	@;void PendSV_init(int priority); //configure PendSV interrupt with 0x00<priority<0xF0 (low four bits are ignored)
@;PendSV priority should be lowest (highest numerical) so it only occurs if no other interrupts are running
	MOV_imm32 r0, PSV_PRIO
	@;establish SVC priority
	MOV_imm32 r3,PendSV_PR		@;byte-address of SVC priority register
	and r0,0xF0					@;only upper 4 bits of STM32F407 priority are used
	strb r0,[r3]				@;
	
	bx lr


@; end of code from stm32f4xx_SYSINT_03.asm

	.extern PendSV_Handler

	.global PENDSV_ASM
	.thumb_func
PENDSV_ASM:
	ldr r1,=PendSV_Handler	@; finish in C
	bx r1



	.global Set_PendSV_Flag
	.thumb_func
Set_PendSV_Flag:
	@;set PendSV
	
	SET_bit ICSR, PENDSVSET
	bx lr
	
	ldr r1,=ICSR			@;Interrupt Control and State Register
	mov r0,(1<<PENDSVSET)	@;PendSV set bit 	
	str r0,[r1]
	bx lr

	.global Clear_PendSV_Flag
	.thumb_func
Clear_PendSV_Flag:
	@;clear pendsv
	
	SET_bit ICSR, PENDSVCLR
	bx lr
	
	ldr r1,=ICSR			@;Interrupt Control and State Register
	mov r0,(1<<PENDSVCLR)	@;PendSV set bit 	
	str r0,[r1]
	bx lr
