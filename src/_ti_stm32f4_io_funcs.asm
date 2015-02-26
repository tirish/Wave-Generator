@; Thomas Irish
@; IO - Functions

@; Anode & Cathode Pin ports
@;19_PC5	PC5/CA_A+LED5/COLON
@;21_PB1	PB1/CA_B+LED6/DIGIT4
@;11_PA1	PA1/CA_C+LED1/DIGIT2
@;76_PB5	PB5/CA_D/
@;35_PB11	PB11/CA_E/AN_R
@;10_PC2	PC2/CA_F+LED4/DIGIT1
@;20_PC4	PC4/CA_G+LED2/DIGIT3
@;22_PB0	PB0/CA_DP+LED3/AN_G

@;84_PD2	PD2/CA_CLK
@;07_PC1	PC1/CA_EN

@;88_PC11	PC11/AN_CLK
@;75_PB4	PB4/AN_EN


	@; Enable IO pin for use in Trigger-Mode
	.global TRIG_PIN_init
	.thumb_func
TRIG_PIN_init:
	ENABLE_GPIOx TRIG_GPIO_BASE
	PORTBIT_init PULLUP_INPIN,TRIG_GPIO_BASE,TRIG_PIN_NUM
	bx lr
	
	
	@; Read IO pin for use in Trigger-Mode
	.global TRIG_PIN_read
	.thumb_func
TRIG_PIN_read:
	PORTBIT_read TRIG_GPIO_BASE,TRIG_PIN_NUM
	bx lr
	



	.global ST_P24DISPLAY_init		@;void ST_P24DISPLAY_init(void);	//initialize ST32F4 pins controlling P24 display pins
	.thumb_func
ST_P24DISPLAY_init:							@;using identifications from 'P24v04r16pins.xls'
	@; ENABLE_GPIOx GPIOx_INDEX
	ENABLE_GPIOx GPIOA_INDEX					@;enable clock for GPIOA
	ENABLE_GPIOx GPIOB_INDEX					@;enable clock for GPIOB
	ENABLE_GPIOx GPIOC_INDEX					@;enable clock for GPIOC
	ENABLE_GPIOx GPIOD_INDEX					@;enable clock for GPIOD
	
	@; PORTBIT_init CONFIG GPIOx_BASE PIN
	PORTBIT_init STD_OUTPIN,GPIOC_BASE,5
	PORTBIT_init STD_OUTPIN,GPIOB_BASE,1
	PORTBIT_init STD_OUTPIN,GPIOA_BASE,1
	PORTBIT_init STD_OUTPIN,GPIOB_BASE,5
	PORTBIT_init STD_OUTPIN,GPIOB_BASE,11
	PORTBIT_init STD_OUTPIN,GPIOC_BASE,2
	PORTBIT_init STD_OUTPIN,GPIOC_BASE,4
	PORTBIT_init STD_OUTPIN,GPIOB_BASE,0
	
	PORTBIT_init STD_OUTPIN,GPIOD_BASE,2
	PORTBIT_init STD_OUTPIN,GPIOC_BASE,1
	
	PORTBIT_init STD_OUTPIN,GPIOC_BASE,11	@;	88_PC11	PC11/AN_CLK
	PORTBIT_init STD_OUTPIN,GPIOB_BASE,4
	
	bx lr


	.global Switches_Init
	.thumb_func
Switches_Init:
	@; assumes ST_P24DISPLAY_init has been called
	@; PORTBIT_init CONFIG GPIOx_BASE PIN
	PORTBIT_init PULLUP_INPIN,GPIOA_BASE,15
	PORTBIT_init PULLUP_INPIN,GPIOC_BASE,8
	bx lr

	

@; BEGIN --- PRINT HEX ---
	.global printHEX		@;void printHEX(int val);	//put pattern to display 'val' 0-F on cathode latch
	.thumb_func
printHEX:
	nop										@;attempt to break the table alignment provided by .align (below)
	and r0,#0x0F							@;restrict argument to first 16 table entries
	lsl r0,2								@; and convert to table offset
	adr r2,printHEX_dispatch_table			@;	get table origin	
	ldr PC,[r2,r0]							@;	  and dispatch selected function from table
	.align 2								@;
