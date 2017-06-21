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
	Date: March, 7th 2017
	*/

`timescale 1ns / 1ps

module jt12_mixer(
	input	clk,	// use at least jt12 clk x 7 (i.e. 54MHz)
	input	rst,
	input	sample,
	input	signed [8:0] left_in,
	input	signed [8:0] right_in,
	input	[ 5:0]	psg,
	input	enable_psg,
	output	signed [15:0] left_out,
	output	signed [15:0] right_out
);

wire signed [19:0] fir6_left, fir6_right;
wire fir6_sample;
wire signed [19:0] psg_fir6;

wire [19:0] fir4_left, fir4_right;

assign left_out = fir4_left[17:2];
assign right_out = fir4_right[17:2];

// Change sampling frequency from 54kHz to 321kHz
// interpolating by 6. This is done using the multiplexed output
// as in the original chip

jt12_fir u_fir6 (
	.clk		( clk 			),
	.rst		( rst  			),
	.sample		( sample	 	),
	.left_in	( left_in 		),
	.right_in	( right_in	 	),
	.left_out	( fir6_left 	),
	.right_out	( fir6_right 	),
	.sample_out	( fir6_sample 	)
);

wire signed [8:0] psg_alt = enable_psg ? { 2'b0, psg, 1'b0 } : 9'd0;

jt12_fir u_fir6_psg (
	.clk		( clk 			),
	.rst		( rst  			),
	.sample		( sample	 	),
	.left_in	( psg_alt 		),
	.right_in	( 9'd0		 	),
	.left_out	( psg_fir6	 	)
);

// Interpolate by 4 to obtain sampling frequency of 1.28MHz
// With that oversampling ratio, a 2nd order sigma delta
// has 11.5bit resolution even with a 1-bit quantizer

wire	fir4_sample;

jt12_interpol u_interpol(
	.clk		( clk 			),
	.rst		( rst  			),
	.sample_in	( fir6_sample 	),
	.left_in	( fir6_left[19:11] ),
	.right_in	( fir6_right[19:11]),

	.left_other	( psg_fir6[19:11]),
	.right_other( psg_fir6[19:11]),
	
	.left_out	( fir4_left		),
	.right_out	( fir4_right	),
	.sample_out	( fir4_sample	)
);

endmodule
