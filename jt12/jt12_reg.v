`timescale 1ns / 1ps


/* This file is part of JT12.

 
	JT12 program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	JT12 program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with JT12.  If not, see <http://www.gnu.org/licenses/>.

	Author: Jose Tejada Gomez. Twitter: @topapate
	Version: 1.0
	Date: 14-2-2017	

*/


module jt12_reg(
	input			rst,
	input			clk,
	input			clk_en,
	input	[7:0]	din,
	
	input	[2:0]	ch,
	input	[1:0]	op,
	
	input			csm,
	input			flag_A,
	input			overflow_A,

	input			up_keyon,	
	input			up_alg,	
	input			up_fnumlo,
	input			up_pms,
	input			up_dt1,
	input			up_tl,
	input			up_ks_ar,
	input			up_amen_dr,
	input			up_sr,
		
	input			up_sl_rr,
	input			up_ssgeg,

	output	reg		ch6op,	// 1 when the operator belongs to CH6
	
	// CH3 Effect-mode operation
	input			effect,
	input	[10:0]	fnum_ch3op2,
	input	[10:0]	fnum_ch3op3, 
	input	[10:0]	fnum_ch3op1,
	input	[ 2:0]	block_ch3op2,
	input	[ 2:0]	block_ch3op3,
	input	[ 2:0]	block_ch3op1,
	input	[ 5:0]	latch_fnum,
	// Pipeline order
	output	reg		zero,
	output 			s1_enters,
	output 			s2_enters,
	output 			s3_enters,
	output 			s4_enters,
	
	// Operator
	output 			use_prevprev1,
	output 			use_internal_x,
	output 			use_internal_y,	
	output 			use_prev2,
	output 			use_prev1,
	
	// PG
	output		[10:0]	fnum_I,
	output		[ 2:0]	block_I,
	// channel configuration
	output		[1:0]	rl,
	output reg	[2:0]	fb_II,
	output		[2:0]	alg,
	// Operator multiplying
	output		[ 3:0]	mul_II,
	// Operator detuning
	output		[ 2:0]	dt1_I,
	
	// EG
	output		[4:0]	ar_I,	// attack  rate
	output		[4:0]	d1r_I, // decay   rate
	output		[4:0]	d2r_I, // sustain rate
	output		[3:0]	rr_I,	// release rate
	output		[3:0]	sl_I,   // sustain level
	output		[1:0]	ks_II,	   // key scale
	output				ssg_en_I,
	output		[2:0]	ssg_eg_I,
	output		[6:0]	tl_IV,
	output		[2:0]	pms_I,
	output		[1:0]	ams_IV,
	output				amsen_IV,

	// envelope operation
	output			keyon_I
);


reg  [1:0] next_op, cur_op;
reg  [2:0] next_ch, cur_ch;
reg	last;

`ifdef SIMULATION
// These signals need to operate during rst
// initial state is not relevant (or critical) in real life
// but we need a clear value during simulation
// This does not work with NCVERILOG
initial begin
	cur_op = 2'd0;
	cur_ch = 3'd0;
	last	= 1'b0;
	zero	= 1'b1;
