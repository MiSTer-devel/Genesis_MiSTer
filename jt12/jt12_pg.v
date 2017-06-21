/*  This file is part of JT12.

	JT12 is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	JT12 is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with JT12.  If not, see <http://www.gnu.org/licenses/>.
	
	Author: Jose Tejada Gomez. Twitter: @topapate
	Version: 1.0
	Date: 14-2-2016
	
	Based on information posted by Nemesis on:
http://gendev.spritesmind.net/forum/viewtopic.php?t=386&postdays=0&postorder=asc&start=167

	Based on jt51_phasegen.v, from JT51	
	
	*/

`timescale 1ns / 1ps

/*

	tab size 4

*/

module jt12_pg(
	input			 	clk,
	input				rst,
	// Channel frequency
	input		[10:0]	fnum_I,
	input		[ 2:0]	block_I,
	// Operator multiplying
	input		[ 3:0]	mul_V,
	// Operator detuning
	input		[ 2:0]	dt1_II, // same as JT51's DT1
	// phase modulation from LFO
	//input		[ 7:0]	pm,
	//input		[ 2:0]	pms,
	// phase operation
	input				pg_rst_III,
	input				zero,
	input				pg_stop,
	
	output  reg [ 4:0]  keycode_III,
	output	reg	[ 9:0]	phase_VIII
);

/*
reg signed [8:0] mod;

always @(*) begin
	case( pms ) // comprobar en silicio
		3'd0: mod <= 9'd0;
		3'd1: mod <= { 7'd0, pm[6:5] };
		3'd2: mod <= { 6'd0, pm[6:4] };
		3'd3: mod <= { 5'd0, pm[6:3] };
		3'd4: mod <= { 4'd0, pm[6:2] };
		3'd5: mod <= { 3'd0, pm[6:1] };
		3'd6: mod <= { 1'd0, pm[6:0], 1'b0 };
		3'd7: mod <= {		 pm[6:0], 2'b0 };
	endcase 	
end

jt12_pm u_pm(
	// Channel frequency
	.kc(kc),
	.kf(kf),
	.add(~pm[7]),
	.mod(mod),
	.kcex(keycode_I)
);
*/

wire pg_rst_VI;

//////////////////////////////////////////////////
// I
reg [4:0] keycode_II;
reg [16:0] phinc_II;

always @(posedge clk) begin : phase_calculation_I
	case ( block_I )
		3'd0: phinc_II <= { 7'd0, fnum_I[10:1] };
		3'd1: phinc_II <= { 6'd0, fnum_I       };
		3'd2: phinc_II <= { 5'd0, fnum_I, 1'd0 };
		3'd3: phinc_II <= { 4'd0, fnum_I, 2'd0 };
		3'd4: phinc_II <= { 3'd0, fnum_I, 3'd0 };
		3'd5: phinc_II <= { 2'd0, fnum_I, 4'd0 };
		3'd6: phinc_II <= { 1'd0, fnum_I, 5'd0 };
		3'd7: phinc_II <= {       fnum_I, 6'd0 };
	endcase
	keycode_II <= { block_I, fnum_I[10], fnum_I[10] ? (|fnum_I[9:7]) : (&fnum_I[9:7])};
end

//////////////////////////////////////////////////
// II
reg [ 5:0] dt1_kf_III;
reg [16:0] phinc_III;
reg [ 2:0] dt1_III;

always @(posedge clk) begin : phase_calculation_II
	case( dt1_II[1:0] )
		2'd1:	dt1_kf_III	<=	{ 1'b0, keycode_II } - 6'd4;
		2'd2:	dt1_kf_III	<=	{ 1'b0, keycode_II } + 6'd4;
		2'd3:	dt1_kf_III	<=	{ 1'b0, keycode_II } + 6'd8;
		default:dt1_kf_III	<=	{ 1'b0, keycode_II };
	endcase
	dt1_III     <= dt1_II;
	phinc_III   <= phinc_II;
	keycode_III <= keycode_II;
end

//////////////////////////////////////////////////
// III		
reg [16:0] phinc_IV;
reg [ 4:0] pow2;
reg [ 2:0] dt1_IV;

always @(*) begin : calcpow2
	case( dt1_kf_III[2:0] )
		3'd0: pow2 <= 5'd16;
		3'd1: pow2 <= 5'd17;
		3'd2: pow2 <= 5'd19;
		3'd3: pow2 <= 5'd20;
		3'd4: pow2 <= 5'd22;
		3'd5: pow2 <= 5'd24;
		3'd6: pow2 <= 5'd26;
		3'd7: pow2 <= 5'd29;
	endcase
end

reg [5:0] dt1_unlimited;
reg [4:0] dt1_limit, dt1_offset_IV;

always @(*) begin : dt1_limit_mux
	case( dt1_III[1:0] )
		default: dt1_limit <= 5'd8;
		2'd1: dt1_limit <= 5'd8;
		2'd2: dt1_limit <= 5'd16;
		2'd3: dt1_limit <= 5'd22;
	endcase
	case( dt1_kf_III[5:3] )
		3'd0:	dt1_unlimited <= { 5'd0, pow2[4]   }; // <2
		3'd1:	dt1_unlimited <= { 4'd0, pow2[4:3] }; // <4
		3'd2:	dt1_unlimited <= { 3'd0, pow2[4:2] }; // <8
		3'd3:	dt1_unlimited <= { 2'd0, pow2[4:1] };
		3'd4:	dt1_unlimited <= { 1'd0, pow2[4:0] };
		3'd5:	dt1_unlimited <= { pow2[4:0], 1'd0 };
		default:dt1_unlimited <= 6'd0;
	endcase
end

always @(posedge clk) begin : phase_calculation_III
	dt1_offset_IV <= dt1_unlimited > dt1_limit ? 
							dt1_limit : dt1_unlimited[4:0];
	dt1_IV   <= dt1_III;	
	phinc_IV <= phinc_III;	
end

//////////////////////////////////////////////////
// IV	
reg [16:0] phinc_V;

always @(posedge clk) begin : phase_calculation_IV
	if( dt1_IV[1:0]==2'd0 )
		phinc_V	<=	phinc_IV;
	else begin
		if( !dt1_IV[2] )
			phinc_V	<=	phinc_IV + dt1_offset_IV;
		else
			phinc_V	<=	phinc_IV - dt1_offset_IV;
	end
end

//////////////////////////////////////////////////
// V APPLY_MUL
reg [16:0] phinc_VI;
always @(posedge clk) begin : phase_calculation_V
	if( mul_V==4'd0 )
		phinc_VI	<= { 1'b0, phinc_V[16:1] };
	else
		phinc_VI	<= phinc_V * mul_V;
end

//////////////////////////////////////////////////
// VI add phinc to the phase
wire		keyon_VI;
wire [19:0]	phase_drop;
reg  [19:0] phase_in;
reg  [ 9:0] phase_VII;

always @(*)
	phase_in <=  pg_rst_VI ? 20'd0 : 
		( pg_stop ? phase_drop : phase_drop + phinc_VI);

always @(posedge clk) begin : phase_calculation_VI
	phase_VII <= phase_in[19:10];
end

//////////////////////////////////////////////////
// VIII padding
 
always @(posedge clk)
	phase_VIII <= phase_VII;

/* VII-XII delay
jt12_sh #( .width(10), .stages(12-7) ) u_padding(
	.clk	( clk		),
	.din	( phase_VII	),
	.drop	( phase_XII	)
);
*/
jt12_sh_rst #( .width(20), .stages(24) ) u_phsh(
	.clk	( clk		),
	.rst	( rst		),
	.din	( phase_in	),
	.drop	( phase_drop)
);

jt12_sh #( .width(1), .stages(3) ) u_rstsh(
	.clk	( clk		),
	.din	( pg_rst_III),
	.drop	( pg_rst_VI	)
);



`ifdef SIMULATION
reg [4:0] sep24_cnt;
wire clk_int = clk;

