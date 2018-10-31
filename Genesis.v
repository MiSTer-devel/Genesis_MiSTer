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
	input             RESET_N,
	input             MCLK,

	output     [12:0] DAC_LDATA,
	output     [12:0] DAC_RDATA,

	input             PAL,
	input             EXPORT,
	output      [3:0] RED,
	output      [3:0] GREEN,
	output      [3:0] BLUE,
	output            VS,
	output            HS,
	output            HBL,
	output            VBL,
	output            CE_PIX,

	output            INTERLACE,
	output            FIELD,

	input             J3BUT,
	input      [11:0] JOY_1,
	input      [11:0] JOY_2,

	output      [2:0] MAPPER_A,
	output            MAPPER_WE,
	output      [7:0] MAPPER_D,

	output reg [22:1] ROM_ADDR,
	input      [15:0] ROM_DATA,
	output reg        ROM_REQ,
	input             ROM_ACK
);


//--------------------------------------------------------------
// CLOCK ENABLERS
//--------------------------------------------------------------
reg TG68_CLKEN;
reg T80_CLKEN;

always @(negedge MCLK) begin
	reg [3:0] VCLKCNT = 0;
	reg [3:0] ZCLKCNT = 0;

	T80_CLKEN <= 0;
	ZCLKCNT <= ZCLKCNT + 1'b1;
	if (ZCLKCNT == 14) begin
		ZCLKCNT <= 0;
		T80_CLKEN <= 1;
	end

	TG68_CLKEN <= 0;
	VCLKCNT <= VCLKCNT + 1'b1;
	if (VCLKCNT == 6) begin
		VCLKCNT <= 0;
		TG68_CLKEN <= 1;
	end
end


//--------------------------------------------------------------
// CPU 68000
//--------------------------------------------------------------
reg   [2:0] TG68_IPL_N;
wire [31:1] TG68_A;
wire [15:0] TG68_DO;
reg         TG68_AS_N;
wire        TG68_UDS_N;
wire        TG68_LDS_N;
wire        TG68_RNW;
wire  [1:0] TG68_STATE;
wire  [2:0] TG68_FC;
reg   [1:0] TG68_ENA_DIV;

// a full cpu cycle consists of 4 TG68_CLKEN cycles
// VCLK = 54 MHz / 7 = 7.7 MHz
always @(posedge MCLK) begin
	if (TG68_CLKEN) begin
		// advance counter till last cycle
		if (TG68_ENA_DIV != 3) TG68_ENA_DIV <= TG68_ENA_DIV + 1'd1;

		// activate AS_N in bus cycle 2 if the cpu wants to do I/O
		if (TG68_ENA_DIV == 1 && TG68_STATE != 1) TG68_AS_N <= 0;

		// de-activate AS_N in bus cycle 3 if dtack is ok. This happens at the same
		// time the tg68k is enabled due to dtack and proceeds one clock
		if (TG68_ENA_DIV == 3 && !TG68_DTACK_N) begin
			TG68_ENA_DIV <= TG68_ENA_DIV + 1'b1;
			TG68_AS_N <= 1;
		end

		// keep counter at 0 in non-bus cycles.
		if (TG68_STATE == 1) TG68_ENA_DIV <= 0;
	end
end

wire TG68_ENA    = (TG68_CLKEN && (TG68_STATE == 1 || (TG68_ENA_DIV == 3 && ~TG68_DTACK_N)));
wire TG68_INTACK = ~TG68_AS_N & &TG68_FC;
wire TG68_IO     = ~TG68_AS_N & (~TG68_UDS_N | ~TG68_LDS_N);

always @(posedge MCLK) begin
	if (TG68_CLKEN && !TG68_ENA_DIV) begin
		if (TG68_VINT) TG68_IPL_N <= 3'b001;
		else if (TG68_HINT) TG68_IPL_N <= 3'b011;
		else TG68_IPL_N <= 3'b111;
	end
end

