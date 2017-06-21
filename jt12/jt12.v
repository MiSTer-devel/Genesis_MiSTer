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

	Based on information provided by
		Sauraen VHDL version of OPN/OPN2, which is based on die shots.
		Nemesis reports, based on measurements
		Comparisons with real hardware lent by Mikes (Va de retro)

	Author: Jose Tejada Gomez. Twitter: @topapate
	Version: 1.0
	Date: 1-4-2017
	
	Use tab = 4 spaces

*/

module jt12(
	input			rst,
	input			clk,
	output			clk_out,
	input	[7:0]	din,
	input	[1:0]	addr,
	input			cs_n,
	input			wr_n,
	input			limiter_en,

	output	[7:0]	dout,
	// combined output
	output	[11:0]	snd_right,
	output	[11:0]	snd_left,
	output			sample,
	// multiplexed output
	output signed	[8:0]	mux_left,
	output signed	[8:0]	mux_right,	
	output				mux_sample,
		
	output			irq_n
);

wire			zero; // Single-clock pulse at the begginig of s1_enters
// LFO
wire	[2:0]	lfo_freq;
wire			lfo_en;
// Operators
wire			amsen_VII;
wire	[ 2:0]	dt1_II;
wire	[ 3:0]	mul_V;
wire	[ 6:0]	tl_VII;

wire	[4:0]	keycode_III;
wire	[ 4:0]	ar_II;
wire	[ 4:0]	d1r_II;
wire	[ 4:0]	d2r_II;
wire	[ 3:0]	rr_II;
wire	[ 3:0]	d1l;
wire	[ 1:0]	ks_III;
// SSG operation
wire			ssg_en_II;
wire	[2:0]	ssg_eg_II;
// envelope operation
wire			keyon_II;
wire	[9:0]	eg_IX;
wire			pg_rst_III;
// Channel
wire	[10:0]	fnum_I;
wire	[ 2:0]	block_I;
wire	[ 1:0]	rl;
wire	[ 2:0]	fb_II;
wire	[ 2:0]	alg;
wire	[ 2:0]	pms;
wire	[ 1:0]	ams_VII;
// PCM
wire			pcm_en;
wire	[ 8:0]	pcm;
// Test
wire			pg_stop, eg_stop;

// Timers
wire	[9:0]	value_A;
wire	[7:0]	value_B;
wire			load_A, load_B;
wire	 		enable_irq_A, enable_irq_B;
wire			clr_flag_A, clr_flag_B;
wire			clr_run_A, clr_run_B;
wire			set_run_A, set_run_B;
wire			flag_A, flag_B;
wire			overflow_A;
// Operator
wire			use_internal_x, use_internal_y;
wire			use_prevprev1, use_prev2, use_prev1;
wire	[ 9:0]	phase_VIII;
wire 			s1_enters, s2_enters, s3_enters, s4_enters;
wire			set_n2, set_n3, set_n6;
wire			clk_int, rst_int;
// LFO
wire	[6:0]	lfo_mod;
wire			lfo_rst;

assign			clk_out = clk_int;

`ifdef TEST_SUPPORT
// Test bits
wire			test_eg, test_op0;
`endif

wire	[7:0]	din_s;
wire	[1:0]	addr_s;

wire	busy, write, ch6op;

jt12_clksync u_clksync(
	.rst		( rst		),
	.clk		( clk		),
	.din		( din		),
	.addr		( addr		),
	.busy_mmr	( busy		),
	.flag_A		( flag_A	),
	.flag_B		( flag_B	),
	.cs_n		( cs_n		),
	.wr_n		( wr_n		),

	.set_n6		( set_n6	),
	.set_n3		( set_n3	),
	.set_n2		( set_n2	),

	.clk_int	( clk_int	),
	.rst_int	( rst_int	),
	.din_s		( din_s		),
	.addr_s		( addr_s	),
	.dout		( dout		),
	.write		( write		)
);

