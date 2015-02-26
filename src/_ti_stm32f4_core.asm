@; Thomas Irish
@; CORE

@; --- characterize target syntax, processor
	.syntax unified				@; ARM Unified Assembler Language (UAL). 
								@; Code written using UAL can be assembled 
								@; for ARM, Thumb-2, or pre-Thumb-2 Thumb
	.thumb						@; Use thmb instructions only

	
	
.bss @; (uninitialized)

	


@; --- begin code memory
.text						@;start the code section



@; General Dependencies
.include "_ti_stm32f4_gen_macros.asm"
.include "_ti_stm32f4_gen_funcs.asm"

@; IO Dependencies
.include "_ti_stm32f4_io_constants.asm"
.include "_ti_stm32f4_io_macros.asm"
.include "_ti_stm32f4_io_funcs.asm"


@; TIM (2-5) dependencies
.include "_ti_stm32f4_tim_constants.asm"
.include "_ti_stm32f4_tim_macros.asm"
.include "_ti_stm32f4_tim_funcs.asm"

@; USART
.include "_ti_stm32f4_usart_constants.asm"
.include "_ti_stm32f4_usart_macros.asm"
.include "_ti_stm32f4_usart_funcs.asm"


@; SVC & PendSV
.include "_ti_stm32f4_svcpendsv_constants.asm"
.include "_ti_stm32f4_svcpendsv_funcs.asm"

.include "_ti_stm32f4_svccalls.asm"

@; Wave forms
.include "_ti_stm32f4_waves.asm"