printHEX_dispatch_table:
	.word write0 @;destination address must be a .thumb_func
	.word write1 @;""
	.word write2 @;""
	.word write3 @;""
	.word write4 @;""
	.word write5 @;""
	.word write6 @;""
	.word write7 @;""
	.word write8 @;""
	.word write9 @;""
	.word writeA @;""
	.word writeB @;""
	.word writeC @;""
	.word writeD @;""
	.word writeE @;""
	.word writeF @;""
	@;functions to populate table above and write various cathode patterns
	.thumb_func
write0: CATHODE_write 0,0,0,0,0,0,1,1
	bx lr
	.thumb_func
write1: CATHODE_write 1,0,0,1,1,1,1,1
	bx lr
	.thumb_func
write2: CATHODE_write 0,0,1,0,0,1,0,1
	bx lr
	.thumb_func
write3: CATHODE_write 0,0,0,0,1,1,0,1
	bx lr
	.thumb_func
write4: CATHODE_write 1,0,0,1,1,0,0,1
	bx lr
	.thumb_func
write5: CATHODE_write 0,1,0,0,1,0,0,1
	bx lr
	.thumb_func
write6: CATHODE_write 0,1,0,0,0,0,0,1
	bx lr
	.thumb_func
write7: CATHODE_write 0,0,0,1,1,1,1,1
	bx lr
	.thumb_func
write8: CATHODE_write 0,0,0,0,0,0,0,1
	bx lr
	.thumb_func
write9: CATHODE_write 0,0,0,1,1,0,0,1
	bx lr
	.thumb_func
writeA: CATHODE_write 0,0,0,1,0,0,0,1
	bx lr
	.thumb_func
writeB: CATHODE_write 1,1,0,0,0,0,0,1
	bx lr
	.thumb_func
writeC: CATHODE_write 0,1,1,0,0,0,1,1
	bx lr
	.thumb_func
writeD: CATHODE_write 1,0,0,0,0,1,0,1
	bx lr
	.thumb_func
writeE: CATHODE_write 0,1,1,0,0,0,0,1
	bx lr
	.thumb_func
writeF: CATHODE_write 0,1,1,1,0,0,0,1
	bx lr
@; END --- PRINT HEX ---



@; LED1 : Cathode C
@; LED2 : Cathode G
@; LED3 : Cathode DP
@; LED4 : Cathode F
@; LED5 : Cathode A
@; LED6 : Cathode B

	@; Sets LED ON, clears all other LEDs
	@; r0 = LED to turn on, index: 1-6
	.global LED_write
	.thumb_func
LED_write:
	nop										@;attempt to break the table alignment provided by .align (below)
	and r0,#0xFF							@;restrict argument to first 16 table entries
	lsl r0,2								@; and convert to table offset
	adr r2,LED_write_dispatch_table			@;	get table origin	
	ldr PC,[r2,r0]							@;	  and dispatch selected function from table
	.align 2								@;
LED_write_dispatch_table:
	.word LEDwrite_dummy @;destination address must be a .thumb_func
	.word LEDwrite1 @;""
	.word LEDwrite2 @;""
	.word LEDwrite3 @;""
	.word LEDwrite4 @;""
	.word LEDwrite5 @;""
	.word LEDwrite6 @;""
	
	.thumb_func
LEDwrite_dummy: @;occupies unused entries of the dispatch table
	bx lr
	.thumb_func
LEDwrite1: CATHODE_write 1,1,0,1,	1,1,1,1
	bx lr
	.thumb_func
LEDwrite2: CATHODE_write 1,1,1,1,	1,1,0,1
	bx lr
	.thumb_func
LEDwrite3: CATHODE_write 1,1,1,1,	1,1,1,0
	bx lr
	.thumb_func
LEDwrite4: CATHODE_write 1,1,1,1,	1,0,1,1
	bx lr
	.thumb_func
