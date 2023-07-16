#include "code_def.h"
#include <stdint.h>
#include <string.h>
#include <stdio.h>

void KEY_ISR(void)
{  static uint16_t num=896;
   static uint32_t speed=0x003fffff;
   static uint8_t flag7=0,flag15=0;
   uint32_t keydata;
   keydata=Keyboard_keydata_clear;
   switch(keydata){
                   case 0x00000020 : {   //频率减
                                         if(num>=871&&num<=1080)
                                              num=num-1;                                                     
                                         else num=1080;
                                         MSI_SetF(num);
                                         SEG_PLAY(num);
                                         UARTString("Set frequency down 0.1 MHz!\n");
                                         Keyboard_keydata_clear=1;                        
                                      };  
                        break;

                   case 0x00000040 : {   //频率加
                                         if(num>=870&&num<=1079)
                                              num=num+1;                                                     
                                         else 
                                              num=870;
                                         MSI_SetF(num);
                                         SEG_PLAY(num);
                                         UARTString("Set frequency add 0.1 MHz!\n");
                                         Keyboard_keydata_clear=1;                        
                                      };  
                        break;

                   case 0x00000080 : {   //FM开关
                                         if(flag7==0)
                                            {
                                             	MSI = 0x0028BB85; //THRESH = 3000
	                                            UARTString("write msi reg5 done!\n");
                                             	//Delay(100);
                                            	MSI = 0x00200016;
	                                            UARTString("write msi reg6 done!\n");
	                                            //Delay(100);
                                              MSI = 0x00043420;
	                                            UARTString("write msi reg0 done!\n");
                                            	//Delay(100);
	                                            MSI = 0x0000FA03; //AFC = 4000
	                                            UARTString("write msi reg3 done!\n");
	                                            //Delay(100);
	                                          //MSI = 0x001DA282;
	                                          //UARTString("write msi reg2 done!\n");
	                                            //Delay(100);
	                                            MSI = 0x0000C0A1;	
	                                            UARTString("write msi reg1 done!\n");
	                                            //Delay(100);
	                                            MSI = 0x00000004;	
	                                            UARTString("write msi reg4 done!\n");
                                              MSI_SetF(num);
                                              SEG_PLAY(num);                                             
                                              UARTString("FM Start!\n"); 
                                             }                                                     
                                         else 
                                            {
                                             MSI = 0x00C43000;
	                                           UARTString("write msi reg0 done!\n");
                                             SEG_PLAY(0);                                             
                                             UARTString("FM shutdown!\n"); 
                                             }
                                         flag7=~flag7;
                                         Keyboard_keydata_clear=1;                        
                                      }; 
                        break;

                   case 0x00000200 : {   //流水灯模式3
                                         SetWaterLightMode(3);
                                         UARTString("Set waterlight to mode3(Flash)!\n");
                                         Keyboard_keydata_clear=1;                        
                                      } ; 
                        break;

                   case 0x00000400 : {   //流水灯模式2
                                         SetWaterLightMode(2);
                                         UARTString("Set waterlight to mode2(Right)!\n");
                                         Keyboard_keydata_clear=1;                        
                                      }; 
                        break;


                   case 0x00000800 : {   //流水灯模式1
                                         SetWaterLightMode(1);
                                         UARTString("Set waterlight to mode1(Left)!\n");
                                         Keyboard_keydata_clear=1;                        
                                      };  
                        break;
 
                   case 0x00002000 : {   //流水灯速度减
                                         if(speed>=0x002fffff&&speed<=0x0effffff)
                                              speed=speed+0x00100000;                                                     
                                         else 
                                              speed=0x0effffff;
                                         SetWaterLightSpeed(speed);
                                         UARTString("Waterlight speed down!\n");
                                         Keyboard_keydata_clear=1;                        
                                      };  
                        break;

                   case 0x00004000 : {   //流水灯速度加
                                         if(speed>=0x002fffff&&speed<=0x0effffff)
                                              speed=speed-0x00100000;                                                     
                                         else 
                                              speed=0x002fffff;
                                         SetWaterLightSpeed(speed);
                                         UARTString("Waterlight speed up!\n");
                                         Keyboard_keydata_clear=1;                       
                                      };  
                        break;

                   case 0x00008000 : {   //流水灯速度
                                         if(flag15==0)
                                           {
                                             SetWaterLightMode(1);
                                             UARTString("Set waterlight to mode1(Left)!\n");
                                             SetWaterLightSpeed(0x003fffff);
                                             UARTString("Set waterlight speed to defualt!\n");
                                           }
                                         else 
                                           {
                                             SetWaterLightMode(4);
                                             UARTString("Waterlight shutdown!\n");
                                           }
                                        flag15=~flag15;
                                        Keyboard_keydata_clear=1; 
                                      };  
                        break;

                   default : 	{UARTString("No Function_key is pushed!\n");
                               Keyboard_keydata_clear=1;                                   
                              }

                   }
   
}
