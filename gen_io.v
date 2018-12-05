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

	input     [24:0] MOUSE,
	input      [1:0] MOUSE_PORT,

   input            SEL,
   input      [4:1] A,
   input            RNW,
   input      [7:0] DI,
   output reg [7:0] DO,
   output reg       DTACK_N,

   input            PAL,
   input            EXPORT
);

reg [7:0]  DATA;
reg [7:0]  DATB;
reg [7:0]  DATC;
reg [7:0]  CTLA;
reg [7:0]  CTLB;
reg [7:0]  CTLC;
reg [7:0]  TXDA;
reg [7:0]  TXDB;
reg [7:0]  TXDC;
reg [7:0]  RXDA;
reg [7:0]  RXDB;
reg [7:0]  RXDC;
reg [7:0]  SCTA;
reg [7:0]  SCTB;
reg [7:0]  SCTC;

reg [1:0]  JCNT1;
reg [1:0]  JCNT2;

reg [16:0] JTMR1;
reg [16:0] JTMR2;

wire [7:0] TDATA = {DATA[7] | ~CTLA[7], DATA[6], DATA[5:0] & CTLA[5:0]};
wire [7:0] TDATB = {DATB[7] | ~CTLB[7], DATB[6], DATB[5:0] & CTLB[5:0]};

reg  THAd, TRAd;
reg  THBd, TRBd;
wire THA = DATA[6] | ~CTLA[6];
wire TRA = DATA[5] | ~CTLA[5];
wire THB = DATB[6] | ~CTLB[6];
wire TRB = DATB[5] | ~CTLB[5];
   
