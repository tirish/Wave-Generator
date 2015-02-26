@;SimpleStartSTM32F4_03.asm wmh 2013-11-01 : redirect SvcHandler, PendSV_Handler, and SysTick_Handler to real routines defined elsewhere
@;SimpleStartSTM32F4_02.asm wmh 2013-11-01 : add STM32F4xx PLL/clock initializations
@;SimpleStartSTM32F4_01.asm wmh 2013-02-03 : adaptation of LPC1768 startup for STM32F04
@; -todo: fix stuff with !! markers
@;SimpleStartLPC1768_02.s wmh 2011-11-10 startup code for NXP LPC1768
@; adapted from http://embeddedfreak.wordpress.com/2009/08/09/cortex-m3-blinky-in-assembly
@; with additions from http://tech.munts.com/MCU/Frameworks/ARM/lpc17xx/ 
 
/* Simple startup file for Cortex-M3 */

 .extern SysTick_Handler
 .extern SVC_Handler
 .extern SvcHandler_ASM
 .extern PendSV_Handler
 .extern PENDSV_ASM
 .extern TIM3_Handler
 .extern TIM4_Handler
 .extern DMA_Handler
 .extern USART2_Handler
  
 .syntax unified	@; to allow thumb-2 instruction set

@; Source: Table 62, pg 372
 @; --- Vector table definition
 .section ".cs3.interrupt_vector"
 .long  __cs3_stack                 /* Top of Stack                 */
 .long  Reset_Handler               /* Reset Handler                */
 .long  NMI_Handler                 /* NMI Handler                  */
 .long  HardFault_Handler           /* Hard Fault Handler           */
 .long  MemManage_Handler           /* MPU Fault Handler            */
 .long  BusFault_Handler            /* Bus Fault Handler            */
 .long  UsageFault_Handler          /* Usage Fault Handler          */
 .long  0                           /* Reserved                     */
 .long  0                           /* Reserved                     */
 .long  0                           /* Reserved                     */
 .long  0                           /* Reserved                     */
 .long  SvcHandler_ASM                  /* SVCall Handler               */
 .long  DebugMon_Handler            /* Debug Monitor Handler        */
 .long  0                           /* Reserved                     */
 .long  PENDSV_ASM              /* PendSV Handler               */
 .long  SysTick_Handler             /* SysTick Handler              */

 .long 0 				/*interrupt 0*/
 .long 0 				/*interrupt 1*/
 .long 0 				/*interrupt 2*/
 .long 0 				/*interrupt 3*/
 .long 0 				/*interrupt 4*/
 .long 0 				/*interrupt 5*/
 .long EXTI0_svc 				/*interrupt 6 : EXTI line 0 */
 .long 0				/*interrupt 7*/
 .long 0 				/*interrupt 8*/
 .long 0 				/*interrupt 9*/
 .long 0 				/*interrupt 10*/
 .long 0 				/*interrupt 11*/
 .long 0 				/*interrupt 12*/
 .long 0 				/*interrupt 13*/
 .long 0 				/*interrupt 14*/
 .long 0 				/*interrupt 15*/
 .long 0 				/*interrupt 16*/
 .long DMA_Handler 				/*interrupt 17 : DMA1_Stream6*/
 .long 0 				/*interrupt 18*/
 .long 0 				/*interrupt 19*/
 .long 0 				/*interrupt 20*/
 .long 0 				/*interrupt 21*/
 .long 0 				/*interrupt 22*/
 .long 0 				/*interrupt 23*/
 .long 0 				/*interrupt 24*/
 .long 0 				/*interrupt 25*/
 .long 0 				/*interrupt 26*/
 .long 0 				/*interrupt 27*/
 .long 0 				/*interrupt 28*/
 .long TIM3_Handler 				/*interrupt 29 : TIM3*/
 .long TIM4_Handler 				/*interrupt 30 : TIM3*/
 .long 0 				/*interrupt 31*/
 .long 0 				/*interrupt 32*/
 .long 0 				/*interrupt 33*/
 .long 0 				/*interrupt 34*/
 .long 0 				/*interrupt 35*/
 .long 0 				/*interrupt 36*/
 .long 0 				/*interrupt 37*/
 .long USART2_Handler 				/*interrupt 38 : USART 2*/
 .long 0 				/*interrupt 39*/
 .long 0 				/*interrupt 40*/
 .long 0 				/*interrupt 41*/
 .long 0 				/*interrupt 42*/
 .long 0 				/*interrupt 43*/
 .long 0 				/*interrupt 44*/
 .long 0 				/*interrupt 45*/
 .long 0 				/*interrupt 46*/
 .long 0 				/*interrupt 47*/
 .long 0 				/*interrupt 48*/
 .long 0 				/*interrupt 49*/
 .long 0 				/*interrupt 50*/
 .long 0 				/*interrupt 51*/
 .long 0 				/*interrupt 52*/
 .long 0 				/*interrupt 53*/
 .long 0 				/*interrupt 54*/
 .long 0 				/*interrupt 55*/
 .long 0 				/*interrupt 56*/
 .long 0 				/*interrupt 57*/
 .long 0 				/*interrupt 58*/
 .long 0 				/*interrupt 59*/
 .long 0 				/*interrupt 60*/
 .long 0 				/*interrupt 61*/
 .long 0 				/*interrupt 62*/
 .long 0 				/*interrupt 63*/
 .long 0 				/*interrupt 64*/
 .long 0 				/*interrupt 65*/
 .long 0 				/*interrupt 66*/
 .long 0 				/*interrupt 67*/
 .long 0 				/*interrupt 68*/
 .long 0 				/*interrupt 69*/
 .long 0 				/*interrupt 70*/
 .long 0 				/*interrupt 71*/
 .long 0 				/*interrupt 72*/
 .long 0 				/*interrupt 73*/
 .long 0 				/*interrupt 74*/
 .long 0 				/*interrupt 75*/
 .long 0 				/*interrupt 76*/
 .long 0 				/*interrupt 77*/
 .long 0 				/*interrupt 78*/
 .long 0 				/*interrupt 79*/
 .long 0 				/*interrupt 80*/
 .long 0 				/*interrupt 81*/
 .long 0 				/*interrupt 82*/
 .long 0 				/*interrupt 83*/
 .long 0 				/*interrupt 84*/
 .long 0 				/*interrupt 85*/
 .long 0 				/*interrupt 86*/
 .long 0 				/*interrupt 87*/
 .long 0 				/*interrupt 88*/
 .long 0 				/*interrupt 89*/
 .long 0 				/*interrupt 90*/

 
