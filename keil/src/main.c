#include <stdint.h>
#include "code_def.h"
#include <string.h>
#include <stdio.h>


//uint8_t k15[6]={'0','1','2','3','4'};
//uint8_t k14[7]={'0','1','2','5','6','7'};
//uint8_t k13[7]={'0','1','2','5','6','8'};

//uint8_t k11[6]={'0','1','2','9','b'};
//uint8_t k10[6]={'0','1','2','a','b'};
//uint8_t k09[6]={'0','1','2','c','d'};

//uint8_t k07[6]={'e','f','g','3','4'};
//uint8_t k06[7]={'e','f','g','h','i','7'};
//uint8_t k05[7]={'e','f','g','h','i','8'};

int main()
{ 
	//interrupt initial
  Keyboard_keydata_clear=1;
  UARTString("Cortex-M0 Start up!\n");
  MSI_Init();
  //uint8_t p[30]="What are you doing?";

  LCD_Init();
  LCD_WIN1();
  //Delay_ms(3000);
  LCD_WIN2();
  IRQ_Enable(1,ENABLE);
  IRQ_Enable(2,ENABLE);
  while(1)
  {}
}
//#define WaterLight_SPEED_VALUE 0x00c9d2ff
//#define WaterLight_INTERVAL_VALUE 0x05f5e100
//	uint16_t waterlight_mode = 2;
//	UARTString("Cortex-M0 Start up!\n");
//	SetWaterLightMode(waterlight_mode);
//	UARTString("set waterlight to mode2\n");
//	SetWaterLightSpeed(WaterLight_SPEED_VALUE);
//	UARTString("set waterlight speed to defualt\n");

