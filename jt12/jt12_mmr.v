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
	Date: 14-2-2017
	*/

`timescale 1ns / 1ps

module jt12_mmr(
	input		  	rst,
	input		  	clk,		// Phi 1
	input	[7:0]	din,
	input			write,
	input	[1:0]	addr,
	output	reg		busy,
	output			ch6op,
	// Clock speed
	output	reg		set_n6,
	output	reg		set_n3,
	output	reg		set_n2,
	// LFO
	output	reg	[2:0]	lfo_freq,
	output	reg		 	lfo_en,
	// Timers
	output	reg	[9:0]	value_A,
	output	reg	[7:0]	value_B,
	output	reg			load_A,
	output	reg			load_B,
	output	reg	 		enable_irq_A,
	output	reg	 		enable_irq_B,
	output	reg			clr_flag_A,
	output	reg			clr_flag_B,
	output	reg			clr_run_A,
	output	reg			clr_run_B,
	output	reg			set_run_A,
	output	reg			set_run_B,
	output	reg			fast_timers,
	input				flag_A,
	input				overflow_A,	
	// PCM
	output	reg	[8:0]	pcm,
	output	reg			pcm_en,

	`ifdef TEST_SUPPORT
	// Test
	output	reg		test_eg,
	output	reg		test_op0,
	`endif
	// Operator
	output			use_prevprev1,
	output			use_internal_x,
	output			use_internal_y,
	output			use_prev2,
	output			use_prev1,
	// PG
	output	[10:0]	fnum_I,
	output	[ 2:0]	block_I,
	output	reg		pg_stop,
	// REG
	output	[ 1:0]	rl,
	output	[ 2:0]	fb_II,
	output	[ 2:0]	alg,
	output	[ 2:0]	pms,
	output	[ 1:0]	ams_VII,
	output			amsen_VII,
	output	[ 2:0]	dt1_II,
	output	[ 3:0]	mul_V,
	output	[ 6:0]	tl_VII,
	output	reg		eg_stop,

	output	[ 4:0]	ar_II,
	output	[ 4:0]	d1r_II,
	output	[ 4:0]	d2r_II,
	output	[ 3:0]	rr_II,
	output	[ 3:0]	d1l,
	output	[ 1:0]	ks_III,
	// SSG operation
	output			ssg_en_II,
	output	[2:0]	ssg_eg_II,

	output			keyon_II,

//	output	[ 1:0]	cur_op,
	// Operator
	output			zero,
	output 			s1_enters,
	output 			s2_enters,
	output 			s3_enters,
	output 			s4_enters
);

reg [7:0]	selected_register;

//reg		sch; // 0 => CH1~CH3 only available. 1=>CH4~CH6
/*
reg		irq_zero_en, irq_brdy_en, irq_eos_en,
		irq_tb_en, irq_ta_en;
		*/
reg		up_clr;
reg 	up_alg;

reg 	up_block;
reg 	up_fnumlo;
reg 	up_pms;
reg 	up_dt1;
reg 	up_tl;
reg 	up_ks_ar;
reg 	up_amen_d1r;
reg 	up_d2r;
reg		up_d1l;
reg		up_ssgeg;
reg		up_keyon;

wire			busy_reg;

parameter 	REG_TEST	=	8'h01,
			REG_TEST2	=	8'h02,
			REG_TESTYM	=	8'h21,
			REG_LFO 	=	8'h22,
			REG_CLKA1	=	8'h24,
			REG_CLKA2	=	8'h25,
			REG_CLKB	=	8'h26,
			REG_TIMER	=	8'h27,
			REG_KON		=	8'h28,
			REG_IRQMASK =	8'h29,
			REG_PCM 	=	8'h2A,
			REG_PCM_EN	=	8'h2B,
			REG_DACTEST =	8'h2C,
			REG_CLK_N6	=	8'h2D,
			REG_CLK_N3	=	8'h2E,
			REG_CLK_N2	=	8'h2F;


reg	csm, effect;

reg [ 2:0] block_ch3op2,  block_ch3op3,  block_ch3op1;
reg [10:0] fnum_ch3op2, fnum_ch3op3, fnum_ch3op1;
reg [ 5:0] latch_ch3op2,  latch_ch3op3,  latch_ch3op1;


reg [2:0] up_ch;
reg [1:0] up_op;

reg [7:0] din_latch;

`include "jt12_mmr_sim.vh"