wire [9:0] pg_ch0s1, pg_ch1s1, pg_ch2s1, pg_ch3s1,
		 pg_ch4s1, pg_ch5s1, pg_ch0s2, pg_ch1s2,
		 pg_ch2s2, pg_ch3s2, pg_ch4s2, pg_ch5s2,
		 pg_ch0s3, pg_ch1s3, pg_ch2s3, pg_ch3s3,
		 pg_ch4s3, pg_ch5s3, pg_ch0s4, pg_ch1s4,
		 pg_ch2s4, pg_ch3s4, pg_ch4s4, pg_ch5s4;

always @(posedge clk_int)
	sep24_cnt <= !zero ? sep24_cnt+1'b1 : 5'd0;

sep24 #( .width(10), .pos0(18)) stsep
(
	.clk	( clk_int	),
	.mixed	( phase_VIII),
	.mask	( 0			),
	.cnt	( sep24_cnt	),	
	
	.ch0s1 (pg_ch0s1), 
	.ch1s1 (pg_ch1s1), 
	.ch2s1 (pg_ch2s1), 
	.ch3s1 (pg_ch3s1), 
	.ch4s1 (pg_ch4s1), 
	.ch5s1 (pg_ch5s1), 

	.ch0s2 (pg_ch0s2), 
	.ch1s2 (pg_ch1s2), 
	.ch2s2 (pg_ch2s2), 
	.ch3s2 (pg_ch3s2), 
	.ch4s2 (pg_ch4s2), 
	.ch5s2 (pg_ch5s2), 

	.ch0s3 (pg_ch0s3), 
	.ch1s3 (pg_ch1s3), 
	.ch2s3 (pg_ch2s3), 
	.ch3s3 (pg_ch3s3), 
	.ch4s3 (pg_ch4s3), 
	.ch5s3 (pg_ch5s3), 

	.ch0s4 (pg_ch0s4), 
	.ch1s4 (pg_ch1s4), 
	.ch2s4 (pg_ch2s4), 
	.ch3s4 (pg_ch3s4), 
	.ch4s4 (pg_ch4s4), 
	.ch5s4 (pg_ch5s4)
);

