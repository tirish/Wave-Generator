//IO code

#include "_ti_stm32f4_IO.h"


/*----------------------------------------------------------------------------
  IO Functions
 *----------------------------------------------------------------------------*/	
int UpdateRotaryEncoderState(int state){
	int re_pstate = WavyDisplay.RE_Prev_State;
	int re_adjust = 0;


	if(re_pstate == -1)
		WavyDisplay.RE_Prev_State = state;
	else {

		switch(re_pstate){
			case 0:
				if(state == 2)
					re_adjust++;
				else if (state == 1)
					re_adjust--;
				break;
					
			case 1:
				if(state == 0)
					re_adjust++;
				else if (state == 3)
					re_adjust--;
				break;
			case 2:
				if(state == 3)
					re_adjust++;
				else if (state == 0)
					re_adjust--;
				break;
			case 3:
				if(state == 1)
					re_adjust++;
				else if (state == 2)
					re_adjust--;
				break;	
		}
	
		WavyDisplay.RE_Prev_State = state;
	}
	
	return re_adjust;
	

}


int PollAndUpdate(void){
	int tmp;
	int re;
	int swVal[14];//index 0 is dummy
	int sw;
	int modifier;
	
	int swIndex;
	
	int base = 10;
	
	int re_adjust=0;
		
	int digit1_adjust=0;
	int digit2_adjust=0;
	int digit3_adjust=0;
	int digit4_adjust=0;
	
	int overall_adjust = 0;
	
	int change = 0;
	
	DISPLAY_off();
	
	
	swVal[0] = 1; //index 0 is dummy
	//determine mode (circular)
	
	
	//read trigger pin
	IO_TRIGGER = TRIG_PIN_read();
	
	
	//poll RE
	re = Get_REncoder();
	re_adjust = UpdateRotaryEncoderState(re);
	// end of RE code
	
	
	//poll switches (digit adjusters)
	for(sw = 1; sw <= 8; sw++){
				
		
		swVal[sw] = Get_Debounced_Switch(sw);//includes edge detector

		if(!swVal[sw]) change++;//new
		
		//active low
		if(!swVal[sw]){

			modifier = (sw % 2 == 0) ? -1 : 1;
						
			switch (sw){
				case 1:
				case 2: digit1_adjust += modifier;
					break;
				case 3:
				case 4: digit2_adjust += modifier;
					break;
				case 5:
				case 6: digit3_adjust += modifier;
					break;
				case 7:
				case 8: digit4_adjust += modifier;
					break;
			}
			
	
			
		} 
		
	}
	//end of switch 1-8 code
	
	overall_adjust += digit1_adjust * base * base * base;
	overall_adjust += digit2_adjust * base * base;
	overall_adjust += digit3_adjust * base;
	overall_adjust += digit4_adjust * 1;
	overall_adjust += re_adjust;
	
	
	
	//poll switches 9-13
	for(sw = 9; sw <= 13; sw++){
	
		swVal[sw] = Get_Debounced_Switch(sw);//includes edge detector
		if(!swVal[sw]) change++;
	}
	
	//UPDATE STATE VARIABLES
	
	//if(change == 0)
	//	return 0;
	
	//frequency
	if(WavyState.variable_selection.value == SEL_FREQ){//frequency is active variable
		tmp = WavyState.frequency.displayValue;
		(*WavyState.frequency.Setter_Func)(tmp+overall_adjust);
	}
	
	//amplitude
	if(WavyState.variable_selection.value == SEL_AMP){//amplitude is active variable
		tmp = WavyState.amplitude.displayValue;
		(*WavyState.amplitude.Setter_Func)(tmp+overall_adjust);
	}
	
	//variable selection
	swIndex = WavyState.variable_selection.TOGGLE_SWITCH % 14;
	if(!swVal[swIndex]){
		(*WavyState.variable_selection.Next_State_Func)();
	}
	//source
	swIndex = WavyState.source.TOGGLE_SWITCH % 14;
	if(!swVal[swIndex]){
		(*WavyState.source.Next_State_Func)();
	}
	
	//operation mode
	swIndex = WavyState.oper_mode.TOGGLE_SWITCH % 14;
	if(!swVal[swIndex]){
		(*WavyState.oper_mode.Next_State_Func)();
	}
	if(WavyState.oper_mode.value == OM_SING && !swVal[SINGLE_MODE_TRIGGER_SW]){
		Prepare_Single_Mode();//clear period-read flag
	}
	
	
	//run status
	swIndex = WavyState.run_status.TOGGLE_SWITCH % 14;
	if(!swVal[swIndex]){
		(*WavyState.run_status.Next_State_Func)();
	}
	
	
	return change;

}


