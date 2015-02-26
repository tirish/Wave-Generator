@; USART Configuration


.equ USART1_Base, 0x40011000
.equ USART2_Base, 0x40004400

@; For clock enable
.equ USART2_Index, 17

@; NVIC position: 38 (pg 370)
.equ USART2_NVIC_NUM, 38

@; USART2_RX: PA3
@; USART2_TX: PA2


@; Status Register (pg 990)
.equ USARTx_SR, 0x00 @;offset

	.equ CTS, 9 @;bit pos; 1 bit
	.equ LBD, 8 @;bit pos; 1 bit
	.equ TXE, 7 @;bit pos; 1 bit	TRANSMIT-READY
	.equ TC,  6 @;bit pos; 1 bit
	.equ RXNE,5 @;bit pos; 1 bit	READ-READY
	.equ IDLE,4 @;bit pos; 1 bit
	.equ ORE, 3 @;bit pos; 1 bit
	.equ NF,  2 @;bit pos; 1 bit
	.equ FE,  1 @;bit pos; 1 bit
	.equ PE,  0 @;bit pos; 1 bit

@; Data Register (pg 993)
.equ USARTx_DR, 0x04 @;offset
	@; first 9 bits are used [8:0]

@; Baud rate (pg 993) - See pg 963 for calculations
.equ USARTx_BRR, 0x08 @;offset
	.equ DIV_Mantissa, 4 @;position; bits [15:4]
	.equ DIV_Fraction, 0 @;position; bits [3:0]

@; Control Register 1 (pg 993)
.equ USARTx_CR1, 0x0C @;offset
	.equ OVER8, 15	@;bit pos; 1 bit
	.equ UE, 13		@;bit pos; 1 bit	USART ENABLE
	.equ M, 12		@;bit pos; 1 bit	WORD LENGTH: 0->8 bits
	.equ WAKE, 11   @;bit pos; 1 bit
	.equ PCE, 10	@;bit pos; 1 bit	PARITY ENABLE: 0->disabled
	.equ PS, 9		@;bit pos; 1 bit
	.equ PEIE, 8	@;bit pos; 1 bit
	.equ TXEIE, 7	@;bit pos; 1 bit	TRANSMIT-READY INT ENABLE
	.equ TCIE, 6	@;bit pos; 1 bit
	.equ RXNEIE, 5	@;bit pos; 1 bit	READ-READY INT ENABLE
	.equ IDLEIE, 4	@;bit pos; 1 bit
	.equ TE, 3		@;bit pos; 1 bit	TRANSMITTER ENABLE
	.equ RE, 2		@;bit pos; 1 bit	RECEIVER ENABLE
	.equ RWU, 1		@;bit pos; 1 bit
	.equ SBK, 0		@;bit pos; 1 bit

@; Control Register 2 (pg 996)
.equ USARTx_CR2, 0x10 @;offset
	.equ LINEN, 14	@;bit pos; 1 bit
	.equ STOP, 12	@;position; two bits [13:12]	pg 996: 0x00 -> 1 stop bit
	.equ CLKEN, 11	@;bit pos; 1 bit
	.equ CPOL, 10	@;bit pos; 1 bit
	.equ CPHA, 9	@;bit pos; 1 bit
	.equ LBCL, 8	@;bit pos; 1 bit
	.equ LBDIE, 6	@;bit pos; 1 bit
	.equ LBDL, 5	@;bit pos; 1 bit
	.equ CR2_ADD,0  @; position; 4 bits [3:0]

@; Control Register 3 (pg 997)
.equ USARTx_CR3, 0x14 @;offset
	.equ ONEBIT, 11	@;bit pos; 1 bit
	.equ CTSIE, 10	@;bit pos; 1 bit	CLEAR-TO-SEND INT ENABLE
	.equ CTSE, 9	@;bit pos; 1 bit	CLEAR-TO-SEND ENABLE
	.equ RTSE, 8	@;bit pos; 1 bit	REQUEST-TO-SEND ENABLE/INT ENABLE
	.equ DMAT, 7	@;bit pos; 1 bit
	.equ DMAR, 6	@;bit pos; 1 bit
	.equ SCEN, 5	@;bit pos; 1 bit
	.equ NACK, 4	@;bit pos; 1 bit
	.equ HDSEL, 3	@;bit pos; 1 bit
	.equ IRLP, 2	@;bit pos; 1 bit
	.equ IREN, 1	@;bit pos; 1 bit
	.equ EIE, 0		@;bit pos; 1 bit

@; Guard Time & Prescaler
.equ USARTx_GTPR, 0x18 @;offset
	.equ GTPR_GT, 8 @;position; 8 bits [15:8]
	.equ GTPR_PSC,0 @;position; 8 bits [7:0]
	
	
	
	