// Copyright (c) 2010 Gregory Estrade (greg@torlus.com)
// Copyright (c) 2018 Sorgelig
//
// All rights reserved
//
// Redistribution and use in source and synthezised forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
// Redistributions in synthesized form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
//
// Neither the name of the author nor the names of other contributors may
// be used to endorse or promote products derived from this software without
// specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Please report bugs to the author, but before you do so, please
// make sure that this is not a derivative work and that
// you have the latest version of this file.

module Genesis
(
	input         RESET_N,
	input         MCLK,

	input         ENABLE_FM,
	input         ENABLE_PSG,
	output [11:0] DAC_LDATA,
	output [11:0] DAC_RDATA,

	input         LOADING,
	input         PAL,
	input         EXPORT,
	input         FAST_FIFO,
	input         SRAM_QUIRK,
	input         EEPROM_QUIRK,
	input         ZBUS_QUIRK,
	
	input  [14:0] BRAM_A,
	input  [15:0] BRAM_DI,
	output [15:0] BRAM_DO,
	input         BRAM_WE,

	output  [3:0] RED,
	output  [3:0] GREEN,
	output  [3:0] BLUE,
	output        VS,
	output        HS,
	output        HBL,
	output        VBL,
	output        CE_PIX,

	output        INTERLACE,
	output        FIELD,

	input         J3BUT,
	input  [11:0] JOY_1,
	input  [11:0] JOY_2,

	input  [24:1] ROMSZ,
	output [24:1] ROM_ADDR,
	input  [15:0] ROM_DATA,
	output reg    ROM_REQ,
	input         ROM_ACK
);

reg reset;
always @(posedge MCLK) if(M68K_CLKENn) reset <= ~RESET_N | LOADING;

//--------------------------------------------------------------
// CLOCK ENABLERS
//--------------------------------------------------------------
wire M68K_CLKEN = M68K_CLKENp;
reg  M68K_CLKENp, M68K_CLKENn;
reg  Z80_CLKEN;

always @(negedge MCLK) begin
	reg [3:0] VCLKCNT = 0;
	reg [3:0] ZCLKCNT = 0;

	Z80_CLKEN <= 0;
	ZCLKCNT <= ZCLKCNT + 1'b1;
	if (ZCLKCNT == 14) begin
		ZCLKCNT <= 0;
		Z80_CLKEN <= 1;
	end

	M68K_CLKENp <= 0;
	VCLKCNT <= VCLKCNT + 1'b1;
	if (VCLKCNT == 6) begin
		VCLKCNT <= 0;
		M68K_CLKENp <= 1;
	end

	M68K_CLKENn <= 0;
	if (VCLKCNT == 3) begin
		M68K_CLKENn <= 1;
	end
end

reg [15:1] ram_rst_a;
always @(posedge MCLK) ram_rst_a <= ram_rst_a + LOADING;


//--------------------------------------------------------------
// CPU 68000
//--------------------------------------------------------------
wire [23:1] M68K_A;
wire [15:0] M68K_DO;
wire        M68K_AS_N;
wire        M68K_UDS_N;
wire        M68K_LDS_N;
wire        M68K_RNW;
wire  [2:0] M68K_FC;

reg   [2:0] M68K_IPL_N;
always @(posedge MCLK) begin
	reg       old_as;
	reg [1:0] scnt;
	
	if(reset) M68K_IPL_N <= 3'b111;
	else if (M68K_CLKEN) begin
		old_as <= M68K_AS_N;
		scnt <= scnt + 1'd1;
		if(~M68K_AS_N) scnt <= 0;
		if((~old_as & M68K_AS_N) || &scnt) begin
			if (M68K_VINT) M68K_IPL_N <= 3'b001;
			else if (M68K_HINT) M68K_IPL_N <= 3'b011;
			else M68K_IPL_N <= 3'b111;
		end
	end
end

wire M68K_INTACK = &M68K_FC;

