#include <string.h>
#include "code_def.h"
void IRQ_Enable(uint32_t IRQ_Number,char state){//IRQ_Number=1,2,3...32 ; state=ENABLE,DISABLE
    uint32_t Number;
    Number = 0x00000001 << (IRQ_Number-1);
    if(state!=ENABLE){
        NVIC_CTRL->ICER = Number;
    }
    else{
        NVIC_CTRL->ISER = Number;
    }
}


void Delay_ms(uint32_t n_ms){
    int i;
    
    while(n_ms--){
        for(i = 0;i<6944;i++);
    }
}
void SetWaterLightMode(int mode)
{
	WaterLight -> Waterlight_MODE = mode;
}

void SetWaterLightSpeed(int speed)
{
	WaterLight -> Waterlight_SPEED = speed;
}
 
char ReadUARTState()
{
    char state;
	state = UART -> UARTTX_STATE;
    return(state);
}

char ReadUART()
{
    char data;
	data = UART -> UARTRX_DATA;
    return(data);
}

void WriteUART(char data)
{
    while(ReadUARTState());
	UART -> UARTTX_DATA = data;
}

void UARTString(char *stri)
{
	unsigned int i;
	for(i=0;i<strlen(stri);i++)
	{
		WriteUART(stri[i]);
	}
}

	
void UARTHandle()
{
	int data;
	data = ReadUART();
 
	UARTString("Cortex-M0 read: ");
	WriteUART(data);
	WriteUART('\n');
	if(data == '1')SetWaterLightMode(1); 
	if(data == '2')SetWaterLightMode(2); 
	if(data == '3')SetWaterLightMode(3); 
}

void MSI_Init()
{
	MSI = 0x0028BB85; //THRESH = 3000
	UARTString("write msi reg5 done!\n");
	//Delay(100);
	MSI = 0x00200016;
	UARTString("write msi reg6 done!\n");
	//Delay(100);
	MSI = 0x00C43000;
	UARTString("write msi reg0 done!\n");
	//Delay(100);
	MSI = 0x0000FA03; //AFC = 4000
	UARTString("write msi reg3 done!\n");
	//Delay(100);
	MSI = 0x001DA282;
	UARTString("write msi reg2 done!\n");
	//Delay(100);
	MSI = 0x0000C0A1;	
	UARTString("write msi reg1 done!\n");
	//Delay(100);
	MSI = 0x00000004;	
	UARTString("write msi reg4 done!\n");
}


// 89.6MHz INT = 29(1D) FRAC = 2600(A28)    88.4MHz INT = 29(1D) FRAC = 1400(578)  101.8MHz INT = 29(21) FRAC = 2800(AF0)
void MSI_SetF(uint16_t num)
{
	uint32_t i,j,m,n;
	i=(uint32_t)num/30;
	j=(uint32_t)((num-i*30)*100);
	m=i<<16;
	n=j<<4;
	MSI =0x00000002|(m|n);
	UARTString("write msi reg2 done!\n");
}

void SEG_Init()
{
	SEG_PLAY(0);
}

void SEG_PLAY(uint16_t num)
{
	uint16_t i,j,m,n;
	i=(uint16_t)(num/1000);
	j=(uint16_t)((num%1000)/100);
	m=(uint16_t)((num%100)/10);
	n=((num%100)%10);

	SEG = 0x00000000|(i<<12)|(j<<8)|(m<<4)|n;
}





























