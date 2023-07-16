module AHBlite_Decoder #(parameter Port0_en = 1,
                         parameter Port1_en = 1,
                         parameter Port2_en = 1,
                         parameter Port3_en = 1,
                         parameter Port4_en = 1,
                         parameter Port5_en = 1,
                         parameter Port6_en = 1,
                         parameter Port7_en = 1)
                        (input [31:0] HADDR,
                         output wire P0_HSEL,
                         output wire P1_HSEL,
                         output wire P2_HSEL,
                         output wire P3_HSEL,
                         output wire P4_HSEL,
                         output wire P5_HSEL,
                         output wire P6_HSEL,
                         output wire P7_HSEL);
    
    //RAMCODE-----------------------------------
    
    //0x00000000-0x0000ffff
    assign P0_HSEL = (HADDR[31:16] == 16'h0000) ? Port0_en : 1'b0;
    /***********************************/
    
    //RAMDATA-----------------------------
    //0X20000000-0X2000FFFF
    assign P1_HSEL = (HADDR[31:16] == 16'h2000) ? Port1_en : 1'b0;
    /***********************************/
    
    //WaterLight-----------------------------
    //0x40000000 WaterLight MODE
    //0x40000004 WaterLight SPEED
    assign P2_HSEL = (HADDR[31:4] == 28'h4000_000) ? Port2_en : 1'b0;
    
    
    //UART-----------------------------
    //0X40000010 UART RX DATA
    //0X40000014 UART TX STATE
    //0X40000018 UART TX DATA
    assign P3_HSEL = (HADDR[31:4] == 28'h4000_001) ? Port3_en : 1'b0;
    
    
    //0X40010000 LCD
    assign P4_HSEL = (HADDR[31:16] == 16'h4001)   ? Port4_en : 1'b0;
    
    
    //0X40020000 SEG
    assign P5_HSEL = (HADDR[31:16] == 16'h4002)   ? Port5_en : 1'b0;
    
    //0X40030000 MSI
    assign P6_HSEL = (HADDR[31:16] == 16'h4003)   ? Port6_en : 1'b0;
    
    //0X40040000 Keyboard
    assign P7_HSEL = (HADDR[31:16] == 16'h4004)   ? Port7_en : 1'b0;
    
endmodule