always @(posedge clk) begin : memory_mapped_registers
	if( rst ) begin
		selected_register 	<= 8'h0;
		busy				<= 1'b0;
		up_ch				<= 3'd0;
		up_op				<= 2'd0;
		{ 	up_keyon,		up_alg, 	up_block, 	up_fnumlo,
			up_pms, 	up_dt1, 	up_tl, 		up_ks_ar,
			up_amen_d1r,up_d2r,		up_d1l,		up_ssgeg } <=  12'd0;
		`ifdef TEST_SUPPORT
		{ test_eg, test_op0 } <= 2'd0;
		`endif
		// IRQ Mask
		/*{ irq_zero_en, irq_brdy_en, irq_eos_en,
			irq_tb_en, irq_ta_en } = 5'h1f; */
		// timers
		{ value_A, value_B } <= 18'd0;
		{ clr_flag_B, clr_flag_A,
		enable_irq_B, enable_irq_A, load_B, load_A } <= 6'd0;
		{ clr_run_A, clr_run_B, set_run_A, set_run_B } <= 4'b1100;
		up_clr <= 1'b0;
		fast_timers <= 1'b0;
		// LFO
		lfo_freq	<= 3'd0;
		lfo_en		<= 1'b0;
		csm			<= 1'b0;
		effect		<= 1'b0;
		// PCM
		pcm			<= 9'h0;
		pcm_en		<= 1'b0;
		// clock speed
		set_n6		<= 1'b1;
		set_n3		<= 1'b0;
		set_n2		<= 1'b0;
		// sch			<= 1'b0;
		// Original test features
		eg_stop		<=	1'b0;
		pg_stop		<=	1'b0;
		`ifdef SIMULATION
		mmr_dump	<= 1'b0;
		`endif
	end else begin
		// WRITE IN REGISTERS
		if( write && !busy ) begin
			busy <= 1'b1;
			if( !addr[0] ) begin
				selected_register <= din;
				up_ch	<= {addr[1], din[1:0]};
				up_op	<= din[3:2]; // 0=S1,1=S3,2=S2,3=S4
			end else begin
				din_latch <= din;
				// Global registers
				if( selected_register < 8'h30 ) begin
					case( selected_register)
					// registros especiales
					//REG_TEST:	lfo_rst <= 1'b1; // regardless of din
					`ifdef TEST_SUPPORT
					REG_TEST2:	{ mmr_dump, test_op0, test_eg } <= din[2:0];
					`endif
					REG_TESTYM: begin
						eg_stop <= din[5];
						pg_stop <= din[3];
						fast_timers <= din[2];
						end
					REG_KON: 	up_keyon 	<= 1'b1;
					REG_CLKA1:	value_A[9:2]<= din;
					REG_CLKA2:	value_A[1:0]<= din[1:0];
					REG_CLKB:	value_B		<= din;
					REG_TIMER: begin
						effect	<= |din[7:6];
						csm		<= din[7:6] == 2'b10;
						{ clr_flag_B, clr_flag_A,
						  enable_irq_B, enable_irq_A,
						  load_B, load_A } <= din[5:0];
						  clr_run_A <= ~din[0];
						  set_run_A <=  din[0];
						  clr_run_B <= ~din[1];
						  set_run_B <=  din[1];
						end
					REG_LFO:	{ lfo_en, lfo_freq } <= din[3:0];
					REG_DACTEST:pcm[0] <= din[3];
					REG_PCM:	pcm[8:1]<= din;
					REG_PCM_EN:	pcm_en	<= din[7];
					//REG_CLK_N6:	{ set_n6, set_n3, set_n2 } <= 3'b100;
					//REG_CLK_N3:	{ set_n6, set_n3, set_n2 } <= 3'b010;
					//REG_CLK_N2:	{ set_n6, set_n3, set_n2 } <= 3'b001;
					/*
					REG_IRQMASK: { sch, irq_zero_en,
						irq_brdy_en,
						irq_eos_en,
						irq_tb_en, irq_ta_en } <= { din[7], din[4:0] }; */
					endcase
				end
                else if( selected_register[1:0]!=2'b11 ) begin
					// channel registers
					if( selected_register >= 8'hA0 ) begin
						case( selected_register )
							8'hA0, 8'hA1, 8'hA2:	up_fnumlo	<= 1'b1;
							8'hA4, 8'hA5, 8'hA6:	up_block	<= 1'b1;
							// CH3 special registers
							8'hA9: { block_ch3op1, fnum_ch3op1 } <= { latch_ch3op1, din };
                            8'hA8: { block_ch3op3, fnum_ch3op3 } <= { latch_ch3op3, din };
                            8'hAA: { block_ch3op2, fnum_ch3op2 } <= { latch_ch3op2, din };
                            8'hAD: latch_ch3op1 <= din[5:0];
							8'hAC: latch_ch3op3 <= din[5:0];
                            8'hAE: latch_ch3op2 <= din[5:0];
							// FB + Algorithm
                            8'hB0, 8'hB1, 8'hB2:	up_alg		<= 1'b1;
							8'hB4, 8'hB5, 8'hB6:	up_pms		<= 1'b1;
						endcase
					end
					else
					// operator registers
					begin
						case( selected_register[7:4] )
							4'h3: up_dt1 	<= 1'b1;
							4'h4: up_tl		<= 1'b1;
							4'h5: up_ks_ar	<= 1'b1;
							4'h6: up_amen_d1r	<= 1'b1;
							4'h7: up_d2r 	<= 1'b1;
							4'h8: up_d1l 	<= 1'b1;
							4'h9: up_ssgeg	<= 1'b1;
						endcase
					end
                end
			end
		end
		else begin /* clear once-only bits */
			// csm 	<= 1'b0;
			// lfo_rst <= 1'b0;
			{ clr_flag_B, clr_flag_A, load_B, load_A } <= 4'd0;
			{ clr_run_A, clr_run_B, set_run_A, set_run_B } <= 4'd0;
			`ifdef SIMULATION
			mmr_dump <= 1'b0;
			`endif
			up_keyon <= 1'b0;
			if( |{  up_keyon,	up_alg, 	up_block, 	up_fnumlo,
					up_pms, 	up_dt1, 	up_tl, 		up_ks_ar,
					up_amen_d1r,up_d2r,		up_d1l,		up_ssgeg } == 1'b0 )
				busy	<= busy_reg | write;
			else
				busy	<= 1'b1;

			if( busy_reg ) begin
				up_clr <= 1'b1;
			end
			else begin
				up_clr <= 1'b0;
				if( up_clr	)
  			 	 { 	up_alg, 	up_block, 	up_fnumlo,
					up_pms, 	up_dt1, 	up_tl, 		up_ks_ar,
					up_amen_d1r,up_d2r,		up_d1l,		up_ssgeg } <=  11'd0;
			end
		end
	end
end

jt12_reg u_reg(
	.rst		( rst		),
	.clk		( clk		),		// P1
	.din		( din_latch	),

	.up_keyon	( up_keyon	),
	.up_alg		( up_alg	),
	.up_block	( up_block	),
	.up_fnumlo	( up_fnumlo	),
	.up_pms		( up_pms	),
	.up_dt1		( up_dt1	),
	.up_tl		( up_tl		),
	.up_ks_ar	( up_ks_ar	),
	.up_amen_d1r(up_amen_d1r),
	.up_d2r		( up_d2r	),

	.up_d1l		( up_d1l	),
	.up_ssgeg	( up_ssgeg	),

	.op			( up_op		),		// operator to update
	.ch			( up_ch 	),		// channel to update

	.csm		( csm		),
	.flag_A		( flag_A	),
	.overflow_A	( overflow_A),

	.busy		( busy_reg	),
	.ch6op		( ch6op		),
	// CH3 Effect-mode operation
	.effect		( effect	),		// allows independent freq. for CH 3
	.fnum_ch3op2( fnum_ch3op2 ),
	.fnum_ch3op3( fnum_ch3op3 ),
	.fnum_ch3op1( fnum_ch3op1 ),
	.block_ch3op2( block_ch3op2 ),
	.block_ch3op3( block_ch3op3 ),
	.block_ch3op1( block_ch3op1 ),
	// Operator
	.use_prevprev1(use_prevprev1),
	.use_internal_x(use_internal_x),
	.use_internal_y(use_internal_y),
	.use_prev2	( use_prev2	),
	.use_prev1	( use_prev1	),
	// PG
	.fnum_I		(	fnum_I	),
	.block_I	(	block_I ),
	.mul_V		(	mul_V	),
	.dt1_II		(	dt1_II	),

	// EG
	.ar_II		(ar_II		),	// attack  rate
	.d1r_II		(d1r_II		), // decay   rate
	.d2r_II		(d2r_II		), // sustain rate
	.rr_II		(rr_II		),	// release rate
	.d1l		(d1l		),   // sustain level
	.ks_III		(ks_III		),	   // key scale
	// SSG operation
	.ssg_en_II	( ssg_en_II	),
	.ssg_eg_II	( ssg_eg_II	),
	// envelope number
	.tl_VII		(tl_VII		),
	.pms		(pms		),
	.ams_VII	(ams_VII	),
	.amsen_VII	(amsen_VII	),
	// channel configuration
	.rl			( rl		),
	.fb_II		( fb_II		),
	.alg		( alg		),
	.keyon_II	( keyon_II	),

	//.cur_op		( cur_op	),
	.zero		( zero		),
	.s1_enters	( s1_enters	),
	.s2_enters	( s2_enters	),
	.s3_enters	( s3_enters	),
	.s4_enters	( s4_enters	)
);

endmodule