always @(posedge RESET or posedge CLK) begin
	if(RESET) begin
		DTACK_N <= 1;
		DO   <= 8'hFF;

		DATA <= 8'h7F;
		DATB <= 8'h7F;
		DATC <= 8'h7F;

		CTLA <= 8'h00;
		CTLB <= 8'h00;
		CTLC <= 8'h00;

		TXDA <= 8'hFF;
		RXDA <= 8'h00;
		SCTA <= 8'h00;

		TXDB <= 8'hFF;
		RXDB <= 8'h00;
		SCTB <= 8'h00;

		TXDC <= 8'hFF;
		RXDC <= 8'h00;
		SCTC <= 8'h00;

		JCNT1 <= 0;
		JCNT2 <= 0;
	end
	else if(CE) begin
		if(JTMR1 > 123000) JCNT1 <= 0;
		else if(DATA[6]) JTMR1 <= JTMR1 + 1'd1;

		if(JTMR2 > 123000) JCNT2 <= 0;
		else if(DATB[6]) JTMR2 <= JTMR2 + 1'd1;

		{THAd,TRAd} <= {THA,TRA};
		if(~THAd & THA) begin
			JTMR1 <= 0;
			JCNT1 <= JCNT1 + 1'd1;
		end

		{THBd,TRBd} <= {THB,TRB};
		if(~THB & THB) begin
			JTMR2 <= 0;
			JCNT2 <= JCNT2 + 1'd1;
		end

		if(~SEL) DTACK_N <= 1;
		else if(SEL & DTACK_N) begin
			if(~RNW) begin
				// Write
				case(A)
					4'h1: DATA <= DI;
					4'h2: DATB <= DI;
					4'h3: DATC <= DI;
					4'h4: CTLA <= DI;
					4'h5: CTLB <= DI;
					4'h6: CTLC <= DI;
					4'h7: TXDA <= DI;
					4'h8: RXDA <= DI;
					4'h9: SCTA <= DI;
					4'hA: TXDB <= DI;
					4'hB: RXDB <= DI;
					4'hC: SCTB <= DI;
					4'hD: TXDC <= DI;
					4'hE: RXDC <= DI;
					4'hF: SCTC <= DI;
				endcase
			end
			else begin
				// Read
				case(A)
					4'h0: DO <= {EXPORT, PAL, 6'b100000};
					4'h1: if(MOUSE_PORT[0])            DO <= {TDATA[7], DATA[6] & CTLA[6], TDATA[5:0]} | (~CTLA[4:0] & mdata);
							else if(DATA[6])
								if (J3BUT || JCNT1 != 3)  DO <= TDATA | (~CTLA[5:0] & {P1_C,P1_B,P1_RIGHT,P1_LEFT,P1_DOWN,P1_UP});
								else                      DO <= TDATA | (~CTLA[5:0] & {P1_C,P1_B,P1_MODE,P1_X,P1_Y,P1_Z});
							else if (J3BUT || JCNT1 < 2) DO <= TDATA | (~CTLA[5:0] & {P1_START,P1_A,2'b00,P1_DOWN,P1_UP});
							else if (JCNT1 == 2)         DO <= TDATA | (~CTLA[5:0] & {P1_START,P1_A,4'b0000});
							else                         DO <= TDATA | (~CTLA[5:0] & {P1_START,P1_A,4'b1111});

					4'h2: if(MOUSE_PORT[1])            DO <= {TDATB[7], DATB[6] & CTLB[6], TDATB[5:0]} | (~CTLB[5:0] & mdata);
							else if(DATB[6])
								if (J3BUT || JCNT2 != 3)  DO <= TDATB | (~CTLB[5:0] & {P2_C,P2_B,P2_RIGHT,P2_LEFT,P2_DOWN,P2_UP});
								else                      DO <= TDATB | (~CTLB[5:0] & {P2_C,P2_B,P2_MODE,P2_X,P2_Y,P2_Z});
							else if (J3BUT || JCNT2 < 2) DO <= TDATB | (~CTLB[5:0] & {P2_START,P2_A,2'b00,P2_DOWN,P2_UP});
							else if (JCNT2 == 2)         DO <= TDATB | (~CTLB[5:0] & {P2_START,P2_A,4'b0000});
							else                         DO <= TDATB | (~CTLB[5:0] & {P2_START,P2_A,4'b1111});
					4'h3: DO <= DATC | ~CTLC; // Unconnected port
					4'h4: DO <= CTLA;
					4'h5: DO <= CTLB;
					4'h6: DO <= CTLC;
					4'h7: DO <= TXDA;
					4'h8: DO <= RXDA;
					4'h9: DO <= SCTA;
					4'hA: DO <= TXDB;
					4'hB: DO <= RXDB;
					4'hC: DO <= SCTB;
					4'hD: DO <= TXDC;
					4'hE: DO <= RXDC;
					4'hF: DO <= SCTC;
				endcase
			end
			DTACK_N <= 0;
		end 
	end
end

reg   [8:0] dx,dy;
reg   [4:0] mdata;
reg  [10:0] curdx,curdy;
wire [10:0] newdx = curdx + {{3{MOUSE[4]}},MOUSE[15:8]};
wire [10:0] newdy = curdy - {{3{MOUSE[5]}},MOUSE[23:16]};

wire [1:0] MT  = {{MOUSE_PORT[0] & THA}  | {MOUSE_PORT[1] & THB},  {MOUSE_PORT[0] & TRA}  | {MOUSE_PORT[1] & TRB}};
wire [1:0] MTd = {{MOUSE_PORT[0] & THAd} | {MOUSE_PORT[1] & THBd}, {MOUSE_PORT[0] & TRAd} | {MOUSE_PORT[1] & TRBd}};
wire       MST = (MOUSE_PORT[0] & ~P1_START) | (MOUSE_PORT[1] & ~P2_START);

always @(posedge CLK) begin
	reg old_stb;
	reg sdx,sdy;
	reg [3:0] cnt;

	if(CE) begin
		if(MT != MTd) begin
			if(~&cnt) cnt <= cnt + 1'd1;

			if(!cnt) begin
				dx <= curdx[8:0];
				dy <= curdy[8:0];
				curdx <= 0;
				curdy <= 0;
			end

			case(cnt)
					0: mdata <= 4'b1011;
					1: mdata <= 4'b1111;
					2: mdata <= 4'b1111;
					3: mdata <= {2'b00,dy[8],dx[8]};
					4: mdata <= {MST,MOUSE[2:0]};
					5: mdata <= dx[7:4];
					6: mdata <= dx[3:0];
					7: mdata <= dy[7:4];
			default: mdata <= dy[3:0];
			endcase
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

		if(MT[1]) begin
			mdata <= 0;
			cnt <= 0;
		end

		mdata[4] <= MT[0] | MT[1];
	end
end

endmodule
