//============================================================================
//  FPPGAGen port to MiSTer by Sorgelig
//
//  YM2612 implementation by Jose Tejada Gomez. Twitter: @topapate
//  Original FPGAGen code: Copyright (c) 2010-2013 Gregory Estrade (greg@torlus.com) 
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
	inout  [37:0] HPS_BUS,

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

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status ORed with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S, // 1 - signed audio samples, 0 - unsigned
	input         TAPE_IN,

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

assign {SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 6'b111111;
assign SDRAM_DQ = 'Z;

assign VIDEO_ARX = status[1] ? 8'd16 : 8'd4;
assign VIDEO_ARY = status[1] ? 8'd9  : 8'd3;

assign AUDIO_S = 1;

assign LED_DISK  = 0;
assign LED_POWER = 0;
assign LED_USER  = joy_emu_num;

`include "build_id.v"
localparam CONF_STR = {
	"FPGAGEN;;",
	"-;",
	"F,BINGEN;",
	"-;",
	"O1,Aspect ratio,4:3,16:9;",
	"O23,Scandoubler Fx,None,CRT 25%,CRT 50%,CRT 75%;",
	"-;",
	"O4,Swap joysticks,No,Yes;",
	"-;",
	"V,v1.02.",`BUILD_DATE
};


wire [31:0] status;
wire  [1:0] buttons;
wire  [7:0] joystick_0;
wire  [7:0] joystick_1;
wire        ioctl_download;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire [15:0] ioctl_data;
reg         ioctl_wait;
wire        ps2_kbd_clk;
wire        ps2_kbd_data;
wire        forced_scandoubler;

hps_io #(.STRLEN($size(CONF_STR)>>3), .PS2DIV(1000), .WIDE(1)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.conf_str(CONF_STR),
	.joystick_0(joystick_0),
	.joystick_1(joystick_1),
	.buttons(buttons),
	.status(status),
	.forced_scandoubler(forced_scandoubler),

	.ioctl_download(ioctl_download),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_data),
	.ioctl_wait(ioctl_wait),

	.ps2_kbd_clk(ps2_kbd_clk),
	.ps2_kbd_data(ps2_kbd_data),
	.ps2_kbd_led_use(0),
	.ps2_kbd_led_status(0)
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

assign CLK_VIDEO = clk_sys;

///////////////////////////////////////////////////
wire [1:0] scale = status[3:2];
wire [2:0] red, green, blue;

assign DDRAM_CLK = clk_ram;
wire reset = RESET|buttons[1];

Virtual_Toplevel fpgagen
(
	.RESET_N(~(reset|ioctl_download)),
	.MCLK(clk_sys),
	.RAMCLK(clk_ram),

	.DAC_LDATA(AUDIO_L),
	.DAC_RDATA(AUDIO_R),

	.RED(red),
	.GREEN(green),
	.BLUE(blue),
	.VS(VGA_VS),
	.HS(VGA_HS),
	.DE(VGA_DE),
	.CE_PIX(CE_PIXEL),
	.VGA(scale || forced_scandoubler),

	.PSG_ENABLE(1),
	.FM_ENABLE(1),
	.FM_LIMITER(1),

	.JOY_1((status[4] ? joystick_1 : joystick_0) | (joy_emu_num ? 8'd0 : joystick_emu)),
	.JOY_2((status[4] ? joystick_0 : joystick_1) | (joy_emu_num ? joystick_emu : 8'd0)),

	.ROM_ADDR(rom_rdaddr),
	.ROM_DATA(rom_data),
	.ROM_REQ(rom_rd),
	.ROM_ACK(rom_rdack)
);

wire [19:0] rom_rdaddr;
wire [63:0] rom_data;
wire rom_rd, rom_rdack;

ddram ddram
(
	.*,
	.reset(reset & ~ioctl_download),

   .wraddr(ioctl_addr),
   .din({ioctl_data[7:0],ioctl_data[15:8]}),
   .we_req(rom_wr),
   .we_ack(rom_wrack),

	
   .rdaddr({rom_rdaddr, 3'b000}),
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

scanlines scanlines
(
	.clk(clk_sys),
	.scanlines(scale),
	.din({{red, red, red[2:1]}, {green, green, green[2:1]}, {blue, blue, blue[2:1]}}),
	.dout({VGA_R, VGA_G, VGA_B}),
	.hs(VGA_HS),
	.vs(VGA_VS)
);


///////////////////////////////////////////////////
wire [7:0] joystick_emu;
wire       joy_emu_num;

keyboard keyboard
(
	.clk(clk_sys),
	.reset(RESET),
	.ps2_kbd_clk(ps2_kbd_clk),
	.ps2_kbd_data(ps2_kbd_data),
	.joystick(joystick_emu),
	.joy_num(joy_emu_num)
);

endmodule