@; Vendor hardware-specific interrupts go here (Not implemented)
 
@; --- hardware reset routine
	.text					@; start the reset code section

	.global Reset_Handler	@; export label name to all modules 
	.thumb_func 			@; identify target type to linker
Reset_Handler:				@; @; start-from-reset code; initialize hardware and system data, launch main()
	@; copy .data section (initialized data) from flash to RAM (currently we must do this in each source file)
	@; (!!todo: figure out how we can get the compiler/asembler/linker to place constants in .rodata, etc)
copy_data:	
	ldr r1, DATA_BEG
	ldr r2, TEXT_END
	ldr r3, DATA_END
	subs r3, r3, r1			@; length of initialized data
	beq zero_bss			@; skip if none
copy_data_loop: 
	ldrb r4,[r2], #1		@; read byte from flash
	strb r4, [r1], #1  		@; store byte to RAM
	subs r3, r3, #1  		@; decrement counter
	bgt copy_data_loop		@; repeat until done

	@; zero out .bss section (uninitialized data) (currently we must do this in each source file)
	@; (!!todo: figure out how to get the linker to give us the extents of the merged .bss sections)
zero_bss: 	
	ldr r1, BSS_BEG
	ldr r3, BSS_END
	subs r3, r3, r1			@; Length of uninitialized data
	beq initRCC				@; Skip if none
	mov r2, #0				@; value to initialize .bss with
zero_bss_loop: 	
	strb r2, [r1],#1		@; Store zero
	subs r3, r3, #1			@; Decrement counter
	bgt zero_bss_loop		@; Repeat until done

initRCC:	
	@; necessary hardware stuff -- replaces SystemCoreClockUpdate() function call in main()
	@;now called in main()

	@exit to main (wont return)
call_main:	
	mov	r0, #0				@; argc=0
	mov r1, #0				@; argv=NULL
	bl	main 				@; gone
	b .						@; trap if return

	@; pointer data for 'copy_data' and 'zero_bss' functions 
TEXT_END:	.word	__sidata	@; __text_end__
DATA_BEG:	.word	__sdata		@; __data_beg__
DATA_END:	.word	__edata		@; __data_end__
BSS_BEG:	.word	__sbss		@; __bss_beg__ 
BSS_END:	.word	__ebss		@; __bss_end__


/* This is how the lazy guy doing it: by aliasing all the
 * interrupts into single address
 */
	.thumb_func
BogusInt_Handler:
	.thumb_func
NMI_Handler:
	.thumb_func
HardFault_Handler:
	.thumb_func
MemManage_Handler:
	.thumb_func
BusFault_Handler:
	.thumb_func
UsageFault_Handler:
	.thumb_func
SvcHandler:@;remove; now going to the one defined in stm32f4xx_SYSINT_xx.asm
	.thumb_func
DebugMon_Handler:
	.thumb_func
PendSV_Handler:@;remove
	.thumb_func
@;DMAint_svc:@;remove
	.thumb_func
EXTI0_svc: @;remove
@; SysTick_Handler: now going to the one defined in main()
	bx  r14	 /* put a breakpoint here when we're debugging so we can trap here but then return to interrupted code */
 
 