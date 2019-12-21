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

// gen-hw.txt from line 416
module gen_io
(
	input            RESET,
	input            CLK,
	input            CE,

	input            J3BUT,

	input            P1_UP,
	input            P1_DOWN,
	input            P1_LEFT,
	input            P1_RIGHT,
	input            P1_A,
	input            P1_B,
	input            P1_C,
	input            P1_START,
	input            P1_MODE,
	input            P1_X,
	input            P1_Y,
	input            P1_Z,

	input            P2_UP,
	input            P2_DOWN,
	input            P2_LEFT,
	input            P2_RIGHT,
	input            P2_A,
	input            P2_B,
	input            P2_C,
	input            P2_START,
	input            P2_MODE,
	input            P2_X,
	input            P2_Y,
	input            P2_Z,

	input            DISK,

	input     [24:0] MOUSE,
	input      [2:0] MOUSE_OPT,

	input            SEL,
	input      [4:1] A,
	input            RNW,
	input      [7:0] DI,
	output reg [7:0] DO,
	output reg       DTACK_N,

	input            PAL,
	input            EXPORT
);

reg  [7:0] R[16];
wire [7:0] DATA = R[1];
wire [7:0] DATB = R[2];
wire [7:0] CTLA = R[4];
wire [7:0] CTLB = R[5];

