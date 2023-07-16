/*      
        ALIENTEK 2.4' TFTLCD IN CORTEXM0_SOC
        MAIN SIGNALS: LCD_CS, LCD_RS, LCD_WR, LCD_RD, LCD_RST, LCD_BL_CTR, LCD_DATA[16]
        2019.12.18
*/

#include "code_def.h"
#include <stdint.h>
#include <stdio.h>
#include "lcdfont.h"

uint16_t POINT_COLOR = 0x0000;
uint16_t BACK_COLOR  = 0xFFFF;

_lcd_dev lcddev;

void MakeData( uint16_t data ) {
    LCD->LCD_DATA[0] = ( data >> 0 ) & 1 ;
    LCD->LCD_DATA[1] = ( data >> 1 ) & 1 ;
    LCD->LCD_DATA[2] = ( data >> 2 ) & 1 ;
    LCD->LCD_DATA[3] = ( data >> 3 ) & 1 ;
    LCD->LCD_DATA[4] = ( data >> 4 ) & 1 ;
    LCD->LCD_DATA[5] = ( data >> 5 ) & 1 ;
    LCD->LCD_DATA[6] = ( data >> 6 ) & 1 ;
    LCD->LCD_DATA[7] = ( data >> 7 ) & 1 ;
    LCD->LCD_DATA[8] = ( data >> 8 ) & 1 ;
    LCD->LCD_DATA[9] = ( data >> 9 ) & 1 ;
    LCD->LCD_DATA[10] = ( data >> 10 ) & 1;
    LCD->LCD_DATA[11] = ( data >> 11 ) & 1;
    LCD->LCD_DATA[12] = ( data >> 12 ) & 1;
    LCD->LCD_DATA[13] = ( data >> 13 ) & 1;
    LCD->LCD_DATA[14] = ( data >> 14 ) & 1;
    LCD->LCD_DATA[15] = ( data >> 15 ) & 1;
}

uint16_t ReadData() {
	uint16_t ans = 0;
	for (int i = 0; i < 16; i++) {
		if (LCD->LCD_DATA[i] == 1)
			ans += (1 << i);
	}
	return ans;
}

//  WRITE REG FUNCTION
void LCD_WR_REG( uint16_t data ) {
  	LCD_RS_CLR; 
 	LCD_CS_CLR; 
	//Delay(50);
	MakeData( data );
	LCD_WR_CLR;
	//Delay(50);
	LCD_WR_SET; 
 	LCD_CS_SET;         
}

//  WRITE DATA
void LCD_WR_DATA( uint16_t data ) {
  	LCD_RS_SET;
	LCD_CS_CLR;
	//Delay(50);
	MakeData( data );
	LCD_WR_CLR;
	//Delay(50);
	LCD_WR_SET;
	LCD_CS_SET;
}

uint16_t LCD_RD_DATA(void)
{										   
	uint16_t t;

	LCD_RS_SET;
	LCD_CS_CLR;
	LCD_RD_CLR;			   
	t=ReadData();
	//Delay(50);  
	LCD_RD_SET;
	LCD_CS_SET; 

	return t;  
}

//  WRITE REG VALUE
//  LCD_Reg : NUMBER OF REG
//  LCD_RegValue : VALUE NEEDED TO BE WRITTEN
void LCD_WriteReg( uint16_t LCD_Reg, uint16_t LCD_RegValue ) {
	LCD_WR_REG( LCD_Reg );  
	LCD_WR_DATA( LCD_RegValue );	    		 
} 

uint16_t LCD_ReadReg(uint16_t LCD_Reg)
{										   
 	LCD_WR_REG(LCD_Reg);   
	//Delay(50);
	return LCD_RD_DATA(); 
}

//  BEGIN TO WRITE GRAM
void LCD_WriteRAM_Prepare( void ) {
    LCD_WR_REG( 0x2c );
}

//  LCD WRITE GRAM
void LCD_WriteRAM( uint16_t RGB_Code ) {
    LCD_WR_DATA( RGB_Code );
}

//  LCD START DISPLAY
void LCD_DisplayOn( void ) {
    LCD_WR_REG( 0x29 );
}

//  LCD END DISPLAY
void LCD_DisplayOff( void ) {
    LCD_WR_REG( 0x28 );
}