void State_To_LED(State_Variable * var){
	int i;
	int claim_count;
	int led_index;
	int led_val;
	
	(*var->LED_Func)();//update led encoding
	claim_count = var->LED_CLAIM_COUNT;
	for(i=0; i < claim_count && i < MAX_LED_CLAIMS; i++){
		led_index = var->LED_CLAIM[i];
		led_val = var->LED_VAL[i];
		WavyDisplay.LED_Value[led_index] = led_val;
	}

}


//take the state variables and set up display values
void State_To_Display(void){
	int i;
	int claim_count;
	int led_index;
	int led_val;

	int tmp;
	
	uint32_t vSel = WavyState.variable_selection.value;
	
	
	//SEVEN SEGMENT DISPLAY VARIABLES
	
	//frequency
	if(vSel ==  SEL_FREQ){
		//(*WavyState.frequency.Display_Update_Func)();
		tmp = WavyState.frequency.displayValue;
		WavyDisplay.displayValue = WavyState.frequency.displayValue;
	} else	
	//amplitude
	if(vSel ==  SEL_AMP){
		(*WavyState.amplitude.Display_Update_Func)();
		WavyDisplay.displayValue = WavyState.amplitude.displayValue;
	} else
	//read only variables
	if(vSel ==  SEL_READ_ONLY_1){
		WavyDisplay.displayValue = *READ_ONLY_1;
	} else if (vSel == SEL_READ_ONLY_2){
		WavyDisplay.displayValue = *READ_ONLY_2;
	} else if (vSel == SEL_READ_ONLY_3){
		WavyDisplay.displayValue = *READ_ONLY_3;
	} else if (vSel == SEL_READ_ONLY_2){
		WavyDisplay.displayValue = *READ_ONLY_4;
	}
	
	
	// LED VARIABLES
	
	//variable_selection
	State_To_LED(&WavyState.variable_selection);
	
	//source
	State_To_LED(&WavyState.source);
		
	//operation mode
	State_To_LED(&WavyState.oper_mode);
	
	//run status
	State_To_LED(&WavyState.run_status);

}



// translate color values into appropriate ASM calls
// write to cathode & anode
void RefreshLED(int LEDnum, int LEDval_l){
	//turn on LED
	//& pick color
	switch(LEDval_l){
		case cRED: //RED
			LED_write(LEDnum);
			enabLED_R();
			break;
		case cGREEN: //GREEN
			LED_write(LEDnum);
			enabLED_G();
			break;
		case cREDGREEN: //RED+GREEN
			LED_write(LEDnum);
			enabLED_RG();
			break;	
	}

	//verified working
}


void RefreshDisplay(void){
	int LEDindex;
	int LEDnum;
	int LEDval_l;
	int displayIndex = WavyDisplay.displayIndex;
	uint32_t fourDigits = bin2BCDv2(WavyDisplay.displayValue);
	

DISPLAY_off();

  CATHODE_CLEAR();
  ANODE_CLEAR();
	
  
  if(displayIndex >= 0 && displayIndex <= 4){
  //seven segment display
  
	  printHEX(fourDigits >> (4 * displayIndex));
		//printHEX(displayIndex);
	  
	  EnableDigit(4-displayIndex);
  
  } else if (displayIndex >= 5 && displayIndex <= 10){
	// LEDs
	// displayIndex -> LED # -> LED index
	// 5 -> 1 -> 0
	// 6 -> 2 -> 1
	// 7 -> 3 -> 2
	// 8 -> 4 -> 3
	// 9 -> 5 -> 4
	// 10-> 6 -> 5
	LEDnum = displayIndex - 4;
	LEDindex = LEDnum - 1;
	
	LEDval_l = WavyDisplay.LED_Value[LEDindex];
	RefreshLED(LEDnum, LEDval_l);
	
  }
  
  DISPLAY_on();
  
  WavyDisplay.displayIndex = (displayIndex+1) % DISPLAY_INDEX_MAX;

}


void IO_Cycle(void){
	int r;

	r = PollAndUpdate();
	State_To_Display();
	RefreshDisplay();
}



void Shift_Registers_Init(void){
	int i;
	// initialize shift registers
	for(i=0; i <SHIFT_REGISTER_COUNT; i++){
		SwitchShiftRegisters[i] = 0xffffffff;
	}

}




void Display_Structure_Init(void){
	int i;

	WavyDisplay.displayIndex = 0;
	WavyDisplay.displayValue = 0;
	for(i=0;i<6;i++) WavyDisplay.LED_Value[i] = 0;
	WavyDisplay.RE_Prev_State = -1; //to be set on first read

	IO_TRIGGER = !TRIG_ON_VAL;//default off

}