jt12_mmr u_mmr(
	.rst		( rst_int	),
	.clk		( clk_int	),		// Phi 1
	.din		( din_s		),
	.write		( write		),
	.addr		( addr_s	),
	.busy		( busy		),
	.ch6op		( ch6op		),
	// Clock speed
	.set_n6		( set_n6	),
	.set_n3		( set_n3	),
	.set_n2		( set_n2	),
	// LFO
	.lfo_freq	( lfo_freq	),
	.lfo_en		( lfo_en	),
	// Timers
	.value_A	( value_A	),
	.value_B	( value_B	),
	.load_A		( load_A	),
	.load_B		( load_B	),
	.enable_irq_A	( enable_irq_A	),
	.enable_irq_B	( enable_irq_B	),
	.clr_flag_A	( clr_flag_A	),
	.clr_flag_B	( clr_flag_B	),
	.clr_run_A	( clr_run_A		),
	.clr_run_B	( clr_run_B		),
	.set_run_A	( set_run_A		),
	.set_run_B	( set_run_B		),
	.flag_A		( flag_A		),
	.overflow_A	( overflow_A	),
	.fast_timers( fast_timers	),
	// PCM
	.pcm		( pcm			),
	.pcm_en		( pcm_en		),

	`ifdef TEST_SUPPORT
	// Test
	.test_eg	( test_eg		),
	.test_op0	( test_op0		),
	`endif
	// Operator
	.use_prevprev1	( use_prevprev1		),
	.use_internal_x	( use_internal_x	),
	.use_internal_y	( use_internal_y	),
	.use_prev2		( use_prev2		),
	.use_prev1		( use_prev1		),
	// PG
	.fnum_I		( fnum_I	),
	.block_I	( block_I	),
	.pg_stop	( pg_stop	),
	// EG
	.rl			( rl		),
	.fb_II		( fb_II		),
	.alg		( alg		),
	.pms		( pms		),
	.ams_VII	( ams_VII	),
	.amsen_VII	( amsen_VII	),
	.dt1_II		( dt1_II	),
	.mul_V		( mul_V		),
	.tl_VII		( tl_VII	),

	.ar_II		( ar_II		),
	.d1r_II		( d1r_II	),
	.d2r_II		( d2r_II	),
	.rr_II		( rr_II		),
	.d1l		( d1l		),
	.ks_III		( ks_III	),

	.eg_stop	( eg_stop	),	
	// SSG operation
	.ssg_en_II	( ssg_en_II	),
	.ssg_eg_II	( ssg_eg_II	),

	.keyon_II	( keyon_II	),
	// Operator
	.zero		( zero		),
	.s1_enters	( s1_enters	),
	.s2_enters	( s2_enters	),
	.s3_enters	( s3_enters	),
	.s4_enters	( s4_enters	)
);

jt12_timers u_timers( 
	.clk		( clk_int		),
	.rst   		( rst_int		),
	.clk_en		( zero			),
	.fast_timers( fast_timers	),
	.value_A	( value_A		),
	.value_B	( value_B		),
	.load_A		( load_A		),
	.load_B		( load_B		),
	.enable_irq_A( enable_irq_B ),
	.enable_irq_B( enable_irq_A ),
	.clr_flag_A	( clr_flag_A	),
	.clr_flag_B	( clr_flag_B	),
	.set_run_A	( set_run_A		),
	.set_run_B	( set_run_B		),
	.clr_run_A	( clr_run_A		),
	.clr_run_B	( clr_run_B		),
	.flag_A		( flag_A		),
	.flag_B		( flag_B		),
	.overflow_A	( overflow_A	),
	.irq_n		( irq_n			)
);