LEDwrite5: CATHODE_write 0,1,1,1,	1,1,1,1
	bx lr
	.thumb_func
LEDwrite6: CATHODE_write 1,0,1,1,	1,1,1,1
	bx lr
	
	
	
	@; Sets LED ON without affecting other LEDs
	@; r0 = LED to turn on, index: 1-6
	.global LED_set
	.thumb_func
LED_set:
	nop										@;attempt to break the table alignment provided by .align (below)
	and r0,#0x0F							@;restrict argument to first 16 table entries
	lsl r0,2								@; and convert to table offset
	adr r2,LED_set_dispatch_table			@;	get table origin	
	ldr PC,[r2,r0]							@;	  and dispatch selected function from table
	.align 2								@;
LED_set_dispatch_table:
	.word LEDset_dummy @;destination address must be a .thumb_func
	.word LEDset1 @;""
	.word LEDset2 @;""
	.word LEDset3 @;""
	.word LEDset4 @;""
	.word LEDset5 @;""
	.word LEDset6 @;""
	
	.thumb_func
LEDset_dummy: @;occupies unused entries of the dispatch table
	bx lr		@; PORTBIT_write GPIOx_BASE PIN VAL
	.thumb_func
LEDset1: PORTBIT_write GPIOA_BASE, 1, 0
	CATHODE_save
	bx lr
	.thumb_func
LEDset2: PORTBIT_write GPIOC_BASE, 4, 0
	CATHODE_save
	bx lr
	.thumb_func
LEDset3: PORTBIT_write GPIOB_BASE, 0, 0
	CATHODE_save
	bx lr
	.thumb_func
LEDset4: PORTBIT_write GPIOC_BASE, 2, 0
	CATHODE_save
	bx lr
	.thumb_func
LEDset5: PORTBIT_write GPIOC_BASE, 5, 0
	CATHODE_save
	bx lr
	.thumb_func
LEDset6: PORTBIT_write GPIOB_BASE, 1, 0
	CATHODE_save
	bx lr


@; ENABLE DIGITS :: ANODE_write X,R,G,D4,D3,D2,D1,P
	.global EnableDigit
	.thumb_func
EnableDigit:
	nop										@;attempt to break the table alignment provided by .align (below)
	MOV_imm32 r1, 4
	SATURATE r0, r1							@;restrict argument to first 4 table entries
	lsl r0,2								@; and convert to table offset
	adr r2,EnableDigit_dispatch_table		@;	get table origin	
	ldr PC,[r2,r0]							@;	  and dispatch selected function from table
	.align 2								@;
EnableDigit_dispatch_table:
	.word enabDIGIT_dummy @;destination address must be a .thumb_func
	.word enabDIGIT_1 @;""
	.word enabDIGIT_2 @;""
	.word enabDIGIT_3 @;""
	.word enabDIGIT_4 @;""
	
	.thumb_func
enabDIGIT_dummy:
	bx lr
	.thumb_func
enabDIGIT_1: ANODE_write 1,1,1,1,1,1,0,1
	bx lr
	.thumb_func
enabDIGIT_2: ANODE_write 1,1,1,1,1,0,1,1
	bx lr
	.thumb_func
enabDIGIT_3: ANODE_write 1,1,1,1,0,1,1,1
	bx lr
	.thumb_func
enabDIGIT_4: ANODE_write 1,1,1,0,1,1,1,1
	bx lr	
	

@; ENABLE COLON	
	.global EnableColon
	.thumb_func
EnableColon:	
	ANODE_write 1,1,1,1,1,1,1,0
	


@; ENABLE DIGITS AND COLON:: ANODE_write X,R,G,D4,D3,D2,D1,P
@; 1,2,3,4
	.global EnableDigitColon
	.thumb_func
EnableDigitColon:
	nop										@;attempt to break the table alignment provided by .align (below)
	MOV_imm32 r1, 4
	SATURATE r0, r1							@;restrict argument to first 4 table entries
	lsl r0,2								@; and convert to table offset
	adr r2,EnableDigitColon_dispatch_table		@;	get table origin	
	ldr PC,[r2,r0]							@;	  and dispatch selected function from table
	.align 2								@;
