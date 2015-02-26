//USART code
#include "_ti_stm32f4_usart.h"



int FetchBit(uint32_t num, int bit){

	uint32_t bitmask = 1;


	bit = bit < 0 ? 0 : bit > 31 ? 31 : bit;//must be positive and at most 31 (indexed from 0 - 31)
	
	bitmask = bitmask << bit;
	
	return (num & bitmask) >> bit;


}


USART_SR ReadAndParseSR(void){

	USART_SR parsed_sr;
	uint32_t sr = USART2_Read_SR();
	
	parsed_sr.CTS = FetchBit(sr,9);
	parsed_sr.LBD = FetchBit(sr,8);
	parsed_sr.TXE = FetchBit(sr,7);
	parsed_sr.TC = FetchBit(sr,6);
	parsed_sr.RXNE = FetchBit(sr,5);
	parsed_sr.IDLE = FetchBit(sr,4);
	parsed_sr.ORE = FetchBit(sr,3);
	parsed_sr.NF = FetchBit(sr,2);
	parsed_sr.FE = FetchBit(sr,1);
	parsed_sr.PE = FetchBit(sr,0);

	return parsed_sr;
}


uint16_t MergeCharacters(uint8_t ch1, uint8_t ch2, uint8_t ch3){

	uint16_t trun_ch1 = (uint16_t) (ch1 & 0xf);
	uint16_t trun_ch2 = (uint16_t) (ch2 & 0xf);
	uint16_t trun_ch3 = (uint16_t) (ch3 & 0xf);

	return (trun_ch1 << 8 | trun_ch2 << 4 | trun_ch3);


}


int USART_Signal_Buf_Add(uint16_t val){
	
	if(USART_DMA_buf_index < TOTAL_SAMPLES){
	
		USART_DMA_buf[USART_DMA_buf_index] = val;
		
		wav_usart.size++; //NEED THIS SINCE SIGNAL CAN BE VARIABLE SIZE
		
		USART_DMA_buf_index++;
		
		return 0;
	}
	
	return 1; //error

}

void USART_Signal_Buf_Clear(void){
	
	int i;
	
	for(i=0; i < TOTAL_SAMPLES; i++) USART_DMA_buf[i] = 0;
		
	wav_usart.size=0; //NEED THIS SINCE SIGNAL CAN BE VARIABLE SIZE
		
	USART_DMA_buf_index=0;
		


}



uint8_t USART_Buffer_Read(USART_Buffer * uBuf){

	uint8_t ch;

	if(uBuf->size > 0){
	

		ch = uBuf->buffer[uBuf->read_index];
		
		uBuf->read_index = (uBuf->read_index + 1) % USART_BUF_SIZE;

		uBuf->size--;
		
		return ch; //success
	}


	return 0; //fail
}

int USART_Buffer_Write(USART_Buffer * uBuf, uint8_t ch){


	if(uBuf->size < USART_BUF_SIZE){
		
	
		uBuf->buffer[uBuf->write_index] = ch;
		uBuf->write_index = (uBuf->write_index + 1) % USART_BUF_SIZE;
	
		uBuf->size++;
		
		return 0; //success
	}

	return 1; //fail; buffer full
}

int Has_Transmission_Queued(){
	return USART_TX_buf.size > 0;

}

#define ERR_NONE			0
#define ERR_INVALID_CHAR 	1
#define ERR_CLEAR_BUF 		2

int ParseChar(uint8_t ch, uint8_t * ret){
	int error = ERR_NONE;
	
	if( (ch-'0') >=0 && (ch-'0') <= 9){
		*ret = ch - '0';
	} else if(ch == 'a' || ch == 'A'){
		*ret = 0xa;
	} else if(ch == 'b' || ch == 'B'){
		*ret = 0xb;
	} else if(ch == 'c' || ch == 'C'){
		*ret = 0xc;
	} else if(ch == 'd' || ch == 'D'){
		*ret = 0xd;
	} else if(ch == 'e' || ch == 'E'){
		*ret = 0xe;
	} else if(ch == 'f' || ch == 'F'){
		*ret = 0xf;
	} else if(ch == 'x' || ch == 'X'){
		error = ERR_CLEAR_BUF;
	} else {
		error = ERR_INVALID_CHAR;
	}
	
	return error;

}

void USART2_Handler(void){
	uint8_t ch, pCh;
	uint8_t ch1,ch2,ch3;

	uint16_t val;

	USART_SR pSR = ReadAndParseSR();
	int error,r;
	
	
	if(pSR.RXNE){
		//something to read
		//move to receiver buffer
		ch = (uint8_t) USART2_Read_Data();
		
		error = ParseChar(ch, &pCh);
		USART_Buffer_Write(&USART_TX_buf,ch);
		
		if(error == ERR_NONE){
			USART_Buffer_Write(&USART_RX_buf, pCh);
		} else if(error == ERR_CLEAR_BUF){
			USART_Signal_Buf_Clear();
			
			USART_Buffer_Write(&USART_TX_buf,'\r');
			USART_Buffer_Write(&USART_TX_buf,'\n');
			USART_Buffer_Write(&USART_TX_buf,':');
		}
			
		
		
		
		if(ch == '\r')
			USART_Buffer_Write(&USART_TX_buf,'\n');
		
		
		if(USART_RX_buf.size >= 3){
			ch1 = USART_Buffer_Read(&USART_RX_buf);
			ch2 = USART_Buffer_Read(&USART_RX_buf);
			ch3 = USART_Buffer_Read(&USART_RX_buf);
			val = MergeCharacters(ch1,ch2,ch3);
			r = USART_Signal_Buf_Add(val);
			
			if(r)
				USART_Buffer_Write(&USART_TX_buf,'!');
			
			USART_Buffer_Write(&USART_TX_buf,'\r');
			USART_Buffer_Write(&USART_TX_buf,'\n');

			
		}
		
	
	}
	
	if(Has_Transmission_Queued()){
		USART2_Transmitter_Enable();
	} else {
		USART2_Transmitter_Disable();
	}
	
	if(pSR.TXE){
		ch = USART_Buffer_Read(&USART_TX_buf);
		USART2_Write_Data(ch);
	
	}
	
	if(Has_Transmission_Queued()){
		USART2_Transmitter_Enable();
	} else {
		USART2_Transmitter_Disable();
	}



}


void USART2_Structure_Init(void){
	int i;


	//receiver buffer
	USART_RX_buf.read_index = 0;
	USART_RX_buf.write_index = 0;
	USART_RX_buf.size = 0;
	for(i=0; i < USART_BUF_SIZE; i++) USART_RX_buf.buffer[i]=0;
	
	//transmitter buffer
	USART_TX_buf.read_index = 0;
	USART_TX_buf.write_index = 0;
	USART_TX_buf.size = 0;
	for(i=0; i < USART_BUF_SIZE; i++) USART_TX_buf.buffer[i]=0;


	//signal buffer
	for(i=0; i < TOTAL_SAMPLES; i++) USART_DMA_buf[i] = 0;
	USART_DMA_buf_index = 0;

}