wire [16:0] phinc_ch0s1, phinc_ch1s1, phinc_ch2s1, phinc_ch3s1,
		 phinc_ch4s1, phinc_ch5s1, phinc_ch0s2, phinc_ch1s2,
		 phinc_ch2s2, phinc_ch3s2, phinc_ch4s2, phinc_ch5s2,
		 phinc_ch0s3, phinc_ch1s3, phinc_ch2s3, phinc_ch3s3,
		 phinc_ch4s3, phinc_ch5s3, phinc_ch0s4, phinc_ch1s4,
		 phinc_ch2s4, phinc_ch3s4, phinc_ch4s4, phinc_ch5s4;

sep24 #( .width(17), .pos0(3+6)) pisep
(
	.clk	( clk_int	),
	.mixed	( phinc_VI),
	.mask	( 0			),
	.cnt	( sep24_cnt	),	
	
	.ch0s1 (phinc_ch0s1), 
	.ch1s1 (phinc_ch1s1), 
	.ch2s1 (phinc_ch2s1), 
	.ch3s1 (phinc_ch3s1), 
	.ch4s1 (phinc_ch4s1), 
	.ch5s1 (phinc_ch5s1), 

	.ch0s2 (phinc_ch0s2), 
	.ch1s2 (phinc_ch1s2), 
	.ch2s2 (phinc_ch2s2), 
	.ch3s2 (phinc_ch3s2), 
	.ch4s2 (phinc_ch4s2), 
	.ch5s2 (phinc_ch5s2), 

	.ch0s3 (phinc_ch0s3), 
	.ch1s3 (phinc_ch1s3), 
	.ch2s3 (phinc_ch2s3), 
	.ch3s3 (phinc_ch3s3), 
	.ch4s3 (phinc_ch4s3), 
	.ch5s3 (phinc_ch5s3), 

	.ch0s4 (phinc_ch0s4), 
	.ch1s4 (phinc_ch1s4), 
	.ch2s4 (phinc_ch2s4), 
	.ch3s4 (phinc_ch3s4), 
	.ch4s4 (phinc_ch4s4), 
	.ch5s4 (phinc_ch5s4)
);

wire [10:0] fnum_ch0s1, fnum_ch1s1, fnum_ch2s1, fnum_ch3s1,
		 fnum_ch4s1, fnum_ch5s1, fnum_ch0s2, fnum_ch1s2,
		 fnum_ch2s2, fnum_ch3s2, fnum_ch4s2, fnum_ch5s2,
		 fnum_ch0s3, fnum_ch1s3, fnum_ch2s3, fnum_ch3s3,
		 fnum_ch4s3, fnum_ch5s3, fnum_ch0s4, fnum_ch1s4,
		 fnum_ch2s4, fnum_ch3s4, fnum_ch4s4, fnum_ch5s4;

