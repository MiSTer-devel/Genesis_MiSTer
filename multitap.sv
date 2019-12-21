//
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

module multitap
(
	input        RESET,
	input        CLK,
	input        CE,

	input        J3BUT,

	input        P1_UP, P1_DOWN, P1_LEFT, P1_RIGHT, P1_A, P1_B, P1_C, P1_START, P1_MODE, P1_X, P1_Y, P1_Z,
	input        P2_UP, P2_DOWN, P2_LEFT, P2_RIGHT, P2_A, P2_B, P2_C, P2_START, P2_MODE, P2_X, P2_Y, P2_Z,
	input        P3_UP, P3_DOWN, P3_LEFT, P3_RIGHT, P3_A, P3_B, P3_C, P3_START, P3_MODE, P3_X, P3_Y, P3_Z,
	input        P4_UP, P4_DOWN, P4_LEFT, P4_RIGHT, P4_A, P4_B, P4_C, P4_START, P4_MODE, P4_X, P4_Y, P4_Z,

	input        DISK,

	input        TEAMPLAYER_EN,
	input        FOURWAY_EN,

	input [24:0] MOUSE,
	input  [2:0] MOUSE_OPT,

	input        PAL,
	input        EXPORT,

	input        SEL,
	input  [4:1] A,
	input        RNW,
	input  [7:0] DI,
	output [7:0] DO,
	output       DTACK_N,

	input        JCART_SEL,
	output[15:0] JCART_DO,
	output       JCART_DTACK_N
);

wire [7:0] GEN_DO;
gen_io io
(
	.*,

	.DO(GEN_DO)
);

wire [7:0] FW_DO;
fourway fourway
(
	.*,

	.DO(FW_DO),
	.DTACK_N()
);

wire [7:0] TP_DO;
teamplayer teamplayer
(
	.*,

	.DO(TP_DO),
	.DTACK_N()
);

pad_io jcart_u
(
	.*,

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

	.SEL(JCART_SEL),
	.DIR(0),
	.DI(DI[0]),
	.DO(JCART_DO[15:8]),
	.DTACK_N(JCART_DTACK_N)
);

pad_io jcart_l
(
	.*,

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

	.SEL(JCART_SEL),
	.DIR(0),
	.DI(DI[0]),
	.DO(JCART_DO[7:0]),
	.DTACK_N()
);

wire MT_SEL = (A==1 || A==2);
assign DO = (FOURWAY_EN & MT_SEL) ? FW_DO : (TEAMPLAYER_EN & MT_SEL) ? TP_DO : GEN_DO;

endmodule
