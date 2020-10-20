// Copyright (c) 2012-2013 Ludvig Strigeus
// This program is GPL Licensed. See COPYING for the full license.

`timescale 1ns / 1ps

//============================================================================
//
//  Multicore 2+ Top by Victor Trucco
//
//============================================================================

`default_nettype none

module Lynx96_UAReloaded(  
   // Clocks
    input wire  clock_50_i,

    // Buttons
//    input wire [4:1]    btn_n_i,

    // SRAM (IS61WV20488FBLL-10)
    output wire [20:0]sram_addr_o  = 21'b000000000000000000000,
    inout wire  [7:0]sram_data_io   = 8'bzzzzzzzz,
    output wire sram_we_n_o     = 1'b1,
    output wire sram_oe_n_o     = 1'b1,
        
    // SDRAM (W9825G6KH-6)
    output [12:0] SDRAM_A,
    output  [1:0] SDRAM_BA,
    inout  [15:0] SDRAM_DQ,
    output        SDRAM_DQMH,
    output        SDRAM_DQML,
    output        SDRAM_CKE,
    output        SDRAM_nCS,
    output        SDRAM_nWE,
    output        SDRAM_nRAS,
    output        SDRAM_nCAS,
    output        SDRAM_CLK,

    // PS2
    inout wire  ps2_clk_io        = 1'bz,
    inout wire  ps2_data_io       = 1'bz,
    inout wire  ps2_mouse_clk_io  = 1'bz,
    inout wire  ps2_mouse_data_io = 1'bz,

    // SD Card
    output wire sd_cs_n_o         = 1'bZ,
    output wire sd_sclk_o         = 1'bZ,
    output wire sd_mosi_o         = 1'bZ,
    input wire  sd_miso_i,

    // Joysticks
//    output wire joy_clock_o       = 1'b1,
//    output wire joy_load_o        = 1'b1,
//    input  wire joy_data_i,
//    output wire joy_p7_o          = 1'b1,

    input wire joy1_up_i, 
    input wire joy1_down_i,
    input wire joy1_left_i,
    input wire joy1_right_i,
    input wire joy1_p6_i,
    input wire joy1_p9_i,
    input wire joy2_up_i, 
    input wire joy2_down_i,
    input wire joy2_left_i,
    input wire joy2_right_i,
    input wire joy2_p6_i,
    input wire joy2_p9_i,
    output wire joy_p7_o          = 1'b1,


    // Audio

    input wire  ear_i,
	 input wire  ear_maxduino,
//    output wire mic_o             = 1'b0,

     // SONIDO I2S
    output wire	SDIN,
    output wire	SCLK,
    output wire	LRCLK,
    output wire	MCLK 			= 1'bz,


    // VGA
    output  [7:0] VGA_R,
    output  [7:0] VGA_G,
    output  [7:0] VGA_B,
    output        VGA_HS,
    output        VGA_VS,
    output        VGA_BLANK  = 1'b1,
    output        VGA_CLOCK,   
 
	 
    //STM32
//    input wire  stm_tx_i,
//    output wire stm_rx_o,
    output wire stm_rst_o           = 1'bz, // '0' to hold the microcontroller reset line, to free the SD card
   
    input         SPI_SCK,
    output        SPI_DO,
    input         SPI_DI,
    input         SPI_SS2,
    //output wire   SPI_nWAIT        = 1'b1, // '0' to hold the microcontroller data streaming

//    inout [31:0] GPIO,

    output LED                    = 1'b1 // '0' is LED on
);


//---------------------------------------------------------
//-- MC2+ defaults
//---------------------------------------------------------
//assign GPIO = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
assign stm_rst_o    = 1'bZ;
//assign stm_rx_o = 1'bZ;

//no SRAM for this core
assign sram_we_n_o  = 1'b1;
assign sram_oe_n_o  = 1'b1;

//all the SD reading goes thru the microcontroller for this core
assign sd_cs_n_o = 1'bZ;
assign sd_sclk_o = 1'bZ;
assign sd_mosi_o = 1'bZ;


reg [7:0] pump_s = 8'b11111111;
//PumpSignal PumpSignal (clk, ~clock_locked, downloading, pump_s);




//-----------------------------------------------------------------


// the configuration string is returned to the io controller to allow
// it to control the menu on the OSD 

parameter CONF_STR = {
            "P,CORE_NAME.ini;",
				"O34,Machine,Lynx 48K,Lynx 96k,96k Scorpion;",
            "OCD,Scanlines,OFF,25%,50%,75%;",
            "OG,Scandoubler,On,Off;",
				"06,Tape,Integrated,Jack;",
            "O5,Joystick swap,OFF,ON;",
            "T0,Reset;",
            "V,v1.0-test1;"
};



wire clk_sys;
wire pll_locked;
pll pll
(
        .inclk0(clock_50_i),
        .areset(0),
        .c0(clk_sys),
        .locked (pll_locked)
);




wire [31:0] status;
wire arm_reset = status[0];
wire [1:0] system_type = status[11:10];
wire pal_video = |system_type;
wire [1:0] scanlines = status[13:12];
wire joy_swap = status[5];
wire mirroring_osd = status[6];
wire overscan_osd = status[7];
wire [3:0] palette2_osd = status[20:17];
wire [2:0] diskside_osd = status[11:9];

wire scandoubler_disable;
wire ypbpr;
wire no_csync;
//wire ps2_kbd_clk, ps2_kbd_data;