fx68k M68K
(
	.clk(MCLK),
	.extReset(reset),
	.pwrUp(reset),
	.enPhi1(M68K_CLKENp),
	.enPhi2(M68K_CLKENn),

	.eRWn(M68K_RNW),
	.ASn(M68K_AS_N),
	.UDSn(M68K_UDS_N),
	.LDSn(M68K_LDS_N),

	.FC0(M68K_FC[0]),
	.FC1(M68K_FC[1]),
	.FC2(M68K_FC[2]),

	.BGn(),
	.DTACKn(M68K_MBUS_DTACK_N | VBUS_BUSY),
	.VPAn(~M68K_INTACK),
	.BERRn(1),
	.BRn(1),
	.BGACKn(1),
	.IPL0n(M68K_IPL_N[0]),
	.IPL1n(M68K_IPL_N[1]),
	.IPL2n(M68K_IPL_N[2]),
	.iEdb(M68K_MBUS_D),
	.oEdb(M68K_DO),
	.eab(M68K_A)
);


//--------------------------------------------------------------
// CPU Z80
//--------------------------------------------------------------
reg         Z80_RESET_N;
reg         Z80_BUSRQ_N;
wire        Z80_M1_N;
wire        Z80_MREQ_N;
wire        Z80_IORQ_N;
wire        Z80_RD_N;
wire        Z80_WR_N;
wire [15:0] Z80_A;
wire  [7:0] Z80_DO;
wire        Z80_IO = ~Z80_MREQ_N & (~Z80_RD_N | ~Z80_WR_N);

T80s #(.T2Write(1)) Z80
(
	.reset_n(Z80_RESET_N),
	.clk(MCLK),
	.cen(Z80_CLKEN & Z80_BUSRQ_N),
	.wait_n(~Z80_MBUS_DTACK_N | ~Z80_ZBUS_DTACK_N | ~Z80_IO),
	.int_n(~Z80_VINT),
	.m1_n(Z80_M1_N),
	.mreq_n(Z80_MREQ_N),
	.iorq_n(Z80_IORQ_N),
	.rd_n(Z80_RD_N),
	.wr_n(Z80_WR_N),
	.a(Z80_A),
	.di((~Z80_ZBUS_DTACK_N) ? Z80_ZBUS_D : Z80_MBUS_D),
	.do(Z80_DO)
);

wire        CTRL_F  = (MBUS_A[11:8] == 1) ? Z80_BUSRQ_N : (MBUS_A[11:8] == 2) ? Z80_RESET_N : NO_DATA[8];
wire [15:0] CTRL_DO = {NO_DATA[15:9], CTRL_F, NO_DATA[7:0]};
reg         CTRL_SEL;
always @(posedge MCLK) begin
	if (reset) begin
		Z80_BUSRQ_N <= 1;
		Z80_RESET_N <= 0;
	end
	else if(CTRL_SEL & ~MBUS_RNW & ~MBUS_UDS_N) begin
		if (MBUS_A[11:8] == 1) Z80_BUSRQ_N <= ~MBUS_DO[8];
		if (MBUS_A[11:8] == 2) Z80_RESET_N <=  MBUS_DO[8];
	end
end


//--------------------------------------------------------------
// VDP + PSG
//--------------------------------------------------------------
reg         VDP_SEL;
wire [15:0] VDP_DO;
wire        VDP_DTACK_N;

wire [23:1] VBUS_A;
wire        VBUS_SEL;
wire        VBUS_BUSY;

wire        M68K_HINT;
wire        M68K_VINT;
wire        Z80_VINT;

wire        vram_req;
wire        vram_we_u;
wire        vram_we_l;
wire [15:1] vram_a;
wire [15:0] vram_d;
wire [15:0] vram_q;

dpram #(15) vram_l
(
	.clock(MCLK),
	.address_a(vram_a),
	.data_a(vram_d[7:0]),
	.wren_a(vram_we_l & (vram_ack ^ vram_req)),
	.q_a(vram_q[7:0]),

	.address_b(ram_rst_a),
	.wren_b(LOADING)
);

dpram #(15) vram_u
(
	.clock(MCLK),
	.address_a(vram_a),
	.data_a(vram_d[15:8]),
	.wren_a(vram_we_u & (vram_ack ^ vram_req)),
	.q_a(vram_q[15:8]),

	.address_b(ram_rst_a),
	.wren_b(LOADING)
);

reg vram_ack;
always @(posedge MCLK) vram_ack <= vram_req;

