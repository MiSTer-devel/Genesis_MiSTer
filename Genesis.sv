//============================================================================
//  FPGAGen port to MiSTer
//  Copyright (c) 2017-2019 Sorgelig
//
//  YM2612 implementation by Jose Tejada Gomez. Twitter: @topapate
//  Original Genesis code: Copyright (c) 2010-2013 Gregory Estrade (greg@torlus.com) 
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [45:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	output  [7:0] VIDEO_ARX,
	output  [7:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S, // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	// SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..5 - USR1..USR4
	// Set USER_OUT to 1 to read from USER_IN.
	input   [5:0] USER_IN,
	output  [5:0] USER_OUT,

	input         OSD_STATUS
);

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;

assign VIDEO_ARX = status[9] ? 8'd16 : 8'd4;
assign VIDEO_ARY = status[9] ? 8'd9  : 8'd3;

assign AUDIO_S = 1;
assign AUDIO_MIX = 0;

assign LED_DISK  = 0;
assign LED_POWER = 0;
assign LED_USER  = cart_download | sav_pending;

//`define SOUND_DBG

`include "build_id.v"
localparam CONF_STR = {
	"Genesis;;",
	"FS,BINGENMD ;",
	"-;",
	"O67,Region (F1-4),JP,US,EU,Auto;",
	"H2ORS,Auto Region Order,U>J>E,J>U>E,E>U>J;",
	"-;",
	"C,Cheats;",
	"H1OO,Cheats Enabled,Yes,No;",
	"-;",
	"D0RG,Load Backup RAM;",
	"D0RH,Save Backup RAM;",
	"D0OD,Autosave,No,Yes;",
	"-;",
	"O9,Aspect ratio,4:3,16:9;",
	"O13,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	"-;",
	"O4,Swap Joysticks,No,Yes;",
	"O5,6 Buttons Mode,No,Yes;",
	"OLM,Multitap,Disabled,4-Way,TeamPlayer,J-Cart;",
	"OIJ,Mouse,None,Port1,Port2;",
	"OK,Mouse Flip Y,No,Yes;",
	"OEF,Audio Filter,Model 1,Model 2,Minimal,No Filter;",
   "ON,HiFi PCM,No,Yes;",
	"-;",
   "OPQ,CPU Turbo,None,Medium,High;",
	"-;",
`ifdef SOUND_DBG
	"OB,Enable FM,Yes,No;",
	"OC,Enable PSG,Yes,No;",
`endif	
	"R0,Reset (F5);",
	"J1,A,B,C,Start,Mode,X,Y,Z;",
	"V,v",`BUILD_DATE
};


wire [15:0] status_menumask = {~region_order_ena,~gg_available,~bk_ena};
wire [31:0] status;
wire  [1:0] buttons;
wire [11:0] joystick_0,joystick_1,joystick_2,joystick_3;
wire        ioctl_download;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire [15:0] ioctl_data;
wire  [7:0] ioctl_index;
reg         ioctl_wait;

reg  [31:0] sd_lba;
reg         sd_rd = 0;
reg         sd_wr = 0;
wire        sd_ack;
wire  [7:0] sd_buff_addr;
wire [15:0] sd_buff_dout;
wire [15:0] sd_buff_din;
wire        sd_buff_wr;
wire        img_mounted;
wire        img_readonly;
wire [63:0] img_size;

wire        forced_scandoubler;
wire [10:0] ps2_key;
wire [24:0] ps2_mouse;

hps_io #(.STRLEN($size(CONF_STR)>>3), .WIDE(1)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.conf_str(CONF_STR),

	.joystick_0(joystick_0),
	.joystick_1(joystick_1),
	.joystick_2(joystick_2),
	.joystick_3(joystick_3),
	.buttons(buttons),
	.forced_scandoubler(forced_scandoubler),
	.new_vmode(new_vmode),

	.status(status),
	.status_in({status[31:8],region_osd,status[5:0]}),
	.status_set(status_set),
	.status_menumask(status_menumask),

	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_data),
	.ioctl_wait(ioctl_wait),

	.sd_lba(sd_lba),
	.sd_rd(sd_rd),
	.sd_wr(sd_wr),
	.sd_ack(sd_ack),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din(sd_buff_din),
	.sd_buff_wr(sd_buff_wr),
	.img_mounted(img_mounted),
	.img_readonly(img_readonly),
	.img_size(img_size),

	.ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse)
);

