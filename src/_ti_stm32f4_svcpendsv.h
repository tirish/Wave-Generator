//SVC & PendSV
#ifndef INC_SVCPENDSV_H
#define INC_SVCPENDSV_H

#include "_ti_stm32f4_core.h"


#define MAX_PENDING 16
#define MAX_SERVICES 256

typedef void (*SVC_Routine)(void);
typedef void (*SVC_Caller)(void);

#define NOT_REGISTERED 0

typedef struct{
	uint8_t REGISTERED[MAX_SERVICES]; //flag
	SVC_Routine handlers[MAX_SERVICES]; //index 0 is a dummy spot, can't be used
	SVC_Caller  callers[MAX_SERVICES]; // ""

} SVC_Calls;

SVC_Calls SVC_Registry;


typedef struct{

	uint8_t PENDING_FLAGS[MAX_SERVICES]; //flag gets set when service becomes pending
	uint32_t PENDING_QUEUE[MAX_PENDING];
	uint32_t read_index;
	uint32_t write_index;
	
	uint32_t size; //current amount pending

} PendSV_Queue;

PendSV_Queue PSV_Queue;



void SVC_PendSV_Structure_Init(void);

#define SVC_NUM_NOT_AVAILABLE	1
#define INVALID_SVC_NUM			2
#define SVC_REGISTERED			0 //success

int Is_Registered(int num);

int Call_SVC(int num);


int Register_SVC(int num, SVC_Routine routine, SVC_Caller caller);


#endif

