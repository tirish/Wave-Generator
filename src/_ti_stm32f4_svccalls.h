// Service Calls
#ifndef INC_SVC_CALLS_H
#define INC_SVC_CALLS_H


//see _svccalls.asm

#define SVC_NUM_State_To_Display 11
extern void SVC_State_To_Display(void);	//ASM service caller

#define SVC_NUM_Test 69
extern void SVC_Test(void);	//ASM service caller



#endif