EnableDigitColon_dispatch_table:
	.word enabDIGITColon_dummy @;destination address must be a .thumb_func
	.word enabDIGITColon_1 @;""
	.word enabDIGITColon_2 @;""
	.word enabDIGITColon_3 @;""
	.word enabDIGITColon_4 @;""
	
	.thumb_func
enabDIGITColon_dummy:
	bx lr
	.thumb_func
enabDIGITColon_1: ANODE_write 1,1,1,1,1,1,0,0
	bx lr
	.thumb_func
enabDIGITColon_2: ANODE_write 1,1,1,1,1,0,1,0
	bx lr
	.thumb_func
enabDIGITColon_3: ANODE_write 1,1,1,1,0,1,1,0
	bx lr
	.thumb_func
enabDIGITColon_4: ANODE_write 1,1,1,0,1,1,1,0
	bx lr	
	

	

@; ENABLE LEDS :: ANODE_write X,R,G,D4,D3,D2,D1,P
	.global enabLED_G
	.thumb_func
enabLED_G: ANODE_write 1,1,0,1,1,1,1,1
	bx lr
	.global enabLED_R
	.thumb_func
enabLED_R: ANODE_write 1,0,1,1,1,1,1,1
	bx lr
	
	.global enabLED_RG
	.thumb_func
enabLED_RG: ANODE_write 1,0,0,1,1,1,1,1
	bx lr
	
	
@; DISPLAY ON/OFF	
	.global DISPLAY_on		@;void DISPLAY_on(void);	//enable anode, cathode outputs
	.thumb_func
DISPLAY_on:
	PORTBIT_write GPIOB_BASE,4,0	@;	75_PB4	PB4/AN_EN
	PORTBIT_write GPIOC_BASE,1,0	@;	07_PC1	PC1/CA_EN
	bx lr
	
	.global DISPLAY_off		@;void DISPLAY_off(void);	//enable anode, cathode outputs
	.thumb_func
DISPLAY_off:
	PORTBIT_write GPIOB_BASE,4,1	@;	75_PB4	PB4/AN_EN
	@;PORTBIT_write GPIOC_BASE,1,1	@;	07_PC1	PC1/CA_EN
	bx lr

	.global ENABLE_CATHODE
	.thumb_func
ENABLE_CATHODE:
	PORTBIT_write GPIOC_BASE,1,0	@;	07_PC1	PC1/CA_EN
	bx lr
	
	.global DISABLE_CATHODE
	.thumb_func
DISABLE_CATHODE:
	PORTBIT_write GPIOC_BASE,1,1	@;	07_PC1	PC1/CA_EN
	bx lr

	

	.global CATHODE_CLEAR
	.thumb_func
CATHODE_CLEAR:
	CATHODE_write_safe 1,1,1,1,	1,1,1,1
	bx lr
	
	
	.global ANODE_CLEAR
	.thumb_func
ANODE_CLEAR:
	ANODE_write 1,1,1,1,	1,1,1,1
	bx lr


	
	
	
	@; Rotary Encoder States
	@; AB
	
	@; 11 : notched
	@; 10 : up three
	@; 00 : up two
	@; 01 : up one
	@; 11 : flat (notched) - INITIAL
	
	@; - TRANSITIONS -
	@;INCREASE
	@;	11 -> 01	:	3 -> 1
	@;	01 -> 00	:	1 -> 0
	@;	00 -> 10	:	0 -> 2
	@;	10 -> 11	:	2 -> 3
	@;DECREASE
	@;	11 -> 10	: 	3 -> 2
	@;	10 -> 00	:	2 -> 0
	@;	00 -> 01	:	0 -> 1
	@; 	01 -> 11	:	1 -> 3
	
	
	
	@; no debounce
	@; REncoder A is treated like switch 14
	.global Get_REncoder_A
	.thumb_func
