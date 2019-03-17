//============================================================================
//  FPGAGen port to MiSTer
//  Copyright (c) 2017,2018 Sorgelig
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
	inout  [44:0] HPS_BUS,

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
	input         TAPE_IN,

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
assign LED_USER  = ioctl_download | sav_pending;


//`define SOUND_DBG

`include "build_id.v"
localparam CONF_STR1 = {
	"Genesis;;",
	"FS,BINGENMD ;",
	"-;",
	"O67,Region,JP,US,EU;",
	"O8,Auto Region,No,Yes;",
	"-;",
};
localparam CONF_STR2 = {
	"G,Load Backup RAM;"
};

localparam CONF_STR3 = {
	"H,Save Backup RAM;",
	"OD,Autosave,No,Yes;",
	"-;",
	"O9,Aspect ratio,4:3,16:9;",
	"O13,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	"-;",
	"O4,Swap joysticks,No,Yes;",
	"O5,6 buttons mode,No,Yes;",
	"OLM,Multitap,Disabled,4-Way,TeamPlayer,J-Cart;",
	"OIJ,Mouse,None,Port1,Port2;",
	"OK,Mouse Flip Y,No,Yes;",
	"OEF,Audio Filter,Model 1,Model 2,Minimal,No Filter;",
	"-;",
`ifdef SOUND_DBG
	"OB,Enable FM,Yes,No;",
	"OC,Enable PSG,Yes,No;",
`endif	
	"R0,Reset;",
	"J1,A,B,C,Start,Mode,X,Y,Z;",
	"V,v",`BUILD_DATE
};


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
wire  [15:0] sd_buff_dout;
wire  [15:0] sd_buff_din;
wire        sd_buff_wr;
wire        img_mounted;
wire        img_readonly;
wire [63:0] img_size;

wire        forced_scandoubler;
wire [10:0] ps2_key;
wire [24:0] ps2_mouse;

hps_io #(.STRLEN(($size(CONF_STR1)>>3) + ($size(CONF_STR2)>>3) + ($size(CONF_STR3)>>3) + 2), .PS2DIV(1000), .WIDE(1)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.conf_str({CONF_STR1,bk_ena ? "R" : "+",CONF_STR2,bk_ena ? "R" : "+",CONF_STR3}),
	.joystick_0(joystick_0),
	.joystick_1(joystick_1),
	.joystick_2(joystick_2),
	.joystick_3(joystick_3),
	.buttons(buttons),
	.forced_scandoubler(forced_scandoubler),
	.new_vmode(new_vmode),

	.status(status),
	.status_in({status[31:8],region_req,status[5:0]}),
	.status_set(region_set),

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
wire [3:0] r, g, b;
wire vs,hs;
wire ce_pix;
wire hblank, vblank;
wire interlace;

assign DDRAM_CLK = clk_ram;
wire reset = RESET | status[0] | buttons[1] | region_set | bk_loading;

wire [15:0] audio_l, audio_r;

system system
(
	.RESET_N(~reset),
	.MCLK(clk_sys),

	.LOADING(ioctl_download),
	.EXPORT(|status[7:6]),
	.PAL(PAL),
	.SRAM_QUIRK(sram_quirk),
	.EEPROM_QUIRK(eeprom_quirk),
	.ZBUS_QUIRK(zbus_quirk),
	.NORAM_QUIRK(noram_quirk),
	.PIER_QUIRK(pier_quirk),

	.DAC_LDATA(audio_l),
	.DAC_RDATA(audio_r),

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

	.LPF_MODE(status[15:14]),

	.BRAM_A({sd_lba[6:0],sd_buff_addr}),
	.BRAM_DI(sd_buff_dout),
	.BRAM_DO(sd_buff_din),
	.BRAM_WE(sd_buff_wr & sd_ack),
	.BRAM_CHANGE(bk_change),

	.ROMSZ(ioctl_addr[24:1]),
	.ROM_ADDR(rom_addr),
	.ROM_DATA(rom_data),
	.ROM_REQ(rom_rd),
	.ROM_ACK(rom_rdack)
);

