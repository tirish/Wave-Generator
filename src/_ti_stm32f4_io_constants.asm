@; Thomas Irish
@; IO - Constants


@; DEFINED STUFF	
	
.equ PERIPH_BASE,       	0x40000000
.equ AHB1PERIPH_BASE,       (PERIPH_BASE + 0x00020000)
.equ RCC_BASE,              (AHB1PERIPH_BASE + 0x3800)
.equ RCC_AHB1ENR,			(RCC_BASE + 0x30)			@; used to enable GPIOs

	
	
@; GPIOx Indices
.equ GPIOA_INDEX, 0
.equ GPIOB_INDEX, 1
.equ GPIOC_INDEX, 2
.equ GPIOD_INDEX, 3
.equ GPIOE_INDEX, 4
.equ GPIOF_INDEX, 5
.equ GPIOG_INDEX, 6
.equ GPIOH_INDEX, 7
.equ GPIOI_INDEX, 8
.equ GPIOJ_INDEX, 9
.equ GPIOK_INDEX, 10
	
@; GPIOx Base Addresses
.equ GPIOA_BASE,            (AHB1PERIPH_BASE + 0x0400 * GPIOA_INDEX)
.equ GPIOB_BASE,            (AHB1PERIPH_BASE + 0x0400 * GPIOB_INDEX)
.equ GPIOC_BASE,            (AHB1PERIPH_BASE + 0x0400 * GPIOC_INDEX)
.equ GPIOD_BASE,            (AHB1PERIPH_BASE + 0x0400 * GPIOD_INDEX)
.equ GPIOE_BASE,            (AHB1PERIPH_BASE + 0x0400 * GPIOE_INDEX)
.equ GPIOF_BASE,            (AHB1PERIPH_BASE + 0x0400 * GPIOF_INDEX)      
.equ GPIOG_BASE,            (AHB1PERIPH_BASE + 0x0400 * GPIOG_INDEX)
.equ GPIOH_BASE,            (AHB1PERIPH_BASE + 0x0400 * GPIOH_INDEX)
.equ GPIOI_BASE,            (AHB1PERIPH_BASE + 0x0400 * GPIOI_INDEX) 
.equ GPIOJ_BASE,            (AHB1PERIPH_BASE + 0x0400 * GPIOJ_INDEX)
.equ GPIOK_BASE,            (AHB1PERIPH_BASE + 0x0400 * GPIOK_INDEX)    	
	
@; GPIOx Offsets 
.equ MODER, 	0x00
.equ OTYPER, 	0x04
.equ OSPEEDR, 	0x08 
.equ PUPDR,		0x0C
.equ IDR,		0x10
.equ ODR,		0x14
.equ BSRRL,		0x18	@; SET
.equ BSRRH,		0x1A	@; RESET
.equ LCKR,		0x1C
.equ AFR1,		0x20	@; bits 0-7
.equ AFR2,		0x24	@; bits 8-15

@; config options
.equ STD_OUTPIN, 	0
.equ PULLUP_INPIN, 	1
.equ STD_INPIN,		2
.equ ALT_PIN,		3
.equ PULLDOWN_INPIN,4

@; Debounce Values

@; number of bits in valid chunk
.equ SHIFTREG_CHUNK_SIZE, 16	@; max=31
@; chunk of zeroes
.equ SHIFTREG_CHUNK, ~(0xffffffff >> (32-SHIFTREG_CHUNK_SIZE))

.equ SHIFTREG_CHUNK_VAL, (1 << (SHIFTREG_CHUNK_SIZE))


@; use this to remove irrelevant bits from shift register (AND with this)
.equ SHIFTREG_UTIL_CLEAR, ~(0xffffffff << (SHIFTREG_CHUNK_SIZE+1))


@; creates a chunk of zeroes
@; proper debounced transition = a 1 followed by chunk of zeroes




@; TRIGGER MODE CONSTANTS
@; used in reading/enabling trigger-mode pin
.equ TRIG_GPIO_BASE_default, GPIOB_BASE
.equ TRIG_PIN_NUM_default, 15
.equ TRIG_PIN_CONFIG_default, PULLDOWN_INPIN

@; modify these to change configuration
@; Can set to any IO pin
.equ TRIG_GPIO_BASE, TRIG_GPIO_BASE_default
.equ TRIG_PIN_NUM, TRIG_PIN_NUM_default
.equ TRIG_PIN_CONFIG, TRIG_PIN_CONFIG_default









