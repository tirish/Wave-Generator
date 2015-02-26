#ifndef INC_IO_H
#define INC_IO_H

// IO code
#include "_ti_stm32f4_core.h"

#define cRED 1
#define cGREEN 2
#define cREDGREEN 3


#define DISPLAY_INDEX_MAX 11 //10 output devices

typedef struct {

	uint32_t displayIndex; //counter used to denote which output device gets refreshed
	
	uint32_t displayValue; //Value to be displayed on the seven segment display
	
	
	uint32_t LED_Value[6]; //Values to display on the LEDs
	

	int RE_Prev_State; //rotary encoder previous state

} Output_Devices;


Output_Devices WavyDisplay;

#define SHIFT_REGISTER_COUNT 13
uint32_t SwitchShiftRegisters[SHIFT_REGISTER_COUNT];

//If IN-PIN set to pulldown, this should 1
//if IN-PIN set to pullup, this should 0
#define TRIG_ON_VAL 1	//1 or 0
uint8_t IO_TRIGGER;


int UpdateRotaryEncoderState(int state);
int PollAndUpdate(void);
void State_To_Display(void);
void RefreshLED(int LEDnum, int LEDval_l);
void RefreshDisplay(void);
void IO_Cycle(void);
void Shift_Registers_Init(void);
void Display_Structure_Init(void);





#endif