wire PAL = status[7];

reg new_vmode;
always @(posedge clk_sys) begin
	reg old_pal;
	int to;
	
	if(~(reset | ioctl_download)) begin
		old_pal <= PAL;
		if(old_pal != PAL) to <= 5000000;
	end
	else to <= 5000000;
	
	if(to) begin
		to <= to - 1;
		if(to == 1) new_vmode <= ~new_vmode;
	end
end

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

compressor compressor
(
	clk_sys,
	audio_l[15:4], audio_r[15:4],
	AUDIO_L,       AUDIO_R
);

///////////////////////////////////////////////////

wire [24:1] rom_addr;
wire [15:0] rom_data;
wire rom_rd, rom_rdack;

ddram ddram
(
	.*,

   .wraddr(ioctl_addr),
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

always @(posedge clk_sys) begin
	reg old_download, old_reset;
	old_download <= ioctl_download;
	old_reset <= reset;

	if(~old_reset && reset) ioctl_wait <= 0;
	if(~old_download && ioctl_download) rom_wr <= 0;
	else begin
		if(ioctl_wr) begin
			ioctl_wait <= 1;
			rom_wr <= ~rom_wr;
		end else if(ioctl_wait && (rom_wr == rom_wrack)) begin
			ioctl_wait <= 0;
		end
	end
end

reg  [1:0] region_req;
reg        region_set = 0;

wire       pressed = ps2_key[9];
wire [8:0] code    = ps2_key[8:0];
always @(posedge clk_sys) begin
	reg old_state, old_download = 0;
	old_state <= ps2_key[10];

	if(old_state != ps2_key[10]) begin
		casex(code)
			'h005: begin region_req <= 0; region_set <= pressed; end // F1
			'h006: begin region_req <= 1; region_set <= pressed; end // F2
			'h004: begin region_req <= 2; region_set <= pressed; end // F3
		endcase
	end

	old_download <= ioctl_download;
	if(status[8] & (old_download ^ ioctl_download) & |ioctl_index) begin
		region_set <= ioctl_download;
		region_req <= ioctl_index[7:6];
	end
end

reg sram_quirk = 0;
reg eeprom_quirk = 0;
reg fifo_quirk = 0;
reg zbus_quirk = 0;
reg noram_quirk = 0;
reg pier_quirk = 0;
always @(posedge clk_sys) begin
	reg [55:0] cart_id;
	reg [127:0] domestic;
	reg old_download, old_reset;
	old_download <= ioctl_download;

	if(~old_download && ioctl_download) {zbus_quirk,fifo_quirk,eeprom_quirk,sram_quirk,noram_quirk,pier_quirk} <= 0;

	if(ioctl_wr) begin
		if(ioctl_addr >= 'h120 && ioctl_addr < 'h130)
			domestic[('h7F - (((ioctl_addr[24:1]) - 'h90) << 3'd4)) -: 'd16] <= {ioctl_data[7:0],ioctl_data[15:8]};

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
			else if({cart_id,ioctl_data[7:0]} == "00001009") fifo_quirk <= 1;   // Sonic
			else if({cart_id,ioctl_data[7:0]} == "00004049") fifo_quirk <= 1;   // Sonic JP
			else if({cart_id,ioctl_data[7:0]} == "T-103036") zbus_quirk <= 1;   // Joe & Mac
			else if({cart_id,ioctl_data[7:0]} == "T-574023") pier_quirk <= 1;   // Pier Solar Reprint
			else if({cart_id,ioctl_data[7:0]} == "T-574013") pier_quirk <= 1;   // Pier Solar 1st Edition
			if(domestic == "OLD TOWERS      ") fifo_quirk <= 1;                 // Old Towers (uses serial 000000000)
		end
	end
end

/////////////////////////  BRAM SAVE/LOAD  /////////////////////////////


wire downloading = ioctl_download;

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
		if(old_downloading & ~ioctl_download & |img_size & bk_ena) begin
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