//  LCD SET CURSOR POSTION
void LCD_SetCursor( uint16_t Xpos, uint16_t Ypos ) {
    LCD_WR_REG( 0X2a ); 
	LCD_WR_DATA( Xpos >> 8 );
    LCD_WR_DATA( Xpos & 0XFF ); 			 
	LCD_WR_REG( 0x2b ); 
	LCD_WR_DATA( Ypos >> 8 );
    LCD_WR_DATA( Ypos & 0XFF ); 
}

//  SET LCD SCANNING DIRECTION 

void LCD_DrawPoint(uint16_t x,uint16_t y)
{
	LCD_SetCursor(x,y);		
	LCD_WriteRAM_Prepare();	
	LCD_WR_DATA(POINT_COLOR); 
}	 

void LCD_Fast_DrawPoint(uint16_t x,uint16_t y,uint16_t color)
{	   
	LCD_WR_REG(lcddev.setxcmd); 
	LCD_WR_DATA(x>>8);LCD_WR_DATA(x&0XFF);  			 
	LCD_WR_REG(lcddev.setycmd); 
	LCD_WR_DATA(y>>8);LCD_WR_DATA(y&0XFF);
	LCD_RS_CLR;
 	LCD_CS_CLR; 
	MakeData(lcddev.wramcmd); 
	LCD_WR_CLR; 
	LCD_WR_SET; 
 	LCD_CS_SET; 
	LCD_WR_DATA(color);		
}

void LCD_Display_Dir(uint8_t dir)
{
	if(dir==0)			
	{
		lcddev.dir=0;	
		lcddev.width=240;
		lcddev.height=320;
		lcddev.wramcmd=0X2C;
	 	lcddev.setxcmd=0X2A;
		lcddev.setycmd=0X2B;  	 
		if(lcddev.id==0X6804||lcddev.id==0X5310)
		{
			lcddev.width=320;
			lcddev.height=480;
		}
		
	}else 				
	{	  				
		lcddev.dir=1;	
		lcddev.width=320;
		lcddev.height=240;
		lcddev.wramcmd=0X2C;
	 	lcddev.setxcmd=0X2A;
		lcddev.setycmd=0X2B;  
	} 
	// LCD_Scan_Dir(DFT_SCAN_DIR);	
}	 

void LCD_Set_Window(uint16_t sx,uint16_t sy,uint16_t width,uint16_t height)
{     
	uint16_t twidth,theight;
	twidth=sx+width-1;
	theight=sy+height-1;
	LCD_WR_REG(lcddev.setxcmd); 
	LCD_WR_DATA(sx>>8); 
	LCD_WR_DATA(sx&0XFF);	 
	LCD_WR_DATA(twidth>>8); 
	LCD_WR_DATA(twidth&0XFF);  
	LCD_WR_REG(lcddev.setycmd); 
	LCD_WR_DATA(sy>>8); 
	LCD_WR_DATA(sy&0XFF); 
	LCD_WR_DATA(theight>>8); 
	LCD_WR_DATA(theight&0XFF); 
  LCD_WR_REG(0x2c);
}
/******************************************************************************
      函数说明：显示图片
      入口数据：x,y起点坐标
                length 图片长度
                width  图片宽度
                pic[]  图片数组    
      返回值：  无
******************************************************************************/
void LCD_ShowPicture(uint16_t x,uint16_t y,uint16_t length,uint16_t width,const uint8_t pic[])
{
	uint8_t picH,picL;
	uint16_t i,j;
	uint32_t k=0;
	LCD_Set_Window(x,y,length,width);
	for(i=0;i<length;i++)
	{
		for(j=0;j<width;j++)
		{
			picH=pic[k*2];
			picL=pic[k*2+1];
			LCD_WR_DATA(picH<<8|picL);
			k++;
		}
	}			
}