Get_REncoder_A:
	MOV_imm32 r0, 14
	b Get_Switch
	
	@; no debounce
	@; REncoder B is treated like switch 15
	.global Get_REncoder_B
	.thumb_func
Get_REncoder_B:
	MOV_imm32 r0, 15
	b Get_Switch
	

	
	
	@; REncoder A is treated like switch 14
	.global Get_REncoder_A_Debounce
	.thumb_func
Get_REncoder_A_Debounce:
	MOV_imm32 r0, 14
	b Get_Debounced_Switch
	

	@; REncoder B is treated like switch 15
	.global Get_REncoder_B_Debounce
	.thumb_func
Get_REncoder_B_Debounce:
	MOV_imm32 r0, 15
	b Get_Debounced_Switch
	
	
	
	@; Get the two values from the Rotary Encoder and combine them like this: AB
	.global Get_REncoder
	.thumb_func
Get_REncoder:
	push {lr}
	bl Get_REncoder_A
	mov r1, r0
	push {r1}
	bl Get_REncoder_B
	pop {r1}
	lsl r1, #1
	orr r0, r1
	and r0, #3
	pop {lr}
	bx lr
	
	
	
	@; r0 = switch # (1-13)
	.global Get_Debounced_Switch
	.thumb_func
Get_Debounced_Switch:
	@; Get current switch value and pass it through debouncer
	push {r0, lr}
	bl Get_Switch
	mov r1, r0 @; put current switch value into r1
	pop {r0}
	bl Debounce_Switch
	pop {lr}
	bx lr
	
	
	@;Get switches (1-13)
	@; r0 = switch num
	.global Get_Switch
	.thumb_func
Get_Switch:
	nop										@;attempt to break the table alignment provided by .align (below)
	MOV_imm32 r1, 15
	SATURATE r0, r1							@;restrict argument to first 13 table entries
	lsl r0,2								@; and convert to table offset
	adr r2,Get_Switch_dispatch_table		@;	get table origin	
	ldr PC,[r2,r0]							@;	  and dispatch selected function from table
	.align 2								@;
Get_Switch_dispatch_table:
	.word Get_Switch_dummy @;destination address must be a .thumb_func
	.word Get_Switch_1 @;"" Cathode D
	.word Get_Switch_2 @;"" Cathode D
	.word Get_Switch_3 @;"" Cathode E
	.word Get_Switch_4 @;"" Cathode E
	.word Get_Switch_5 @;"" Cathode DP
	.word Get_Switch_6 @;"" Cathode DP
	.word Get_Switch_7 @;"" Cathode B
	.word Get_Switch_8 @;"" Cathode B
	.word Get_Switch_9 @;"" Cathode G
	.word Get_Switch_10 @;""Cathode G
	.word Get_Switch_11 @;""Cathode A
	.word Get_Switch_12 @;""Cathode A
	.word Get_Switch_13 @;""Cathode C
	.word Get_Switch_14 @;""Cathode F - REncoder A
	.word Get_Switch_15 @;""Cathode F - REncoder B
@; CATHODE_write A,B,C,D, E,F,G,DP
@; Read from PA15: 1,3,5,7,9,11,13
@; Read from PC8: 2,4,6,8,10,12
	.thumb_func
Get_Switch_dummy:
	MOV_imm32 r0, 1 @; active low, returns NOT ACTIVE
	bx lr

	.thumb_func
Get_Switch_1:
	CATHODE_write_safe 1,1,1,0, 1,1,1,1
	b READ_ODD
	
	.thumb_func
Get_Switch_2:
	CATHODE_write_safe 1,1,1,0, 1,1,1,1
	b READ_EVEN	
	
	.thumb_func
Get_Switch_3:
	CATHODE_write_safe 1,1,1,1, 0,1,1,1
	b READ_ODD
	
	.thumb_func
Get_Switch_4:
	CATHODE_write_safe 1,1,1,1, 0,1,1,1
	b READ_EVEN
	
	.thumb_func
Get_Switch_5:
	CATHODE_write_safe 1,1,1,1, 1,1,1,0
	b READ_ODD
	
	.thumb_func
