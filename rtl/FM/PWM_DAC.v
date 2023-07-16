module PWM_DAC(
	input pll_200m,
	input RSTn,
	input [12:0] audio_data,
	output PWM_Audio


);
	reg [12:0]cnt;

	always @ (posedge pll_200m or negedge RSTn)
		if(!RSTn)		
			cnt <= 13'd0;				
		else if(cnt == 13'b1_1111_1111_1111)				
			cnt <= 13'd0;			
		else		
			cnt <= cnt + 1'b1;		
			
	assign PWM_Audio = audio_data > cnt;
			
endmodule