/******************************************************************************
      函数说明：显示单个32x32汉字
      入口数据：x,y显示坐标
                *s 要显示的汉字
                fc 字的颜色
                bc 字的背景色
                sizey 字号
                mode:  0非叠加模式  1叠加模式
      返回值：  无
******************************************************************************/
void LCD_ShowChinese32x32(uint16_t x,uint16_t y,uint8_t s,uint16_t fc,uint16_t bc,uint8_t sizey,uint8_t mode)
{
	uint8_t i,j,m=0;
	uint16_t k;
	uint16_t HZnum;//汉字数目
	uint16_t TypefaceNum;//一个字符所占字节大小
	uint16_t x0=x;
	TypefaceNum=(sizey/8+((sizey%8)?1:0))*sizey;
	HZnum=sizeof(tfont32)/sizeof(typFNT_GB32);	//统计汉字数目
	for(k=0;k<HZnum;k++) 
	{
		if ((tfont32[k].Index== s))
		{ 	
			LCD_Set_Window(x,y,sizey,sizey);
			for(i=0;i<TypefaceNum;i++)
			{
				for(j=0;j<8;j++)
				{	
					if(!mode)//非叠加方式
					{
						if(tfont32[k].Msk[i]&(0x01<<j))LCD_WR_DATA(fc);
						else LCD_WR_DATA(bc);
						m++;
						if(m%sizey==0)
						{
							m=0;
							break;
						}
					}
					else//叠加方式
					{
						if(tfont32[k].Msk[i]&(0x01<<j))	LCD_Fast_DrawPoint(x,y,fc);//画一个点
						x++;
						if((x-x0)==sizey)
						{
							x=x0;
							y++;
							break;
						}
					}
				}
			}
		}				  	
		continue;  //查找到对应点阵字库立即退出，防止多个汉字重复取模带来影响
	}
}

/******************************************************************************
      函数说明：显示汉字串
      入口数据：x,y显示坐标
                *s 要显示的汉字串
                fc 字的颜色
                bc 字的背景色
                sizey 字号 可选 16 24 32
                mode:  0非叠加模式  1叠加模式
      返回值：  无
******************************************************************************/
void LCD_ShowChinese(uint16_t x,uint16_t y,uint8_t *s,uint16_t fc,uint16_t bc,uint8_t sizey,uint8_t mode)
{
	while(*s!=0)
	{

    if(sizey==32) LCD_ShowChinese32x32(x,y,*s,fc,bc,sizey,mode);
		else return;
		s+=1;
		y+=sizey;
	}
}