wire code_index = &ioctl_index;
wire cart_download = ioctl_download & ~code_index;
wire code_download = ioctl_download & code_index;

///////////////////////////////////////////////////
wire clk_sys, clk_ram, locked;

pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_sys),
	.outclk_1(clk_ram),
	.locked(locked)
);

///////////////////////////////////////////////////
// Code loading for WIDE IO (16 bit)
reg [128:0] gg_code;
wire        gg_available;

// Code layout:
// {clock bit, code flags,     32'b address, 32'b compare, 32'b replace}
//  128        127:96          95:64         63:32         31:0
// Integer values are in BIG endian byte order, so it up to the loader
// or generator of the code to re-arrange them correctly.

always_ff @(posedge clk_sys) begin
	gg_code[128] <= 1'b0;

	if (code_download & ioctl_wr) begin
		case (ioctl_addr[3:0])
			0:  gg_code[111:96]  <= ioctl_data; // Flags Bottom Word
			2:  gg_code[127:112] <= ioctl_data; // Flags Top Word
			4:  gg_code[79:64]   <= ioctl_data; // Address Bottom Word
			6:  gg_code[95:80]   <= ioctl_data; // Address Top Word
			8:  gg_code[47:32]   <= ioctl_data; // Compare Bottom Word
			10: gg_code[63:48]   <= ioctl_data; // Compare top Word
			12: gg_code[15:0]    <= ioctl_data; // Replace Bottom Word
			14: begin
				gg_code[31:16]   <= ioctl_data; // Replace Top Word
				gg_code[128]     <=  1'b1;      // Clock it in
			end
		endcase
	end
end

///////////////////////////////////////////////////
wire [3:0] r, g, b;
wire vs,hs;
wire ce_pix;
wire hblank, vblank;
wire interlace;

assign DDRAM_CLK = clk_ram;
wire reset = RESET | status[0] | buttons[1] | bk_loading | key_reset;