always @(posedge RESET or posedge CLK) begin
	if(RESET) begin
		DTACK_N <= 1;
		DO <= 'hFF;
		R  <= '{0, 'h7F,'h7F,'h7F, 0,0,0, 'hFF,0,0, 'hFF,0,0, 'hFF,0,0};
	end
	else if(CE) begin
		if(~SEL) DTACK_N <= 1;
		else if(SEL & DTACK_N) begin
			if(~RNW) R[A] <= DI;
			else begin
				// Read
				case(A)
						0: DO <= {EXPORT, PAL, ~DISK, 5'd0};
						1: DO <= (CTLA & DATA) | (~CTLA & (MOUSE_OPT[0] ? mdata : PAD1_DO));
						2: DO <= (CTLB & DATB) | (~CTLB & (MOUSE_OPT[1] ? mdata : PAD2_DO));
						3: DO <= R[3] & R[6]; // Unconnected port
				default: DO <= R[A];
				endcase
			end
			DTACK_N <= 0;
		end
	end
end

wire [7:0] PAD1_DO;
pad_io pad1
(
	.RESET(RESET),
	.CLK(CLK),
	.CE(CE),

	.J3BUT(J3BUT),

	.P_UP(P1_UP),
	.P_DOWN(P1_DOWN),
	.P_LEFT(P1_LEFT),
	.P_RIGHT(P1_RIGHT),
	.P_A(P1_A),
	.P_B(P1_B),
	.P_C(P1_C),
	.P_START(P1_START),
	.P_MODE(P1_MODE),
	.P_X(P1_X),
	.P_Y(P1_Y),
	.P_Z(P1_Z),

	.SEL(SEL && A == 1),
	.RNW(RNW),
	.DIR(~CTLA[6]),
	.DI(DI[6]),
	.DO(PAD1_DO)
);

wire [7:0] PAD2_DO;
pad_io pad2
(
	.RESET(RESET),
	.CLK(CLK),
	.CE(CE),

	.J3BUT(J3BUT),

	.P_UP(P2_UP),
	.P_DOWN(P2_DOWN),
	.P_LEFT(P2_LEFT),
	.P_RIGHT(P2_RIGHT),
	.P_A(P2_A),
	.P_B(P2_B),
	.P_C(P2_C),
	.P_START(P2_START),
	.P_MODE(P2_MODE),
	.P_X(P2_X),
	.P_Y(P2_Y),
	.P_Z(P2_Z),

	.SEL(SEL && A == 2),
	.RNW(RNW),
	.DIR(~CTLB[6]),
	.DI(DI[6]),
	.DO(PAD2_DO)
);


reg   [8:0] dx,dy;
reg   [4:0] mdata;
reg  [10:0] curdx,curdy;
wire [10:0] newdx = curdx + {{3{MOUSE[4]}},MOUSE[15:8]};
wire [10:0] newdy = MOUSE_OPT[2] ? (curdy - {{3{MOUSE[5]}},MOUSE[23:16]}) : (curdy + {{3{MOUSE[5]}},MOUSE[23:16]});

wire TRA = DATA[5] & CTLA[5];
wire TRB = DATB[5] & CTLB[5];

wire MTH = (MOUSE_OPT[0] & PAD1_DO[6]) | (MOUSE_OPT[1] & PAD2_DO[6]);
wire MTR = (MOUSE_OPT[0] & TRA) | (MOUSE_OPT[1] & TRB);
wire [3:0] BTN = MOUSE_OPT[0] ? ~{P1_START,P1_C,P1_B,P1_A} : ~{P2_START,P2_C,P2_B,P2_A};

always @(posedge CLK) begin
	reg old_stb;
	reg mtrd,mtrd2;
	reg [3:0] cnt;
	reg [5:0] delay;
	
	if(!delay) begin
		if(mtrd ^ MTR) delay <= 1;
	end
	else if(CE) begin
		if(&delay) mtrd <= MTR;
		delay <= delay + 1'd1;
	end

	mtrd2 <= mtrd;
	if(mtrd2 ^ mtrd) begin
		if(~&cnt) cnt <= cnt + 1'd1;
		if(!cnt) begin
			dx <= curdx[8:0];
			dy <= curdy[8:0];
			curdx <= 0;
			curdy <= 0;
		end
	end
	else begin
		old_stb <= MOUSE[24];
		if(old_stb != MOUSE[24]) begin
			if($signed(newdx) > $signed(10'd255)) curdx <= 10'd255;
			else if($signed(newdx) < $signed(-10'd255)) curdx <= -10'd255;
			else curdx <= newdx;

			if($signed(newdy) > $signed(10'd255)) curdy <= 10'd255;
			else if($signed(newdy) < $signed(-10'd255)) curdy <= -10'd255;
			else curdy <= newdy;
		end;
	end
	
	case(cnt)
			0: mdata <= 4'b1011;
			1: mdata <= 4'b1111;
			2: mdata <= 4'b1111;
			3: mdata <= {dy[8],dx[8]};
			4: mdata <= MOUSE[2:0] | BTN;
			5: mdata <= dx[7:4];
			6: mdata <= dx[3:0];
			7: mdata <= dy[7:4];
	default: mdata <= dy[3:0];
	endcase

	if(MTH) begin
		mdata <= 0;
		cnt <= 0;
	end

	mdata[4] <= mtrd2;
end

endmodule


module pad_io
(
   input RESET,
   input CLK,
   input CE,
   
   input J3BUT,
   
   input P_UP,
   input P_DOWN,
   input P_LEFT,
   input P_RIGHT,
   input P_A,
   input P_B,
   input P_C,
   input P_START,
   input P_MODE,
   input P_X,
   input P_Y,
   input P_Z,

   input SEL,
   input RNW,

   input DIR,
   input DI,

   output reg [7:0] DO,
   output reg       DTACK_N
);

reg TH;
reg [1:0] JCNT;

always @(*) begin
	DO[7:6] = {1'b0,TH};
	if(TH)
		if (JCNT != 3)   DO[5:0] = {P_C,P_B,P_RIGHT,P_LEFT,P_DOWN,P_UP};
		else             DO[5:0] = {P_C,P_B,P_MODE,P_X,P_Y,P_Z};
	else if (JCNT < 2)  DO[5:0] = {P_START,P_A,2'b00,P_DOWN,P_UP};
	else if (JCNT == 2) DO[5:0] = {P_START,P_A,4'b0000};
	else                DO[5:0] = {P_START,P_A,4'b1111};
end

always @(posedge RESET or posedge CLK) begin
	reg [16:0] JTMR;
	reg  [7:0] FLTMR;

	reg THd;
	reg di;

	if(RESET) begin
		DTACK_N <= 1;
		TH   <= 0;
		JCNT <= 0;
	end
	else if(CE) begin
	
		if(~&FLTMR) FLTMR <= FLTMR + 1'd1;
		if(~DIR) begin
			TH <= di;
			FLTMR <= 0;
		end
		else if(FLTMR == 210) TH <= 1;
	
		THd <= TH;
		if(JTMR > 11600 || J3BUT) JCNT <= 0;
		if(~THd & TH) JCNT <= JCNT + 1'd1;

		if(~&JTMR) JTMR <= JTMR + 1'd1;
		if(THd & ~TH) JTMR <= 0;

		if(~SEL) DTACK_N <= 1;
		else if(SEL & DTACK_N) begin
			if(~RNW) di <= DI;
			DTACK_N <= 0;
		end 
	end
end

endmodule