void LCD_Init(void)
{   
	LCD_RST_CLR;
	LCD_RST_SET;
	LCD_BL_CTR_SET;
	
	Delay_ms(50);					// delay 50 ms 
	//LCD_Scan_Dir(L2R_U2D);
	LCD_WR_REG(0XD3);				   
	lcddev.id=LCD_RD_DATA();	//dummy read 	
	lcddev.id=LCD_RD_DATA();	//读到0X00
	lcddev.id=LCD_RD_DATA();   	//读取93								   
	lcddev.id<<=8;
	lcddev.id|=LCD_RD_DATA();  	//读取41 	
	
	LCD_WR_REG(0xCF);  
	LCD_WR_DATA(0x00); 
	LCD_WR_DATA(0xC1); 
	LCD_WR_DATA(0X30); 
	LCD_WR_REG(0xED);  
	LCD_WR_DATA(0x64); 
	LCD_WR_DATA(0x03); 
	LCD_WR_DATA(0X12); 
	LCD_WR_DATA(0X81); 
	LCD_WR_REG(0xE8);  
	LCD_WR_DATA(0x85); 
	LCD_WR_DATA(0x10); 
	LCD_WR_DATA(0x7A); 
	LCD_WR_REG(0xCB);  
	LCD_WR_DATA(0x39); 
	LCD_WR_DATA(0x2C); 
	LCD_WR_DATA(0x00); 
	LCD_WR_DATA(0x34); 
	LCD_WR_DATA(0x02); 
	LCD_WR_REG(0xF7);  
	LCD_WR_DATA(0x20); 
	LCD_WR_REG(0xEA);  
	LCD_WR_DATA(0x00); 
	LCD_WR_DATA(0x00); 
	LCD_WR_REG(0xC0);    //Power control 
	LCD_WR_DATA(0x1B);   //VRH[5:0] 
	LCD_WR_REG(0xC1);    //Power control 
	LCD_WR_DATA(0x01);   //SAP[2:0];BT[3:0] 
	LCD_WR_REG(0xC5);    //VCM control 
	LCD_WR_DATA(0x30); 	 //3F
	LCD_WR_DATA(0x30); 	 //3C
	LCD_WR_REG(0xC7);    //VCM control2 
	LCD_WR_DATA(0XB7); 
	LCD_WR_REG(0x36);    // Memory Access Control 
	LCD_WR_DATA(0x08|(DFT_SCAN_DIR<<4));
	LCD_WR_REG(0x3A);   
	LCD_WR_DATA(0x55); 
	LCD_WR_REG(0xB1);   
	LCD_WR_DATA(0x00);   
	LCD_WR_DATA(0x1A); 
	LCD_WR_REG(0xB6);    // Display Function Control 
	LCD_WR_DATA(0x0A); 
	LCD_WR_DATA(0xA2); 
	LCD_WR_REG(0xF2);    // 3Gamma Function Disable 
	LCD_WR_DATA(0x00); 
	LCD_WR_REG(0x26);    //Gamma curve selected 
	LCD_WR_DATA(0x01); 
	LCD_WR_REG(0xE0);    //Set Gamma 
	LCD_WR_DATA(0x0F); 
	LCD_WR_DATA(0x2A); 
	LCD_WR_DATA(0x28); 
	LCD_WR_DATA(0x08); 
	LCD_WR_DATA(0x0E); 
	LCD_WR_DATA(0x08); 
	LCD_WR_DATA(0x54); 
	LCD_WR_DATA(0XA9); 
	LCD_WR_DATA(0x43); 
	LCD_WR_DATA(0x0A); 
	LCD_WR_DATA(0x0F); 
	LCD_WR_DATA(0x00); 
	LCD_WR_DATA(0x00); 
	LCD_WR_DATA(0x00); 
	LCD_WR_DATA(0x00); 		 
	LCD_WR_REG(0XE1);    //Set Gamma 
	LCD_WR_DATA(0x00); 
	LCD_WR_DATA(0x15); 
	LCD_WR_DATA(0x17); 
	LCD_WR_DATA(0x07); 
	LCD_WR_DATA(0x11); 
	LCD_WR_DATA(0x06); 
	LCD_WR_DATA(0x2B); 
	LCD_WR_DATA(0x56); 
	LCD_WR_DATA(0x3C); 
	LCD_WR_DATA(0x05); 
	LCD_WR_DATA(0x10); 
	LCD_WR_DATA(0x0F); 
	LCD_WR_DATA(0x3F); 
	LCD_WR_DATA(0x3F); 
	LCD_WR_DATA(0x0F); 
	LCD_WR_REG(0x2B); 
	LCD_WR_DATA(0x00);
	LCD_WR_DATA(0x00);
	LCD_WR_DATA(0x00);
	LCD_WR_DATA(0xef);
	LCD_WR_REG(0x2A); 
	LCD_WR_DATA(0x00);
	LCD_WR_DATA(0x00);
	LCD_WR_DATA(0x01);
	LCD_WR_DATA(0x3f);	 
	LCD_WR_REG(0x11); //Exit Sleep
	Delay_ms(120);
	LCD_WR_REG(0x29); //display on
	
  //LCD_Scan_Dir(L2R_U2D);
	LCD_Display_Dir(1);
  LCD_Clear(WHITE);
}  		  

void LCD_Clear(uint16_t color)
{
	uint32_t index=0;      
	uint32_t totalpoint=lcddev.width;
	totalpoint*=lcddev.height; 			
	if((lcddev.id==0X6804)&&(lcddev.dir==1))
	{						    
 		lcddev.dir=0;	 
 		lcddev.setxcmd=0X2A;
		lcddev.setycmd=0X2B;  	 			
		LCD_SetCursor(0x00,0x0000);		  
 		lcddev.dir=1;	 
  		lcddev.setxcmd=0X2B;
		lcddev.setycmd=0X2A;  	 
 	}else LCD_SetCursor(0x00,0x0000);	 
	LCD_WriteRAM_Prepare();     			  	  
	for(index=0;index<totalpoint;index++)LCD_WR_DATA(color);	
} 

void LCD_Fill(uint16_t sx,uint16_t sy,uint16_t ex,uint16_t ey,uint16_t color)
{          
	uint16_t i,j;
	uint16_t xlen=0;
	xlen=ex-sx+1;	 
	for(i=sy;i<=ey;i++)
	{
	 	LCD_SetCursor(sx,i);      				
		LCD_WriteRAM_Prepare();     				  
		for(j=0;j<xlen;j++)LCD_WR_DATA(color);		    
	}
}  

void LCD_Color_Fill(uint16_t sx,uint16_t sy,uint16_t ex,uint16_t ey,uint16_t *color)
{  
	uint16_t height,width;
	uint16_t i,j;
	width=ex-sx+1; 			
	height=ey-sy+1;			
 	for(i=0;i<height;i++)
	{
 		LCD_SetCursor(sx,sy+i);   	 
		LCD_WriteRAM_Prepare();     
		for(j=0;j<width;j++)LCD_WR_DATA(color[i*width+j]);
	}	  
} 

