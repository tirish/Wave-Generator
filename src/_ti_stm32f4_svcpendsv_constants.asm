@; SVC & PendSV
@; Constants


	@;registers used for SysTick, SVC, and PendSV initializations, drawn from DDI0439 and DDI0403D
	.equ SCR,0xE000ED10			@;System Control Register
	.equ CCR,0xE000ED14			@;Configuration and Control Register.
	.equ SHPR1,0xE000ED18		@;System Handler Priority Register 1
	.equ SHPR2,0xE000ED1C		@;System Handler Priority Register 2
	.equ SHPR3,0xE000ED20		@;System Handler Priority Register 3
	.equ SHCSR,0xE000ED24		@;System Handler Control and State Register

	
	.equ ICSR,0xE000ED04		@;Interrupt Control and State Register
	.equ PENDSVSET,28			@; bit location in ICSR to set PendSV interrupt pending
	.equ PENDSVCLR,27			@; ""					 clear PendSV ""
	
	.equ SysTick_PR,SHPR3+3		@;DDI0403D section B3.2.12
	.equ PendSV_PR,SHPR3+2		@; ""
	.equ SvcHandler_PR,SHPR2+3	@;DDI0403D section B3.2.11
	
	