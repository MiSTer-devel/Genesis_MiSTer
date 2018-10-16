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
	input			up_block,
	input			up_fnumlo,
	input			up_pms,
	input			up_dt1,
	input			up_tl,
	input			up_ks_ar,
	input			up_amen_d1r,
	input			up_d2r,
		
	input			up_d1l,
	input			up_ssgeg,

	output			busy,
	output	reg		ch6op,	// 1 when the operator belongs to CH6
	
	// CH3 Effect-mode operation
	input			effect,
	input	[10:0]	fnum_ch3op2,
	input	[10:0]	fnum_ch3op3, 
	input	[10:0]	fnum_ch3op1,
	input	[ 2:0]	block_ch3op2,
	input	[ 2:0]	block_ch3op3,
	input	[ 2:0]	block_ch3op1,
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
	output		[ 3:0]	mul_V,
	// Operator detuning
	output		[ 2:0]	dt1_II,
	
	// EG
	output		[4:0]	ar_II,	// attack  rate
	output		[4:0]	d1r_II, // decay   rate
	output		[4:0]	d2r_II, // sustain rate
	output		[3:0]	rr_II,	// release rate
	output		[3:0]	d1l,   // sustain level
	output		[1:0]	ks_III,	   // key scale
	output				ssg_en_II,
	output		[2:0]	ssg_eg_II,
	output		[6:0]	tl_VII,
	output		[2:0]	pms_I,
	output		[1:0]	ams_VII,
	output				amsen_VII,

	// envelope operation
	output			keyon_II
);


reg	 [4:0] cnt;
reg  [1:0] next_op, cur_op;
reg  [2:0] next_ch, cur_ch;
reg busy_op; 
reg up_keyon_long;

