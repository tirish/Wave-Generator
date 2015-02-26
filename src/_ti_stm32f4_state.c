// State Functions
// functions should talk to hardware directly
#include "_ti_stm32f4_state.h"

/*
	RUN STATUS HANDLERS (Next)
*/

void Next_State_Run_Status(void){
	uint32_t state = WavyState.run_status.value;
	
	if(state == RS_On){
		//turn off
		WavyState.run_status.value = RS_Off;
		
		TIM6_Disable();
		
	} else {
		//turn on
		WavyState.run_status.value = RS_On;
		TIM6_Enable();
	}

}



/*
	OPERATION MODE HANDLERS (Next)
*/
void Prepare_Single_Mode(void){
	READ_PERIOD = 0; //CLEAR PERIOD-READ flag
	WavyState.wav->index = 0;//Restart period
}


void Next_State_Oper_Mode(void){
	uint32_t state = WavyState.oper_mode.value;
	
	if(state == OM_SING){
		WavyState.oper_mode.value = OM_REP;
	} else if (state == OM_REP) {
		WavyState.oper_mode.value = OM_TRIG;
	} else {
		WavyState.oper_mode.value = OM_SING;
		Prepare_Single_Mode();
	}


}


/*
	SOURCE HANDLERS (Next)
*/
void Next_State_Source(void){
	uint32_t state = WavyState.source.value;
	
	if(state == SRC_SINE){
		WavyState.source.value = SRC_SAW;
		WavyState.wav = &wav_saw;
	} else if (state == SRC_SAW) {
		WavyState.source.value = SRC_SQUA;
		WavyState.wav = &wav_squ;
	} else if (state == SRC_SQUA){
		WavyState.source.value = SRC_USART;
		WavyState.wav = &wav_usart;
	} else {
		WavyState.source.value = SRC_SINE;
		WavyState.wav = &wav_sin;
	}


}


/*
	VARIABLE SELECTION HANDLERS (Next)
*/



void Next_State_Variable_Selection(void){
	uint32_t state = WavyState.variable_selection.value;
	int r;
	
	if(state == SEL_FREQ){
		WavyState.variable_selection.value = SEL_AMP;
	} else if(state == SEL_AMP){
		WavyState.variable_selection.value = SEL_READ_ONLY_1;
	} else if(state == SEL_READ_ONLY_1){
		WavyState.variable_selection.value = SEL_READ_ONLY_2;
	} else if(state == SEL_READ_ONLY_2){
		WavyState.variable_selection.value = SEL_READ_ONLY_3;
	} else if(state == SEL_READ_ONLY_3){
		WavyState.variable_selection.value = SEL_READ_ONLY_4;
	} else {
		WavyState.variable_selection.value = SEL_FREQ;
	}


}


/*
	AMPLITUDE HANDLERS (Get/Set/Update)
*/
//TODO
uint32_t Get_Amplitude(){

	return WavyState.amplitude.value; 
}

//TODO
void Set_Amplitude(uint32_t val){


	if(val > AMP_MAX) val = AMP_MAX;
	if(val < AMP_MIN) val = AMP_MIN;

	WavyState.amplitude.displayValue = val;

	WavyState.amplitude.value = val;
	
}

//TODO
void Update_Amplitude_Display(){

	WavyState.amplitude.displayValue = WavyState.amplitude.value;
}



/*
	FREQUENCY HANDLERS (Get/Set/Update)
*/


void Update_Frequency_Display(){
	
	//supports 1hz to 9999hz
	if(WavyState.frequency.value < FREQ_MAX){
		// Hz
		
		//debug
		//WavyState.frequency.displayValue = WavyState.frequency.value;
	
	}
	

}
 
 
 uint32_t Get_Frequency(void){
	uint32_t arr = TIM6_Get_ARR();
	uint32_t psc = TIM6_Get_PSC();
	
	uint32_t dma_sampling_freq = (168000000/(psc+1))/arr;
	uint32_t wave_freq = dma_sampling_freq / (TOTAL_SAMPLES*DMA_REQUEST_FREQ_TWEAK); //defined in _waves.h & _state.h
	
	return wave_freq;
}
	
	
	/*
		168 mhz = sysClk
		counterClk = sysClk/(PSC+1)
		timerClk = counterClk/ARR = DMA request frequency
		
		CASE ONE
		set PSC+1 = 168
		then counterClk = 168mHz / 168 = 1mHz
		modify ARR accordingly: ARR = counterClk / freq
		ie. freq = 1,000,000
		ARR = 1,000,000 / 1,000,000 = 1
		
		
		ARR maxes out at 65,536
		if PSC+1 = 168
		and ARR = 65,536
		freq would = 15.25 = 16 (roughly)
		therefore for all frequencies above 15, ARR can change while PSC+1=168
		for frequencies below 15, PSC must also be modified
		
		CASE TWO (freq < 15)
		set PSC+1 = 16800
		then counterClk = 168mHz / 16800 = 10kHz
		modify ARR accordingly: ARR = counterClk / freq
		ie. freq = 10
		ARR = 10000/ 10 = 1000
		ie. freq = 1
		ARR = 10000 / 1 = 10000
		
		CASE THREE (freq > 1,000,000)
		set PSC+1 = 1
		then counterClk = 168mHz / 1 = 168mHz
		modify ARR accordingly: ARR = counterClk / freq
		ie. freq = 3,000,000
		ARR = 168,000,000 / 3,000,000 = 168/3 = 56
		ie. freq = 2,559,744
		ARR = 168,000,000 / 2,559,744 = 65
		ie. freq = 25,597,440
		ARR = 168,000,000 / 25,597,440 = 6 -> 28,000,000
		
		if ARR = MAX = 65,536
		& PSC+1 = 1
		freq would be: 2536 hz
	
	*/