wire [7:0] core_joy_A;
wire [7:0] core_joy_B;
wire [1:0] buttons;
wire [1:0] switches;



wire [7:0] joyA = joy_swap ? core_joy_B : core_joy_A;
wire [7:0] joyB = joy_swap ? core_joy_A : core_joy_B;

wire [7:0] lynx_joy_A = ~{1'b0,1'b0,joyA[4],1'b0,joyA[0],joyA[1],joyA[2],joyA[3]}  ;
wire [7:0] lynx_joy_B = ~{1'b0,1'b0,joyB[4],1'b0,joyB[0],joyB[1],joyB[2],joyB[3]}  ;
 

 
 wire ce_pix;
 wire crtcDe;
 wire[1:0] mode;
 wire reset;
 wire [1:0] ps2;
 
 assign reset=status[0]; 
 
 assign ps2={{ps2_data_io},{ps2_clk_io}};
 
 lynx48 lynx48   
(
        .clock    (clk_sys),
        .reset_osd(~reset),
        .led      (LED),

        .hSync    (HSync  ),
        .vSync    (VSync  ),
        .vBlank   (VBlank ),
        .hBlank   (HBlank ),
        .crtcDe   (crtcDe ),
        .rgb      (video  ),
        
        .ps2      (ps2    ),
        .joy_0    (lynx_joy_A),
        .joy_1    (lynx_joy_B),
        
        .audio    (sample),
        .ear      (status[6] ? ear_i : ear_maxduino),
        
        
        .ce_pix   (ce_pix ),
        .mode     (mode)
);




assign scandoubler_disable = ~status[16];


wire HBlank;
wire HSync;
wire VBlank;
wire VSync;
wire [8:0] video;

mist_video #(.COLOR_DEPTH(5), .OSD_COLOR(3'd1), .SD_HCNT_WIDTH(10)) mist_video (
    .clk_sys     ( clk_sys    ),

    // OSD SPI interface
    .SPI_SCK     ( SPI_SCK    ),
    .SPI_SS3     ( SPI_SS2    ),
    .SPI_DI      ( SPI_DI     ),

    // scanlines (00-none 01-25% 10-50% 11-75%)
    .scanlines   ( scanlines  ),

    // non-scandoubled pixel clock divider 0 - clk_sys/4, 1 - clk_sys/2
    .ce_divider  ( 1'b0       ),

    // 0 = HVSync 31KHz, 1 = CSync 15KHz
    .scandoubler_disable ( 1'b0 ),

    // Rotate OSD [0] - rotate [1] - left or right
    .rotate      ( 2'b00      ),
    // composite-like blending
    .blend       ( 1'b0       ),

    // video in
	 .R({video[8:6],video[8]}), 
    .G({video[5:3],video[5]}), 
    .B({video[2:0],video[2]}),

    .HSync       ( ~HSync    ),
    .VSync       ( ~VSync    ),

    // MiST video output signals
    .VGA_R       ( vga_r_o    ),
    .VGA_G       ( vga_g_o    ),
    .VGA_B       ( vga_b_o    ),
    .VGA_VS      ( VGA_VS     ),
    .VGA_HS      ( VGA_HS     ),

    .osd_enable ( osd_enable )
);


wire [4:0] vga_r_o;
wire [4:0] vga_g_o;
wire [4:0] vga_b_o;


assign VGA_R = {vga_r_o[4:0],vga_r_o[4:2]};
assign VGA_G = {vga_g_o[4:0],vga_g_o[4:2]};
assign VGA_B = {vga_b_o[4:0],vga_b_o[4:2]};

assign VGA_BLANK = 1'b1;
assign VGA_CLOCK = clk_sys ; 



wire osd_enable;

/*
keyboard keyboard (
    .clk(clk),
    .reset(reset_nes),
    .ps2_kbd_clk(ps2_clk_io),
    .ps2_kbd_data(ps2_data_io),

    .joystick_0(kbd_joy0),
    .joystick_1(kbd_joy1),
    
    .powerpad(powerpad),
    .fds_eject(fds_eject),

    .osd_o (osd_s),
    .osd_enable ( osd_enable )
);
*/
//------------------------------------------

wire kbd_intr;
wire [7:0] kbd_scancode;

wire [1:0] clk_cnt;

always @(posedge clk_sys)
begin
    clk_cnt <= clk_cnt + 1'b1;
end

//get scancode from keyboard
io_ps2_keyboard keyboard 
 (
  .clk       ( clk_cnt[0] ),
  .kbd_clk   ( ps2_clk_io ),
  .kbd_dat   ( ps2_data_io ),
  .interrupt ( kbd_intr ),
  .scancode  ( kbd_scancode )
);

wire [15:0]joy1_s;
wire [15:0]joy2_s;
wire [8:0]controls_s;
wire direct_video;
wire [1:0]osd_rotate;

   
wire [15:0] sample;	
assign MCLK = clock_50_i;
  
audio_out audio_out
(
	.reset			(reset),
	.clk				(clock_50_i),
	.sample_rate	(0),  // 0 is 48 KHz , 1 is 96 Khz
	.left_in			(sample[15:0]),
	.right_in		(sample[15:0]),
	.i2s_bclk		(SCLK),
	.i2s_lrclk		(LRCLK),
	.i2s_data		(SDIN)
); 

            
endmodule
