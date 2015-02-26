#ifndef INC_STATE_H
#define INC_STATE_H
// State Values for program

#include "_ti_stm32f4_core.h"


typedef uint32_t (*State_Variable_Getter)(void);
typedef void (*State_Variable_Setter)(uint32_t val);
typedef void (*State_Variable_Display_Updater)(void);

typedef void (*State_Variable_LED_Encoder)(void);
typedef void (*State_Variable_Next_State)(void);


#define MAX_LED_CLAIMS 2
#define CLAIM1 0
#define CLAIM2 1
typedef struct {

	uint32_t value;
	uint32_t displayValue;
	
	uint8_t LED_CLAIM_COUNT; //total claimed LEDs
	
	int LED_CLAIM[MAX_LED_CLAIMS]; 	//LED Indices that are claimed (values = 0 to 5 for LEDs 1 to 6)
									// NOTE the index in this array does not relate to the index of the LED
	int LED_VAL[MAX_LED_CLAIMS];	// values to given to these claimed LEDs
	
	
	int TOGGLE_SWITCH;				//0: disabled; use indicated switch as toggle switch
	
	
	State_Variable_Getter Getter_Func;
	State_Variable_Setter Setter_Func;
	State_Variable_Display_Updater Display_Update_Func;
	State_Variable_LED_Encoder LED_Func;
	State_Variable_Next_State Next_State_Func;


} State_Variable;


#define STATE_VARIABLE_COUNT 6
typedef struct {

	State_Variable frequency;
	State_Variable amplitude;
	State_Variable variable_selection;
	State_Variable source;
	State_Variable oper_mode;
	State_Variable run_status;
	
	struct WavySignal_s * wav;
	

} Program_State;

Program_State WavyState;



//Single-Mode Values
int READ_PERIOD; //status flag
#define SINGLE_MODE_TRIGGER_SW 12




// Defintions for State Variables

// Assumed Values
//#define cRED 1
//#define cGREEN 2
//#define cREDGREEN 3

// Variable Selection (LED Values)
#define SEL_FREQ			10
#define SEL_AMP				20
#define SEL_READ_ONLY_1		0			
#define SEL_READ_ONLY_2		1
#define SEL_READ_ONLY_3		2
#define SEL_READ_ONLY_4		3

// Source
#define SRC_SINE 	0
#define SRC_SAW		1
#define SRC_SQUA	2
#define SRC_USART	3

// Operation Mode (LED Values)
#define OM_SING		0
#define OM_REP		2
#define OM_TRIG		1

// Run Status (LED Values)
#define RS_On 		2
#define RS_Off		1



// Convenience Definitions

//LED Indices (For Claims)
#define LED1 		0
#define LED2 		1
#define LED3 		2
#define LED4 		3
#define LED5 		4
#define LED6 		5

#define FREQ_MIN 1
#define FREQ_MAX 1000
#define FREQ_INIT 100

#define DMA_REQUEST_FREQ_TWEAK 10
#define DMA_REQUEST_FREQ_MAX FREQ_MAX*TOTAL_SAMPLES*DMA_REQUEST_FREQ_TWEAK
#define DMA_REQUEST_FREQ_MIN FREQ_MIN*TOTAL_SAMPLES*DMA_REQUEST_FREQ_TWEAK

#define AMP_MIN 1
#define AMP_MAX 100
#define AMP_INIT 100


#define MAX_RO 	4
#define RO_1 	0
#define RO_2	1
#define RO_3	2
#define RO_4	3

uint32_t RO_Dummy;//used as default value to point to

uint32_t *READ_ONLY_1;
uint32_t *READ_ONLY_2;
uint32_t *READ_ONLY_3;
uint32_t *READ_ONLY_4;


void Prepare_Single_Mode(void);

void Set_RO_Value(int index, uint32_t * val);

void State_Structure_Init(void);







#endif

