module FM_DEMOD(
	input data_clk,
	input RSTn,
	input [11:0]msi_i,
	input [11:0]msi_q,
	
	output [11:0]demod_data,	
	output probe1

);

	reg signed [12:0]msi_i_dly1;
	reg signed [12:0]msi_i_dly2;
	reg signed [12:0]msi_q_dly1;
	reg signed [12:0]msi_q_dly2;
	
	wire signed [25:0] product1;
	wire signed [25:0] product2;
	reg  signed [25:0] sub[0:31];	
	wire signed [30:0] sum;		
	
	

	always @ (posedge data_clk or negedge RSTn)
		if(!RSTn)begin
			msi_i_dly1 <= 12'd0;
			msi_i_dly2 <= 12'd0;
		end
		else begin
			msi_i_dly1 <= {1'b0,msi_i};
			msi_i_dly2 <= msi_i_dly1;
		end
		
	always @ (posedge data_clk or negedge RSTn)
		if(!RSTn)begin
			msi_q_dly1 <= 12'd0;
			msi_q_dly2 <= 12'd0;
		end
		else begin
			msi_q_dly1 <= {1'b0,msi_q};
			msi_q_dly2 <= msi_q_dly1;
		end
		
	assign product1 = msi_i_dly2 * msi_q_dly1;
	assign product2 = msi_i_dly1 * msi_q_dly2;	
	
	genvar i;	
	generate 	
	for(i = 0 ; i < 32; i = i + 1) begin :gen_sub	
		always @ (posedge data_clk or negedge RSTn)	
			if(!RSTn)		
				sub[i] <= 30'd0;					
			else if(i == 0)				
				sub[i] <= product1 - product2;				
			else 				
				sub[i] <= sub[i - 1];				
	end	
	endgenerate
		
	assign sum = sub[0]  + sub[1]   + sub [2]  +  sub[3]  +		
				 sub[4]  + sub[5]   + sub [6]  +  sub[7]  +	
				 sub[8]  + sub[9]   + sub [10] +  sub[11] +		
				 sub[12] + sub[13]  + sub [14] +  sub[15] +				 
				 sub[16] + sub[17]  + sub [18] +  sub[19] +		
				 sub[20] + sub[21]  + sub [22] +  sub[23] +	
				 sub[24] + sub[25]  + sub [26] +  sub[27] +		
				 sub[28] + sub[28]  + sub [30] +  sub[31] ;
						 			 
	assign demod_data = sum[30] ? 12'd0 : sum[25:13];		
	assign probe1 = sum[30];
	
endmodule
	