void LCD_DrawLine(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2)
{
	uint16_t t; 
	int xerr=0,yerr=0,delta_x,delta_y,distance; 
	int incx,incy,uRow,uCol; 
	delta_x=x2-x1; 
	delta_y=y2-y1; 
	uRow=x1; 
	uCol=y1; 
	if(delta_x>0)incx=1; 
	else if(delta_x==0)incx=0;
	else {incx=-1;delta_x=-delta_x;} 
	if(delta_y>0)incy=1; 
	else if(delta_y==0)incy=0;
	else{incy=-1;delta_y=-delta_y;} 
	if( delta_x>delta_y)distance=delta_x; 
	else distance=delta_y; 
	for(t=0;t<=distance+1;t++ )
	{  
		LCD_DrawPoint(uRow,uCol);
		xerr+=delta_x ; 
		yerr+=delta_y ; 
		if(xerr>distance) 
		{ 
			xerr-=distance; 
			uRow+=incx; 
		} 
		if(yerr>distance) 
		{ 
			yerr-=distance; 
			uCol+=incy; 
		} 
	}  
}    
								  
void LCD_ShowChar(uint16_t x,uint16_t y,uint8_t num,uint8_t size,uint8_t mode)
{  							  
    uint8_t temp,t1,t;
	uint16_t y0=y;
	uint8_t csize=(size/8+((size%8)?1:0))*(size/2);			
 	num=num-' ';
	for(t=0;t<csize;t++)
	{   
		if(size==12)temp=asc2_1206[num][t]; 	 	
		else if(size==16)temp=asc2_1608[num][t];	
		else if(size==24)temp=asc2_2412[num][t];	
		else return;								
		for(t1=0;t1<8;t1++)
		{			    
			if(temp&0x80)LCD_Fast_DrawPoint(x,y,BROWN);
			else if(mode==0)LCD_Fast_DrawPoint(x,y,BACK_COLOR);
			temp<<=1;
			y++;
			if(y>=lcddev.height)return;		
			if((y-y0)==size)
			{
				y=y0;
				x++;
				if(x>=lcddev.width)return;	
				break;
			}
		}  	 
	}  	    	   	 	  
}   

uint32_t LCD_Pow(uint8_t m,uint8_t n)
{
	uint32_t result=1;	 
	while(n--)result*=m;    
	return result;
}			 
	 
void LCD_ShowNum(uint16_t x,uint16_t y,uint32_t num,uint8_t len,uint8_t size)
{         	
	uint8_t t,temp;
	uint8_t enshow=0;						   
	for(t=0;t<len;t++)
	{
		temp=(num/LCD_Pow(10,len-t-1))%10;
		if(enshow==0&&t<(len-1))
		{
			if(temp==0)
			{
				LCD_ShowChar(x+(size/2)*t,y,' ',size,0);
				continue;
			}else enshow=1; 
		 	 
		}
	 	LCD_ShowChar(x+(size/2)*t,y,temp+'0',size,0); 
	}
} 

void LCD_ShowxNum(uint16_t x,uint16_t y,uint32_t num,uint8_t len,uint8_t size,uint8_t mode)
{  
	uint8_t t,temp;
	uint8_t enshow=0;						   
	for(t=0;t<len;t++)
	{
		temp=(num/LCD_Pow(10,len-t-1))%10;
		if(enshow==0&&t<(len-1))
		{
			if(temp==0)
			{
				if(mode&0X80)LCD_ShowChar(x+(size/2)*t,y,'0',size,mode&0X01);  
				else LCD_ShowChar(x+(size/2)*t,y,' ',size,mode&0X01);  
 				continue;
			}else enshow=1; 
		 	 
		}
	 	LCD_ShowChar(x+(size/2)*t,y,temp+'0',size,mode&0X01); 
	}
}   
void LCD_ShowString(uint16_t x,uint16_t y,uint16_t width,uint16_t height,uint8_t size,uint8_t *p)
{         
	uint8_t x0=x;
	width+=x;
	height+=y;
    while((*p<='~')&&(*p>=' '))
    {       
        if(x>=width){x=x0;y+=size;}
        if(y>=height)break;
        LCD_ShowChar(x,y,*p,size,0);
        x+=size/2;
        p++;
    }  
}