jt12_lfo u_lfo(
	.rst		( rst_int	),
	.clk		( clk_int	),
	.zero		( zero		),
	.lfo_rst	( 1'b0		),
	.lfo_en		( lfo_en	),
	.lfo_freq	( lfo_freq	),
	.lfo_mod	( lfo_mod	)
);

`ifndef TIMERONLY

jt12_pg u_pg(
	.clk		( clk_int		),
	.rst		( rst_int		),
	// Channel frequency
	.fnum_I		( fnum_I		),
	.block_I	( block_I		),
	// Operator multiplying
	.mul_V		( mul_V 		),
	// Operator detuning
	.dt1_II		( dt1_II 		), // same as JT51's DT1
	// phase operation
	.pg_rst_III	( pg_rst_III	),
	.zero		( zero			),
	.pg_stop	( pg_stop		),
	.keycode_III( keycode_III	),
	.phase_VIII	( phase_VIII 	)
);

jt12_eg u_eg(
	`ifdef TEST_SUPPORT
	.test_eg		( test_eg		),
	`endif
	.rst			( rst_int		),
	.clk			( clk_int		),
	.zero			( zero			),
	.eg_stop		( eg_stop		),	
	// envelope configuration
	.keycode_III	( keycode_III	),
	.arate_II		( ar_II			), // attack  rate
	.rate1_II		( d1r_II		), // decay   rate
	.rate2_II		( d2r_II		), // sustain rate
	.rrate_II		( rr_II			), // release rate
	.d1l			( d1l			),   // sustain level
	.ks_III			( ks_III		),	   // key scale
	// SSG operation
	.ssg_en_II		( ssg_en_II		),
	.ssg_eg_II		( ssg_eg_II		),
	// envelope operation
	.keyon_II		( keyon_II		),
	// envelope number
	.am				( lfo_mod		),
	.tl_VII			( tl_VII		),
	.ams_VII		( ams_VII		),
	.amsen_VII		( amsen_VII		),

	.eg_IX			( eg_IX 		),
	.pg_rst_III		( pg_rst_III	)
);

wire	[8:0]	op_result;

jt12_op u_op(
	.rst			( rst_int		),
	.clk			( clk_int		),
	.pg_phase_VIII	( phase_VIII	),
	.eg_atten_IX	( eg_IX			),
	.fb_II			( fb_II			),

	.test_214		( 1'b0			),
	.s1_enters		( s1_enters		),
	.s2_enters		( s2_enters	 	),
	.s3_enters		( s3_enters		),
	.s4_enters		( s4_enters 	),
	.use_prevprev1	( use_prevprev1 ),
	.use_internal_x	( use_internal_x),
	.use_internal_y	( use_internal_y),
	.use_prev2		( use_prev2		),
	.use_prev1		( use_prev1		),
	.zero			( zero			),
	.op_result		( op_result		)
);

jt12_acc u_acc(
	.rst		( rst_int	),
	.clk		( clk_int	),
	.op_result	( op_result	),
	.rl			( rl		),
	.limiter_en	( limiter_en),
	// note that the order changes to deal 
	// with the operator pipeline delay
	.s1_enters	( s2_enters ),
	.s2_enters	( s1_enters ),
	.s3_enters	( s4_enters ),
	.s4_enters	( s3_enters ),
	.ch6op		( ch6op		),
	.pcm_en		( pcm_en	),	// only enabled for channel 6
	.pcm		( pcm		),
	.alg		( alg		),
	// combined output
	.left		( snd_left	),
	.right		( snd_right	),
	.sample		( sample	),
	// muxed output
	.mux_left	( mux_left	),
	.mux_right	( mux_right ),
	.mux_sample	( mux_sample)
);

`ifdef SIMULATION
reg [4:0] sep24_cnt;

wire [9:0] eg_ch0s1, eg_ch1s1, eg_ch2s1, eg_ch3s1, eg_ch4s1, eg_ch5s1,
		eg_ch0s2, eg_ch1s2, eg_ch2s2, eg_ch3s2, eg_ch4s2, eg_ch5s2,
		eg_ch0s3, eg_ch1s3, eg_ch2s3, eg_ch3s3, eg_ch4s3, eg_ch5s3,
		eg_ch0s4, eg_ch1s4, eg_ch2s4, eg_ch3s4, eg_ch4s4, eg_ch5s4;

always @(posedge clk_int)
	sep24_cnt <= !zero ? sep24_cnt+1'b1 : 5'd0;

sep24 #( .width(10), .pos0(5'd0)) egsep
(
	.clk	( clk_int	),
	.mixed	( eg_IX		),
	.mask	( 10'd0		),
	.cnt	( sep24_cnt	),

	.ch0s1 (eg_ch0s1), 
	.ch1s1 (eg_ch1s1), 
	.ch2s1 (eg_ch2s1), 
	.ch3s1 (eg_ch3s1), 
	.ch4s1 (eg_ch4s1), 
	.ch5s1 (eg_ch5s1), 

	.ch0s2 (eg_ch0s2), 
	.ch1s2 (eg_ch1s2), 
	.ch2s2 (eg_ch2s2), 
	.ch3s2 (eg_ch3s2), 
	.ch4s2 (eg_ch4s2), 
	.ch5s2 (eg_ch5s2), 

	.ch0s3 (eg_ch0s3), 
	.ch1s3 (eg_ch1s3), 
	.ch2s3 (eg_ch2s3), 
	.ch3s3 (eg_ch3s3), 
	.ch4s3 (eg_ch4s3), 
	.ch5s3 (eg_ch5s3), 

	.ch0s4 (eg_ch0s4), 
	.ch1s4 (eg_ch1s4), 
	.ch2s4 (eg_ch2s4), 
	.ch3s4 (eg_ch3s4), 
	.ch4s4 (eg_ch4s4), 
	.ch5s4 (eg_ch5s4)
);
`endif

`endif

endmodule
