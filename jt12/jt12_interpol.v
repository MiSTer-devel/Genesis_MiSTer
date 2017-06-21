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

module jt12_interpol(
	input	clk,
	input	rst,
	input	sample_in,
	input	signed [8:0] left_in,
	input	signed [8:0] right_in,
	// mix in other sound sources, like PSG of Megadrive
	// other sound sources should be at the same
	// sampling frequency than the FM sound
	// so a filter like jt12_fir must be used first
	input	signed [8:0] left_other,
	input	signed [8:0] right_other,		
	
	output  signed [19:0] left_out,
	output  signed [19:0] right_out,
	output	sample_out
);

reg [8:0] fir_left_in, fir_right_in;
reg	fir_sample_in;

reg [2:0] state, next;
reg [5:0] cnt;

parameter FIRST=3'd0, SECOND=3'd1, THIRD=3'd2, FOURTH=3'd3, WAIT=3'd4;

always @(posedge clk)
if( rst ) begin
	state <= FIRST;
	next  <= FIRST;
	fir_sample_in <= 1'b0;
	cnt	  <= 6'd0;
end else begin
	case( state )
		default: begin
			fir_left_in <= left_in;
			fir_right_in<= right_in;
			fir_sample_in <= 1'b1;
			next <= SECOND;
			state <= WAIT;
			end
		SECOND: begin
			fir_left_in <= 9'd0;
			fir_right_in<= 9'd0;
			fir_sample_in <= 1'b1;
			next <= THIRD;
			state <= WAIT;
			end
		THIRD: begin
			fir_left_in <= left_other;
			fir_right_in<= right_other;
			fir_sample_in <= 1'b1;
			next <= FOURTH;
			state <= WAIT;		
			end
		FOURTH: begin
			fir_left_in <= 9'd0;
			fir_right_in<= 9'd0;
			fir_sample_in <= 1'b1;
			next <= FIRST;
			state <= WAIT;				
			end
		WAIT: begin			
			fir_sample_in <= 1'b0;
			if( cnt==6'd41 ) begin
				cnt	  <= 6'd1;
				state <= next;
			end
			else cnt <= cnt + 1'b1;	
		end
	endcase	
end

jt12_fir4 u_fir4 (
	.clk		( clk 			),
	.rst		( rst  			),
	.sample		( fir_sample_in ),
	.left_in	( fir_left_in 	),
	.right_in	( fir_right_in 	),
	.left_out	( left_out		),
	.right_out	( right_out		),
	.sample_out	( sample_out	)
);

endmodule
