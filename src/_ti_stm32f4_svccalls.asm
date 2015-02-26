@; Service Calls

@; Register Service Calls here as needed
@; See _svccalls.h



	@; Keep consistent with _svccalls.h
	.equ SVC_NUM_Test, 69
	.equ SVC_NUM_State_To_Display, 11


	.global SVC_Test
	.thumb_func
SVC_Test:
	svc #SVC_NUM_Test
	bx lr
	
	
	.global SVC_State_To_Display
	.thumb_func
SVC_State_To_Display:
	svc #SVC_NUM_State_To_Display
	bx lr
	
	