Get_Switch_6:
	CATHODE_write_safe 1,1,1,1, 1,1,1,0
	b READ_EVEN
	
	.thumb_func
Get_Switch_7:
	CATHODE_write_safe 1,0,1,1, 1,1,1,1
	b READ_ODD
	
	.thumb_func
Get_Switch_8:
	CATHODE_write_safe 1,0,1,1, 1,1,1,1
	b READ_EVEN
	
	.thumb_func
Get_Switch_9:
	CATHODE_write_safe 1,1,1,1, 1,1,0,1
	b READ_ODD
	
	.thumb_func
Get_Switch_10:
	CATHODE_write_safe 1,1,1,1, 1,1,0,1
	b READ_EVEN
	
	.thumb_func
Get_Switch_11:
	CATHODE_write_safe 0,1,1,1, 1,1,1,1
	b READ_ODD

	.thumb_func
Get_Switch_12:
	CATHODE_write_safe 0,1,1,1, 1,1,1,1
	b READ_EVEN
	
	.thumb_func
Get_Switch_13:
	CATHODE_write_safe 1,1,0,1, 1,1,1,1
	b READ_ODD

	@; REncoder A
	.thumb_func
Get_Switch_14:
	CATHODE_write_safe 1,1,1,1, 1,0,1,1
	b READ_EVEN

	@; REncoder B
	.thumb_func
Get_Switch_15:
	CATHODE_write_safe 1,1,1,1, 1,0,1,1
	b READ_ODD




	
	
	.thumb_func
READ_ODD:
	PORTBIT_read GPIOA_BASE, 15
	b CATHODE_CLEAR @; TEST
	bx lr @;unused
	
	.thumb_func
READ_EVEN:
	PORTBIT_read GPIOC_BASE, 8
	b CATHODE_CLEAR @; TEST
	bx lr @; unused
	
	
@; DELAY
	.global DELAY
	.thumb_func
DELAY:							@; short software delay
	MOVW    R3, #0x00FF			@; r3=0x0000FFFF
	MOVT    R3, #0x0000			@; ..
DELAYloop:						@; repeat here
	CBZ     R3, DELAYexit		@; r3 == 0?
	SUB     R3, R3, #1			@; 	no --
	B       DELAYloop			@;	  continue 
DELAYexit:						@;  yes --
	BX      LR					@;    return to caller

	
	
	
	
	
@; Debounce Functions

	.extern SwitchShiftRegisters
	
	@; int Debounce_Switch(int num, int val)
	@; r0 = switch num
	@; r1 = current value
	.global Debounce_Switch
	.thumb_func
Debounce_Switch:
	MOV_imm32 r2, 15
	SATURATE r0, r2							@;restrict argument to first 15 table entries
	MOV_imm32 r2, 1
	sub r0, r2		@;subtract one, switch 1 -> index 0
	
	lsl r0,2								@; and convert to table offset
	ldr r2,=SwitchShiftRegisters			@;	get table origin	
	add r0, r2							@;	  r0 contains address of shift register
	

	@; r0 = address of shift register
	@; r1 = new value to debounce
	.global Debounce
	.thumb_func
Debounce:

	ldr r2, [r0]	@; r2 contains shift reg
	lsl r2, #1
	
	MOV_imm32 r3, 1	@; isolate single bit
	and r1, r3
	
	orr r2, r1	@; r2 contains updated shift reg
				@; no longer need to preserve r1
	str r2, [r0]@; update shift reg
				@; no longer need to preserve r0
	
	MOV_imm32 r1, SHIFTREG_UTIL_CLEAR

	and r2, r1	@; clears bits beyond the chunk size
	
	MOV_imm32 r1, SHIFTREG_CHUNK_VAL @; active low
	
	cmp r1, r2
	
	ite eq
	moveq r0, 0 @; chunk matched up, active low, return ACTIVE
	movne r0, 1 @; chunk didnt match, active low, return NOT ACTIVE


	bx lr
	
	

	
@; end of Debounce functions




	