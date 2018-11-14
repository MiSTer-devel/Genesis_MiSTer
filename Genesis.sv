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
	output        SDRAM_nWE
);

assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;

assign VIDEO_ARX = status[9] ? 8'd16 : 8'd4;
assign VIDEO_ARY = status[9] ? 8'd9  : 8'd3;

assign AUDIO_S = 1;
assign AUDIO_MIX = 0;

assign LED_DISK  = 0;
assign LED_POWER = 0;
assign LED_USER  = ioctl_download;

`include "build_id.v"
localparam CONF_STR = {
	"Genesis;;",
	"-;",
	"F,BINGENMD ;",
	"-;",
	"O67,Region,JP,US,EU;",
	"O8,Auto Region,No,Yes;",
	"-;",
	"O9,Aspect ratio,4:3,16:9;",
	"O13,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	"-;",
	"O4,Swap joysticks,No,Yes;",
	"O5,6 buttons mode,No,Yes;",
	"-;",
	"OA,VRAM access rate,Fast,Original;",
`ifdef LITE
	"OB,Enable FM,Yes,No;",
	"OC,Enable PSG,Yes,No;",
`endif	
	"R0,Reset;",
	"J1,A,B,C,Start,Mode,X,Y,Z;",
	"V,v1.55.",`BUILD_DATE
};


wire [31:0] status;
wire  [1:0] buttons;
wire [15:0] joystick_0;
wire [15:0] joystick_1;
wire        ioctl_download;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire [15:0] ioctl_data;
wire  [7:0] ioctl_index;
reg         ioctl_wait;
wire        forced_scandoubler;
wire [10:0] ps2_key;

hps_io #(.STRLEN($size(CONF_STR)>>3), .PS2DIV(1000), .WIDE(1)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.conf_str(CONF_STR),
	.joystick_0(joystick_0),
	.joystick_1(joystick_1),
	.buttons(buttons),
	.forced_scandoubler(forced_scandoubler),

	.status(status),
	.status_in({status[31:8],region_req,status[5:0]}),
	.status_set(region_set),

	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_data),
	.ioctl_wait(ioctl_wait),

	.ps2_key(ps2_key)
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
wire reset = RESET | status[0] | buttons[1] | region_set;

wire [12:0] audio_l, audio_r;

Genesis Genesis
(
	.RESET_N(~reset),
	.MCLK(clk_sys),

	.LOADING(ioctl_download),
	.EXPORT(|status[7:6]),
	.PAL(status[7]),
	.SRAM_QUIRK(sram_quirk),
	.EEPROM_QUIRK(eeprom_quirk),

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
	.FAST_FIFO(~status[10]),

	.J3BUT(~status[5]),
	.JOY_1((status[4] ? joystick_1[11:0] : joystick_0[11:0])),
	.JOY_2((status[4] ? joystick_0[11:0] : joystick_1[11:0])),

`ifdef LITE
	.ENABLE_FM(~status[11]),
	.ENABLE_PSG(~status[12]),
`else
	.ENABLE_FM(1),
	.ENABLE_PSG(1),
`endif

	.ROMSZ(ioctl_addr[24:1]),
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

compressor compressor
(
	clk_sys,
	audio_l[12:1], audio_r[12:1],
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
always @(posedge clk_sys) begin
	reg [47:0] cart_id;
	reg old_download, old_reset;
	old_download <= ioctl_download;

	if(~old_download && ioctl_download) {eeprom_quirk,sram_quirk} <= 0;

	if(ioctl_wr) begin
		if(ioctl_addr == 'h184) cart_id[47:32] <= {ioctl_data[7:0],ioctl_data[15:8]};
		if(ioctl_addr == 'h186) cart_id[31:16] <= {ioctl_data[7:0],ioctl_data[15:8]};
		if(ioctl_addr == 'h188) cart_id[15:00] <= {ioctl_data[7:0],ioctl_data[15:8]};
		if(ioctl_addr == 'h18A) begin
			     if({cart_id,ioctl_data[7:0]} == "-081276") sram_quirk <= 1;
			else if({cart_id                } == "-81406" ) sram_quirk <= 1;
			else if({cart_id,ioctl_data[7:0]} == "-081586") sram_quirk <= 1;
			else if({cart_id                } == "-81576" ) sram_quirk <= 1;
			else if({cart_id                } == "-81476" ) sram_quirk <= 1;
			else if({cart_id                } == "K-1215" ) eeprom_quirk <= 1;
		end
	end
end

endmodule