void Set_Frequency(uint32_t freq){//frequency unit = Hz
	// convert frequency into modications of PSC and ARR

	
	
	uint32_t l_disp_freq;
	uint32_t l_true_freq;
	uint32_t psc;
	uint32_t arr;
	
	
	uint32_t dma_sampling_freq;
	
	
	//enforce frequency range (1hz to 9999hz)
	if(freq > FREQ_MAX) freq = FREQ_MAX;
	if(freq < FREQ_MIN) freq = FREQ_MIN;
	
	if(freq == WavyState.frequency.displayValue)//no change
		return;

	
	WavyState.frequency.displayValue = freq; //set display value
	freq = Update_Step_Size(freq);	//tweak freq
	
	dma_sampling_freq = freq * TOTAL_SAMPLES * DMA_REQUEST_FREQ_TWEAK; //defined in _waves.h
	
	
	//valid frequency range: 1HZ - 1mHz : 1 - 1,000,000
	
	//256 * 9999 = 2,559,744
	// * 10 = 25,597,440
	
	TIM6_Pause();
	if(dma_sampling_freq < 1 || dma_sampling_freq > 168000000){
		//do nothing
	} else if(dma_sampling_freq < 15){
		//should be unused
		psc = 16800-1;
		arr = 10000/dma_sampling_freq;
		TIM6_Set_PSC(psc);
		TIM6_Set_ARR(arr);
	} else if(dma_sampling_freq <= 100000){
		psc = 168-1;
		arr = 1000000/dma_sampling_freq;
		TIM6_Set_PSC(psc);
		TIM6_Set_ARR(arr);
	} else if(dma_sampling_freq <= 168000000){
		psc = 0;
		arr = 168000000/dma_sampling_freq;
		TIM6_Set_PSC(psc);
		TIM6_Set_ARR(arr);
	}
	TIM6_Update();
	TIM6_Unpause();
	
	
	WavyState.frequency.value = Get_Frequency();
	l_true_freq = WavyState.frequency.value;
	

}


/*
 LED Encoders
*/
void LED_Encoder_Variable_Selection(void){
	uint32_t val = WavyState.variable_selection.value;
	if(val == SEL_FREQ){
		WavyState.variable_selection.LED_VAL[CLAIM1] = cGREEN;
		WavyState.variable_selection.LED_VAL[CLAIM2] = 0;
	} else if(val == SEL_AMP){
		WavyState.variable_selection.LED_VAL[CLAIM1] = 0;
		WavyState.variable_selection.LED_VAL[CLAIM2] = cGREEN;
	} else {
		WavyState.variable_selection.LED_VAL[CLAIM1] = (val == 3 || val == 2) ? cRED : 0;
		WavyState.variable_selection.LED_VAL[CLAIM2] = (val == 3 || val == 1) ? cRED : 0;
	
	}

	
}

void LED_Encoder_Source(void){
	//2 bit binary encoder, with LED1 as most significant bit
	uint32_t val = WavyState.source.value;
	WavyState.source.LED_VAL[CLAIM1] = (val == 3 || val == 2) ? cGREEN : 0;// the 2 makes it green
	WavyState.source.LED_VAL[CLAIM2] = (val == 3 || val == 1) ? cGREEN : 0;

}

void LED_Encoder_Oper_Mode(void){
	WavyState.oper_mode.LED_VAL[CLAIM1] = WavyState.oper_mode.value;

}

void LED_Encoder_Run_Status(void){
	uint32_t val = WavyState.run_status.value;
	WavyState.run_status.LED_VAL[CLAIM1] = val;

}


/*
	INIT CODE
*/