void LCD_WIN2()
{
  LCD_Clear(WHITE);
  Delay_ms(30);
  LCD_DrawLine(80,10,160,240);
	LCD_DrawLine(160,240,240,10);
  LCD_Fast_DrawPoint(160,160,RED);
	LCD_ShowString(40,100,240,24,24,p);
	LCD_ShowPicture(280,160,26,80,gImage_pic);

	Delay_ms(3000);
	LCD_Clear(WHITE);
  //LCD_DrawLine(0,0,0,240);
  LCD_ShowxNum(10,0,15,2,16,0);
	//LCD_DrawLine(1,0,1,240);
  LCD_ShowChinese32x32(3,16,'j',RED,BLUE,32,0);

  //uint8_t k151[3]="15";
 // LCD_ShowString(3,32,32,16,16,k151);
  LCD_ShowChinese(3,48,k15,GREEN,YELLOW, 32, 0);
  LCD_DrawLine(35,16,35,240);
  //LCD_DrawLine(36,0,36,240);
	//LCD_DrawLine(37,0,37,240);
  LCD_ShowChinese32x32(38,0,'j',RED,BLUE,32,0);
  LCD_ShowChinese(38,48,k14,GREEN,YELLOW, 32, 0);
  LCD_DrawLine(70,0,70,240);
  //LCD_DrawLine(71,0,71,240);
	//LCD_DrawLine(72,0,72,240);
  LCD_ShowChinese32x32(73,0,'j',RED,BLUE,32,0);
  LCD_ShowChinese(73,48,k13,GREEN,YELLOW, 32, 0);
  LCD_DrawLine(105,0,105,240);
  //LCD_DrawLine(106,0,106,240);
	//LCD_DrawLine(107,0,107,240);
  LCD_ShowChinese32x32(108,0,'j',RED,BLUE,32,0);
  LCD_ShowChinese(108,48,k11,GREEN,YELLOW, 32, 0);
  LCD_DrawLine(140,0,140,240);
  //LCD_DrawLine(141,0,141,240);
	//LCD_DrawLine(142,0,142,240);
  LCD_ShowChinese32x32(143,0,'j',RED,BLUE,32,0);
  LCD_ShowChinese(143,48,k10,GREEN,YELLOW, 32, 0);
  LCD_DrawLine(175,0,175,240);
  //LCD_DrawLine(176,0,176,240);
	//LCD_DrawLine(177,0,177,240);
  LCD_ShowChinese32x32(178,0,'j',RED,BLUE,32,0);
  LCD_ShowChinese(178,48,k09,GREEN,YELLOW, 32, 0);
  LCD_DrawLine(210,0,210,240);
  //LCD_DrawLine(211,0,211,240);
	//LCD_DrawLine(212,0,212,240);
  //LCD_DrawLine(213,0,213,240);
	//LCD_DrawLine(214,0,214,240);
  LCD_ShowChinese32x32(215,0,'j',RED,BLUE,32,0);
  LCD_ShowChinese(215,48,k07,GREEN,YELLOW, 32, 0);
  LCD_DrawLine(249,0,249,240);
  LCD_ShowChinese32x32(250,0,'j',RED,BLUE,32,0);
  LCD_ShowChinese(250,48,k06,GREEN,YELLOW, 32, 0);
  LCD_DrawLine(284,0,284,240);
  LCD_ShowChinese32x32(285,0,'j',RED,BLUE,32,0);
  LCD_ShowChinese(285,48,k05,GREEN,YELLOW, 32, 0);
  LCD_DrawLine(317,0,317,240);
}

void LCD_WIN1()
{
  LCD_Clear(WHITE);
  LCD_ShowPicture(80,82,40,38,gImage_11);
  LCD_ShowPicture(120,82,40,38,gImage_12);
  LCD_ShowPicture(160,82,40,38,gImage_13);
  LCD_ShowPicture(200,82,40,38,gImage_14);
  LCD_ShowPicture(80,120,40,38,gImage_21);
  LCD_ShowPicture(120,120,40,38,gImage_22);
  LCD_ShowPicture(160,120,40,38,gImage_23);
  LCD_ShowPicture(200,120,40,38,gImage_24);
  Delay_ms(3000);
  LCD_Init();
}