wire TG68_DTACK_N =	TG68_ROM_SEL  ? TG68_ROM_DTACK_N  :
							TG68_RAM_SEL  ? TG68_RAM_DTACK_N  :
							TG68_CTRL_SEL ? TG68_CTRL_DTACK_N :
							TG68_IO_SEL   ? TG68_IO_DTACK_N   :
							TG68_VDP_SEL  ? TG68_VDP_DTACK_N  :
							TG68_ZBUS_SEL ? TG68_ZBUS_DTACK_N :
							1'b0;

wire [15:0] TG68_DI= TG68_ROM_SEL  ? TG68_ROM_D  :
							TG68_RAM_SEL  ? TG68_RAM_D  :
							TG68_CTRL_SEL ? TG68_CTRL_D :
							TG68_IO_SEL   ? TG68_IO_D   :
							TG68_VDP_SEL  ? TG68_VDP_D  :
							TG68_ZBUS_SEL ? TG68_ZBUS_D :
							NO_DATA;

TG68KdotC_Kernel #(.TASbug(1)) CPU_68K
(
	.clk(MCLK),
	.nreset(RESET_N),
	.clkena_in(TG68_ENA),
	.data_in(TG68_DI),
	.ipl(TG68_IPL_N),
	.addr(TG68_A),
	.data_write(TG68_DO),
	.nuds(TG68_UDS_N),
	.nlds(TG68_LDS_N),
	.nwr(TG68_RNW),
	.busstate(TG68_STATE),
	.fc(TG68_FC)
);


//--------------------------------------------------------------
// CPU Z80
//--------------------------------------------------------------
reg         T80_RESET_N;
reg         T80_BUSRQ_N;
wire        T80_M1_N;
wire        T80_MREQ_N;
wire        T80_IORQ_N;
wire        T80_RD_N;
wire        T80_WR_N;
wire        T80_BUSAK_N;
wire [15:0] T80_A;
wire  [7:0] T80_DO;
wire        T80_IO = ~T80_MREQ_N & (~T80_RD_N | ~T80_WR_N);

wire T80_WAIT_N = T80_ROM_SEL  ? ~T80_ROM_DTACK_N  :
						T80_RAM_SEL  ? ~T80_RAM_DTACK_N  :
						T80_CTRL_SEL ? ~T80_CTRL_DTACK_N :
						T80_IO_SEL   ? ~T80_IO_DTACK_N   :
						T80_VDP_SEL  ? ~T80_VDP_DTACK_N  :
						T80_ZBUS_SEL ? ~T80_ZBUS_DTACK_N :
						1'b1;

wire [7:0] T80_DI =	T80_ROM_SEL  ? T80_ROM_D  :
							T80_RAM_SEL  ? T80_RAM_D  :
							T80_CTRL_SEL ? T80_CTRL_D :
							T80_IO_SEL   ? T80_IO_D   :
							T80_VDP_SEL  ? T80_VDP_D  :
							T80_ZBUS_SEL ? T80_ZBUS_D :
							8'hFF;

T80s #(.T2Write(1)) CPU_Z80
(
	.reset_n(T80_RESET_N),
	.clk(MCLK),
	.cen(T80_CLKEN),
	.wait_n(T80_WAIT_N),
	.int_n(~T80_VINT),
	.busrq_n(T80_BUSRQ_N),
	.m1_n(T80_M1_N),
	.mreq_n(T80_MREQ_N),
	.iorq_n(T80_IORQ_N),
	.rd_n(T80_RD_N),
	.wr_n(T80_WR_N),
	.busak_n(T80_BUSAK_N),
	.a(T80_A),
	.di(T80_DI),
	.do(T80_DO)
);

// CONTROL AREA
// $A11100 ZBUS request
// $A11200 Reset the Z80

reg [15:0] TG68_CTRL_D;
reg        TG68_CTRL_DTACK_N;
reg  [7:0] T80_CTRL_D;
reg        T80_CTRL_DTACK_N;