//Default Configuration
void State_Structure_Init(void){
	int i;
	int tmp;

	//frequency
	WavyState.frequency.value = 0;
	WavyState.frequency.displayValue = 0;//to be set
	WavyState.frequency.LED_CLAIM_COUNT = 0;
	WavyState.frequency.TOGGLE_SWITCH = 0; //unused
	WavyState.frequency.Getter_Func = Get_Frequency;
	WavyState.frequency.Setter_Func = Set_Frequency;
	WavyState.frequency.Display_Update_Func = Update_Frequency_Display;
	WavyState.frequency.LED_Func = 0; //unused
	WavyState.frequency.Next_State_Func = 0; //unused
	
	//initialize the frequency (assumes the TIM6 has been configured)
	/*
	tmp = (*WavyState.frequency.Getter_Func)();
	if(tmp > FREQ_MAX){
		(*WavyState.frequency.Setter_Func)(FREQ_MAX);
		//WavyState.frequency.value = (*WavyState.frequency.Getter_Func)();
	} else {
		WavyState.frequency.value = tmp;
	}
	*/
	(*WavyState.frequency.Setter_Func)(FREQ_INIT);
	
	
	
	
	
	//amplitude
	WavyState.amplitude.value = AMP_INIT; 
	WavyState.amplitude.displayValue = AMP_INIT;
	WavyState.amplitude.LED_CLAIM_COUNT = 0;
	WavyState.amplitude.TOGGLE_SWITCH = 0; //unused
	WavyState.amplitude.Getter_Func = Get_Amplitude;
	WavyState.amplitude.Setter_Func = Set_Amplitude;
	WavyState.amplitude.Display_Update_Func = Update_Amplitude_Display;
	WavyState.amplitude.LED_Func = 0; //unused
	WavyState.amplitude.Next_State_Func = 0; //unused
	
	// variable selection
	WavyState.variable_selection.value = SEL_FREQ;
	WavyState.variable_selection.displayValue = 0; //unused
	WavyState.variable_selection.LED_CLAIM_COUNT = 2;
	WavyState.variable_selection.LED_CLAIM[CLAIM1] = LED2;
	WavyState.variable_selection.LED_CLAIM[CLAIM2] = LED5;
	WavyState.variable_selection.TOGGLE_SWITCH = 11; //claim switch 11
	WavyState.variable_selection.Getter_Func = 0; //not yet set
	WavyState.variable_selection.Setter_Func = 0;//not yet set
	WavyState.variable_selection.Display_Update_Func = 0;//not yet set
	WavyState.variable_selection.LED_Func = LED_Encoder_Variable_Selection;
	WavyState.variable_selection.Next_State_Func = Next_State_Variable_Selection;
	(* WavyState.variable_selection.LED_Func)(); //init - maybe?
	
	
	
	// source
	WavyState.wav = &wav_sin;			//default: sin
	WavyState.source.value = SRC_SINE;	//default: sin
	WavyState.source.displayValue = 0; //unused
	WavyState.source.LED_CLAIM_COUNT = 2;
	WavyState.source.LED_CLAIM[CLAIM1] = LED1;
	WavyState.source.LED_CLAIM[CLAIM2] = LED4;
	WavyState.source.TOGGLE_SWITCH = 9; //claim switch 9
	WavyState.source.Getter_Func = 0; //not yet set
	WavyState.source.Setter_Func = 0;//not yet set
	WavyState.source.Display_Update_Func = 0;//not yet set
	WavyState.source.LED_Func = LED_Encoder_Source;
	WavyState.source.Next_State_Func = Next_State_Source;
	(* WavyState.source.LED_Func)(); // init - maybe?
	
	
	// operation mode
	WavyState.oper_mode.value = OM_REP;
	WavyState.oper_mode.displayValue = 0; //unused
	WavyState.oper_mode.LED_CLAIM_COUNT = 1;
	WavyState.oper_mode.LED_CLAIM[CLAIM1] = LED3;
	WavyState.oper_mode.TOGGLE_SWITCH = 10; //claim switch 10
	WavyState.oper_mode.Getter_Func = 0; //not yet set
	WavyState.oper_mode.Setter_Func = 0;//not yet set
	WavyState.oper_mode.Display_Update_Func = 0;//not yet set
	WavyState.oper_mode.LED_Func = LED_Encoder_Oper_Mode;
	WavyState.oper_mode.Next_State_Func = Next_State_Oper_Mode;
	(* WavyState.oper_mode.LED_Func)(); // init - maybe?
	
	
	// run status
	WavyState.run_status.value = RS_On;
	WavyState.run_status.displayValue = 0; //unused
	WavyState.run_status.LED_CLAIM_COUNT = 1;
	WavyState.run_status.LED_CLAIM[CLAIM1] = LED6;
	WavyState.run_status.TOGGLE_SWITCH = 13; //claim switch 13
	WavyState.run_status.Getter_Func = 0; //not yet set
	WavyState.run_status.Setter_Func = 0;//not yet set
	WavyState.run_status.Display_Update_Func = 0;//not yet set
	WavyState.run_status.LED_Func = LED_Encoder_Run_Status;
	WavyState.run_status.Next_State_Func = Next_State_Run_Status;
	(* WavyState.run_status.LED_Func)(); // init - maybe?
	

	RO_Dummy = 0;
	
	// read only variables (used with variable selection)
	READ_ONLY_1=&RO_Dummy;
	READ_ONLY_2=&RO_Dummy;
	READ_ONLY_3=&RO_Dummy;
	READ_ONLY_4=&RO_Dummy;


}


void Set_RO_Value(int index, uint32_t * val){
	index %=MAX_RO;
	index++;
	
	switch(index){
		case 1: READ_ONLY_1 = val; break;
		case 2: READ_ONLY_2 = val; break;
		case 3: READ_ONLY_3 = val; break;
		case 4: READ_ONLY_4 = val; break;
	}
	
	

}


