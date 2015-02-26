//USART header
#ifndef INC_USART_H
#define INC_USART_H

#include "_ti_stm32f4_core.h"

#define USART_BUF_SIZE 16


typedef struct {
	
	int CTS : 1;
	int LBD : 1;
	int TXE : 1;
	int TC	: 1;
	int RXNE: 1;
	int IDLE: 1;
	int ORE : 1;
	int NF	: 1;
	int FE	: 1;
	int PE	: 1;


} USART_SR;


typedef struct {

	uint8_t buffer[USART_BUF_SIZE];
	
	uint32_t read_index;
	uint32_t write_index;
	
	uint32_t size;


} USART_Buffer;

USART_Buffer USART_RX_buf;	//Receiver buffer
USART_Buffer USART_TX_buf;	//Transmission buffer



void USART2_Handler(void);
void USART2_Structure_Init(void);

void DebugLoop(void);


#endif

