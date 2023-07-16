module FIR(
	input eoc,
	input RSTn,	
	input [11:0]fir_in,
	
	output [11:0]audio_out
);
		


reg[11:0] delay_pipeline[1:29] ;
wire [11:0] coeff [1:29];

assign coeff[1 ] = 12'd48   ;
assign coeff[2 ] = 12'd48   ;
assign coeff[3 ] = 12'd50   ;
assign coeff[4 ] = 12'd53   ;
assign coeff[5 ] = 12'd56   ;
assign coeff[6 ] = 12'd53   ;
assign coeff[7 ] = 12'd42   ;
assign coeff[8 ] = 12'd24   ;
assign coeff[9 ] = 12'd10   ;
assign coeff[10] = 12'd15   ;
assign coeff[11] = 12'd52   ;
assign coeff[12] = 12'd119  ;
assign coeff[13] = 12'd199  ;
assign coeff[14] = 12'd264  ;
assign coeff[15] = 12'd290  ;
assign coeff[16] = 12'd264  ;
assign coeff[17] = 12'd199  ;
assign coeff[18] = 12'd119  ;
assign coeff[19] = 12'd52   ;
assign coeff[20] = 12'd15   ;
assign coeff[21] = 12'd10   ;
assign coeff[22] = 12'd24   ;
assign coeff[23] = 12'd42   ;
assign coeff[24] = 12'd53   ;
assign coeff[25] = 12'd56   ;
assign coeff[26] = 12'd53   ;
assign coeff[27] = 12'd50   ;
assign coeff[28] = 12'd48   ;
assign coeff[29] = 12'd48   ;


always @ (posedge eoc or negedge RSTn)
	if(!RSTn)
	   {delay_pipeline[1 ],
		delay_pipeline[2 ],
		delay_pipeline[3 ],	
		delay_pipeline[4 ],	
		delay_pipeline[5 ],	
		delay_pipeline[6 ],	
		delay_pipeline[7 ],	
		delay_pipeline[8 ],	
		delay_pipeline[9 ],	
		delay_pipeline[10],	
		delay_pipeline[11],	
		delay_pipeline[12],	
		delay_pipeline[13],	
		delay_pipeline[14],	
		delay_pipeline[15],	
		delay_pipeline[16],	
		delay_pipeline[17],	
		delay_pipeline[18],	
        delay_pipeline[19],
        delay_pipeline[20],
        delay_pipeline[21],
        delay_pipeline[22],
        delay_pipeline[23],
        delay_pipeline[24],
        delay_pipeline[25],
        delay_pipeline[26],
        delay_pipeline[27],
        delay_pipeline[28],
        delay_pipeline[29]} = {29{12'd0}};
	else
	   {delay_pipeline[1 ],
		delay_pipeline[2 ],
		delay_pipeline[3 ],
		delay_pipeline[4 ],
		delay_pipeline[5 ],
		delay_pipeline[6 ],
		delay_pipeline[7 ],
		delay_pipeline[8 ],
		delay_pipeline[9 ],
        delay_pipeline[10],
        delay_pipeline[11],
        delay_pipeline[12],
        delay_pipeline[13],
        delay_pipeline[14],
        delay_pipeline[15],
        delay_pipeline[16],
        delay_pipeline[17],
        delay_pipeline[18],
        delay_pipeline[19],
        delay_pipeline[20],
        delay_pipeline[21],
        delay_pipeline[22],
        delay_pipeline[23],
        delay_pipeline[24],
        delay_pipeline[25],
        delay_pipeline[26],
        delay_pipeline[27],
        delay_pipeline[28],
        delay_pipeline[29]}
		=
	   {fir_in,
		delay_pipeline[1 ],
		delay_pipeline[2 ],
		delay_pipeline[3 ],
        delay_pipeline[4 ],
        delay_pipeline[5 ],
        delay_pipeline[6 ],
        delay_pipeline[7 ],
        delay_pipeline[8 ],
        delay_pipeline[9 ],
         delay_pipeline[10],
         delay_pipeline[11],
         delay_pipeline[12],
         delay_pipeline[13],
         delay_pipeline[14],
         delay_pipeline[15],
         delay_pipeline[16],
         delay_pipeline[17],
         delay_pipeline[18],
         delay_pipeline[19],
         delay_pipeline[20],
         delay_pipeline[21],
         delay_pipeline[22],
         delay_pipeline[23],
         delay_pipeline[24],
         delay_pipeline[25],
         delay_pipeline[26],
         delay_pipeline[27],
         delay_pipeline[28]};
		 
reg [23:0] multi_data[1:29];

genvar i;
generate
for(i = 1; i < 30; i = i + 1)begin:Block1
	always @ (posedge eoc or negedge RSTn)
		if(!RSTn)
			multi_data[i] <= 24'd0;
		else
			multi_data[i] <= delay_pipeline[i] * coeff[i];			
end	
endgenerate

reg [23:0]sum;

always @ (posedge eoc or negedge RSTn)
		if(!RSTn)
			sum <= 24'd0;
		else
			sum = multi_data[1 ]   +
				  multi_data[2 ]   +
                  multi_data[3 ]   +
                  multi_data[4 ]   +
                  multi_data[5 ]   +
                  multi_data[6 ]   +
                  multi_data[7 ]   +
                  multi_data[8 ]   +
                  multi_data[9 ]   +
                  multi_data[10]   +
                  multi_data[11]   +
                  multi_data[12]   +
                  multi_data[13]   +
                  multi_data[14]   +
                  multi_data[15]   +
                  multi_data[16]   +
                  multi_data[17]   +
                  multi_data[18]   +
                  multi_data[19]   +
                  multi_data[20]   +
                  multi_data[21]   +
                  multi_data[22]   +
                  multi_data[23]   +
                  multi_data[24]   +
                  multi_data[25]   +
                  multi_data[26]   +
                  multi_data[27]   +
                  multi_data[28]   +
                  multi_data[29];                   
                 
assign audio_out = sum[23:12];
endmodule