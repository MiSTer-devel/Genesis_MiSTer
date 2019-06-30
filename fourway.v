// Copyright (c) 2019 Sorgelig
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

module fourway
(
   input RESET,
   input CLK,
   input CE,
   
   input J3BUT,
   
   input P1_UP,
   input P1_DOWN,
   input P1_LEFT,
   input P1_RIGHT,
   input P1_A,
   input P1_B,
   input P1_C,
   input P1_START,
   input P1_MODE,
   input P1_X,
   input P1_Y,
   input P1_Z,
   
   input P2_UP,
   input P2_DOWN,
   input P2_LEFT,
   input P2_RIGHT,
   input P2_A,
   input P2_B,
   input P2_C,
   input P2_START,
   input P2_MODE,
   input P2_X,
   input P2_Y,
   input P2_Z,

   input P3_UP,
   input P3_DOWN,
   input P3_LEFT,
   input P3_RIGHT,
   input P3_A,
   input P3_B,
   input P3_C,
   input P3_START,
   input P3_MODE,
   input P3_X,
   input P3_Y,
   input P3_Z,

   input P4_UP,
   input P4_DOWN,
   input P4_LEFT,
   input P4_RIGHT,
   input P4_A,
   input P4_B,
   input P4_C,
   input P4_START,
   input P4_MODE,
   input P4_X,
   input P4_Y,
   input P4_Z,

   input PAL,
   input EXPORT,

   input            SEL,
   input      [4:1] A,
   input            RNW,
   input      [7:0] DI,
   output reg [7:0] DO,
   output reg       DTACK_N
);

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

	.SEL(PAD_SEL && (NUM == 0)),
	.RNW(RNW),
	.DI(DI[6]),
	.DO(PAD1_DO)
);

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

	.SEL(PAD_SEL && (NUM == 1)),
	.RNW(RNW),
	.DI(DI[6]),
	.DO(PAD2_DO)
);

pad_io pad3
(
	.RESET(RESET),
	.CLK(CLK),
	.CE(CE),

	.J3BUT(J3BUT),

	.P_UP(P3_UP),
	.P_DOWN(P3_DOWN),
	.P_LEFT(P3_LEFT),
	.P_RIGHT(P3_RIGHT),
	.P_A(P3_A),
	.P_B(P3_B),
	.P_C(P3_C),
	.P_START(P3_START),
	.P_MODE(P3_MODE),
	.P_X(P3_X),
	.P_Y(P3_Y),
	.P_Z(P3_Z),

	.SEL(PAD_SEL && (NUM == 2)),
	.RNW(RNW),
	.DI(DI[6]),
	.DO(PAD3_DO)
);

pad_io pad4
(
	.RESET(RESET),
	.CLK(CLK),
	.CE(CE),

	.J3BUT(J3BUT),

	.P_UP(P4_UP),
	.P_DOWN(P4_DOWN),
	.P_LEFT(P4_LEFT),
	.P_RIGHT(P4_RIGHT),
	.P_A(P4_A),
	.P_B(P4_B),
	.P_C(P4_C),
	.P_START(P4_START),
	.P_MODE(P4_MODE),
	.P_X(P4_X),
	.P_Y(P4_Y),
	.P_Z(P4_Z),

	.SEL(PAD_SEL && (NUM == 3)),
	.RNW(RNW),
	.DI(DI[6]),
	.DO(PAD4_DO)
);

wire PAD_SEL = SEL && (A==1); 

wire [7:0] PAD1_DO,PAD2_DO,PAD3_DO,PAD4_DO;
reg  [2:0] NUM;

always @(*) begin
	if(A==1) begin
		case(NUM)
			0: DO = PAD1_DO;
			1: DO = PAD2_DO;
			2: DO = PAD3_DO;
			3: DO = PAD4_DO;
			default: DO = 8'h70;
		endcase
	end
	else DO = 8'h7F;
end

always @(posedge RESET or posedge CLK) begin
	reg [7:0] CTLB; 

	if(RESET) begin
		DTACK_N <= 1;
		CTLB <= 0;
		NUM <= 0;
	end
	else if(CE) begin
		if(~SEL) DTACK_N <= 1;
		else if(SEL & DTACK_N) begin
			if(~RNW) begin
				case(A)
					2: if(&CTLB[6:4]) NUM <= DI[6:4];
					5: CTLB <= DI;
				endcase 
			end
			DTACK_N <= 0;
		end
	end
end

endmodule