wire TG68_CTRL_SEL = (TG68_A[23:12] == 12'hA11 || TG68_A[23:12] == 12'hA14) && TG68_IO;
wire T80_CTRL_SEL  = T80_A[15] && ({BAR[23:15], T80_A[14:12]} == 12'hA11 || {BAR[23:15], T80_A[14:12]} == 12'hA14) && T80_IO;

always @(posedge MCLK) begin
	if (~RESET_N) begin
		TG68_CTRL_DTACK_N <= 1;
		T80_CTRL_DTACK_N  <= 1;
		T80_BUSRQ_N <= 1;
		T80_RESET_N <= 0;
	end
	else begin
		if (~TG68_CTRL_SEL) TG68_CTRL_DTACK_N <= 1;
		if (~T80_CTRL_SEL)  T80_CTRL_DTACK_N  <= 1;

		if (TG68_CTRL_SEL & TG68_CTRL_DTACK_N) begin
			TG68_CTRL_DTACK_N <= 0;
			if (~TG68_RNW) begin
				// Write
				if (TG68_A[15:8] == 8'h11) begin
					if (~TG68_UDS_N) T80_BUSRQ_N <= ~TG68_DO[8];
				end
				else if (TG68_A[15:8] == 8'h12) begin
					if (~TG68_UDS_N) T80_RESET_N <= TG68_DO[8];
				end
			end
			else begin
				// Read
				TG68_CTRL_D <= NO_DATA;
				if (TG68_A[15:8] == 8'h11)      TG68_CTRL_D[8] <= T80_BUSAK_N;
				else if (TG68_A[15:8] == 8'h12) TG68_CTRL_D[8] <= T80_RESET_N;
			end
		end
		else if (T80_CTRL_SEL & T80_CTRL_DTACK_N) begin
			T80_CTRL_DTACK_N <= 0;
			if (~T80_WR_N) begin
				// Write
				if ({BAR[15], T80_A[14:8]} == 8'h11) begin
					if (~T80_A[0]) T80_BUSRQ_N <= ~T80_DO[0];
				end
				else if ({BAR[15], T80_A[14:8]} == 8'h12) begin
					if (~T80_A[0]) T80_RESET_N <= T80_DO[0];
				end
			end
			else begin
				// Read
				T80_CTRL_D <= NO_DATA[7:0];
				if ({BAR[15], T80_A[14:8]} == 8'h11 && !T80_A[0]) T80_CTRL_D[0] <= T80_BUSAK_N;
			end
		end
	end
end


//--------------------------------------------------------------
// VDP + PSG
//--------------------------------------------------------------
// VDP in Z80 address space :
// Z80:
// 7F = 01111111 000
// 68000:
// 7F = 01111111 000
// FF = 11111111 000

reg         VDP_SEL;
reg   [4:1] VDP_A;
reg         VDP_RNW;
reg  [15:0] VDP_DI;
wire [15:0] VDP_DO;
wire        VDP_DTACK_N;

reg  [15:0] TG68_VDP_D;
reg         TG68_VDP_DTACK_N;
reg   [7:0] T80_VDP_D;
reg         T80_VDP_DTACK_N;

wire [23:0] VBUS_ADDR;
wire        VBUS_SEL;

wire        TG68_HINT;
wire        TG68_VINT;
wire        T80_VINT;

wire VBUS_DTACK_N = 	DMA_ROM_SEL ? DMA_ROM_DTACK_N :
							DMA_RAM_SEL ? DMA_RAM_DTACK_N :
							1'b0;

wire [15:0] VBUS_DATA = DMA_ROM_SEL ? DMA_ROM_D :
								DMA_RAM_SEL ? DMA_RAM_D :
								16'hFFFF;

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
	.q_a(vram_q[7:0])
);

dpram #(15) vram_u
(
	.clock(MCLK),
	.address_a(vram_a),
	.data_a(vram_d[15:8]),
	.wren_a(vram_we_u & (vram_ack ^ vram_req)),
	.q_a(vram_q[15:8])
);

reg vram_ack;
always @(posedge MCLK) vram_ack <= vram_req;

vdp vdp
(
	.rst_n(RESET_N),
	.clk(MCLK),

	.sel(VDP_SEL),
	.a(VDP_A),
	.rnw(VDP_RNW),
	.di(VDP_DI),
	.do(VDP_DO),
	.dtack_n(VDP_DTACK_N),

	.vram_req(vram_req),
	.vram_ack(vram_ack),
	.vram_we_u(vram_we_u),
	.vram_we_l(vram_we_l),
	.vram_a(vram_a),
	.vram_do(vram_d),
	.vram_di(vram_q),

	.tg68_hint(TG68_HINT),
	.tg68_vint(TG68_VINT),
	.tg68_intack(TG68_INTACK),

	.t80_vint(T80_VINT),
	.t80_intack(~T80_M1_N & ~T80_IORQ_N),

	.vbus_addr(VBUS_ADDR),
	.vbus_data(VBUS_DATA),
	.vbus_sel(VBUS_SEL),
	.vbus_dtack_n(VBUS_DTACK_N),

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
	.reset(~RESET_N),
	.clk(MCLK),
	.clken(T80_CLKEN),

	.wr_n(VDP_RNW | ~VDP_SEL | ~VDP_A[4] | VDP_A[3]),
	.d_in(VDP_DI[15:8]),
	.snd(PSG_SND)
);

wire TG68_VDP_SEL = (TG68_A[23:21] == 3'b110 && !TG68_A[18:16] && !TG68_A[7:5] && TG68_IO)
                 || (TG68_A[23:16] == 8'hA0 && TG68_A[14:5] == {7'b1111111, 3'b000} && TG68_IO);	// Z80 Address space

wire T80_VDP_SEL  = (T80_A[15:5] == {8'h7F, 3'b000} && T80_IO)
                 || (T80_A[15] && BAR[23:21] == 3'b110 && !BAR[18:16] && !TG68_A[7:5] && T80_IO);	// 68000 Address space

always @(posedge MCLK) begin
	reg [1:0] VDPC;

	localparam 	VDPC_IDLE     = 0,
					VDPC_TG68_ACC = 1,
					VDPC_T80_ACC  = 2,
					VDPC_DESEL    = 3;

	if (~RESET_N) begin
		TG68_VDP_DTACK_N <= 1;
		T80_VDP_DTACK_N  <= 1;
		VDP_SEL <= 0;
		VDP_RNW <= 1;
		VDPC <= VDPC_IDLE;
	end
	else begin
		if (TG68_VDP_SEL == 0) TG68_VDP_DTACK_N <= 1;
		if (T80_VDP_SEL  == 0)  T80_VDP_DTACK_N <= 1;

		case (VDPC)
			VDPC_IDLE:
				if (TG68_VDP_SEL & TG68_VDP_DTACK_N) begin
					VDP_SEL <= 1;
					VDP_A <= TG68_A[4:1];
					VDP_RNW <= TG68_RNW;
					VDP_DI <= TG68_DO;
					VDPC <= VDPC_TG68_ACC;
				end else if (T80_VDP_SEL & T80_VDP_DTACK_N) begin
					VDP_SEL <= 1;
					VDP_A <= T80_A[4:1];
					VDP_RNW <= T80_WR_N;
					VDP_DI <= {T80_DO, T80_DO};
					VDPC <= VDPC_T80_ACC;
				end

			VDPC_TG68_ACC:
				if (~VDP_DTACK_N) begin
					VDP_SEL <= 0;
					TG68_VDP_D <= VDP_DO;
					TG68_VDP_DTACK_N <= 0;
					VDPC <= VDPC_DESEL;
				end

			VDPC_T80_ACC:
				if (~VDP_DTACK_N) begin
					VDP_SEL <= 0;
					T80_VDP_D <= (~T80_A[0]) ? VDP_DO[15:8] : T80_VDP_D <= VDP_DO[7:0];
					T80_VDP_DTACK_N <= 0;
					VDPC <= VDPC_DESEL;
				end

			VDPC_DESEL:
				if (VDP_DTACK_N) begin
					VDP_RNW <= 1;
					VDPC <= VDPC_IDLE;
				end
		endcase
	end
end


//--------------------------------------------------------------
// I/O
//--------------------------------------------------------------
reg        IO_SEL;
reg  [4:1] IO_A;
reg        IO_RNW;
reg  [7:0] IO_DI;
wire [7:0] IO_DO;
wire       IO_DTACK_N;

reg [15:0] TG68_IO_D;
reg        TG68_IO_DTACK_N;

reg  [7:0] T80_IO_D;
reg        T80_IO_DTACK_N;

gen_io io
(
	.rst_n(RESET_N),
	.clk(MCLK & TG68_CLKEN),

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
	.a(IO_A),
	.rnw(IO_RNW),
	.di(IO_DI),
	.do(IO_DO),
	.dtack_n(IO_DTACK_N),

	.pal(PAL),
	.export(EXPORT)
);

wire TG68_IO_SEL = TG68_A[23:5] == {16'hA100, 3'b000} && TG68_IO;
wire T80_IO_SEL  = T80_A[15] && {BAR, T80_A[14:5]} == {16'hA100, 3'b000} && T80_IO;

always @(posedge MCLK) begin
	reg [1:0] IOC;

	localparam 	IOC_IDLE     = 0,
					IOC_TG68_ACC = 1,
					IOC_T80_ACC  = 2,
					IOC_DESEL    = 3;

	if (~RESET_N) begin
		TG68_IO_DTACK_N <= 1;
		T80_IO_DTACK_N  <= 1;
		IOC <= IOC_IDLE;
	end
	else begin
		if (~TG68_IO_SEL) TG68_IO_DTACK_N <= 1;
		if (~T80_IO_SEL)  T80_IO_DTACK_N  <= 1;

		case (IOC)
		IOC_IDLE:
			if (TG68_IO_SEL & TG68_IO_DTACK_N) begin
				IO_SEL <= 1;
				IO_A <= TG68_A[4:1];
				IO_RNW <= TG68_RNW;
				IO_DI <= TG68_DO[7:0];
				IOC <= IOC_TG68_ACC;
			end
			else if (T80_IO_SEL & T80_IO_DTACK_N) begin
				IO_SEL <= 1;
				IO_A <= T80_A[4:1];
				IO_RNW <= T80_WR_N;
				IO_DI <= T80_DO;
				IOC <= IOC_T80_ACC;
			end

		IOC_TG68_ACC:
			if (~IO_DTACK_N) begin
				IO_SEL <= 0;
				TG68_IO_D <= {IO_DO, IO_DO};
				TG68_IO_DTACK_N <= 0;
				IOC <= IOC_DESEL;
			end

		IOC_T80_ACC:
			if (~IO_DTACK_N) begin
				IO_SEL <= 0;
				T80_IO_D <= IO_DO;
				T80_IO_DTACK_N <= 0;
				IOC <= IOC_DESEL;
			end

		IOC_DESEL:
			if (IO_DTACK_N) begin
				IO_RNW <= 1;
				IOC <= IOC_IDLE;
			end
		endcase
	end
end


//-----------------------------------------------------------------------
// ROM Handling
//-----------------------------------------------------------------------
reg [15:0] TG68_ROM_D;
reg        TG68_ROM_DTACK_N;
reg  [7:0] T80_ROM_D;
reg        T80_ROM_DTACK_N;
reg [15:0] DMA_ROM_D;
reg        DMA_ROM_DTACK_N;

assign MAPPER_A  = TG68_A[3:1];
assign MAPPER_WE = TG68_IO && ~TG68_RNW && TG68_A[23:4] == 20'hA130F;
assign MAPPER_D  = TG68_DO[7:0];

wire TG68_ROM_SEL = ~TG68_A[23] & TG68_IO & TG68_RNW;
wire T80_ROM_SEL  = ~BAR[23] & T80_A[15] & T80_IO & ~T80_RD_N;
wire DMA_ROM_SEL  = ~VBUS_ADDR[23] & VBUS_SEL;

always @(posedge MCLK) begin
	reg [1:0] ROMC;

	localparam	ROMC_IDLE    = 0,
					ROMC_TG68_RD = 1,
					ROMC_DMA_RD  = 2,
					ROMC_T80_RD  = 3;

	if (~RESET_N) begin
		ROMC <= ROMC_IDLE;
		TG68_ROM_DTACK_N <= 1;
		T80_ROM_DTACK_N  <= 1;
		DMA_ROM_DTACK_N  <= 1;
	end
	else begin
		if (~TG68_ROM_SEL) TG68_ROM_DTACK_N <= 1;
		if (~T80_ROM_SEL)  T80_ROM_DTACK_N  <= 1;
		if (~DMA_ROM_SEL)  DMA_ROM_DTACK_N  <= 1;

		case (ROMC)
		ROMC_IDLE:
			if (TG68_ROM_SEL & TG68_ROM_DTACK_N) begin
				ROM_REQ <= ~ROM_ACK;
				ROM_ADDR <= TG68_A[22:1];
				ROMC <= ROMC_TG68_RD;
			end
			else if (T80_ROM_SEL & T80_ROM_DTACK_N) begin
				ROM_REQ <= ~ROM_ACK;
				ROM_ADDR <= {BAR[22:15], T80_A[14:1]};
				ROMC <= ROMC_T80_RD;
			end
			else if (DMA_ROM_SEL & DMA_ROM_DTACK_N) begin
				ROM_REQ <= ~ROM_ACK;
				ROM_ADDR <= VBUS_ADDR[22:1];
				ROMC <= ROMC_DMA_RD;
			end

		ROMC_TG68_RD:
			if (ROM_REQ == ROM_ACK) begin
				TG68_ROM_D <= ROM_DATA;
				TG68_ROM_DTACK_N <= 0;
				ROMC <= ROMC_IDLE;
			end

		ROMC_T80_RD:
			if (ROM_REQ == ROM_ACK) begin
				T80_ROM_D <= (T80_A[0]) ? ROM_DATA[7:0] : ROM_DATA[15:8];
				T80_ROM_DTACK_N <= 0;
				ROMC <= ROMC_IDLE;
			end

		ROMC_DMA_RD:
			if (ROM_REQ == ROM_ACK) begin
				DMA_ROM_D <= ROM_DATA;
				DMA_ROM_DTACK_N <= 0;
				ROMC <= ROMC_IDLE;
			end
		endcase
	end
end


//-----------------------------------------------------------------------
// 68K RAM Handling
//-----------------------------------------------------------------------
reg [15:0] TG68_RAM_D;
reg        TG68_RAM_DTACK_N;
reg  [7:0] T80_RAM_D;
reg        T80_RAM_DTACK_N;
reg [15:0] DMA_RAM_D;
reg        DMA_RAM_DTACK_N;

reg         ram68k_req;
reg         ram68k_ack;
reg         ram68k_we;
reg  [15:1] ram68k_a;
reg  [15:0] ram68k_d;
wire [15:0] ram68k_q;
reg         ram68k_l_n;
reg         ram68k_u_n;

dpram #(15) ram68k_l
(
	.clock(MCLK),
	.address_a(ram68k_a[15:1]),
	.data_a(ram68k_d[7:0]),
	.wren_a((~ram68k_l_n) & ram68k_we & (ram68k_ack ^ ram68k_req)),
	.q_a(ram68k_q[7:0])
);

dpram #(15) ram68k_u
(
	.clock(MCLK),
	.address_a(ram68k_a[15:1]),
	.data_a(ram68k_d[15:8]),
	.wren_a((~ram68k_u_n) & ram68k_we & (ram68k_ack ^ ram68k_req)),
	.q_a(ram68k_q[15:8])
);

always @(posedge MCLK) ram68k_ack <= ram68k_req;

wire TG68_RAM_SEL = &TG68_A[23:21] & TG68_IO;
wire T80_RAM_SEL  = &BAR[23:21] & T80_A[15] && T80_IO;
wire DMA_RAM_SEL  = &VBUS_ADDR[23:21] & VBUS_SEL;

always @(posedge MCLK) begin
	reg [1:0] RAMC;

	localparam 	RAMC_IDLE = 0,
					RAMC_TG68 = 1,
					RAMC_DMA  = 2,
					RAMC_T80  = 3;

	if (~RESET_N) begin
		TG68_RAM_DTACK_N <= 1;
		T80_RAM_DTACK_N  <= 1;
		DMA_RAM_DTACK_N  <= 1;
		ram68k_req <= 0;
		RAMC <= RAMC_IDLE;
	end
	else begin
		if (~TG68_RAM_SEL) TG68_RAM_DTACK_N <= 1;
		if (~T80_RAM_SEL)  T80_RAM_DTACK_N  <= 1;
		if (~DMA_RAM_SEL)  DMA_RAM_DTACK_N  <= 1;

		case (RAMC)
		RAMC_IDLE:
			if (TG68_RAM_SEL & TG68_RAM_DTACK_N) begin
				ram68k_req <= ~ram68k_req;
				ram68k_a <= TG68_A[15:1];
				ram68k_d <= TG68_DO;
				ram68k_we <= ~TG68_RNW;
				ram68k_u_n <= TG68_UDS_N;
				ram68k_l_n <= TG68_LDS_N;
				RAMC <= RAMC_TG68;
			end
			else if (T80_RAM_SEL & T80_RAM_DTACK_N) begin
				ram68k_req <= ~ram68k_req;
				ram68k_a <= {BAR[15], T80_A[14:1]};
				ram68k_d <= {T80_DO, T80_DO};
				ram68k_we <= ~T80_WR_N;
				ram68k_u_n <= T80_A[0];
				ram68k_l_n <= ~T80_A[0];
				RAMC <= RAMC_T80;
			end
			else if (DMA_RAM_SEL & DMA_RAM_DTACK_N) begin
				ram68k_req <= ~ram68k_req;
				ram68k_a <= VBUS_ADDR[15:1];
				ram68k_we <= 0;
				ram68k_u_n <= 0;
				ram68k_l_n <= 0;
				RAMC <= RAMC_DMA;
			end

		RAMC_TG68:
			if (ram68k_req == ram68k_ack) begin
				TG68_RAM_D <= ram68k_q;
				TG68_RAM_DTACK_N <= 0;
				RAMC <= RAMC_IDLE;
			end

		RAMC_T80:
			if (ram68k_req == ram68k_ack) begin
				T80_RAM_D <= (T80_A[0]) ? ram68k_q[7:0] : ram68k_q[15:8];
				T80_RAM_DTACK_N <= 0;
				RAMC <= RAMC_IDLE;
			end

		RAMC_DMA:
			if (ram68k_req == ram68k_ack) begin
				DMA_RAM_D <= ram68k_q;
				DMA_RAM_DTACK_N <= 0;
				RAMC <= RAMC_IDLE;
			end
		endcase
	end
end


//-----------------------------------------------------------------------
// ZBUS Handling
//-----------------------------------------------------------------------
// 68000: A00000-A0FFFF

reg [15:0] ZBUS_A;
reg        ZBUS_WE;
reg  [7:0] ZBUS_D;
wire [7:0] ZBUS_Q = ZRAM_SEL ? ZRAM_Q : FM_SEL ? FM_DO : 8'hFF;

reg [15:0] TG68_ZBUS_D;
reg  [7:0] T80_ZBUS_D;
reg        TG68_ZBUS_DTACK_N;
reg        T80_ZBUS_DTACK_N;
wire       TG68_ZBUS_SEL = TG68_A[23:16] == 8'hA0 && TG68_IO && (~T80_BUSAK_N | ~T80_RESET_N);
wire       T80_ZBUS_SEL  = ~T80_A[15] && T80_IO;

// RAM 0000-1FFF (2000-3FFF)
wire ZRAM_SEL = !ZBUS_A[15:14];

wire  [7:0] ZRAM_Q;
dpram #(13) ramZ80
(
	.clock(MCLK),
	.address_a(ZBUS_A[12:0]),
	.data_a(ZBUS_D),
	.wren_a(ZBUS_WE & ZRAM_SEL),
	.q_a(ZRAM_Q)
);

always @(posedge MCLK) begin
	reg [1:0] state;
	reg       src;
	reg       we;

	localparam	IDLE = 0,
					TEST = 1,
					READ = 2;

	ZBUS_WE <= 0;

	if (~RESET_N) begin
		TG68_ZBUS_DTACK_N <= 1;
		T80_ZBUS_DTACK_N  <= 1;
		state <= IDLE;
	end
	else begin
		if (~TG68_ZBUS_SEL) TG68_ZBUS_DTACK_N <= 1;
		if (~T80_ZBUS_SEL)  T80_ZBUS_DTACK_N  <= 1;

		case (state)
		IDLE:
			if (TG68_ZBUS_SEL & TG68_ZBUS_DTACK_N) begin
				ZBUS_A <= {1'b0, TG68_A[14:1], TG68_UDS_N};
				ZBUS_D <= (~TG68_UDS_N) ? TG68_DO[15:8] : TG68_DO[7:0];
				we <= ~TG68_RNW;
				src <= 0;
				state <= TEST;
			end
			else if (T80_ZBUS_SEL & T80_ZBUS_DTACK_N) begin
				ZBUS_A <= T80_A;
				ZBUS_D <= T80_DO;
				we <= ~T80_WR_N;
				src <= 1;
				state <= TEST;
			end

		TEST:
			if (~(FM_SEL & we & FM_DO[7])) begin
				ZBUS_WE <= we;
				state <= READ;
			end

		READ:
			begin
				if (~src) begin
					TG68_ZBUS_D <= {ZBUS_Q, ZBUS_Q};
					TG68_ZBUS_DTACK_N <= 0;
				end
				else begin
					T80_ZBUS_D <= ZBUS_Q;
					T80_ZBUS_DTACK_N <= 0;
				end
				state <= IDLE;
			end
		endcase
	end
end

//-----------------------------------------------------------------------
// Z80 BANK REGISTER
//-----------------------------------------------------------------------
// 6000-60FF

wire BANK_SEL = ZBUS_A[15:8] == 8'h60;
reg [23:15] BAR;

always @(posedge MCLK) begin
	if (~RESET_N) BAR <= 0;
	else if (BANK_SEL & ZBUS_WE) BAR <= {ZBUS_D[0], BAR[23:16]};
end

//--------------------------------------------------------------
// YM2612
//--------------------------------------------------------------
// 4000-4003 (4000-5FFF)

wire        FM_SEL = ZBUS_A[15:13] == 3'b010;
wire  [7:0] FM_DO;
wire [11:0] FM_right;
wire [11:0] FM_left;

jt12 fm
(
	.rst(~RESET_N), //~T80_RESET_N,
	.clk(MCLK),
	.cen(TG68_CLKEN),

	.limiter_en(1),
	.cs_n(0),
	.addr(ZBUS_A[1:0]),
	.wr_n(~(FM_SEL & ZBUS_WE)),
	.din(ZBUS_D),
	.dout(FM_DO),

	.snd_left(FM_left),
	.snd_right(FM_right)
);

assign DAC_LDATA = ({FM_left[11],  FM_left})  + ({PSG_SND, 3'b000});
assign DAC_RDATA = ({FM_right[11], FM_right}) + ({PSG_SND, 3'b000});


//-----------------------------------------------------------------------
// BUS NOISE GENERATOR
//-----------------------------------------------------------------------
reg [15:0] NO_DATA;
always @(posedge MCLK) begin
	reg [16:0] lfsr;

	if (TG68_CLKEN) begin
		lfsr = {(lfsr[0] ^ lfsr[2] ^ !lfsr), lfsr[16:1]};
		NO_DATA <= {NO_DATA[14:0], lfsr[0]};
	end
end

endmodule