vdp vdp
(
	.rst_n(~reset),
	.clk(MCLK),

	.sel(VDP_SEL),
	.a(MBUS_A[4:1]),
	.rnw(MBUS_RNW),
	.di(MBUS_DO),
	.do(VDP_DO),
	.dtack_n(VDP_DTACK_N),

	.vram_req(vram_req),
	.vram_ack(vram_ack),
	.vram_we_u(vram_we_u),
	.vram_we_l(vram_we_l),
	.vram_a(vram_a),
	.vram_do(vram_d),
	.vram_di(vram_q),

	.tg68_hint(M68K_HINT),
	.tg68_vint(M68K_VINT),
	.tg68_intack(M68K_INTACK),

	.t80_vint(Z80_VINT),
	.t80_intack(~Z80_M1_N & ~Z80_IORQ_N),

	.vbus_addr(VBUS_A),
	.vbus_data(VDP_MBUS_D),
	.vbus_sel(VBUS_SEL),
	.vbus_dtack_n(VDP_MBUS_DTACK_N),
	.vbus_busy(VBUS_BUSY),

	.fast_fifo(FAST_FIFO),

	.field(FIELD),
	.interlace(INTERLACE),

	.pal(PAL),
	.r(RED),
	.g(GREEN),
	.b(BLUE),
	.hs(HS),
	.vs(VS),
	.ce_pix(CE_PIX),
	.hbl(HBL),
	.vbl(VBL)
);

// PSG 0x10-0x17 in VDP space
wire [5:0] PSG_SND;
psg psg
(
	.reset(reset),
	.clk(MCLK),
	.clken(Z80_CLKEN),

	.wr_n(MBUS_RNW | ~VDP_SEL | ~MBUS_A[4] | MBUS_A[3]),
	.d_in(MBUS_DO[15:8]),

	.snd(PSG_SND)
);


//--------------------------------------------------------------
// I/O
//--------------------------------------------------------------
reg        IO_SEL;
wire [7:0] IO_DO;
wire       IO_DTACK_N;

gen_io io
(
	.rst_n(~reset),
	.clk(MCLK & M68K_CLKEN),

	.j3but(J3BUT),

	.p1_up(~JOY_1[3]),
	.p1_down(~JOY_1[2]),
	.p1_left(~JOY_1[1]),
	.p1_right(~JOY_1[0]),
	.p1_a(~JOY_1[4]),
	.p1_b(~JOY_1[5]),
	.p1_c(~JOY_1[6]),
	.p1_start(~JOY_1[7]),
	.p1_mode(~JOY_1[8]),
	.p1_x(~JOY_1[9]),
	.p1_y(~JOY_1[10]),
	.p1_z(~JOY_1[11]),

	.p2_up(~JOY_2[3]),
	.p2_down(~JOY_2[2]),
	.p2_left(~JOY_2[1]),
	.p2_right(~JOY_2[0]),
	.p2_a(~JOY_2[4]),
	.p2_b(~JOY_2[5]),
	.p2_c(~JOY_2[6]),
	.p2_start(~JOY_2[7]),
	.p2_mode(~JOY_2[8]),
	.p2_x(~JOY_2[9]),
	.p2_y(~JOY_2[10]),
	.p2_z(~JOY_2[11]),

	.sel(IO_SEL),
	.a(MBUS_A[4:1]),
	.rnw(MBUS_RNW),
	.di(MBUS_DO[7:0]),
	.do(IO_DO),
	.dtack_n(IO_DTACK_N),

	.pal(PAL),
	.export(EXPORT)
);


//-----------------------------------------------------------------------
// ROM
//-----------------------------------------------------------------------
assign ROM_ADDR = use_map ? {map[MBUS_A[21:19]], MBUS_A[18:1]} : MBUS_A[22:1];

