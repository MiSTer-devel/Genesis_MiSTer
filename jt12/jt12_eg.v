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

	The non SSG-EG section is basically that of JT51's jt51_envelope.v
	adapted to 6 channels, instead of the eight.

	The SSG-EG is based on the works of Nemesis, published on
	http://gendev.spritesmind.net/forum/search.php?st=0&sk=t&sd=d&sr=posts&keywords=SSG-EG&t=386&sf=msgonly&ch=-1&start=15

	This module tries to replicate exactly the original YM2612 waveforms.
	Nonetheless, the verilog code is not a replica of the original circuit
	as there is no reverse engineering description of it.

	Questions:
		-I latch the SSG enable bit on keyon. I have to do this in order to ignore the inversion bit before the keyon
		-If SSG enable is set to 0 by software before issueing a keyoff it will be ignored
		-However, the other SSG bits will have an effect if changed in the meantime between keyon and keyoff
		-Was YM2612 like that?

	*/

`timescale 1ns / 1ps

/*

	tab size 4

*/

module jt12_eg (
	`ifdef TEST_SUPPORT
	input				test_eg,
	`endif
	input			 	rst,
	input			 	clk,
	input				clk_en,
	input				zero,
	input				eg_stop,
	// envelope configuration
	input		[4:0]	keycode_III,
	input		[4:0]	arate_II, // attack  rate
	input		[4:0]	rate1_II, // decay   rate
	input		[4:0]	rate2_II, // sustain rate
	input		[3:0]	rrate_II, // release rate
	input		[3:0]	d1l,   // sustain level
	input		[1:0]	ks_III,	   // key scale
	// SSG operation
	input				ssg_en_II,
	input		[2:0]	ssg_eg_II,
	// envelope operation
	input				keyon_II,
	// envelope number
	input		[6:0]	am,
	input		[6:0]	tl_VII,
	input		[1:0]	ams_VII,
	input				amsen_VII,

	output	reg	[9:0]	eg_IX,
	output	reg			pg_rst_III
);

 // eg[9:6] -> direct attenuation (divide by 2)
		// eg[5:0] -> mantisa attenuation (uses LUT)
		// 1 LSB of eg is -0.09257 dB

wire ssg_inv_II  = ssg_eg_II[2] & ssg_en_II;
wire ssg_alt_II  = ssg_eg_II[1] & ssg_en_II;
wire ssg_hold_II = ssg_eg_II[0] & ssg_en_II;

parameter ATTACK=3'd0, DECAY1=3'd1, DECAY2=3'd2, RELEASE=3'd7, HOLD=3'd3;

reg		[4:0]	d1level_II;
reg		[9:0]	eg_III, eg_IV, eg_V;
wire	[9:0]	eg_II;

reg 	step_V;
reg		sum_up;
reg 	[5:0]	rate_V;

// remember: { log_msb, pow_addr } <= log_val[11:0] + { tl, 5'd0 } + { eg, 2'd0 };

reg		[1:0]	eg_cnt_base;
reg		[14:0]	eg_cnt;

always @(posedge clk) begin : envelope_counter
	if( rst ) begin
		eg_cnt_base	<= 2'd0;
		eg_cnt		<=15'd0;
	end
	else begin
		if( zero && clk_en ) begin
			// envelope counter increases every 3 output samples,
			// there is one sample every 32 clock ticks
			if( eg_cnt_base == 2'd2 ) begin
				eg_cnt 		<= eg_cnt + 1'b1;
				eg_cnt_base	<= 2'd0;
			end
			else eg_cnt_base <= eg_cnt_base + 1'b1;
		end
	end
end

wire			cnt_out; // = all_cnt_last[3*31-1:3*30];


reg  [7:0]	step_idx;
reg	 [2:0]	state_III, state_IV, state_V, state_VI, state_VII, state_VIII;
wire [2:0]	state_II;


wire	ar_off_VI;
reg		ar_off_III;

//	Register Cycle I

always @(posedge clk) if( clk_en ) begin
	if( d1l == 4'd15 )
		d1level_II <= 5'h1f; // 93dB
	else
		d1level_II <= {1'b0, d1l};
end

//	Register Cycle II
wire	ssg_invertion_II, ssg_invertion_VIII;
reg		ssg_invertion_III;
reg	[4:0] cfg_III;
wire	ssg_pg_rst = eg_II>=10'h200 && ssg_en_II &&
							 !( ssg_alt_II || ssg_hold_II );
wire	ssg_en_out;
wire	keyon_last_II;
reg		ssg_en_in_II;

always @(*) begin
	if( state_II==RELEASE )
		ssg_en_in_II = 1'b0;
	else
		ssg_en_in_II = keyon_II ? ssg_en_II : ssg_en_out;
end

wire	ar_off_II = arate_II == 5'h1f;

wire	keyon_now_II  = !keyon_last_II && keyon_II;
wire	keyoff_now_II = keyon_last_II && !keyon_II;

always @(posedge clk) if( clk_en ) begin
	// ar_off_III	<= arate_II == 5'h1f;
	// trigger release
	if( keyoff_now_II ) begin
		cfg_III <= { rrate_II, 1'b1 };
		state_III <= RELEASE;
		pg_rst_III	<= 1'b0;
		ar_off_III <= 1'b0;
	end
	else begin
		// trigger 1st decay
		if( keyon_now_II ) begin
			cfg_III <= arate_II;
			state_III <= ATTACK;
			pg_rst_III <= 1'b1;
			ar_off_III <= ar_off_II;
		end
		else begin : sel_rate
			pg_rst_III <= (eg_II==10'h3FF) ||ssg_pg_rst;
			if( (state_II==DECAY1 ||state_II==DECAY2) && ssg_en_II && eg_II >= 10'h200 ) begin
				ssg_invertion_III <= ssg_alt_II ^ ssg_invertion_II;
				if( ssg_hold_II ) begin
					cfg_III <= 5'd0;
					state_III <= HOLD; // repeats!
					ar_off_III <= 1'b0;
				end
				else begin
					cfg_III	<=	rate2_II;
					state_III <= ATTACK; // repeats!
					ar_off_III <= 1'b1;
				end
			end
			else begin
				ssg_invertion_III <= state_II==RELEASE ? 1'b0 : ssg_invertion_II;
				case ( state_II )
					ATTACK: begin
						if( eg_II==10'd0 ) begin
							state_III <= DECAY1;
							cfg_III		 <= rate1_II;
						end
						else begin
							state_III <= state_II; // attack
							cfg_III		 <= arate_II;
						end
						ar_off_III <= 1'b0;
						end
					DECAY1: begin
						if( eg_II[9:5] >= d1level_II ) begin
							cfg_III <= rate2_II;
							state_III <= DECAY2;
						end
						else begin
							cfg_III	<=	rate1_II;
							state_III <= state_II;	// decay1
						end
						ar_off_III <= 1'b0;
						end
					DECAY2:
						begin
							cfg_III	<=	rate2_II;
							state_III <= state_II;	// decay2
							ar_off_III <= 1'b0;
						end
					RELEASE: begin
							cfg_III	<=	{ rrate_II, 1'b1 };
							state_III <= state_II;	// release
							ar_off_III <= 1'b0;
						end
					HOLD: begin
							cfg_III <= 5'd0;
							state_III <= HOLD; // repeats!
							ar_off_III <= 1'b0;
						end
				endcase
			end
		end
	end

	eg_III <= eg_II;
end

///////////////////////////////////////////////////////////////////
//	Register Cycle III
reg		[6:0]	pre_rate_III;
reg		[5:0]	rate_IV;

always @(*) begin : pre_rate_calc
	if( cfg_III == 5'd0 )
		pre_rate_III = 7'd0;
	else
		case( ks_III )
			2'd3:	pre_rate_III = { cfg_III, 1'b0 } + { 1'b0, keycode_III };
			2'd2:	pre_rate_III = { cfg_III, 1'b0 } + { 2'b0, keycode_III[4:1] };
			2'd1:	pre_rate_III = { cfg_III, 1'b0 } + { 3'b0, keycode_III[4:2] };
			2'd0:	pre_rate_III = { cfg_III, 1'b0 } + { 4'b0, keycode_III[4:3] };
		endcase
end

always @(posedge clk) if( clk_en ) begin 
	if( rst ) begin
		state_IV <= RELEASE;
		eg_IV <= 10'h3ff;
		rate_IV <= 6'h1F; // should it be 6'h3F? TODO
	end
	else begin
		state_IV <= state_III;
		eg_IV <= eg_III;
		rate_IV <= pre_rate_III[6] ? 6'd63 : pre_rate_III[5:0];
	end
end
///////////////////////////////////////////////////////////////////
//	Register Cycle IV
reg		[2:0]	cnt_V;

always @(posedge clk) if( clk_en ) begin
	if( rst ) begin
		state_V	<= RELEASE;
		rate_V <= 6'h1F; // should it be 6'h3F? TODO
		eg_V <= 10'h3ff;
		//cnt_V<= 3'd0;
	end
	else begin
		state_V	<= state_IV;
		rate_V <= rate_IV;
		eg_V <= eg_IV;
		if( state_IV == ATTACK )
			case( rate_IV[5:2] )
				4'h0: cnt_V <= eg_cnt[13:11];
				4'h1: cnt_V <= eg_cnt[12:10];
				4'h2: cnt_V <= eg_cnt[11: 9];
				4'h3: cnt_V <= eg_cnt[10: 8];
				4'h4: cnt_V <= eg_cnt[ 9: 7];
				4'h5: cnt_V <= eg_cnt[ 8: 6];
				4'h6: cnt_V <= eg_cnt[ 7: 5];
				4'h7: cnt_V <= eg_cnt[ 6: 4];
				4'h8: cnt_V <= eg_cnt[ 5: 3];
				4'h9: cnt_V <= eg_cnt[ 4: 2];
				4'ha: cnt_V <= eg_cnt[ 3: 1];
				default: cnt_V <= eg_cnt[ 2: 0];
			endcase
		else
			case( rate_IV[5:2] )
				4'h0: cnt_V <= eg_cnt[14:12];
				4'h1: cnt_V <= eg_cnt[13:11];
				4'h2: cnt_V <= eg_cnt[12:10];
				4'h3: cnt_V <= eg_cnt[11: 9];
				4'h4: cnt_V <= eg_cnt[10: 8];
				4'h5: cnt_V <= eg_cnt[ 9: 7];
				4'h6: cnt_V <= eg_cnt[ 8: 6];
				4'h7: cnt_V <= eg_cnt[ 7: 5];
				4'h8: cnt_V <= eg_cnt[ 6: 4];
				4'h9: cnt_V <= eg_cnt[ 5: 3];
				4'ha: cnt_V <= eg_cnt[ 4: 2];
				4'hb: cnt_V <= eg_cnt[ 3: 1];
				default: cnt_V <= eg_cnt[ 2: 0];
			endcase
	end
end
//////////////////////////////////////////////////////////////
// Register Cycle V
always @(*) begin : rate_step
	if( rate_V[5:4]==2'b11 ) begin // 0 means 1x, 1 means 2x
		if( rate_V[5:2]==4'hf && state_V == ATTACK)
			step_idx = 8'b11111111; // Maximum attack speed, rates 60&61
		else
		case( rate_V[1:0] )
			2'd0: step_idx = 8'b00000000;
			2'd1: step_idx = 8'b10001000; // 2
			2'd2: step_idx = 8'b10101010; // 4
			2'd3: step_idx = 8'b11101110; // 6
		endcase
	end
	else begin
		if( rate_V[5:2]==4'd0 && state_V != ATTACK)
			step_idx = 8'b11111110; // limit slowest decay rate_IV
		else
		case( rate_V[1:0] )
			2'd0: step_idx = 8'b10101010; // 4
			2'd1: step_idx = 8'b11101010; // 5
			2'd2: step_idx = 8'b11101110; // 6
			2'd3: step_idx = 8'b11111110; // 7
		endcase
	end
	// a rate_IV of zero keeps the level still
	step_V = rate_V[5:1]==5'd0 ? 1'b0 : step_idx[ cnt_V ];
end

reg	[5:1]	rate_VI;
reg [9:0]	eg_VI;
reg			step_VI;

always @(posedge clk) 
	if( rst ) begin
		state_VI <= RELEASE;
		rate_VI <= 5'd1;
		eg_VI <= 10'h3ff;
		sum_up <= 1'b0;
		step_VI <= 1'b0;
	end
	else if( clk_en ) begin
		state_VI <= state_V;
		rate_VI <= rate_V[5:1];
		eg_VI <= eg_V;
		sum_up <= cnt_V[0] != cnt_out;
		step_VI <= step_V;
	end

//////////////////////////////////////////////////////////////
// Register cycle VI
reg [3:0] 	preatt_VI;
reg [5:0] 	att_VI;
wire		ssg_en_VI;
reg	[9:0]	eg_VII, eg_stopped_VII;
reg	[10:0]	egatt_VI;

always @(*) begin
	case( rate_VI[5:2] )
		4'b1100: preatt_VI = { 2'b0, step_VI, ~step_VI }; // 12
		4'b1101: preatt_VI = { 1'b0, step_VI, ~step_VI, 1'b0 }; // 13
		4'b1110: preatt_VI = { step_VI, ~step_VI, 2'b0 }; // 14
		4'b1111: preatt_VI = 4'd8;// 15
		default: preatt_VI = { 2'b0, step_VI, 1'b0 };
	endcase
	att_VI = ssg_en_VI ? { preatt_VI, 2'd0 } : { 2'd0, preatt_VI };
	egatt_VI = {4'd0, att_VI} + eg_VI;
	eg_stopped_VII = eg_VI;
end

reg [8:0] ar_sum0;
reg [9:0] ar_result, ar_sum;

always @(*) begin : ar_calculation
	casex( rate_VI[5:2] )
		default: ar_sum0 = {2'd0, eg_VI[9:4]} + 8'd1;
		4'b1100: ar_sum0 = {2'd0, eg_VI[9:4]} + 8'd1;
		4'b1101: ar_sum0 = {1'd0, eg_VI[9:3]} + 8'd1;
		4'b111x: ar_sum0 = eg_VI[9:2] + 8'd1;
	endcase
	if( rate_VI[5:4] == 2'b11 )
		ar_sum = step_VI ? { ar_sum0, 1'b0 } : { 1'b0, ar_sum0 };
	else
		ar_sum = step_VI ? { 1'b0, ar_sum0 } : 10'd0;
	ar_result = ar_sum<eg_VI ? eg_VI-ar_sum : 10'd0;
end

always @(posedge clk) 
	if( rst ) begin
		eg_VII <= 10'h3ff;
		state_VII <= RELEASE;
	end
	else if( clk_en ) begin
		if( ar_off_VI ) begin
			// eg_VII <= ssg_en_II ? 10'h200 : 10'd0;
			eg_VII <= 10'd0;
		end
		else
		if( state_VI == ATTACK ) begin
			if( sum_up && eg_VI != 10'd0 )
				if( rate_VI[5:1]==5'h1f )
					eg_VII <= 10'd0;
				else
					eg_VII <= ar_result;
			else
				eg_VII <= eg_VI;
		end
		else begin : DECAY_SUM
			if( sum_up ) begin
				if ( egatt_VI<= 11'd1023 )
					eg_VII <= egatt_VI[9:0];
				else eg_VII <= 10'h3FF;
			end
			else eg_VII <= eg_VI;
		end
		state_VII <= state_VI;
	end

//////////////////////////////////////////////////////////////
// Register cycle VII
reg		[9:0]	eg_internal_VIII;
reg		[8:0]	am_final;
reg		[11:0]	sum_eg_tl;

always @(*) begin : sum_eg_and_tl
	casex( {amsen_VII, ams_VII } )
		3'b0xx,3'b100: am_final = 9'd0;
		3'b101: am_final = { 2'b00, am };
		3'b110: am_final = { 1'b0, am, 1'b0};
		3'b111: am_final = { am, 2'b0	  };
	endcase
	`ifdef TEST_SUPPORT
	if( test_eg && tl_VII!=7'd0 )
		sum_eg_tl = 11'd0;
	else
	`endif
		sum_eg_tl = { 1'b0, tl_VII,   3'd0 }
				   + { 1'b0, eg_VII}
				   + { 1'b0, am_final, 1'b0 };
end

always @(posedge clk) 
	if( rst ) begin
		eg_internal_VIII <= 10'h3ff;
		state_VIII <= RELEASE;
	end
	else if( clk_en ) begin
		eg_internal_VIII <= sum_eg_tl[11:10] > 2'b0 ? {10{1'b1}} : sum_eg_tl[9:0];
		state_VIII <= state_VII;
	end


//////////////////////////////////////////////////////////////
// Register cycle VIII
wire ssg_inv_VIII, ssg_en_VIII;
//reg	[9:0] eg_IX;
always @(posedge clk) 
	if( rst )
		eg_IX <= 10'h3ff;
	else if( clk_en ) begin
		if( ssg_en_VIII && (ssg_invertion_VIII ^^ ssg_inv_VIII) )
			eg_IX <= eg_internal_VIII>=10'h200 ? 10'h0 : (10'h200 - eg_internal_VIII);
		else
			eg_IX <= eg_internal_VIII;
	end

//////////////////////////////////////////////////////////////
// Register cycle IX-XII
/*
jt12_sh #(.width(10), .stages(12-8)) u_padding(
	.clk	( clk		),
	.din	( eg_IX		),
	.drop	( eg_XII	)
);
*/
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
// Shift registers

jt12_sh24 #( .width(1) ) u_ssgen(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.din	( ssg_en_in_II ),
	.st4	( ssg_en_VI	  ),
	.st6	( ssg_en_VIII ), // note that din is *_II
	.st24	( ssg_en_out  )
);

jt12_sh #( .width(1), .stages(6) ) u_ssgattsh(
	.clk	( clk			),
	.clk_en	( clk_en		),
	.din	( ssg_inv_II	),
	.drop	( ssg_inv_VIII	)
);

jt12_sh #( .width(1), .stages(3) ) u_aroffsh(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.din	( ar_off_III),
	.drop	( ar_off_VI	)
);

jt12_sh #( .width(1), .stages(5) ) u_ssg1sh(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.din	( ssg_invertion_III	),
	.drop	( ssg_invertion_VIII	)
);


jt12_sh #( .width(1), .stages(18) ) u_ssg2sh(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.din	( ssg_invertion_VIII	),
	.drop	( ssg_invertion_II	)
);


/* Had 27 stages in JT51, for 32 operators
   Has 19 stages here, for 24 operators
   plus 1 extra stage. 20 stages does not work well.
   Maybe JT51 should be 26!! */
jt12_sh/*_rst*/ #( .width(10), .stages(19)/*, .rstval(1'b1)*/ ) u_egsh(
	.clk	( clk		),
	.clk_en	( clk_en	),
//	.rst	( rst		),
	.din	( eg_stop ? eg_stopped_VII : eg_VII		),
	.drop	( eg_II	)
);

/* Had 32 stages in JT51, for 32 operators
   Has 24 stages here, for 24 operators */
jt12_sh/*_rst*/ #( .width(1), .stages(24) ) u_cntsh(
	.clk	( clk		),
	.clk_en	( clk_en	),
//	.rst	( rst		),	
	.din	( cnt_V[0]	),
	.drop	( cnt_out	)
);

jt12_sh #( .width(1), .stages(24) ) u_konsh(
	.clk	( clk		),
	.clk_en	( clk_en	),
//	.rst	( rst		),	
	.din	( keyon_II	),
	.drop	( keyon_last_II	)
);

/* Had 31 stages in JT51, for 32 operators
   Has 23 stages here, for 24 operators */
jt12_sh/*_rst*/ #( .width(3), .stages(18)/*, .rstval(1'b1)*/ ) u_statesh(
	.clk	( clk		),
	.clk_en	( clk_en	),
//	.rst	( rst		),
	.din	( state_VIII),
	.drop	( state_II	)
);

`ifdef SIMULATION
reg [4:0] sep24_cnt;

wire [2:0] state_ch0s1, state_ch1s1, state_ch2s1, state_ch3s1,
		 state_ch4s1, state_ch5s1, state_ch0s2, state_ch1s2,
		 state_ch2s2, state_ch3s2, state_ch4s2, state_ch5s2,
		 state_ch0s3, state_ch1s3, state_ch2s3, state_ch3s3,
		 state_ch4s3, state_ch5s3, state_ch0s4, state_ch1s4,
		 state_ch2s4, state_ch3s4, state_ch4s4, state_ch5s4;


always @(posedge clk) if(clk_en)
	sep24_cnt <= !zero ? sep24_cnt+1'b1 : 5'd0;

sep24 #( .width(3), .pos0(0) ) stsep
(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.mixed	( state_II	),
	.mask	( 24'd0		),
	.cnt	( sep24_cnt	),

	.ch0s1 (state_ch0s1),
	.ch1s1 (state_ch1s1),
	.ch2s1 (state_ch2s1),
	.ch3s1 (state_ch3s1),
	.ch4s1 (state_ch4s1),
	.ch5s1 (state_ch5s1),

	.ch0s2 (state_ch0s2),
	.ch1s2 (state_ch1s2),
	.ch2s2 (state_ch2s2),
	.ch3s2 (state_ch3s2),
	.ch4s2 (state_ch4s2),
	.ch5s2 (state_ch5s2),

	.ch0s3 (state_ch0s3),
	.ch1s3 (state_ch1s3),
	.ch2s3 (state_ch2s3),
	.ch3s3 (state_ch3s3),
	.ch4s3 (state_ch4s3),
	.ch5s3 (state_ch5s3),

	.ch0s4 (state_ch0s4),
	.ch1s4 (state_ch1s4),
	.ch2s4 (state_ch2s4),
	.ch3s4 (state_ch3s4),
	.ch4s4 (state_ch4s4),
	.ch5s4 (state_ch5s4)
);

`endif

endmodule

