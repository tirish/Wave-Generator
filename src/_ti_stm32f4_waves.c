//Waves code
#include "_ti_stm32f4_waves.h"



//wave sources (from asm)
extern uint32_t WAVE_SIN_SRC;
extern uint32_t WAVE_SAW_SRC;
extern uint32_t WAVE_SQU_SRC;




void ReadWave_Ping(WavySignal * wav){

	ReadWave(wav, PING_buf);

}

void ReadWave_Pong(WavySignal * wav){

	ReadWave(wav, PONG_buf);

}



/*
	Reads ENTRIES_PER_BUF amount of entries from the wave's buffer
	into the input buffer.
	
	If the read pointer of the wave goes off the end, it is looped
	back to the beginning.
	
	Between reading from the wave's buffer and storing the value into
	the input buffer, the value is multiplied by the amplitude
	state-variable.
*/
void ReadWave(WavySignal * wav, uint16_t * buffer){


	uint32_t amp = WavyState.amplitude.value;
	uint16_t val; //entries are half-words
	
	uint32_t val_long;
	
	float val_f;
	float percentage;
	
	int i=0;
	int curSize;
	
	int debug;
	
		
	for(i=0; i < ENTRIES_PER_BUF; i++){
	
		if(wav->size == 0)
			break;
	
		if(READ_PERIOD && WavyState.oper_mode.value == OM_SING){
			break;
		}
		
		if(WavyState.oper_mode.value == OM_TRIG && IO_TRIGGER != TRIG_ON_VAL){
			break;
		}
	
	
		val = wav->start_ptr[wav->index];
		
		//handle amplitude
		
	//	val_f = (float) val;
	//	percentage = ( (float) amp / (float) AMP_MAX);
	//	val_f = val_f * percentage; //need to do this with floats
		
	//	val = (uint16_t) (val_f + 0.5);
		
		val_long = ((uint32_t) val * (amp) )/ AMP_MAX;
		
		val = (uint16_t) val_long;
		
		
		
		if(val > 0xfff) val = 0xfff; //saturate
		
		// ----
		
		buffer[i] = val;		

		wav->index+= STEP_SIZE;
		if(wav->index >=  wav->size){
			wav->index = WavyState.oper_mode.value == OM_SING ? 0 : wav->index % wav->size;
			READ_PERIOD = 1;//status value indicating a period has been read
		}
		
		//wav->index = (wav->index + 1) % TOTAL_SAMPLES;
	}
	
	for(;i < ENTRIES_PER_BUF; i++){
		//fill remaining with zeroes
		buffer[i] = 0;
	}



}


//assign how many samples to skip based on frequency
uint32_t Update_Step_Size(uint32_t freq){

	if(freq <= 200){
		STEP_SIZE = 1;
	} else if(freq <= 400){
		STEP_SIZE = 2;
	} else if(freq <= 600){
		STEP_SIZE = 3;
	} else if(freq <= 800){
		STEP_SIZE = 4;
	} else if(freq <= 1000){
		STEP_SIZE = 4;
	}

	return freq/STEP_SIZE;

}


//uses modified version of old handler and calls ReadWave
void DMA_Handler(void){
	int r =	DMAint_svc();
	
	if(r == 1){ //PING
		ReadWave_Ping(WavyState.wav);
	} else if(r == 2){//PONG
		ReadWave_Pong(WavyState.wav);
	}

	r=0;//debug
}

/*
	Should be called before DMA/DAC configuration
*/
void Wave_Structure_Init(void){

	uint32_t debug;
	int i;

	//use this to get macro value into ASM configuration for DMA
	asm_ENTRIES_PER_BUF = ENTRIES_PER_BUF;

	
	for(i=0; i< ENTRIES_PER_BUF; i++){
		PING_buf[i] = 0;
		PONG_buf[i] = 0;
	}
	STEP_SIZE = 1;
	
	
	//sin
	wav_sin.type = SRC_SINE;
	wav_sin.start_ptr = (uint16_t *) &WAVE_SIN_SRC;
	wav_sin.index = 0;
	wav_sin.size = TOTAL_SAMPLES;

	
	//saw
	wav_saw.type = SRC_SAW;
	wav_saw.start_ptr = (uint16_t *) &WAVE_SAW_SRC;
	wav_saw.index = 0;
	wav_saw.size = TOTAL_SAMPLES;
	
	
	//square
	wav_squ.type = SRC_SQUA;
	wav_squ.start_ptr = (uint16_t *) &WAVE_SQU_SRC;
	wav_squ.index = 0;
	wav_squ.size = TOTAL_SAMPLES;
	
	
	//usart
	wav_usart.type = SRC_USART;
	wav_usart.start_ptr = &USART_DMA_buf;
	wav_usart.index = 0;
	wav_usart.size = 0; //MUST BE INCREMENTED/RESET ACCORDING TO WHAT USART GIVES IT



	
}



