REM  makeSTM32F4_P24IO_Blinky.bat wmh 2013-03-16 : compile STM32F4DISCOVERY/P24v04 LED demo and .asm opcode demo 
REM !!this version adds -L and -l switches which allow linking to Cortex M3 library functions
REM set path=.\;C:\yagarto_gcc472\bin;

REM assemble with '-g' omitted where we want to hide things in the AXF
arm-none-eabi-as -g -mcpu=cortex-m4 -o aStartup.o SimpleStartSTM32F4_03.asm
arm-none-eabi-as -g -mcpu=cortex-m4 -o aDACDMA.o stm32f4xx_DACDMA_05_edit.asm


arm-none-eabi-as -g -mcpu=cortex-m4 -o aTI_CORE.o _ti_stm32f4_core.asm

REM compiling C
arm-none-eabi-gcc -I./  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps _ti_stm32f4_IO.c -o cTI_IO.o
arm-none-eabi-gcc -I./  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps _ti_stm32f4_state.c -o cTI_State.o
arm-none-eabi-gcc -I./  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps _ti_stm32f4_waves.c -o cTI_Waves.o
arm-none-eabi-gcc -I./  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps _ti_stm32f4_usart.c -o cTI_USART.o
arm-none-eabi-gcc -I./  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps _ti_stm32f4_svcpendsv.c -o cTI_SVC_PENDSV.o

arm-none-eabi-gcc -I./  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps main_new.c -o cMain.o


REM linking
arm-none-eabi-gcc -nostartfiles -g -Wl,--no-gc-sections -Wl,-Map,Blinky.map -Wl,-T linkBlinkySTM32F4_01.ld -oBlinky.elf aStartup.o aTI_CORE.o cTI_SVC_PENDSV.o cTI_State.o cTI_USART.o cTI_Waves.o cTI_IO.o aDACDMA.o cMain.o -lgcc


REM hex file
arm-none-eabi-objcopy -O ihex Blinky.elf Blinky.hex

REM AXF file
copy Blinky.elf Blinky.AXF

REM list file
arm-none-eabi-objdump -S  Blinky.axf >Blinky.lst

pause