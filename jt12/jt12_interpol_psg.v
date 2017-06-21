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

module jt12_interpol_psg(
	input	clk,
	input	rst,
	input	sample_in, // use mux_sample signal from jt12
	input	signed [8:0] ch0,
	input	signed [8:0] ch1,
	input	signed [8:0] ch2,
	input	signed [8:0] noise,
	
	output  signed [19:0] psg_out,
	output	sample_out
);

reg [8:0] fir_in;
reg [2:0] cnt;
reg		update;

always @(posedge clk)
	if( rst )

	else begin
		last_sample <= sample;
		update <= sample && !last_sample;
	end

always @(posedge clk)
if( rst ) begin
	cnt <= 3'd0;
	cnt	  <= 6'd0;
end else 
		if( update ) begin
			case( cnt ) 
				3'd0: fir_in <= ch0;
				3'd1: fir_in <= ch1;
				3'd2: fir_in <= ch2;
				3'd3: fir_in <= noise;
				default: fir_in <= 9'd0;
			endcase
			cnt <= cnt==3'd5 ? 3'd0 : cnt+1'b1;
		end


jt12_fir4 u_fir4 (
	.clk		( clk 			),
	.rst		( rst  			),
	.sample		( sample_in 	),
	.left_in	( fir_in	 	),
	.right_in	( 9'd0		 	),
	.left_out	( psg_out		),
	.sample_out	( sample_out	)
);

endmodule
