module SegDecoder#(
	parameter CNT_WIDTH = 16,
	parameter CNT_MAX   = 16'd24999
	)(	

	input  wire       clk,
	input  wire       RSTn,
	input  wire [3:0] data_disp_3,//the leftmost seg data in
	input  wire [3:0] data_disp_2,
	input  wire [3:0] data_disp_1,
	input  wire [3:0] data_disp_0,
	
	output reg  [7:0] seg_bit_disp,
	output reg  [3:0] seg_sel	//seg_sel[3] = 0, the leftmost seg is valid
	
	
);

reg [CNT_WIDTH - 1:0]cnt;
reg             [1:0]seg_sel_cnt;
reg             [7:0]data_disp; 

always @(posedge clk or negedge RSTn)
	if(!RSTn)
		cnt <= 32'd0;
	else if(CNT_MAX == cnt)
		cnt <= 32'd0;
	else 
		cnt <= cnt + 1'b1;
		
always @(posedge clk or negedge RSTn)
	if(!RSTn)
		seg_sel_cnt <= 2'd0;
	else if(CNT_MAX == cnt)
		seg_sel_cnt <= seg_sel_cnt + 1'b1;

always @ (*)
	case (seg_sel_cnt)
		2'b00 : seg_sel = 4'b1110;
		2'b01 :	seg_sel = 4'b1101;
		2'b10 : seg_sel = 4'b1011;
		2'b11 : seg_sel = 4'b0111;		
	endcase

always @ (*)
	case (seg_sel_cnt)
		2'b00 : data_disp = data_disp_0;
		2'b01 :	data_disp = data_disp_1;
		2'b10 : data_disp = data_disp_2;
		2'b11 : data_disp = data_disp_3;
	endcase

always @ (*)
	case(data_disp)
		4'h0 : seg_bit_disp[6:0] = 7'h3f;
		4'h1 : seg_bit_disp[6:0] = 7'h06;
		4'h2 : seg_bit_disp[6:0] = 7'h5b;
		4'h3 : seg_bit_disp[6:0] = 7'h4f;
		4'h4 : seg_bit_disp[6:0] = 7'h66;
		4'h5 : seg_bit_disp[6:0] = 7'h6d;
		4'h6 : seg_bit_disp[6:0] = 7'h7d;
		4'h7 : seg_bit_disp[6:0] = 7'h07;
		4'h8 : seg_bit_disp[6:0] = 7'h7f;
		4'h9 : seg_bit_disp[6:0] = 7'h6f;
		4'ha : seg_bit_disp[6:0] = 7'h77;
		4'hb : seg_bit_disp[6:0] = 7'h7c;
		4'hc : seg_bit_disp[6:0] = 7'h39;
		4'hd : seg_bit_disp[6:0] = 7'h5e;
		4'he : seg_bit_disp[6:0] = 7'h79;
		4'hf : seg_bit_disp[6:0] = 7'h71;
		default :seg_bit_disp[6:0] = 7'h00;
	endcase			
	
always @(*)
	seg_bit_disp[7] = (seg_sel_cnt == 2'b01) ? 1'b1 : 1'b0;		
		
endmodule