sep24 #( .width(11), .pos0(3+1)) fnsep
(
	.clk	( clk_int	),
	.mixed	( fnum_I),
	.mask	( 0			),
	.cnt	( sep24_cnt	),	
	
	.ch0s1 (fnum_ch0s1), 
	.ch1s1 (fnum_ch1s1), 
	.ch2s1 (fnum_ch2s1), 
	.ch3s1 (fnum_ch3s1), 
	.ch4s1 (fnum_ch4s1), 
	.ch5s1 (fnum_ch5s1), 

	.ch0s2 (fnum_ch0s2), 
	.ch1s2 (fnum_ch1s2), 
	.ch2s2 (fnum_ch2s2), 
	.ch3s2 (fnum_ch3s2), 
	.ch4s2 (fnum_ch4s2), 
	.ch5s2 (fnum_ch5s2), 

	.ch0s3 (fnum_ch0s3), 
	.ch1s3 (fnum_ch1s3), 
	.ch2s3 (fnum_ch2s3), 
	.ch3s3 (fnum_ch3s3), 
	.ch4s3 (fnum_ch4s3), 
	.ch5s3 (fnum_ch5s3), 

	.ch0s4 (fnum_ch0s4), 
	.ch1s4 (fnum_ch1s4), 
	.ch2s4 (fnum_ch2s4), 
	.ch3s4 (fnum_ch3s4), 
	.ch4s4 (fnum_ch4s4), 
	.ch5s4 (fnum_ch5s4)
);

wire pgrst_III_ch0s1, pgrst_III_ch1s1, pgrst_III_ch2s1, pgrst_III_ch3s1,
		 pgrst_III_ch4s1, pgrst_III_ch5s1, pgrst_III_ch0s2, pgrst_III_ch1s2,
		 pgrst_III_ch2s2, pgrst_III_ch3s2, pgrst_III_ch4s2, pgrst_III_ch5s2,
		 pgrst_III_ch0s3, pgrst_III_ch1s3, pgrst_III_ch2s3, pgrst_III_ch3s3,
		 pgrst_III_ch4s3, pgrst_III_ch5s3, pgrst_III_ch0s4, pgrst_III_ch1s4,
		 pgrst_III_ch2s4, pgrst_III_ch3s4, pgrst_III_ch4s4, pgrst_III_ch5s4;

sep24 #( .width(1), .pos0(23)) pgrstsep
(
	.clk	( clk_int	),
	.mixed	( pg_rst_III),
	.mask	( 0			),
	.cnt	( sep24_cnt	),	
	
	.ch0s1 (pgrst_III_ch0s1), 
	.ch1s1 (pgrst_III_ch1s1), 
	.ch2s1 (pgrst_III_ch2s1), 
	.ch3s1 (pgrst_III_ch3s1), 
	.ch4s1 (pgrst_III_ch4s1), 
	.ch5s1 (pgrst_III_ch5s1), 

	.ch0s2 (pgrst_III_ch0s2), 
	.ch1s2 (pgrst_III_ch1s2), 
	.ch2s2 (pgrst_III_ch2s2), 
	.ch3s2 (pgrst_III_ch3s2), 
	.ch4s2 (pgrst_III_ch4s2), 
	.ch5s2 (pgrst_III_ch5s2), 

	.ch0s3 (pgrst_III_ch0s3), 
	.ch1s3 (pgrst_III_ch1s3), 
	.ch2s3 (pgrst_III_ch2s3), 
	.ch3s3 (pgrst_III_ch3s3), 
	.ch4s3 (pgrst_III_ch4s3), 
	.ch5s3 (pgrst_III_ch5s3), 

	.ch0s4 (pgrst_III_ch0s4), 
	.ch1s4 (pgrst_III_ch1s4), 
	.ch2s4 (pgrst_III_ch2s4), 
	.ch3s4 (pgrst_III_ch3s4), 
	.ch4s4 (pgrst_III_ch4s4), 
	.ch5s4 (pgrst_III_ch5s4)
);


`endif

endmodule

