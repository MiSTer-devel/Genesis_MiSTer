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

wire TG68_DTACK_N = (TG68_MBUS_SEL ? TG68_MBUS_DTACK_N :
							TG68_ZBUS_SEL ? TG68_ZBUS_DTACK_N :
							1'b0) | VBUS_BUSY;

wire [15:0] TG68_DI= TG68_MBUS_SEL ? TG68_MBUS_D :
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

wire T80_WAIT_N = T80_MBUS_SEL ? ~T80_MBUS_DTACK_N :
						T80_ZBUS_SEL ? ~T80_ZBUS_DTACK_N :
						1'b1;

wire [7:0] T80_DI =	T80_MBUS_SEL ? T80_MBUS_D :
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
wire TG68_CTRL_SEL = TG68_A[23:12] == 12'hA11;
wire T80_CTRL_SEL  = T80_A[15] && ({BAR[23:15], T80_A[14:12]} == 12'hA11);

wire        CTRL_F  = (MBUS_A[11:8] == 1) ? T80_BUSAK_N : (MBUS_A[11:8] == 2) ? T80_RESET_N : NO_DATA[8];
wire [15:0] CTRL_DO = {NO_DATA[15:9], CTRL_F, NO_DATA[7:0]};
reg         CTRL_WE;
always @(posedge MCLK) begin
	if (~RESET_N) begin
		T80_BUSRQ_N <= 1;
		T80_RESET_N <= 0;
	end
	else if(CTRL_WE) begin
		if (MBUS_A[11:8] == 1) begin
			T80_BUSRQ_N <= ~MBUS_DO[8];
		end
		else if (MBUS_A[11:8] == 2) begin
			T80_RESET_N <= MBUS_DO[8];
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
wire TG68_VDP_SEL = (TG68_A[23:21] == 3'b110 && !TG68_A[18:16] && !TG68_A[7:5])
                 || (TG68_A[23:16] == 8'hA0 && TG68_A[14:5] == {7'b1111111, 3'b000});   // Z80 Address space

wire T80_VDP_SEL  = (T80_A[15:5] == {8'h7F, 3'b000})
                 || (T80_A[15] && BAR[23:21] == 3'b110 && !BAR[18:16] && !TG68_A[7:5]); // 68000 Address space

reg         VDP_SEL;
reg         VDP_RNW;
wire [15:0] VDP_DO;
wire        VDP_DTACK_N;

wire [23:0] VBUS_ADDR;
wire        VBUS_SEL;
wire        VBUS_BUSY;

wire        TG68_HINT;
wire        TG68_VINT;
wire        T80_VINT;

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
	.a(MBUS_A[4:1]),
	.rnw(VDP_RNW),
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

	.tg68_hint(TG68_HINT),
	.tg68_vint(TG68_VINT),
	.tg68_intack(TG68_INTACK),

	.t80_vint(T80_VINT),
	.t80_intack(~T80_M1_N & ~T80_IORQ_N),

	.vbus_addr(VBUS_ADDR),
	.vbus_data(VDP_MBUS_D),
	.vbus_sel(VBUS_SEL),
	.vbus_dtack_n(VDP_MBUS_DTACK_N),
	.vbus_busy(VBUS_BUSY),

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

	.wr_n(VDP_RNW | ~VDP_SEL | ~MBUS_A[4] | MBUS_A[3]),
	.d_in(MBUS_DO[15:8]),
	.snd(PSG_SND)
);


//--------------------------------------------------------------
// I/O
//--------------------------------------------------------------
wire TG68_IO_SEL = TG68_A[23:5] == {16'hA100, 3'b000};
wire T80_IO_SEL  = T80_A[15] && {BAR, T80_A[14:5]} == {16'hA100, 3'b000};

reg        IO_SEL;
reg        IO_RNW;
wire [7:0] IO_DO;
wire       IO_DTACK_N;

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
	.a(MBUS_A[4:1]),
	.rnw(IO_RNW),
	.di(MBUS_DO[7:0]),
	.do(IO_DO),
	.dtack_n(IO_DTACK_N),

	.pal(PAL),
	.export(EXPORT)
);


//-----------------------------------------------------------------------
// ROM
//-----------------------------------------------------------------------
assign MAPPER_A  = TG68_A[3:1];
assign MAPPER_WE = TG68_IO && ~TG68_RNW && TG68_A[23:4] == 20'hA130F;
assign MAPPER_D  = TG68_DO[7:0];

wire TG68_ROM_SEL = ~TG68_A[23] & TG68_RNW;
wire T80_ROM_SEL  = ~BAR[23] & T80_A[15] & ~T80_RD_N;
wire VDP_ROM_SEL  = ~VBUS_ADDR[23];


//-----------------------------------------------------------------------
// 68K RAM
//-----------------------------------------------------------------------
wire TG68_RAM_SEL = &TG68_A[23:21];
wire T80_RAM_SEL  = &BAR[23:21] & T80_A[15];
wire VDP_RAM_SEL  = &VBUS_ADDR[23:21];

reg ram68k_we_u;
dpram #(15) ram68k_u
(
	.clock(MCLK),
	.address_a(MBUS_A[15:1]),
	.data_a(MBUS_DO[15:8]),
	.wren_a(ram68k_we_u),
	.q_a(ram68k_q[15:8])
);

reg ram68k_we_l;
dpram #(15) ram68k_l
(
	.clock(MCLK),
	.address_a(MBUS_A[15:1]),
	.data_a(MBUS_DO[7:0]),
	.wren_a(ram68k_we_l),
	.q_a(ram68k_q[7:0])
);
wire [15:0] ram68k_q;


//-----------------------------------------------------------------------
// MBUS Handling
//-----------------------------------------------------------------------
wire TG68_MBUS_SEL = TG68_IO  & (TG68_RAM_SEL | TG68_ROM_SEL | TG68_IO_SEL | TG68_VDP_SEL | TG68_CTRL_SEL);
wire T80_MBUS_SEL  = T80_IO   & (T80_RAM_SEL  | T80_ROM_SEL  | T80_IO_SEL  | T80_VDP_SEL  | T80_CTRL_SEL);
wire VDP_MBUS_SEL  = VBUS_SEL & (VDP_RAM_SEL  | VDP_ROM_SEL);

reg TG68_MBUS_DTACK_N;
reg T80_MBUS_DTACK_N;
reg VDP_MBUS_DTACK_N;

reg [15:0] TG68_MBUS_D;
reg  [7:0] T80_MBUS_D;
reg [15:0] VDP_MBUS_D;

reg [22:1] MBUS_A;
reg [15:0] MBUS_DO;

always @(posedge MCLK) begin
	reg  [3:0] mstate;
	reg  [1:0] src;
	reg        we;
	reg [15:0] data;
	reg        uds_n;
	reg        lds_n;

	localparam 	SRC_TG68 = 0,
					SRC_T80  = 1,
					SRC_VDP  = 2;

	localparam 	MBUS_IDLE     = 0,
					MBUS_RAM_ACC  = 1,
					MBUS_RAM_READ = 2,
					MBUS_ROM_ACC  = 3,
					MBUS_ROM_READ = 4,
					MBUS_VDP_ACC  = 5,
					MBUS_VDP_READ = 6,
					MBUS_VDP_WAIT = 7,
					MBUS_IO_ACC   = 8,
					MBUS_IO_READ  = 9,
					MBUS_IO_WAIT  = 10,
					MBUS_CTRL_ACC = 11,
					MBUS_FINISH   = 12;

	ram68k_we_u <= 0;
	ram68k_we_l <= 0;
	CTRL_WE <= 0;

	if (~RESET_N) begin
		TG68_MBUS_DTACK_N <= 1;
		T80_MBUS_DTACK_N  <= 1;
		VDP_MBUS_DTACK_N  <= 1;
		VDP_SEL <= 0;
		VDP_RNW <= 1;
		IO_SEL <= 0;
		IO_RNW <= 1;
		mstate <= MBUS_IDLE;
	end
	else begin
		if (~TG68_IO)  TG68_MBUS_DTACK_N <= 1;
		if (~T80_IO)   T80_MBUS_DTACK_N  <= 1;
		if (~VBUS_SEL) VDP_MBUS_DTACK_N  <= 1;
		
		case(mstate)
		MBUS_IDLE:
			if(TG68_MBUS_SEL & TG68_MBUS_DTACK_N & ~VBUS_BUSY) begin
				src <= SRC_TG68;
				MBUS_A <= TG68_A[22:1];
				MBUS_DO <= TG68_DO;
				uds_n <= TG68_UDS_N;
				lds_n <= TG68_LDS_N;
				we <= ~TG68_RNW;
				if(TG68_RAM_SEL)  mstate <= MBUS_RAM_ACC;
				if(TG68_ROM_SEL)  mstate <= MBUS_ROM_ACC;
				if(TG68_VDP_SEL)  mstate <= MBUS_VDP_ACC;
				if(TG68_IO_SEL)   mstate <= MBUS_IO_ACC;
				if(TG68_CTRL_SEL) mstate <= MBUS_CTRL_ACC;
			end
			else if(T80_MBUS_SEL & T80_MBUS_DTACK_N & ~VBUS_BUSY) begin
				src <= SRC_T80;
				MBUS_A <= {BAR[22:15], T80_A[14:1]};
				MBUS_DO <= {T80_DO,T80_DO};
				uds_n <= T80_A[0];
				lds_n <= ~T80_A[0];
				we <= ~T80_WR_N;
				if(T80_RAM_SEL)  mstate <= MBUS_RAM_ACC;
				if(T80_ROM_SEL)  mstate <= MBUS_ROM_ACC;
				if(T80_VDP_SEL)  mstate <= MBUS_VDP_ACC;
				if(T80_IO_SEL)   mstate <= MBUS_IO_ACC;
				if(T80_CTRL_SEL) mstate <= MBUS_CTRL_ACC;
			end
			else if(VDP_MBUS_SEL & VDP_MBUS_DTACK_N) begin
				src <= SRC_VDP;
				MBUS_A <= VBUS_ADDR[22:1];
				MBUS_DO <= 0;
				uds_n <= 0;
				lds_n <= 0;
				we <= 0;
				if(VDP_RAM_SEL) mstate <= MBUS_RAM_ACC;
				if(VDP_ROM_SEL) mstate <= MBUS_ROM_ACC;
			end

		MBUS_RAM_ACC:
			begin
				ram68k_we_u <= we & ~uds_n;
				ram68k_we_l <= we & ~lds_n;
				mstate <= MBUS_RAM_READ;
			end
		
		MBUS_RAM_READ:
			begin
				data <= ram68k_q;
				mstate <= MBUS_FINISH;
			end

		MBUS_ROM_ACC:
			begin
				ROM_REQ <= ~ROM_ACK;
				ROM_ADDR <= MBUS_A;
				mstate <= MBUS_ROM_READ;
			end

		MBUS_ROM_READ:
			if (ROM_REQ == ROM_ACK) begin
				data <= ROM_DATA;
				mstate <= MBUS_FINISH;
			end

		MBUS_VDP_ACC:
			begin
				VDP_SEL <= 1;
				VDP_RNW <= ~we;
				mstate <= MBUS_VDP_READ;
			end

		MBUS_VDP_READ:
			if (~VDP_DTACK_N) begin
				VDP_SEL <= 0;
				data <= VDP_DO;
				mstate <= MBUS_VDP_WAIT;
			end

		MBUS_VDP_WAIT:
			if (VDP_DTACK_N) begin
				VDP_RNW <= 1;
				mstate <= MBUS_FINISH;
			end

		MBUS_IO_ACC:
			begin
				IO_SEL <= 1;
				IO_RNW <= ~we;
				mstate <= MBUS_IO_READ;
			end

		MBUS_IO_READ:
			if(~IO_DTACK_N) begin
				IO_SEL <= 0;
				data <= {IO_DO, IO_DO};
				mstate <= MBUS_IO_WAIT;
			end

		MBUS_IO_WAIT:
			if (IO_DTACK_N) begin
				IO_RNW <= 1;
				mstate <= MBUS_FINISH;
			end

		MBUS_CTRL_ACC:
			begin
				CTRL_WE <= we & ~uds_n;
				data <= CTRL_DO;
				mstate <= MBUS_FINISH;
			end

		MBUS_FINISH:
			begin
				case(src)
				SRC_TG68:
					begin
						TG68_MBUS_D <= data;
						TG68_MBUS_DTACK_N <= 0;
					end

				SRC_T80:
					begin
						T80_MBUS_D <= T80_A[0] ? data[7:0] : data[15:8];
						T80_MBUS_DTACK_N <= 0;
					end

				SRC_VDP:
					begin
						VDP_MBUS_D <= data;
						VDP_MBUS_DTACK_N <= 0;
					end
				endcase;
				mstate <= MBUS_IDLE;
			end
		endcase;
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
	reg [1:0] zstate;
	reg       src;
	reg       we;

	localparam	ZBUS_IDLE = 0,
					ZBUS_TEST = 1,
					ZBUS_READ = 2;

	ZBUS_WE <= 0;

	if (~RESET_N) begin
		TG68_ZBUS_DTACK_N <= 1;
		T80_ZBUS_DTACK_N  <= 1;
		zstate <= ZBUS_IDLE;
	end
	else begin
		if (~TG68_ZBUS_SEL) TG68_ZBUS_DTACK_N <= 1;
		if (~T80_ZBUS_SEL)  T80_ZBUS_DTACK_N  <= 1;

		case (zstate)
		ZBUS_IDLE:
			if (TG68_ZBUS_SEL & TG68_ZBUS_DTACK_N) begin
				ZBUS_A <= {1'b0, TG68_A[14:1], TG68_UDS_N};
				ZBUS_D <= (~TG68_UDS_N) ? TG68_DO[15:8] : TG68_DO[7:0];
				we <= ~TG68_RNW;
				src <= 0;
				zstate <= ZBUS_TEST;
			end
			else if (T80_ZBUS_SEL & T80_ZBUS_DTACK_N) begin
				ZBUS_A <= T80_A;
				ZBUS_D <= T80_DO;
				we <= ~T80_WR_N;
				src <= 1;
				zstate <= ZBUS_TEST;
			end

		ZBUS_TEST:
			if (~(FM_SEL & we & FM_DO[7])) begin
				ZBUS_WE <= we;
				zstate <= ZBUS_READ;
			end

		ZBUS_READ:
			begin
				if (~src) begin
					TG68_ZBUS_D <= {ZBUS_Q, ZBUS_Q};
					TG68_ZBUS_DTACK_N <= 0;
				end
				else begin
					T80_ZBUS_D <= ZBUS_Q;
					T80_ZBUS_DTACK_N <= 0;
				end
				zstate <= ZBUS_IDLE;
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
