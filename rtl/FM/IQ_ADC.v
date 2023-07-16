module 	IQ_ADC(
	input 		   	 ADC_CLK,
	input 		   	 RSTn,	
	output reg [11:0]msi_i,
	output reg [11:0]msi_q,
	output reg       data_clk
);

	wire eoc;		
	wire[11:0]adc_data;	
	reg  [2:0]Channel;
	reg [11:0]msi_i_dly;
	
	
	//ADC Channel 011 MICin		
	//	  Channel 100 msi_q
	//	  Channel 110 msi_i
	
	ADC ADC( 	
		.eoc(eoc),//transfer complete signal, output	
		.dout(adc_data),//ADC Data out, output 		
		.clk(ADC_CLK),//input		
		.pd(1'b0), 		
		.s(Channel), //channel select		
		.soc(1'b1)//ADC enable signal, high active		
	);
	
	always@(posedge eoc or negedge RSTn )
  		if (!RSTn)
      		Channel <= 3'b110;
      	else if (Channel == 3'b110)
           	Channel <= 3'b100;      	
		else if (Channel == 3'b100)
           	Channel <= 3'b110;       	
     	  
	always@(posedge eoc or negedge RSTn)
		if(!RSTn)begin
			msi_i_dly <= 12'd0;
			msi_i     <= 12'd0;
			msi_q     <= 12'd0;
		end
		else
			case (Channel)
				3'b110:
					msi_i_dly <= adc_data;   
				3'b100:begin 
					msi_q <= adc_data;
					msi_i <= msi_i_dly;
				end
			endcase 
			
	always@(posedge eoc or negedge RSTn)
		if(!RSTn)
			data_clk <= 1'b0;
		else
			case (Channel)
				3'b110: data_clk <= 1'b0;
				3'b100: data_clk <= 1'b1;
			endcase

endmodule







		
     		