end
`endif

assign s1_enters = cur_op == 2'b00;
assign s3_enters = cur_op == 2'b01;
assign s2_enters = cur_op == 2'b10;
assign s4_enters = cur_op == 2'b11;

wire [4:0] next = { next_op, next_ch };
wire [4:0] cur  = {  cur_op,  cur_ch };

wire [2:0] fb_I;

always @(posedge clk) if( clk_en ) begin
	fb_II <= fb_I;
	ch6op <= next_ch==3'd6;
end	

// FNUM and BLOCK
wire	[10:0]	fnum_I_raw;
wire	[ 2:0]	block_I_raw;
wire    effect_on = effect && (cur_ch==3'd2);
wire    effect_on_s1 = effect_on && (cur_op == 2'd0 );
wire    effect_on_s3 = effect_on && (cur_op == 2'd1 );
wire    effect_on_s2 = effect_on && (cur_op == 2'd2 );
wire	noeffect	 = ~|{effect_on_s1, effect_on_s3, effect_on_s2};
assign fnum_I = ( {11{effect_on_s1}} & fnum_ch3op1 ) |
				( {11{effect_on_s2}} & fnum_ch3op2 ) |
				( {11{effect_on_s3}} & fnum_ch3op3 ) |
				( {11{noeffect}}	 & fnum_I_raw  );

assign block_I =( {3{effect_on_s1}} & block_ch3op1 ) |
				( {3{effect_on_s2}} & block_ch3op2 ) |
				( {3{effect_on_s3}} & block_ch3op3 ) |
				( {3{noeffect}}	 & block_I_raw  );
				
wire [2:0] ch_II, ch_III, ch_IV, ch_V, ch_VI;

wire [4:0] req_opch_I = { op, ch };
wire [4:0] 	req_opch_II, req_opch_III, 
			req_opch_IV, req_opch_V, req_opch_VI;
				
jt12_sumch u_opch_II ( .chin(req_opch_I  ), .chout(req_opch_II)  );
jt12_sumch u_opch_III( .chin(req_opch_II ), .chout(req_opch_III) );
jt12_sumch u_opch_IV ( .chin(req_opch_III), .chout(req_opch_IV)  );
jt12_sumch u_opch_V  ( .chin(req_opch_IV ), .chout(req_opch_V)   );
// jt12_sumch u_opch_VI ( .chin(req_opch_V  ), .chout(req_opch_VI)  );

wire update_op_I  = cur == req_opch_I;
wire update_op_II = cur == req_opch_II;
//wire update_op_III= cur == req_opch_III;
wire update_op_IV = cur == req_opch_IV;
//wire update_op_V  = cur == req_opch_V;
// wire update_op_VI = cur == opch_VI;
// wire [2:0] op_plus1 = op+2'd1;
// wire update_op_VII= cur == { op_plus1[1:0], ch };

// key on/off
wire	[3:0]	keyon_op = din[7:4];
wire	[2:0]	keyon_ch = din[2:0];
// channel data
wire	[1:0]	rl_in	= din[7:6];
wire	[2:0]	fb_in	= din[5:3];
wire	[2:0]	alg_in	= din[2:0];
wire	[2:0]	pms_in	= din[2:0];
wire	[1:0]	ams_in	= din[5:4];
wire	[7:0]	fnlo_in	= din;
// operator data
wire	[2:0]	dt1_in	= din[6:4];
wire	[3:0]	mul_in	= din[3:0];
wire	[6:0]	tl_in	= din[6:0];
wire	[1:0]	ks_in	= din[7:6];
wire	[4:0]	ar_in	= din[4:0];
wire			amen_in	= din[7];
wire	[4:0]	d1r_in	= din[4:0];
wire	[4:0]	d2r_in	= din[4:0];
wire	[3:0]	sl_in	= din[7:4];
wire	[3:0]	rr_in	= din[3:0];
wire	[3:0]	ssg_in	= din[3:0];

wire	[3:0]	ssg;

wire	update_ch_I  = cur_ch == ch;
wire	update_ch_IV = { ~cur_ch[2], cur_ch[1:0]} == ch;

wire up_alg_ch	= up_alg	& update_ch_I;
wire up_fnumlo_ch=up_fnumlo & update_ch_I;
wire up_pms_ch	= up_pms	& update_ch_I;
wire up_ams_ch	= up_pms	& update_ch_IV;

// DT1 & MUL
wire up_dt1_op	= up_dt1	& update_op_I;
wire up_mul_op	= up_dt1	& update_op_II;
// TL
wire up_tl_op	= up_tl		& update_op_IV;
// KS & AR
wire up_ks_op	= up_ks_ar	& update_op_II;
wire up_ar_op	= up_ks_ar	& update_op_I;
// AM ON, D1R
wire up_amen_op	= up_amen_dr& update_op_IV;
wire up_dr_op	= up_amen_dr& update_op_I;
// Sustain Rate (D2R)
wire up_sr_op	= up_sr	& update_op_I;
// D1L & RR
wire up_sl_op	= up_sl_rr	& update_op_I;
wire up_rr_op	= up_sl_rr	& update_op_I;
// SSG
//wire up_ssgen_op = up_ssgeg	& update_op_I;
wire up_ssg_op	= up_ssgeg	& update_op_I;

always @(*) begin
	// next = cur==5'd23 ? 5'd0 : cur +1'b1;
	next_op = cur_ch==3'd6 ? cur_op+1'b1 : cur_op;
	next_ch = cur_ch[1:0]==2'b10 ? cur_ch+2'd2 : cur_ch+1'd1;
end

always @(posedge clk) begin : up_counter
	if( clk_en ) begin
		{ cur_op, cur_ch }	<= { next_op, next_ch };
		zero 	<= next == 5'd0;
	end
end

jt12_kon u_kon(
	.rst		( rst		),
	.clk		( clk		),
	.clk_en		( clk_en	),
	.keyon_op	( keyon_op	),
	.keyon_ch	( keyon_ch	),
	.cur_op		( cur_op	),
	.cur_ch		( cur_ch	),
	.up_keyon	( up_keyon	),
	.csm		( csm		),
	// .flag_A		( flag_A	),
	.overflow_A	( overflow_A),
	
	.keyon_I	( keyon_I	)
);

jt12_mod u_mod(
	.alg_I		( alg		),
	.s1_enters	( s1_enters ),
	.s3_enters	( s3_enters ),
	.s2_enters	( s2_enters ),
	.s4_enters	( s4_enters ),
	
	.use_prevprev1 ( use_prevprev1  ),
	.use_internal_x( use_internal_x ),
	.use_internal_y( use_internal_y ),	
	.use_prev2	 ( use_prev2	  ),
	.use_prev1	 ( use_prev1	  )
);

// memory for OP registers
parameter regop_width=44;

wire [regop_width-1:0] regop_in, regop_out;


jt12_opram u_opram(
	.clk	( clk 		),
	.clk_en	( clk_en	),
	.wr_addr( cur 		),
	.rd_addr( next 		),
	.data	( rst ? { ~7'd0, 37'd0 } : regop_in ),
	.q		( regop_out )
);

assign regop_in = {
	up_tl_op	? tl_in  : tl_IV, // 7
	up_dt1_op	? dt1_in : dt1_I,	// 3
	up_mul_op	? mul_in : mul_II,	// 4 - 7
	up_ks_op	? ks_in	 : ks_II,	// 2 - 16
	up_ar_op	? ar_in	 : ar_I,	// 5 - 21
	up_amen_op	? amen_in: amsen_IV,// 1 - 22
	up_dr_op	? d1r_in : d1r_I,	// 5 - 25
	up_sr_op	? d2r_in : d2r_I,	// 5 - 30
	up_sl_op	? sl_in  : sl_I,	// 4 - 34
	up_rr_op	? rr_in	 : rr_I,	// 4 - 38
	up_ssg_op	? ssg_in[3]   : ssg_en_I,	// 1 - 39
	up_ssg_op	? ssg_in[2:0] : ssg_eg_I	// 3 - 42
};

assign { tl_IV, dt1_I, mul_II, ks_II, 
			ar_I,	amsen_IV, d1r_I, d2r_I, sl_I, rr_I,
			ssg_en_I,	ssg_eg_I 				} = regop_out;


// memory for CH registers
// Block/fnum data is latched until fnum low byte is written to
// Trying to synthesize this memory as M-9K RAM in Altera devices
// turns out worse in terms of resource utilization. Probably because
// this memory is already very small. It is better to leave it as it is.
parameter regch_width=25;
wire [regch_width-1:0] regch_out;
wire [regch_width-1:0] regch_in = {
	up_fnumlo_ch? { latch_fnum, fnlo_in } : { block_I_raw, fnum_I_raw }, // 14
	up_alg_ch	? { fb_in, alg_in } : { fb_I, alg },//3+3
	up_ams_ch	?            ams_in : ams_IV, //2
	up_pms_ch	?            pms_in : pms_I   //3
}; 

assign { 	block_I_raw, fnum_I_raw, 
			fb_I, alg, ams_IV, pms_I } = regch_out;

jt12_sh_rst #(.width(regch_width),.stages(6)) u_regch(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.rst	( rst		),
	.din	( regch_in	),
	.drop	( regch_out	)
);

// RL is on a different register to 
// have the reset to 1
jt12_sh_rst #(.width(2),.stages(6),.rstval(1'b1)) u_regch_rl(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.rst	( rst		),
	.din	( up_pms_ch	? rl_in :  rl	),
	.drop	( rl	)
);

endmodule
