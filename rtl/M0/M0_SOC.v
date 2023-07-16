module M0_SOC (input wire clk,
               input wire RSTn,
               inout wire SWDIO,
               input wire SWCLK,
               output wire [7:0]LED,
               output wire TXD,
               input wire RXD,
               output wire LCD_CS,
               output wire LCD_RS,
               output wire LCD_WR,
               output wire LCD_RD,
               output wire LCD_RST,
               output wire [15:0]LCD_DATA,
               output wire LCD_BL_CTR,
               input wire [3:0]col,
               output wire [3:0]row,
               output wire [7:0]seg_bit_disp,
               output wire [3:0]seg_sel,
               output wire MSI_REF,
               output wire spi_en,
               output wire spi_clk,
               output wire spi_data	,
               output wire PWM_Audio	,
               output wire probe1,
               output wire probe2);
    
    //------------------------------------------------------------------------------
    // DEBUG IOBUF
    //------------------------------------------------------------------------------
    
    wire SWDO;
    wire SWDOEN;
    wire SWDI;
    
    assign SWDI  = SWDIO;
    assign SWDIO = (SWDOEN) ?  SWDO : 1'bz;
    
    //------------------------------------------------------------------------------
    // Interrupt
    //------------------------------------------------------------------------------
    wire [31:0] IRQ;
    
    wire  key_interrupt;
    /*Connect the IRQ with Keyboard*/
    
    wire interrupt_UART;
    /*Connect the IRQ with UART*/
    assign IRQ = {30'b0,key_interrupt,interrupt_UART};
    /***************************/
    
    wire RXEV;
    assign RXEV = 1'b0;
    
    //------------------------------------------------------------------------------
    // RESET
    //------------------------------------------------------------------------------
    
    wire SYSRESETREQ;
    reg cpuresetn;
    
    always @(posedge clk or negedge RSTn)begin
        if (~RSTn) cpuresetn            <= 1'b0;
        else if (SYSRESETREQ) cpuresetn <= 1'b0;
        else cpuresetn                  <= 1'b1;
    end
    
    wire CDBGPWRUPREQ;
    reg CDBGPWRUPACK;
    
    always @(posedge clk or negedge RSTn)begin
        if (~RSTn) CDBGPWRUPACK <= 1'b0;
        else CDBGPWRUPACK       <= CDBGPWRUPREQ;
    end
    
    //------------------------------------------------------------------------------
    // AHB MASTER SIGNAL
    //------------------------------------------------------------------------------
    
    wire [31:0] HADDR;
    wire [2:0] HBURST;
    wire        HMASTLOCK;
    wire [3:0] HPROT;
    wire [2:0] HSIZE;
    wire [1:0] HTRANS;
    wire [31:0] HWDATA;
    wire        HWRITE;
    wire [31:0] HRDATA;
    wire        HRESP;
    wire        HREADY;
    
    //------------------------------------------------------------------------------
    // Instantiate Cortex-M0 processor logic level
    //------------------------------------------------------------------------------
    
    cortexm0ds_logic u_logic (
    
    // System inputs
    .FCLK           (clk),           //FREE running clock
    .SCLK           (clk),           //system clock
    .HCLK           (clk),           //AHB clock
    .DCLK           (clk),           //Debug clock
    .PORESETn       (RSTn),          //Power on reset
    .HRESETn        (cpuresetn),     //AHB and System reset
    .DBGRESETn      (RSTn),          //Debug Reset
    .RSTBYPASS      (1'b0),          //Reset bypass
    .SE             (1'b0),          // dummy scan enable port for synthesis
    
    // Power management inputs
    .SLEEPHOLDREQn  (1'b1),          // Sleep extension request from PMU
    .WICENREQ       (1'b0),          // WIC enable request from PMU
    .CDBGPWRUPACK   (CDBGPWRUPACK),  // Debug Power Up ACK from PMU
    
    // Power management outputs
    .CDBGPWRUPREQ   (CDBGPWRUPREQ),
    .SYSRESETREQ    (SYSRESETREQ),
    
    // System bus
    .HADDR          (HADDR[31:0]),
    .HTRANS         (HTRANS[1:0]),
    .HSIZE          (HSIZE[2:0]),
    .HBURST         (HBURST[2:0]),
    .HPROT          (HPROT[3:0]),
    .HMASTER        (),
    .HMASTLOCK      (HMASTLOCK),
    .HWRITE         (HWRITE),
    .HWDATA         (HWDATA[31:0]),
    .HRDATA         (HRDATA[31:0]),
    .HREADY         (HREADY),
    .HRESP          (HRESP),
    
    // Interrupts
    .IRQ            (IRQ),          //Interrupt
    .NMI            (1'b0),         //Watch dog interrupt
    .IRQLATENCY     (8'h0),
    .ECOREVNUM      (28'h0),
    
    // Systick
    .STCLKEN        (1'b0),
    .STCALIB        (26'h0),
    
    // Debug - JTAG or Serial wire
    // Inputs
    .nTRST          (1'b1),
    .SWDITMS        (SWDI),
    .SWCLKTCK       (SWCLK),
    .TDI            (1'b0),
    // Outputs
    .SWDO           (SWDO),
    .SWDOEN         (SWDOEN),
    
    .DBGRESTART     (1'b0),
    
    // Event communication
    .RXEV           (RXEV),         // Generate event when a DMA operation completed.
    .EDBGRQ         (1'b0)          // multi-core synchronous halt request
    
    );
    
    //------------------------------------------------------------------------------
    // AHBlite Interconncet
    //------------------------------------------------------------------------------
    
    //P0
    wire            HSEL_P0     ;
    wire    [31:0]  HADDR_P0    ;
    wire    [2:0]   HBURST_P0   ;
    wire            HMASTLOCK_P0;
    wire    [3:0]   HPROT_P0    ;
    wire    [2:0]   HSIZE_P0    ;
    wire    [1:0]   HTRANS_P0   ;
    wire    [31:0]  HWDATA_P0   ;
    wire            HWRITE_P0   ;
    wire            HREADY_P0   ;
    wire            HREADYOUT_P0;
    wire    [31:0]  HRDATA_P0   ;
    wire            HRESP_P0    ;
    
    //P1
    wire            HSEL_P1     ;
    wire    [31:0]  HADDR_P1    ;
    wire    [2:0]   HBURST_P1   ;
    wire            HMASTLOCK_P1;
    wire    [3:0]   HPROT_P1    ;
    wire    [2:0]   HSIZE_P1    ;
    wire    [1:0]   HTRANS_P1   ;
    wire    [31:0]  HWDATA_P1   ;
    wire            HWRITE_P1   ;
    wire            HREADY_P1   ;
    wire            HREADYOUT_P1;
    wire    [31:0]  HRDATA_P1   ;
    wire            HRESP_P1    ;
    
    //P2
    wire            HSEL_P2     ;
    wire    [31:0]  HADDR_P2    ;
    wire    [2:0]   HBURST_P2   ;
    wire            HMASTLOCK_P2;
    wire    [3:0]   HPROT_P2    ;
    wire    [2:0]   HSIZE_P2    ;
    wire    [1:0]   HTRANS_P2   ;
    wire    [31:0]  HWDATA_P2   ;
    wire            HWRITE_P2   ;
    wire            HREADY_P2   ;
    wire            HREADYOUT_P2;
    wire    [31:0]  HRDATA_P2   ;
    wire            HRESP_P2    ;
    
    //P3
    wire            HSEL_P3     ;
    wire    [31:0]  HADDR_P3    ;
    wire    [2:0]   HBURST_P3   ;
    wire            HMASTLOCK_P3;
    wire    [3:0]   HPROT_P3    ;
    wire    [2:0]   HSIZE_P3    ;
    wire    [1:0]   HTRANS_P3   ;
    wire    [31:0]  HWDATA_P3   ;
    wire            HWRITE_P3   ;
    wire            HREADY_P3   ;
    wire            HREADYOUT_P3;
    wire    [31:0]  HRDATA_P3   ;
    wire            HRESP_P3    ;
    
    //P4
    wire            HSEL_P4     ;
    wire    [31:0]  HADDR_P4    ;
    wire    [2:0]   HBURST_P4   ;
    wire            HMASTLOCK_P4;
    wire    [3:0]   HPROT_P4    ;
    wire    [2:0]   HSIZE_P4    ;
    wire    [1:0]   HTRANS_P4   ;
    wire    [31:0]  HWDATA_P4   ;
    wire            HWRITE_P4   ;
    wire            HREADY_P4   ;
    wire            HREADYOUT_P4;
    wire    [31:0]  HRDATA_P4   ;
    wire            HRESP_P4    ;
    
    //P5
    wire            HSEL_P5     ;
    wire    [31:0]  HADDR_P5    ;
    wire    [2:0]   HBURST_P5   ;
    wire            HMASTLOCK_P5;
    wire    [3:0]   HPROT_P5    ;
    wire    [2:0]   HSIZE_P5    ;
    wire    [1:0]   HTRANS_P5   ;
    wire    [31:0]  HWDATA_P5   ;
    wire            HWRITE_P5   ;
    wire            HREADY_P5   ;
    wire            HREADYOUT_P5;
    wire    [31:0]  HRDATA_P5   ;
    wire            HRESP_P5    ;
    
    //P6
    wire            HSEL_P6     ;
    wire    [31:0]  HADDR_P6    ;
    wire    [2:0]   HBURST_P6   ;
    wire            HMASTLOCK_P6;
    wire    [3:0]   HPROT_P6    ;
    wire    [2:0]   HSIZE_P6    ;
    wire    [1:0]   HTRANS_P6   ;
    wire    [31:0]  HWDATA_P6   ;
    wire            HWRITE_P6   ;
    wire            HREADY_P6   ;
    wire            HREADYOUT_P6;
    wire    [31:0]  HRDATA_P6   ;
    wire            HRESP_P6    ;
    
    //P7
    wire            HSEL_P7     ;
    wire    [31:0]  HADDR_P7    ;
    wire    [2:0]   HBURST_P7   ;
    wire            HMASTLOCK_P7;
    wire    [3:0]   HPROT_P7    ;
    wire    [2:0]   HSIZE_P7    ;
    wire    [1:0]   HTRANS_P7   ;
    wire    [31:0]  HWDATA_P7   ;
    wire            HWRITE_P7   ;
    wire            HREADY_P7   ;
    wire            HREADYOUT_P7;
    wire    [31:0]  HRDATA_P7   ;
    wire            HRESP_P7    ;
    
    AHBlite_Interconnect Interconncet(
    .HCLK           (clk),
    .HRESETn        (cpuresetn),
    
    // CORE SIDE
    .HADDR          (HADDR),
    .HTRANS         (HTRANS),
    .HSIZE          (HSIZE),
    .HBURST         (HBURST),
    .HPROT          (HPROT),
    .HMASTLOCK      (HMASTLOCK),
    .HWRITE         (HWRITE),
    .HWDATA         (HWDATA),
    .HRDATA         (HRDATA),
    .HREADY         (HREADY),
    .HRESP          (HRESP),
    
    // P0
    .HSEL_P0        (HSEL_P0),
    .HADDR_P0       (HADDR_P0),
    .HBURST_P0      (HBURST_P0),
    .HMASTLOCK_P0   (HMASTLOCK_P0),
    .HPROT_P0       (HPROT_P0),
    .HSIZE_P0       (HSIZE_P0),
    .HTRANS_P0      (HTRANS_P0),
    .HWDATA_P0      (HWDATA_P0),
    .HWRITE_P0      (HWRITE_P0),
    .HREADY_P0      (HREADY_P0),
    .HREADYOUT_P0   (HREADYOUT_P0),
    .HRDATA_P0      (HRDATA_P0),
    .HRESP_P0       (HRESP_P0),
    
    // P1
    .HSEL_P1        (HSEL_P1),
    .HADDR_P1       (HADDR_P1),
    .HBURST_P1      (HBURST_P1),
    .HMASTLOCK_P1   (HMASTLOCK_P1),
    .HPROT_P1       (HPROT_P1),
    .HSIZE_P1       (HSIZE_P1),
    .HTRANS_P1      (HTRANS_P1),
    .HWDATA_P1      (HWDATA_P1),
    .HWRITE_P1      (HWRITE_P1),
    .HREADY_P1      (HREADY_P1),
    .HREADYOUT_P1   (HREADYOUT_P1),
    .HRDATA_P1      (HRDATA_P1),
    .HRESP_P1       (HRESP_P1),
    
    // P2
    .HSEL_P2        (HSEL_P2),
    .HADDR_P2       (HADDR_P2),
    .HBURST_P2      (HBURST_P2),
    .HMASTLOCK_P2   (HMASTLOCK_P2),
    .HPROT_P2       (HPROT_P2),
    .HSIZE_P2       (HSIZE_P2),
    .HTRANS_P2      (HTRANS_P2),
    .HWDATA_P2      (HWDATA_P2),
    .HWRITE_P2      (HWRITE_P2),
    .HREADY_P2      (HREADY_P2),
    .HREADYOUT_P2   (HREADYOUT_P2),
    .HRDATA_P2      (HRDATA_P2),
    .HRESP_P2       (HRESP_P2),
    
    // P3
    .HSEL_P3        (HSEL_P3),
    .HADDR_P3       (HADDR_P3),
    .HBURST_P3      (HBURST_P3),
    .HMASTLOCK_P3   (HMASTLOCK_P3),
    .HPROT_P3       (HPROT_P3),
    .HSIZE_P3       (HSIZE_P3),
    .HTRANS_P3      (HTRANS_P3),
    .HWDATA_P3      (HWDATA_P3),
    .HWRITE_P3      (HWRITE_P3),
    .HREADY_P3      (HREADY_P3),
    .HREADYOUT_P3   (HREADYOUT_P3),
    .HRDATA_P3      (HRDATA_P3),
    .HRESP_P3       (HRESP_P3),
    
    // P4 LCD
    .HSEL_P4        (HSEL_P4),
    .HADDR_P4       (HADDR_P4),
    .HBURST_P4      (HBURST_P4),
    .HMASTLOCK_P4   (HMASTLOCK_P4),
    .HPROT_P4       (HPROT_P4),
    .HSIZE_P4       (HSIZE_P4),
    .HTRANS_P4      (HTRANS_P4),
    .HWDATA_P4      (HWDATA_P4),
    .HWRITE_P4      (HWRITE_P4),
    .HREADY_P4      (HREADY_P4),
    .HREADYOUT_P4   (HREADYOUT_P4),
    .HRDATA_P4      (HRDATA_P4),
    .HRESP_P4       (HRESP_P4),
    
    //P5 SEG
    .HSEL_P5     	(HSEL_P5),
    .HADDR_P5    	(HADDR_P5),
    .HBURST_P5   	(HBURST_P5),
    .HMASTLOCK_P5   (HMASTLOCK_P5),
    .HPROT_P5    	(HPROT_P5),
    .HSIZE_P5       (HSIZE_P5),
    .HTRANS_P5   	(HTRANS_P5),
    .HWDATA_P5   	(HWDATA_P5),
    .HWRITE_P5   	(HWRITE_P5),
    .HREADY_P5   	(HREADY_P5),
    .HREADYOUT_P5	(HREADYOUT_P5),
    .HRDATA_P5   	(HRDATA_P5),
    .HRESP_P5    	(HRESP_P5),
    
    //P6 MSI
    .HSEL_P6     	(HSEL_P6),
    .HADDR_P6    	(HADDR_P6),
    .HBURST_P6   	(HBURST_P6),
    .HMASTLOCK_P6   (HMASTLOCK_P6),
    .HPROT_P6    	(HPROT_P6),
    .HSIZE_P6       (HSIZE_P6),
    .HTRANS_P6   	(HTRANS_P6),
    .HWDATA_P6   	(HWDATA_P6),
    .HWRITE_P6   	(HWRITE_P6),
    .HREADY_P6   	(HREADY_P6),
    .HREADYOUT_P6	(HREADYOUT_P6),
    .HRDATA_P6   	(HRDATA_P6),
    .HRESP_P6    	(HRESP_P6),
    
    //P7 keyboard
    .HSEL_P7     	(HSEL_P7),
    .HADDR_P7    	(HADDR_P7),
    .HBURST_P7   	(HBURST_P7),
    .HMASTLOCK_P7   (HMASTLOCK_P7),
    .HPROT_P7    	(HPROT_P7),
    .HSIZE_P7       (HSIZE_P7),
    .HTRANS_P7   	(HTRANS_P7),
    .HWDATA_P7   	(HWDATA_P7),
    .HWRITE_P7   	(HWRITE_P7),
    .HREADY_P7   	(HREADY_P7),
    .HREADYOUT_P7	(HREADYOUT_P7),
    .HRDATA_P7   	(HRDATA_P7),
    .HRESP_P7    	(HRESP_P7)
    );
    
    //------------------------------------------------------------------------------
    // AHB RAMCODE SLAVE0
    //------------------------------------------------------------------------------
    
    wire [31:0] RAMCODE_RDATA,RAMCODE_WDATA;
    wire [12:0] RAMCODE_WADDR;
    wire [12:0] RAMCODE_RADDR;
    wire [3:0]  RAMCODE_WRITE;
    
    AHBlite_Block_RAM RAMCODE_Interface(
    /* Connect to Interconnect Port 0 */
    .HCLK           (clk),
    .HRESETn        (cpuresetn),
    .HSEL           (HSEL_P0),
    .HADDR          (HADDR_P0),
    .HPROT          (HPROT_P0),
    .HSIZE          (HSIZE_P0),
    .HTRANS         (HTRANS_P0),
    .HWDATA         (HWDATA_P0),
    .HWRITE         (HWRITE_P0),
    .HRDATA         (HRDATA_P0),
    .HREADY         (HREADY_P0),
    .HREADYOUT      (HREADYOUT_P0),
    .HRESP          (HRESP_P0),
    .BRAM_WRADDR    (RAMCODE_WADDR),
    .BRAM_RDADDR    (RAMCODE_RADDR),
    .BRAM_RDATA     (RAMCODE_RDATA),
    .BRAM_WDATA     (RAMCODE_WDATA),
    .BRAM_WRITE     (RAMCODE_WRITE)
    /**********************************/
    );
    
    Block_RAM RAM_CODE(
    .clka           (clk),
    .addra          (RAMCODE_WADDR),
    .addrb          (RAMCODE_RADDR),
    .dina           (RAMCODE_WDATA),
    .doutb          (RAMCODE_RDATA),
    .wea            (RAMCODE_WRITE)
    );
    
    //------------------------------------------------------------------------------
    // AHB RAMDATA SLAVE 1
    //------------------------------------------------------------------------------
    
    wire [31:0] RAMDATA_RDATA;
    wire [31:0] RAMDATA_WDATA;
    wire [12:0] RAMDATA_WADDR;
    wire [12:0] RAMDATA_RADDR;
    wire [3:0]  RAMDATA_WRITE;
    
    AHBlite_Block_RAM RAMDATA_Interface(
    /* Connect to Interconnect Port 1 */
    .HCLK           (clk),
    .HRESETn        (cpuresetn),
    .HSEL           (HSEL_P1),
    .HADDR          (HADDR_P1),
    .HPROT          (HPROT_P1),
    .HSIZE          (HSIZE_P1),
    .HTRANS         (HTRANS_P1),
    .HWDATA         (HWDATA_P1),
    .HWRITE         (HWRITE_P1),
    .HRDATA         (HRDATA_P1),
    .HREADY         (HREADY_P1),
    .HREADYOUT      (HREADYOUT_P1),
    .HRESP          (HRESP_P1),
    .BRAM_WRADDR    (RAMDATA_WADDR),
    .BRAM_RDADDR    (RAMDATA_RADDR),
    .BRAM_WDATA     (RAMDATA_WDATA),
    .BRAM_RDATA     (RAMDATA_RDATA),
    .BRAM_WRITE     (RAMDATA_WRITE)
    /**********************************/
    );
    
    Block_RAM RAM_DATA(
    .clka           (clk),
    .addra          (RAMDATA_WADDR),
    .addrb          (RAMDATA_RADDR),
    .dina           (RAMDATA_WDATA),
    .doutb          (RAMDATA_RDATA),
    .wea            (RAMDATA_WRITE)
    );
    
    //------------------------------------------------------------------------------
    // AHB WaterLight SLAVE 2
    //------------------------------------------------------------------------------
    
    wire [7:0] WaterLight_mode;
    wire [31:0] WaterLight_speed;
    wire pwm_cnt_clear;        

    AHBlite_WaterLight WaterLight_Interface(
    /* Connect to Interconnect Port 2 */
    .HCLK                   (clk),
    .HRESETn                (cpuresetn),
    .HSEL                   (HSEL_P2),
    .HADDR                  (HADDR_P2),
    .HPROT                  (HPROT_P2),
    .HSIZE                  (HSIZE_P2),
    .HTRANS                 (HTRANS_P2),
    .HWDATA                 (HWDATA_P2),
    .HWRITE                 (HWRITE_P2),
    .HRDATA                 (HRDATA_P2),
    .HREADY                 (HREADY_P2),
    .HREADYOUT              (HREADYOUT_P2),
    .HRESP                  (HRESP_P2),
    .WaterLight_mode        (WaterLight_mode),
    .WaterLight_speed       (WaterLight_speed),    
    .pwm_cnt_clear          (pwm_cnt_clear)
    /**********************************/
    );
    
    WaterLight WaterLight(
    .WaterLight_mode(WaterLight_mode),
    .WaterLight_speed(WaterLight_speed),
    .clk(clk),
    .RSTn(cpuresetn),    
    .pwm_cnt_clear(pwm_cnt_clear),
    .LED(LED)    
    );
    
    //------------------------------------------------------------------------------
    // AHB UART SLAVE3
    //------------------------------------------------------------------------------
    
    wire state;
    wire [7:0] UART_RX_data;
    wire [7:0] UART_TX_data;
    wire tx_en;
    
    AHBlite_UART UART_Interface(
    /* Connect to Interconnect Port 3*/
    .HCLK           (clk),
    .HRESETn        (cpuresetn),
    .HSEL           (HSEL_P3),
    .HADDR          (HADDR_P3),
    .HPROT          (HPROT_P3),
    .HSIZE          (HSIZE_P3),
    .HTRANS         (HTRANS_P3),
    .HWDATA         (HWDATA_P3),
    .HWRITE         (HWRITE_P3),
    .HRDATA         (HRDATA_P3),
    .HREADY         (HREADY_P3),
    .HREADYOUT      (HREADYOUT_P3),
    .HRESP          (HRESP_P3),
    .UART_RX        (UART_RX_data),
    .state          (state),
    .tx_en          (tx_en),
    .UART_TX        (UART_TX_data)
    );
    
    wire clk_uart;
    wire bps_en;
    wire bps_en_rx,bps_en_tx;
    assign bps_en = bps_en_rx | bps_en_tx;
    
    clkuart_pwm clkuart_pwm(
    .clk(clk),
    .RSTn(cpuresetn),
    .clk_uart(clk_uart),
    .bps_en(bps_en)
    );
    
    UART_RX UART_RX(
    .clk(clk),
    .clk_uart(clk_uart),
    .RSTn(cpuresetn),
    .RXD(RXD),
    .data(UART_RX_data),
    .interrupt(interrupt_UART),
    .bps_en(bps_en_rx)
    );
    
    UART_TX UART_TX(
    .clk(clk),
    .clk_uart(clk_uart),
    .RSTn(cpuresetn),
    .data(UART_TX_data),
    .tx_en(tx_en),
    .TXD(TXD),
    .state(state),
    .bps_en(bps_en_tx)
    );
    
    //------------------------------------------------------------------------------
    // AHB LCD SLAVE4
    //------------------------------------------------------------------------------
    
    AHBlite_LCD LCD_Interface(
    /* Connect to Interconnect Port 4 */
    .HCLK                   (clk),
    .HRESETn                (cpuresetn),
    .HSEL                   (HSEL_P4),
    .HADDR                  (HADDR_P4),
    .HPROT                  (HPROT_P4),
    .HSIZE                  (HSIZE_P4),
    .HTRANS                 (HTRANS_P4),
    .HWDATA                 (HWDATA_P4),
    .HWRITE                 (HWRITE_P4),
    .HRDATA                 (HRDATA_P4),
    .HREADY                 (HREADY_P4),
    .HREADYOUT              (HREADYOUT_P4),
    .HRESP                  (HRESP_P4),
    .LCD_CS                 (LCD_CS),
    .LCD_RS                 (LCD_RS),
    .LCD_WR                 (LCD_WR),
    .LCD_RD                 (LCD_RD),
    .LCD_RST                (LCD_RST),
    .LCD_DATA               (LCD_DATA),
    .LCD_BL_CTR             (LCD_BL_CTR)
    /**********************************/
    );
    
    //------------------------------------------------------------------------------
    // AHB SEG SLAVE5
    //------------------------------------------------------------------------------
    
    wire [3:0]data_disp_3;
    wire [3:0]data_disp_2;
    wire [3:0]data_disp_1;
    wire [3:0]data_disp_0;
    
    AHBlite_SEG SEG_Interface(
    /* Connect to Interconnect Port 5 */
    .HCLK     (clk),
    .HRESETn  (cpuresetn),
    .HSEL     (HSEL_P5),
    .HADDR    (HADDR_P5),
    .HTRANS   (HTRANS_P5),
    .HSIZE    (HSIZE_P5),
    .HPROT    (HPROT_P5),
    .HWRITE   (HWRITE_P5),
    .HWDATA   (HWDATA_P5),
    .HREADY   (HREADY_P5),
    .HREADYOUT(HREADYOUT_P5),
    .HRDATA   (HRDATA_P5),
    .HRESP    (HRESP_P5),
    
    .data_disp({data_disp_3,data_disp_2,data_disp_1,data_disp_0})
    );
    
    
    
    SegDecoder SegDecoder(
    
    .clk(clk),
    .RSTn(RSTn),
    .data_disp_3(data_disp_3),// the leftmost seg data in
    .data_disp_2(data_disp_2),
    .data_disp_1(data_disp_1),
    .data_disp_0(data_disp_0),
    
    .seg_bit_disp(seg_bit_disp),
    .seg_sel    (seg_sel)
    
    );
    
    
    //------------------------------------------------------------------------------
    // AHB MSI SLAVE6
    //------------------------------------------------------------------------------
    wire               FIFO_state   ;
    wire               ena_write    ;
    wire    [23:0]     spi_data_FIFO;
    
    
    AHBlite_SPI MSI_Interface(
    /* Connect to Interconnect Port 6 */
    .HCLK          (clk),
    .HRESETn       (cpuresetn),
    .HSEL          (HSEL_P6),
    .HADDR         (HADDR_P6),
    .HTRANS        (HTRANS_P6),
    .HSIZE         (HSIZE_P6),
    .HPROT         (HPROT_P6),
    .HWRITE        (HWRITE_P6),
    .HWDATA        (HWDATA_P6),
    .HREADY        (HREADY_P6),
    .HREADYOUT     (HREADYOUT_P6),
    .HRDATA        (HRDATA_P6),
    .HRESP         (HRESP_P6),
    
    .FIFO_state    (FIFO_state),
    .ena_write     (ena_write),
    .spi_data_FIFO (spi_data_FIFO)  //SPI_FIFO写入的数据
    
    );
    
    
    SPI_Master MSI_SPI(
    //input
    .clk           (clk), //时钟信号 50M的时钟
    .RSTn          (cpuresetn), //复位信号 按键复位
    .spi_data_FIFO (spi_data_FIFO), //SPI_FIFO写入的数据
    .ena_write     (ena_write), //SPI_FIFO写入使能信号
    //output
    .spi_en        (spi_en), //MSI写使能信号 （EN）
    .spi_clk       (spi_clk), //SPI的时钟信号（CLK）
    .spi_data      (spi_data), //SPI的数据信号（DATA）
    .FIFO_state    (FIFO_state)  //FIFO状态信号
    );
    
    
    //------------------------------------------------------------------------------
    // AHB Keyboard SLAVE7
    //------------------------------------------------------------------------------
    wire [15:0]key_data;
    wire  key_clear;
    AHBlite_Keyboard Keyboard_interface(
    /* Connect to Interconnect Port 7 */
    
    .HCLK (clk),
    .HRESETn (cpuresetn),
    .HSEL (HSEL_P7),
    .HADDR (HADDR_P7),
    .HPROT (HPROT_P7),
    .HSIZE (HSIZE_P7),
    .HTRANS (HTRANS_P7),
    .HWDATA (HWDATA_P7),
    .HWRITE (HWRITE_P7),
    .HRDATA (HRDATA_P7),
    .HREADY (HREADY_P7),
    .HREADYOUT (HREADYOUT_P7),
    .HRESP (HRESP_P7),
    .key_data (key_data),
    .key_clear (key_clear)
    );
    
    
    Keyboard keyboard(
    .clk(clk)
    ,.rstn(cpuresetn)
    ,.key_clear(key_clear)
    ,.col(col)
    ,.row(row)
    // ,.key(key)
    ,.key_interrupt(key_interrupt)
    ,.key_data(key_data)
    );
    
    
    //------------------------------------------------------------------------------
    // PLL
    //------------------------------------------------------------------------------
    wire pll_200m;
    wire ADC_CLK;
    
    
    PLL PLL(
    .refclk  (clk),
    .reset   (1'b0),
    //.extlock,
    .clk0_out(pll_200m),//200M for PWM
    .clk1_out(ADC_CLK),//16M for ADC
    .clk2_out(MSI_REF)//24M for MSI REF
    );
    
    //------------------------------------------------------------------------------
    // IQ ADC
    //------------------------------------------------------------------------------
    
    wire       data_clk;
    wire [11:0]msi_i;
    wire [11:0]msi_q;
    
    IQ_ADC IQ_ADC(
    
    .ADC_CLK (ADC_CLK),
    .RSTn    (RSTn),
    
    .msi_i   (msi_i),
    .msi_q   (msi_q),
    .data_clk(data_clk)
    
    );
    
    //------------------------------------------------------------------------------
    // FM DEMODULATION
    //------------------------------------------------------------------------------
    
    wire [12:0]demod_data;
    
    FM_DEMOD FM_DEMOD(
    .data_clk(data_clk),
    .RSTn(RSTn),
    .msi_i(msi_i),
    .msi_q(msi_q),
    
    .demod_data(demod_data),
    .probe1(probe1)
    );
    
    //------------------------------------------------------------------------------
    // FIR FILTER
    //------------------------------------------------------------------------------
    
    wire [11:0]audio_data;
    //
    FIR FIR(
    .eoc(data_clk),
    .RSTn(RSTn),
    .fir_in(demod_data),
    .audio_out(audio_data)
    );
    
    //------------------------------------------------------------------------------
    // PWM DAC
    //------------------------------------------------------------------------------
    
    PWM_DAC PWM_DAC(
    
    .pll_200m(pll_200m),
    .RSTn(RSTn),
    .audio_data(audio_data),
    .PWM_Audio(PWM_Audio)
    
    );
    
    assign probe2 = PWM_Audio;
    
    
endmodule
