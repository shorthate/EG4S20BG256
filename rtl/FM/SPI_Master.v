module SPI_Master(
	input clk,			         //时钟信号 50M的时钟
	input RSTn,		            //复位信号 按键复位
	input [23:0]spi_data_FIFO,	//SPI_FIFO写入的数据
	input ena_write,	         //SPI_FIFO写入使能信号
	
	output     spi_en ,        //MSI写入使能信号 （EN）
	output reg spi_clk,	       //SPI的时钟信号（CLK）
	output     spi_data,	      //SPI的数据信号（DATA）
	output     FIFO_state      //FIFO状态信号
	);
	
//==============================================================
// Local Registe Declare 
//==============================================================
// SPI Interface  
	 reg     [2:0]       spi_clk_cnt    ;// SPI Clock Divider Count
	 reg     [4:0]       spi_data_cnt   ;// SPI Write Data Count
	
// State
    reg     [1:0]       state          ;// FSM Current State
	 reg     [1:0]       state_nxt      ;// ---   Next State      
    
//==============================================================
// Local Wire Declare 
//==============================================================
    wire               FIFOrd_en       ;// SPI_FIFO读出使能 
    wire               FIFOwr_en       ;// SPI_FIFO写入使能  
    wire               [23:0] FIFOdata ;// SPI_FIFO读出数据 
    wire               FIFOempty       ;// SPI_FIFO空状态信号 
    wire               FIFOfull        ;// SPI_FIFO满状态信号 
	 
//==============================================================
// Local Parameter Declare 
//==============================================================  
    localparam  ST_IDLE          = 2'b00;    // Idle  State 
    localparam  ST_WRITE_DATA    = 2'b01;    // Write Data
    localparam  ST_FINISH        = 2'b10;    // Finish State 
 
//==============================================================
// Input control / status
//==============================================================
 
//FIFO write control
	 assign FIFOwr_en = (~FIFOfull) & ena_write;
	 assign FIFOrd_en = (state == ST_WRITE_DATA) && (state_nxt == ST_FINISH) && (~FIFOempty);
	 assign FIFO_state = FIFOfull;
  
//input and output SPI_FIFO        
	 FIFO #(
		 .DW(24),
		 .DEP(16)
		 )SPI_FIFO(
		
	     .clock(clk),
	     .sclr(RSTn),
	     .rdreq(FIFOrd_en),
	     .wrreq(FIFOwr_en),
	     .full(FIFOfull),
	     .empty(FIFOempty),
	     .data(spi_data_FIFO),
	     .q(FIFOdata)
	 );  
//==============================================================
// Generate SPI Clock 
//==============================================================
//SPI_CLK divider
	 always @ (posedge clk or negedge RSTn)begin 
        if(!RSTn)
            spi_clk_cnt   <=  3'd0;
        else if(state==ST_WRITE_DATA)
            spi_clk_cnt   <=  (spi_clk_cnt == 3'd5) ? 2'd0 : spi_clk_cnt + 1'd1 ;
        else if(state==ST_FINISH)
            spi_clk_cnt   <=  spi_clk_cnt + 1'd1 ;
		  else 
		      spi_clk_cnt   <=  3'd0;
    end 

    always @ (posedge clk or negedge RSTn)begin 
        if(!RSTn)
            spi_clk <= 1'b0;
        else if(state==ST_WRITE_DATA) begin 
            if(spi_clk_cnt == 3'd2)
                spi_clk <= 1'b1;
            else if(spi_clk_cnt == 3'd5)  
                spi_clk <= 1'b0;            
            else                
                spi_clk <= spi_clk;            
        end
			   else 
                spi_clk <= 1'b0;
    end    
	
//==============================================================
// SPI FSM Part 1/3
//==============================================================   
    always @ (posedge clk or negedge RSTn) begin 
        if(!RSTn)
            state          <= ST_IDLE;
        else 
            state          <= state_nxt;        
    end
	 
//==============================================================
// SPI FSM Part 2/3
//==============================================================   
    always @ (*) begin
        case(state)
            ST_IDLE:
		               state_nxt = ~FIFOempty ? ST_WRITE_DATA : ST_IDLE;
				ST_WRITE_DATA:
		               state_nxt = (spi_data_cnt == 5'd24 && spi_clk_cnt == 3'd1) ? ST_FINISH :ST_WRITE_DATA;		
				ST_FINISH:
				         state_nxt = (spi_clk_cnt == 3'd6) ? ST_IDLE : ST_FINISH ;
				default:
			            state_nxt = ST_IDLE;
		endcase			            
     end	
//==============================================================
// SPI FSM Part 3/3
//==============================================================   
	 always @ (posedge clk or negedge RSTn) begin
		  if(!RSTn)
			   spi_data_cnt <= 5'd0;
		  else if(state == ST_WRITE_DATA)
		          spi_data_cnt <=  (spi_clk_cnt == 3'd5) ? spi_data_cnt + 1'b1 : spi_data_cnt ;
		  else
		      spi_data_cnt <= 5'd0;
     end
//==============================================================
// SPI Finish
//==============================================================
    assign    spi_en      =  ~(state == ST_WRITE_DATA);

//==============================================================
// SPI  Output
//==============================================================    
    assign    spi_data    =  FIFOdata[5'd23-spi_data_cnt];
	 
endmodule
