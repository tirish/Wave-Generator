@;stm32f4xx_TMR6&7_registers01.inc wmh 2013-11-27 : absolute and relative TMR6,TMR7 register addresses 
@; derived from ST RM0090 reference manual DM00031020.pdf pages 55,531

.equ TIM6_base		,0x40001000 
.equ TIM7_base		,0x40001400

.equ relTIMx_CR1	,0x00 
.equ relTIMx_CR2	,0x04 
.equ relTIMx_DIER	,0x0C 
.equ relTIMx_SR		,0x10 
.equ relTIMx_EGR	,0x14 
.equ relTIMx_CNT	,0x24 
.equ relTIMx_PSC	,0x28 
.equ relTIMx_ARR	,0x2C

.equ  absTIM6_CR1	,TIM6_base+0x00 
.equ  absTIM6_CR2	,TIM6_base+0x04 
.equ  absTIM6_DIER	,TIM6_base+0x0C 
.equ  absTIM6_SR	,TIM6_base+0x10 
.equ  absTIM6_EGR	,TIM6_base+0x14 
.equ  absTIM6_CNT	,TIM6_base+0x24 
.equ  absTIM6_PSC	,TIM6_base+0x28 
.equ  absTIM6_ARR	,TIM6_base+0x2C

.equ  absTIM7_CR1	,TIM7_base+0x00 
.equ  absTIM7_CR2	,TIM7_base+0x04 
.equ  absTIM7_DIER	,TIM7_base+0x0C 
.equ  absTIM7_SR	,TIM7_base+0x10 
.equ  absTIM7_EGR	,TIM7_base+0x14 
.equ  absTIM7_CNT	,TIM7_base+0x24 
.equ  absTIM7_PSC	,TIM7_base+0x28 
.equ  absTIM7_ARR	,TIM7_base+0x2C