`ifdef SIMULATION
// These signals need to operate during rst
// initial state is not relevant (or critical) in real life
// but we need a clear value during simulation
initial begin
	cur_op = 2'd0;
	cur_ch = 3'd0;
	cnt		= 5'h0;
	last	= 1'b0;
	zero	= 1'b1;
	busy_op	= 1'b0;
	up_keyon_long = 1'b0;
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
wire update_op_III= cur == req_opch_III;
// wire update_op_IV = cur == opch_IV;
wire update_op_V  = cur == req_opch_V;
// wire update_op_VI = cur == opch_VI;
wire [2:0] op_plus1 = op+2'd1;
wire update_op_VII= cur == { op_plus1[1:0], ch };

// key on/off
wire	[3:0]	keyon_op = din[7:4];
wire	[2:0]	keyon_ch = din[2:0];
// channel data
wire	[1:0]	rl_in	= din[7:6];
wire	[2:0]	fb_in	= din[5:3];
wire	[2:0]	alg_in	= din[2:0];
wire	[2:0]	pms_in	= din[2:0];
wire	[1:0]	ams_in	= din[5:4];
wire	[2:0]	block_in= din[5:3];
wire	[2:0]	fnhi_in	= din[2:0];
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
wire	[3:0]	d1l_in	= din[7:4];
wire	[3:0]	rr_in	= din[3:0];
wire	[3:0]	ssg_in	= din[3:0];

wire	[3:0]	ssg;

reg			last;

wire	update_ch_I  = cur_ch == ch;

wire up_alg_ch	= up_alg	& update_ch_I;
wire up_block_ch= up_block	& update_ch_I;
wire up_fnumlo_ch=up_fnumlo & update_ch_I;
wire up_pms_ch	= up_pms	& update_ch_I;

// DT1 & MUL
wire up_dt1_op	= up_dt1	& update_op_II;
wire up_mul_op	= up_dt1	& update_op_V;
// TL
wire up_tl_op	= up_tl		& update_op_VII;
// KS & AR
wire up_ks_op	= up_ks_ar	& update_op_III;
wire up_ar_op	= up_ks_ar	& update_op_II;
// AM ON, D1R
wire up_amen_op	= up_amen_d1r	& update_op_VII;
wire up_d1r_op	= up_amen_d1r	& update_op_II;
// Sustain Rate (D2R)
wire up_d2r_op	= up_d2r	& update_op_II;
// D1L & RR
wire up_d1l_op	= up_d1l	& update_op_I;
wire up_rr_op	= up_d1l	& update_op_II;
// SSG
//wire up_ssgen_op = up_ssgeg	& update_op_I;
wire up_ssg_op	= up_ssgeg	& update_op_II;

wire up = 	up_alg 	| up_block 	| up_fnumlo | up_pms |
			up_dt1 	| up_tl 	| up_ks_ar	| up_amen_d1r | 
			up_d2r	| up_d1l 	| up_ssgeg  | up_keyon;			

always @(*) begin
	// next = cur==5'd23 ? 5'd0 : cur +1'b1;
	next_op = cur_ch==3'd6 ? cur_op+1'b1 : cur_op;
	next_ch = cur_ch[1:0]==2'b10 ? cur_ch+2'd2 : cur_ch+1'd1;
end

assign	busy = busy_op;

always @(posedge clk) begin : up_counter
	if( clk_en ) begin
		{ cur_op, cur_ch }	<= { next_op, next_ch };
		zero 	<= next == 5'd0;
		last	<= up;
		if( up && !last ) begin
			cnt		<= cur;
			busy_op	<= 1'b1;
			up_keyon_long <= up_keyon;
		end
		else if( cnt == cur ) begin
			busy_op <= 1'b0;
			up_keyon_long <= 1'b0;
		end
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
	.up_keyon	( up_keyon_long	),
	.csm		( csm		),
	// .flag_A		( flag_A	),
	.overflow_A	( overflow_A),
	
	.keyon_II	( keyon_II	)
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
	up_tl_op	? tl_in  : tl_VII, // 7
	up_dt1_op	? dt1_in : dt1_II,	// 3
	up_mul_op	? mul_in : mul_V,	// 4 - 7
	up_ks_op	? ks_in	 : ks_III,	// 2 - 16
	up_ar_op	? ar_in	 : ar_II,	// 5 - 21
	up_amen_op	? amen_in: amsen_VII,// 1 - 22
	up_d1r_op	? d1r_in : d1r_II,	// 5 - 25
	up_d2r_op	? d2r_in : d2r_II,	// 5 - 30
	up_d1l_op	? d1l_in : d1l,		// 4 - 34
	up_rr_op	? rr_in	 : rr_II,	// 4 - 38
	up_ssg_op	? ssg_in[3]   : ssg_en_II,	// 1 - 39
	up_ssg_op	? ssg_in[2:0] : ssg_eg_II	// 3 - 42
};

assign { tl_VII, dt1_II, mul_V, ks_III, 
			ar_II,	amsen_VII, d1r_II, d2r_II, d1l, rr_II,
			ssg_en_II,	ssg_eg_II 				} = regop_out;


wire [2:0] block_latch, fnum_latch;

// memory for CH registers
// Block/fnum data is latched until fnum low byte is written to
// Trying to synthesize this memory as M-9K RAM in Altera devices
// turns out worse in terms of resource utilization. Probably because
// this memory is already very small. It is better to leave it as it is.
parameter regch_width=31;
wire [regch_width-1:0] regch_out;
wire [regch_width-1:0] regch_in = {
	up_block_ch	? { block_in, fnhi_in } : { block_latch, fnum_latch }, // 3+3
	up_fnumlo_ch? { block_latch, fnum_latch, fnlo_in } : { block_I_raw, fnum_I_raw }, // 14
	up_alg_ch	? { fb_in, alg_in } : { fb_I, alg },//3+3
	up_pms_ch	? { ams_in, pms_in } : { ams_VII, pms_I }//2+2+3
}; 

assign { block_latch, fnum_latch, 
			block_I_raw, fnum_I_raw, 
			fb_I, alg, ams_VII, pms_I } = regch_out;

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
