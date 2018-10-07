module jt12 (
	input			rst,
	input			clk,		// CPU clock
	input			cen,		// optional clock enable, it not needed leave as 1'b1
	input	[7:0]	din,
	input	[1:0]	addr,
	input			cs_n,
	input			wr_n,
	input			limiter_en,
	
	output	[7:0]	dout,
	output			irq_n,
	// combined output
	output	signed	[11:0]	snd_right,
	output	signed	[11:0]	snd_left,
	output			snd_sample,
	// multiplexed output
	output signed	[8:0]	mux_right,	
	output signed	[8:0]	mux_left,
	output			mux_sample
);

wire flag_A, flag_B, busy;

assign dout[7:0] = { busy, 5'd0, flag_B, flag_A };
wire write = !cs_n && !wr_n;
wire clk_en;

// Timers
wire	[9:0]	value_A;
wire	[7:0]	value_B;
wire			load_A, load_B;
wire	 		enable_irq_A, enable_irq_B;
wire			clr_flag_A, clr_flag_B;
wire			overflow_A;
wire			fast_timers;

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

wire	ch6op;

// Operator
wire			use_internal_x, use_internal_y;
wire			use_prevprev1, use_prev2, use_prev1;
wire	[ 9:0]	phase_VIII;
wire 			s1_enters, s2_enters, s3_enters, s4_enters;
wire			rst_int;
// LFO
wire	[6:0]	lfo_mod;
wire			lfo_rst;

`ifdef TEST_SUPPORT
// Test bits
wire			test_eg, test_op0;
`endif

jt12_mmr u_mmr(
	.rst		( rst		),
	.clk		( clk		),
	.cen		( cen		),	// external clock enable
	.clk_en		( clk_en	),	// internal clock enable	
	.din		( din		),
	.write		( write		),
	.addr		( addr		),
	.busy		( busy		),
	.ch6op		( ch6op		),
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
	.clk		( clk			),
	.rst   		( rst			),
	.clk_en		( zero & clk_en	),
	.fast_timers( fast_timers	), // fix this to work well with clock enable signals
	.value_A	( value_A		),
	.value_B	( value_B		),
	.load_A		( load_A		),
	.load_B		( load_B		),
	.enable_irq_A( enable_irq_B ),
	.enable_irq_B( enable_irq_A ),
	.clr_flag_A	( clr_flag_A	),
	.clr_flag_B	( clr_flag_B	),
	.flag_A		( flag_A		),
	.flag_B		( flag_B		),
	.overflow_A	( overflow_A	),
	.irq_n		( irq_n			)
);

jt12_lfo u_lfo(
	.rst		( rst		),
	.clk		( clk		),
	.clk_en		( clk_en	),
	.zero		( zero		),
	.lfo_rst	( 1'b0		),
	.lfo_en		( lfo_en	),
	.lfo_freq	( lfo_freq	),
	.lfo_mod	( lfo_mod	)
);

`ifndef TIMERONLY

jt12_pg u_pg(
	.rst		( rst			),
	.clk		( clk			),
	.clk_en		( clk_en		),
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
	.rst			( rst			),
	.clk			( clk			),
	.clk_en			( clk_en		),
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
	.rst			( rst			),
	.clk			( clk			),
	.clk_en			( clk_en		),
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
	.rst		( rst		),
	.clk		( clk		),
	.clk_en		( clk_en	),
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
	.sample		( snd_sample),
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

always @(posedge clk) if( clk_en )
	sep24_cnt <= !zero ? sep24_cnt+1'b1 : 5'd0;

sep24 #( .width(10), .pos0(5'd0)) egsep
(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.mixed	( eg_IX		),
	.mask	( 24'd0		),
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