//SSF2 mapper
reg [5:0] map[8];
reg       use_map = 0;
always @(posedge MCLK) begin
	if(reset) begin
		map[0] <= 0; map[1] <= 1; map[2] <= 2;	map[3] <= 3; map[4] <= 4; map[5] <= 5; map[6] <= 6; map[7] <= 7;
		use_map <= 0;
	end
	else if(~MBUS_RNW && MBUS_A[23:4] == 20'hA130F && MBUS_A[3:1]) begin
		map[MBUS_A[3:1]] <= MBUS_DO[5:0];
		use_map <= 1;
	end
end


//-----------------------------------------------------------------------
// 64KB SRAM
//-----------------------------------------------------------------------
reg SRAM_SEL;

dpram #(15) sram_u
(
	.clock(MCLK),
	.address_a(MBUS_A[15:1]),
	.data_a(MBUS_DO[15:8]),
	.wren_a(SRAM_SEL & ~MBUS_RNW & ~MBUS_UDS_N),
	.q_a(sram_q[15:8]),

	.address_b(LOADING ? ram_rst_a : BRAM_A[14:0]),
	.data_b(LOADING ? 8'h00 : BRAM_DI[15:8]),
	.wren_b(LOADING | BRAM_WE),
	.q_b(BRAM_DO[15:8])
);

dpram #(15) sram_l
(
	.clock(MCLK),
	.address_a(MBUS_A[15:1]),
	.data_a(MBUS_DO[7:0]),
	.wren_a(SRAM_SEL & ~MBUS_RNW & ~MBUS_LDS_N),
	.q_a(sram_q[7:0]),

	.address_b(LOADING ? ram_rst_a : BRAM_A[14:0]),
	.data_b(LOADING ? 8'h00 : BRAM_DI[7:0]),
	.wren_b(LOADING | BRAM_WE),
	.q_b(BRAM_DO[7:0])
);
wire [15:0] sram_q;


//-----------------------------------------------------------------------
// 68K RAM
//-----------------------------------------------------------------------
reg RAM_SEL;

dpram #(15) ram68k_u
(
	.clock(MCLK),
	.address_a(MBUS_A[15:1]),
	.data_a(MBUS_DO[15:8]),
	.wren_a(RAM_SEL & ~MBUS_RNW & ~MBUS_UDS_N),
	.q_a(ram68k_q[15:8]),

	.address_b(ram_rst_a),
	.wren_b(LOADING)
);

dpram #(15) ram68k_l
(
	.clock(MCLK),
	.address_a(MBUS_A[15:1]),
	.data_a(MBUS_DO[7:0]),
	.wren_a(RAM_SEL & ~MBUS_RNW & ~MBUS_LDS_N),
	.q_a(ram68k_q[7:0]),

	.address_b(ram_rst_a),
	.wren_b(LOADING)
);
wire [15:0] ram68k_q;


//-----------------------------------------------------------------------
// MBUS Handling
//-----------------------------------------------------------------------
reg        M68K_MBUS_DTACK_N;
reg        Z80_MBUS_DTACK_N;
reg        VDP_MBUS_DTACK_N;

reg [15:0] M68K_MBUS_D;
reg  [7:0] Z80_MBUS_D;
reg [15:0] VDP_MBUS_D;

reg [23:1] MBUS_A;
reg [15:0] MBUS_DO;

reg        MBUS_RNW;
reg        MBUS_UDS_N;
reg        MBUS_LDS_N;

always @(posedge MCLK) begin
	reg  [3:0] mstate;
	reg  [1:0] msrc;
	reg [15:0] data;
	
	localparam	MSRC_NONE = 0,
					MSRC_M68K = 1,
					MSRC_Z80  = 2,
					MSRC_VDP  = 3;

	localparam 	MBUS_IDLE     = 0,
					MBUS_SELECT   = 1,
					MBUS_RAM_READ = 2,
					MBUS_ROM_READ = 3,
					MBUS_VDP_READ = 4,
					MBUS_IO_READ  = 5,
					MBUS_SRAM_READ= 6,
					MBUS_ZBUS_PRE = 7,
					MBUS_ZBUS_READ= 8,
					MBUS_FINISH   = 9;

	if (reset) begin
		M68K_MBUS_DTACK_N <= 1;
		Z80_MBUS_DTACK_N  <= 1;
		VDP_MBUS_DTACK_N  <= 1;
		VDP_SEL <= 0;
		IO_SEL <= 0;
		ZBUS_SEL <= 0;
		mstate <= MBUS_IDLE;
		MBUS_RNW <= 1;
	end
	else begin
		if (M68K_AS_N) M68K_MBUS_DTACK_N <= 1;
		if (~Z80_IO)   Z80_MBUS_DTACK_N  <= 1;
		if (~VBUS_SEL) VDP_MBUS_DTACK_N  <= 1;

		case(mstate)
		MBUS_IDLE:
			begin
				CTRL_SEL <= 0;
				SRAM_SEL <= 0;
				RAM_SEL <= 0;
				MBUS_RNW <= 1;
				MBUS_UDS_N <= 1;
				MBUS_LDS_N <= 1;
				if(~M68K_AS_N & M68K_MBUS_DTACK_N & M68K_CLKENn & ~VBUS_BUSY) begin
					msrc <= MSRC_M68K;
					MBUS_A <= M68K_A[23:1];
					data <= NO_DATA;
					MBUS_DO <= M68K_DO;
					MBUS_RNW <= M68K_RNW;
					mstate <= MBUS_SELECT;
				end
				else if(Z80_IO & ~Z80_ZBUS & Z80_MBUS_DTACK_N & ~VBUS_BUSY) begin
					msrc <= MSRC_Z80;
					MBUS_A <= Z80_A[15] ? {BAR[23:15],Z80_A[14:1]} : {16'hC000, Z80_A[7:1]};
					data <= 16'hFFFF;
					MBUS_DO <= {Z80_DO,Z80_DO};
					MBUS_RNW <= Z80_WR_N;
					mstate <= MBUS_SELECT;
				end
				else if(VBUS_SEL & VDP_MBUS_DTACK_N) begin
					msrc <= MSRC_VDP;
					MBUS_A <= VBUS_A;
					data <= NO_DATA;
					MBUS_DO <= 0;
					mstate <= MBUS_SELECT;
				end
			end
			
		MBUS_SELECT:
			begin
				//NO DEVICE (usually lockup on real HW)
				mstate <= MBUS_FINISH;

				//ROM: 000000-7FFFFF
				if(~MBUS_A[23]) begin
					if (EEPROM_QUIRK && {MBUS_A,1'b0} == 'h200000) begin
						data <= 0;
						mstate <= MBUS_FINISH;
					end
					else if (SRAM_QUIRK && {MBUS_A,1'b0} == 'h200000) begin
						SRAM_SEL <= 1;
						mstate <= MBUS_SRAM_READ;
					end
					else if (MBUS_A < ROMSZ) begin
						ROM_REQ <= ~ROM_ACK;
						mstate <= MBUS_ROM_READ;
					end
					else if(MBUS_A[22:21] == 1 && ~&MBUS_A[20:19]) begin
						// 200000-37FFFF
						SRAM_SEL <= 1;
						mstate <= MBUS_SRAM_READ;
					end
					else begin
						data <= 0;
						mstate <= MBUS_FINISH;
					end
				end
				
				//ZBUS: A00000-A07FFF (A08000-A0FFFF)
				if(MBUS_A[23:16] == 'hA0) mstate <= MBUS_ZBUS_PRE;

				//I/O: A10000-A1001F (+mirrors)
				if(MBUS_A[23:5] == {16'hA100, 3'b000}) begin
					IO_SEL <= 1;
					mstate <= MBUS_IO_READ;
				end

				//CTL: A11100, A11200
				if(MBUS_A[23:12] == 12'hA11 && !MBUS_A[7:1]) begin
					CTRL_SEL <= 1;
					data <= CTRL_DO;
					mstate <= MBUS_FINISH;
				end

				//VDP: C00000-C0001F (+mirrors)
				if(MBUS_A[23:21] == 3'b110 && !MBUS_A[18:16] && !MBUS_A[7:5]) begin
					VDP_SEL <= 1;
					mstate <= MBUS_VDP_READ;
				end

				//RAM: E00000-FFFFFF
				if(&MBUS_A[23:21]) begin
					RAM_SEL <= 1;
					mstate <= MBUS_RAM_READ;
				end
			end
			
		MBUS_ZBUS_PRE:
			case(msrc)
			MSRC_M68K:
				if(M68K_AS_N | (~M68K_UDS_N | ~M68K_LDS_N)) begin
					MBUS_UDS_N <= M68K_UDS_N;
					MBUS_LDS_N <= M68K_LDS_N;
					ZBUS_SEL <= 1;
					mstate <= MBUS_ZBUS_READ;
				end

			MSRC_Z80:
				begin
					MBUS_UDS_N <= Z80_A[0];
					MBUS_LDS_N <= ~Z80_A[0];
					ZBUS_SEL <= 1;
					mstate <= MBUS_ZBUS_READ;
				end

			MSRC_VDP:
				begin
					MBUS_UDS_N <= 0;
					MBUS_LDS_N <= 0;
					ZBUS_SEL <= 1;
					mstate <= MBUS_ZBUS_READ;
				end
			endcase

		MBUS_ZBUS_READ:
			if(~MBUS_ZBUS_DTACK_N) begin
				ZBUS_SEL <= 0;
				data <= {MBUS_ZBUS_D, MBUS_ZBUS_D};
				mstate <= MBUS_FINISH;
			end

		MBUS_RAM_READ:
			begin
				data <= ram68k_q;
				mstate <= MBUS_FINISH;
			end

		MBUS_ROM_READ:
			if (ROM_REQ == ROM_ACK) begin
				data <= ROM_DATA;
				mstate <= MBUS_FINISH;
			end

		MBUS_SRAM_READ:
			begin
				data <= sram_q;
				mstate <= MBUS_FINISH;
			end

		MBUS_VDP_READ:
			if (~VDP_DTACK_N) begin
				VDP_SEL <= 0;
				data <= VDP_DO;
				mstate <= MBUS_FINISH;
			end

		MBUS_IO_READ:
			if(~IO_DTACK_N) begin
				IO_SEL <= 0;
				data <= {IO_DO, IO_DO};
				mstate <= MBUS_FINISH;
			end

		MBUS_FINISH:
			begin
				case(msrc)
				MSRC_M68K:
					begin
						M68K_MBUS_D <= data;
						M68K_MBUS_DTACK_N <= 0;
						if(M68K_AS_N | MBUS_RNW | ~M68K_UDS_N | ~M68K_LDS_N) begin
							MBUS_UDS_N <= M68K_UDS_N;
							MBUS_LDS_N <= M68K_LDS_N;
							mstate <= MBUS_IDLE;
						end
					end

				MSRC_Z80:
					begin
						Z80_MBUS_D <= Z80_A[0] ? data[7:0] : data[15:8];
						Z80_MBUS_DTACK_N <= 0;
						MBUS_UDS_N <= Z80_A[0];
						MBUS_LDS_N <= ~Z80_A[0];
						mstate <= MBUS_IDLE;
					end

				MSRC_VDP:
					begin
						VDP_MBUS_D <= data;
						VDP_MBUS_DTACK_N <= 0;
						mstate <= MBUS_IDLE;
					end
				endcase;
			end
		endcase;
	end
end


//-----------------------------------------------------------------------
// ZBUS Handling
//-----------------------------------------------------------------------
// Z80:   0000-7EFF
// 68000: A00000-A07FFF (A08000-A0FFFF)

wire       Z80_ZBUS  = ~Z80_A[15] && ~&Z80_A[14:8];

reg        ZBUS_SEL;
reg [14:0] ZBUS_A;
reg        ZBUS_WE;
reg  [7:0] ZBUS_DO;
wire [7:0] ZBUS_DI = ZRAM_SEL ? ZRAM_DO : FM_SEL ? FM_DO : 8'hFF;

reg  [7:0] MBUS_ZBUS_D;
reg  [7:0] Z80_ZBUS_D;

reg        MBUS_ZBUS_DTACK_N;
reg        Z80_ZBUS_DTACK_N;

wire       Z80_ZBUS_SEL  = Z80_ZBUS & Z80_IO;
wire       ZBUS_FREE = (~Z80_BUSRQ_N | ~ZBUS_QUIRK) & Z80_RESET_N;

// RAM 0000-1FFF (2000-3FFF)
wire ZRAM_SEL = ~ZBUS_A[14];

wire  [7:0] ZRAM_DO;
dpram #(13) ramZ80
(
	.clock(MCLK),
	.address_a(ZBUS_A[12:0]),
	.data_a(ZBUS_DO),
	.wren_a(ZBUS_WE & ZRAM_SEL),
	.q_a(ZRAM_DO)
);

always @(posedge MCLK) begin
	reg [1:0] zstate;
	reg [1:0] zsrc;

	localparam 	ZSRC_MBUS = 0,
					ZSRC_Z80  = 1;

	localparam	ZBUS_IDLE   = 0,
					ZBUS_READ   = 1,
					ZBUS_FINISH = 2;

	ZBUS_WE <= 0;
	
	if (reset) begin
		MBUS_ZBUS_DTACK_N <= 1;
		Z80_ZBUS_DTACK_N  <= 1;
		zstate <= ZBUS_IDLE;
	end
	else begin
		if (~ZBUS_SEL)     MBUS_ZBUS_DTACK_N <= 1;
		if (~Z80_ZBUS_SEL) Z80_ZBUS_DTACK_N  <= 1;

		case (zstate)
		ZBUS_IDLE:
			if (ZBUS_SEL & MBUS_ZBUS_DTACK_N) begin
				ZBUS_A <= {MBUS_A[14:1], MBUS_UDS_N};
				ZBUS_DO <= (~MBUS_UDS_N) ? MBUS_DO[15:8] : MBUS_DO[7:0];
				ZBUS_WE <= ~MBUS_RNW & ZBUS_FREE;
				zsrc <= ZSRC_MBUS;
				zstate <= ZBUS_READ;
			end
			else if (Z80_ZBUS_SEL & Z80_ZBUS_DTACK_N) begin
				ZBUS_A <= Z80_A[14:0];
				ZBUS_DO <= Z80_DO;
				ZBUS_WE <= ~Z80_WR_N;
				zsrc <= ZSRC_Z80;
				zstate <= ZBUS_READ;
			end

		ZBUS_READ:
			zstate <= ZBUS_FINISH;

		ZBUS_FINISH:
			begin
				case(zsrc)
				ZSRC_MBUS:
					begin
						MBUS_ZBUS_D <= ZBUS_FREE ? ZBUS_DI : 8'hFF;
						MBUS_ZBUS_DTACK_N <= 0;
					end

				ZSRC_Z80:
					begin
						Z80_ZBUS_D <= ZBUS_DI;
						Z80_ZBUS_DTACK_N <= 0;
					end
				endcase
				zstate <= ZBUS_IDLE;
			end
		endcase
	end
end


//-----------------------------------------------------------------------
// Z80 BANK REGISTER
//-----------------------------------------------------------------------
// 6000-60FF

wire BANK_SEL = ZBUS_A[14:8] == 7'h60;
reg [23:15] BAR;

always @(posedge MCLK) begin
	if (reset) BAR <= 0;
	else if (BANK_SEL & ZBUS_WE) BAR <= {ZBUS_DO[0], BAR[23:16]};
end


//--------------------------------------------------------------
// YM2612
//--------------------------------------------------------------
// 4000-4003 (4000-5FFF)

wire        FM_SEL = ZBUS_A[14:13] == 2'b10;
wire  [7:0] FM_DO;
wire [15:0] FM_right;
wire [15:0] FM_left;

jt12 fm
(
	.rst(~Z80_RESET_N),
	.clk(MCLK),
	.cen(M68K_CLKEN),

	.cs_n(0),
	.addr(ZBUS_A[1:0]),
	.wr_n(~(FM_SEL & ZBUS_WE)),
	.din(ZBUS_DO),
	.dout(FM_DO),

	.snd_left(FM_left),
	.snd_right(FM_right)
);

assign DAC_LDATA = ({12{ENABLE_FM}} & FM_left[15:4])  + ({12{ENABLE_PSG}} & {PSG_SND, 3'b00});
assign DAC_RDATA = ({12{ENABLE_FM}} & FM_right[15:4]) + ({12{ENABLE_PSG}} & {PSG_SND, 3'b00});


//-----------------------------------------------------------------------
// BUS NOISE GENERATOR
//-----------------------------------------------------------------------
reg [15:0] NO_DATA;
always @(posedge MCLK) begin
	reg [16:0] lfsr;

	if (M68K_CLKEN) begin
		lfsr <= {(lfsr[0] ^ lfsr[2] ^ !lfsr), lfsr[16:1]};
		NO_DATA <= {NO_DATA[14:0], lfsr[0]};
	end
end

endmodule