system system
(
	.RESET_N(~reset),
	.MCLK(clk_sys),

	.LOADING(cart_download),
	.EXPORT(|core_region),
	.PAL(PAL),
	.SRAM_QUIRK(sram_quirk),
	.EEPROM_QUIRK(eeprom_quirk),
	.NORAM_QUIRK(noram_quirk),
	.PIER_QUIRK(pier_quirk),
	.TTN2_QUIRK(ttn2_quirk),

	.DAC_LDATA(AUDIO_L),
	.DAC_RDATA(AUDIO_R),
	
	.TURBO(status[26:25]),

	.RED(r),
	.GREEN(g),
	.BLUE(b),
	.VS(vs),
	.HS(hs),
	.HBL(hblank),
	.VBL(vblank),
	.CE_PIX(ce_pix),
	.FIELD(VGA_F1),
	.INTERLACE(interlace),
	.FAST_FIFO(fifo_quirk),
	
	.GG_RESET(code_download && ioctl_wr && !ioctl_addr),
	.GG_EN(status[24]),
	.GG_CODE(gg_code),
	.GG_AVAILABLE(gg_available),

	.J3BUT(~status[5]),
	.JOY_1(status[4] ? joystick_1 : joystick_0),
	.JOY_2(status[4] ? joystick_0 : joystick_1),
	.JOY_3(joystick_2),
	.JOY_4(joystick_3),
	.MULTITAP(status[22:21]),

	.MOUSE(ps2_mouse),
	.MOUSE_OPT(status[20:18]),

`ifdef SOUND_DBG
	.ENABLE_FM(~status[11]),
	.ENABLE_PSG(~status[12]),
`else
	.ENABLE_FM(1),
	.ENABLE_PSG(1),
`endif
    .EN_HIFI_PCM(status[23]), // Option "N"
	.LPF_MODE(status[15:14]),

	.BRAM_A({sd_lba[6:0],sd_buff_addr}),
	.BRAM_DI(sd_buff_dout),
	.BRAM_DO(sd_buff_din),
	.BRAM_WE(sd_buff_wr & sd_ack),
	.BRAM_CHANGE(bk_change),

	.ROMSZ(rom_sz[24:1]),
	.ROM_ADDR(rom_addr),
	.ROM_DATA(rom_data),
	.ROM_REQ(rom_rd),
	.ROM_ACK(rom_rdack)
);

wire [2:0] scale = status[3:1];
wire [2:0] sl = scale ? scale - 1'd1 : 3'd0;

assign CLK_VIDEO = clk_ram;
assign VGA_SL = {~interlace,~interlace}&sl[1:0];

reg old_ce_pix;
always @(posedge CLK_VIDEO) old_ce_pix <= ce_pix;


video_mixer #(.LINE_LENGTH(320), .HALF_DEPTH(1)) video_mixer
(
	.*,

	.clk_sys(CLK_VIDEO),
	.ce_pix(~old_ce_pix & ce_pix),
	.ce_pix_out(CE_PIXEL),

	.scanlines(0),
	.scandoubler(~interlace && (scale || forced_scandoubler)),
	.hq2x(scale==1),

	.mono(0),

	.R(r),
	.G(g),
	.B(b),

	// Positive pulses.
	.HSync(hs),
	.VSync(vs),
	.HBlank(hblank),
	.VBlank(vblank)
);

///////////////////////////////////////////////////

wire [24:1] rom_addr;
wire [15:0] rom_data;
wire rom_rd, rom_rdack;

ddram ddram
(
	.*,

   .wraddr(cart_download ? ioctl_addr : rom_sz),
   .din({ioctl_data[7:0],ioctl_data[15:8]}),
   .we_req(rom_wr),
   .we_ack(rom_wrack),

   .rdaddr(rom_addr),
   .dout(rom_data),
   .rd_req(rom_rd),
   .rd_ack(rom_rdack)
);

reg  rom_wr;
wire rom_wrack;
reg [24:0] rom_sz;
always @(posedge clk_sys) begin
	reg old_download, old_reset;
	old_download <= cart_download;
	old_reset <= reset;

	if(~old_reset && reset) ioctl_wait <= 0;
	if (old_download & ~cart_download) begin
		rom_sz <= ioctl_addr[24:0];
		ioctl_wait <= 0;
	end

	if(~old_download && cart_download)
		rom_wr <= 0;
	else if (cart_download) begin
		if(ioctl_wr) begin
			ioctl_wait <= 1;
			rom_wr <= ~rom_wr;
		end else if(ioctl_wait && (rom_wr == rom_wrack)) begin
			ioctl_wait <= 0;
		end
	end
end

/////////////////////////  key accelerator  /////////////////////////////

reg [1:0] region_osd; // use to set the OSD menu region when an accelerator key is pressed
reg status_set = 0; // notification to the OSD menu an input value has been changed
reg key_reset = 0;

wire       pressed = ps2_key[9];
wire [8:0] code    = ps2_key[8:0];
always @(posedge clk_sys) begin
	reg old_state = 0;
	old_state <= ps2_key[10];
		
	if(old_state != ps2_key[10]) begin
		casex(code)
			'h005: begin region_osd <= 0; status_set <= pressed; end // F1
			'h006: begin region_osd <= 1; status_set <= pressed; end // F2
			'h004: begin region_osd <= 2; status_set <= pressed; end // F3
			'h00C: begin region_osd <= 3; status_set <= pressed; end // F4
			'h003: begin key_reset <= pressed; end // F5
		endcase
	end
end

/////////////////////////  Cartridge header  /////////////////////////////

// read the header of the loaded file/cart
//.ascii  "SEGA MEGA DRIVE "                                              /* Console Name (16) */
//        .ascii  "(C)SEGA 2012.MAR"                                      /* Copyright Information (16) */
//        .ascii  "MY PROG                                         "      /* Domestic Name (48) */
//        .ascii  "MY PROG                                         "      /* Overseas Name (48) */
//        .ascii  "GM 00000000-00"                                        /* Serial Number (2, 14) */
//        .word   0x0000                                                  /* Checksum (2) */
//        .ascii  "JD              "                                      /* I/O Support (16) */
//        .long   0x00000000                                              /* ROM Start Address (4) */
//        .long   0x20000                                                 /* ROM End Address (4) */
//        .long   0x00FF0000                                              /* Start of Backup RAM (4) */
//        .long    0x00FFFFFF                                             /* End of Backup RAM (4) */
//        .ascii  "                        "                              /* Modem Support (12) */
//        .ascii  "                                        "              /* Memo (40) */
//        .ascii  "JUE             "                                      /* Country Support (16) */

function automatic [1:0] region_code;
	// E = Europe
	// J = Japan
	// U = USA
	// other code which run as europe        
	// A = Asia
	// B = Brazil
	// 4 = Brazil
	// F = France
	// 8 = Hong Kong
		
	input [7:0] region_char;
	
	if (region_char== "J") region_code = 0;
	else if (region_char== "U") region_code= 1;
	else if (region_char== " ") region_code = 3; // special case, not a real region code
	else region_code = 2;

endfunction

reg cart_reg_ready = 0;
reg [5:0] cart_reg; // get the 3 region code at most

reg sram_quirk = 0;
reg eeprom_quirk = 0;
reg fifo_quirk = 0;
reg noram_quirk = 0;
reg pier_quirk = 0;
reg ttn2_quirk = 0;
always @(posedge clk_sys) begin
	reg [55:0] cart_id; // 7+1 char id string on 14
	reg old_download;
	old_download <= cart_download;

	// re-initialization
	if(~old_download && cart_download) {fifo_quirk,eeprom_quirk,sram_quirk,noram_quirk,pier_quirk,ttn2_quirk,cart_reg,cart_reg_ready} <= 0;
	
	if(ioctl_wr & cart_download) begin
		// get the cartridge id string (partial id, only 8 char of the id)
		if(ioctl_addr == 'h182) cart_id[55:48] <= {ioctl_data[15:8]};
		if(ioctl_addr == 'h184) cart_id[47:32] <= {ioctl_data[7:0],ioctl_data[15:8]};
		if(ioctl_addr == 'h186) cart_id[31:16] <= {ioctl_data[7:0],ioctl_data[15:8]};
		if(ioctl_addr == 'h188) cart_id[15:00] <= {ioctl_data[7:0],ioctl_data[15:8]};
		if(ioctl_addr == 'h18A) begin
			if({cart_id,ioctl_data[7:0]} == "T-081276") sram_quirk <= 1;   // NFL Quarterback Club
			else if({cart_id,ioctl_data[7:0]} == "T-81406 ") sram_quirk <= 1;   // NBA Jam TE
			else if({cart_id,ioctl_data[7:0]} == "T-081586") sram_quirk <= 1;   // NFL Quarterback Club '96
			else if({cart_id,ioctl_data[7:0]} == "T-81576 ") sram_quirk <= 1;   // College Slam
			else if({cart_id,ioctl_data[7:0]} == "T-81476 ") sram_quirk <= 1;   // Frank Thomas Big Hurt Baseball
			else if({cart_id,ioctl_data[7:0]} == "MK-1215 ") eeprom_quirk <= 1; // Evander Real Deal Holyfield's Boxing
			else if({cart_id,ioctl_data[7:0]} == "G-4060  ") eeprom_quirk <= 1; // Wonder Boy
			else if({cart_id,ioctl_data[7:0]} == "00001211") eeprom_quirk <= 1; // Sports Talk Baseball
			else if({cart_id,ioctl_data[7:0]} == "MK-1228 ") eeprom_quirk <= 1; // Greatest Heavyweights
			else if({cart_id,ioctl_data[7:0]} == "G-5538  ") eeprom_quirk <= 1; // Greatest Heavyweights JP
			else if({cart_id,ioctl_data[7:0]} == "00004076") eeprom_quirk <= 1; // Honoo no Toukyuuji Dodge Danpei
			else if({cart_id,ioctl_data[7:0]} == "T-12046 ") eeprom_quirk <= 1; // Mega Man - The Wily Wars 
			else if({cart_id,ioctl_data[7:0]} == "T-12053 ") eeprom_quirk <= 1; // Rockman Mega World 
			else if({cart_id,ioctl_data[7:0]} == "G-4524  ") eeprom_quirk <= 1; // Ninja Burai Densetsu
			else if({cart_id,ioctl_data[7:0]} == "T-113016") noram_quirk <= 1;  // Puggsy fake ram check
			else if({cart_id,ioctl_data[7:0]} == "T-89016 ") fifo_quirk <= 1;   // Clue
			else if({cart_id,ioctl_data[7:0]} == "T-574023") pier_quirk <= 1;   // Pier Solar Reprint
			else if({cart_id,ioctl_data[7:0]} == "T-574013") pier_quirk <= 1;   // Pier Solar 1st Edition
			else if({cart_id,ioctl_data[7:0]} == "TITAN002") ttn2_quirk <= 1;   // Titan Overdrive 2
		end
		
		// get the cartridge region string (partial only the first 3 char)
		if(ioctl_addr == 'h1F0) cart_reg[5:2] <= {region_code(ioctl_data[7:0]),region_code(ioctl_data[15:8])};
		if(ioctl_addr == 'h1F2) cart_reg[1:0] <= region_code(ioctl_data[7:0]);
	end
		
	if (old_download && ~cart_download) cart_reg_ready <= 1; // cart downloading finished
end

/////////////////////////  Region/video Mode selection  /////////////////////////////
reg [1:0] core_region; // use to store the region of the system
reg region_order_ena = 0; // use to display the region order option

// only the first bit is taken 
// 0 for jp (0 == 00 ) and us (1 == 01)
// 1 for eu (2 = 10) 
wire PAL = core_region[1]; 

reg new_vmode;
always @(posedge clk_sys) begin
	reg old_pal;
	int to;
	
	if(~(reset | cart_download)) begin
		old_pal <= PAL;
		if(old_pal != PAL) to <= 5000000;
	end
	else to <= 5000000;
	
	if(to) begin
		to <= to - 1;
		if(to == 1) new_vmode <= ~new_vmode;
	end
end

always @(posedge clk_sys) begin
	reg [5:0] order;

	if (status[7:6] == 3) begin // auto region selection
		region_order_ena <= 1;
		if (~OSD_STATUS) // only update the region when the user quit the osd
			if (cart_reg_ready) begin // cart downloading finished			
				// select the order according to the user choice
				case (status[28:27])
					0: begin order[5:4] <= 1; order[3:2] <= 0; order[1:0] <= 2; end // U>J>E
					1: begin order[5:4] <= 0; order[3:2] <= 1; order[1:0] <= 2; end // J>U>E
					2: begin order[5:4] <= 2; order[3:2] <= 1; order[1:0] <= 0; end // E>U>J
					default : begin order[5:4] <= 1; order[3:2] <= 0; order[1:0] <= 2; end // U>J>E, shall not happen
				endcase
				
				// check if the first region choice is in the header
				if ((cart_reg[5:4] == order[5:4]) || (cart_reg[3:2] == order[5:4]) || (cart_reg[1:0] == order[5:4]))
					core_region <= order[5:4];
				// if not, check if the second choice is in the header
				else if ((cart_reg[5:4] == order[3:2]) || (cart_reg[3:2] == order[3:2]) || (cart_reg[1:0] == order[3:2])) 
					core_region <= order[3:2];
				// if the first 2 preferred region code has not been found, the third one shall be there
				else
					core_region <= order[1:0];					
			end
	end else begin // manual region selection
		region_order_ena <= 0;
		if (~OSD_STATUS) 	// only update the region when the user quit the osd
			core_region <= status[7:6];
	end
end

/////////////////////////  BRAM SAVE/LOAD  /////////////////////////////


wire downloading = cart_download;

reg bk_ena = 0;
reg sav_pending = 0;
wire bk_change;

always @(posedge clk_sys) begin
	reg old_downloading = 0;

	old_downloading <= downloading;
	if(~old_downloading & downloading) bk_ena <= 0;

	//Save file always mounted in the end of downloading state.
	if(downloading && img_mounted && !img_readonly) bk_ena <= 1;

	if (bk_change & ~OSD_STATUS)
		sav_pending <= 1'b1;
	else if (bk_state)
		sav_pending <= 1'b0;
end

wire bk_load    = status[16];
wire bk_save    = status[17] | (sav_pending & OSD_STATUS & status[13]);
reg  bk_loading = 0;
reg  bk_state   = 0;

always @(posedge clk_sys) begin
	reg old_downloading = 0;
	reg old_load = 0, old_save = 0, old_ack;

	old_downloading <= downloading;

	old_load <= bk_load;
	old_save <= bk_save;
	old_ack  <= sd_ack;

	if(~old_ack & sd_ack) {sd_rd, sd_wr} <= 0;

	if(!bk_state) begin
		if(bk_ena & ((~old_load & bk_load) | (~old_save & bk_save))) begin
			bk_state <= 1;
			bk_loading <= bk_load;
			sd_lba <= 0;
			sd_rd <=  bk_load;
			sd_wr <= ~bk_load;
		end
		if(old_downloading & ~cart_download & |img_size & bk_ena) begin
			bk_state <= 1;
			bk_loading <= 1;
			sd_lba <= 0;
			sd_rd <= 1;
			sd_wr <= 0;
		end
	end else begin
		if(old_ack & ~sd_ack) begin
			if(&sd_lba[6:0]) begin
				bk_loading <= 0;
				bk_state <= 0;
			end else begin
				sd_lba <= sd_lba + 1'd1;
				sd_rd  <=  bk_loading;
				sd_wr  <= ~bk_loading;
			end
		end
	end
end


endmodule
