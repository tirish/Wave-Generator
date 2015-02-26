// Waves 
#ifndef INC_WAVES_H
#define INC_WAVES_H

#include "_ti_stm32f4_core.h"



/*
From _state.h
// Source
#define SRC_SINE 	
#define SRC_SAW		
#define SRC_SQUA	
#define SRC_USART	

*/

#define TOTAL_SAMPLES 256 //Amount in generated samples/limit to amount of samples

#define ENTRIES_PER_BUF 16

//use this to get macro value into ASM configuration for DMA
uint32_t asm_ENTRIES_PER_BUF;

typedef struct WavySignal_s{

	uint32_t type; //Using #define IDs
	
	uint32_t index;
	
	uint16_t * start_ptr;
	int size;


} WavySignal;


WavySignal wav_sin;//sinusoid
WavySignal wav_saw;//sawtooth
WavySignal wav_squ;//square

WavySignal wav_usart;

uint16_t USART_DMA_buf[TOTAL_SAMPLES]; //buffer for signal
uint32_t USART_DMA_buf_index;
uint8_t USART_writing;


//ping pong buffers
uint16_t PING_buf[ENTRIES_PER_BUF];
uint16_t PONG_buf[ENTRIES_PER_BUF];

// step size (for skip-sampling)
uint32_t STEP_SIZE;

uint32_t Update_Step_Size(uint32_t freq);

void ReadWave_Ping(WavySignal * wav);
void ReadWave_Pong(WavySignal * wav);
void ReadWave(WavySignal * wav, uint16_t * buffer);

void DMA_Handler(void);

void Wave_Structure_Init(void);


#endif


