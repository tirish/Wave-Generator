//SVC & PendSV

#include "_ti_stm32f4_svcpendsv.h"


#define NONE_PENDING 0

uint32_t Next_Task(void){
	uint32_t num;
	int debug_index;
	
	//verify there are tasks
	if(PSV_Queue.size == 0)
		return NONE_PENDING;
		
	// read
	debug_index = PSV_Queue.read_index;
	num = PSV_Queue.PENDING_QUEUE[PSV_Queue.read_index++];
	PSV_Queue.read_index%=MAX_PENDING;
	PSV_Queue.size--;

	return num;
}

#define DO_NOT_SET_FLAG 1
#define SET_FLAG 0

int Queue_Task(uint32_t num){

	int debug_index;
	


	//verify registery
	if(!Is_Registered( (int)num)) 
		return DO_NOT_SET_FLAG;
	
	//verify not pending already
	if(PSV_Queue.PENDING_FLAGS[num] == 1)
		return DO_NOT_SET_FLAG;
	
	
	//verify queue isn't full
	if(PSV_Queue.size >= MAX_PENDING)
		return DO_NOT_SET_FLAG;
		
	//store
	debug_index = PSV_Queue.write_index;
	PSV_Queue.PENDING_FLAGS[num] = 1;
	PSV_Queue.PENDING_QUEUE[PSV_Queue.write_index++] = num;
	PSV_Queue.write_index%=MAX_PENDING;
	PSV_Queue.size++;
	
	return SET_FLAG;

}


void SVC_Handler(int num){
	//uint32_t num;
	int r;

	//get SVC number
	//num = SvcHandler_ASM();//must come first
	
	//store SVC in pending queue
	r=Queue_Task(num);
	
	
	//set PendSV flag
	if(r != DO_NOT_SET_FLAG)
		Set_PendSV_Flag();


}


void PendSV_Handler(void){

	uint32_t svc;
	SVC_Routine routine;
	
	while((svc = Next_Task()) != 0){
		//get func
		routine = SVC_Registry.handlers[svc];
	
		//call func
		(*routine)();
		
		//clear pending flag for svc
		PSV_Queue.PENDING_FLAGS[svc] = 0;
	
	}
	
	//Clear Pending flag
	Clear_PendSV_Flag();

}


int Is_Registered(int num){
	
	return SVC_Registry.REGISTERED[num] != NOT_REGISTERED;
}


int Call_SVC(int num){
	int r = 0;
	SVC_Caller caller;
	
	if(Is_Registered(num)){
	
		caller = SVC_Registry.callers[num];//get it
		(*caller)();//call it
	
	} else {
		r = 1;
	}

	return r;

}


int Register_SVC(int num, SVC_Routine routine, SVC_Caller caller){

	if(num <= 0 || num >= (MAX_SERVICES-1))
		return INVALID_SVC_NUM;

	
	if(Is_Registered(num))
		return SVC_NUM_NOT_AVAILABLE;
		
	SVC_Registry.REGISTERED[num] = 1;
	SVC_Registry.handlers[num] = routine;
	SVC_Registry.callers[num] = caller;
	return SVC_REGISTERED;


}


void SVC_PendSV_Structure_Init(void){
	int i;
	
	
	for(i=0; i<MAX_SERVICES;i++){
		SVC_Registry.handlers[i]=0;
		SVC_Registry.callers[i] = 0;
		PSV_Queue.PENDING_FLAGS[i] = 0;
		SVC_Registry.REGISTERED[i]=NOT_REGISTERED;
	}
	
	for(i=0;i<MAX_PENDING;i++) PSV_Queue.PENDING_QUEUE[i]=0;
	PSV_Queue.read_index = 0;
	PSV_Queue.write_index = 0;
	PSV_Queue.size = 0;
	



}


