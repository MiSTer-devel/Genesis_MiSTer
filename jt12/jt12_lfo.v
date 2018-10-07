/*  This file is part of jt12.

    jt12 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    jt12 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with jt12.  If not, see <http://www.gnu.org/licenses/>.
	
	Author: Jose Tejada Gomez. Twitter: @topapate
	Version: 1.0
	Date: 25-2-2017
	*/

`timescale 1ns / 1ps

/*

	tab size 4

*/

module jt12_lfo(
	input			 	rst,
	input			 	clk,
	input				clk_en,
	input				zero,
	input				lfo_rst,
	input				lfo_en,
	input		[2:0]	lfo_freq,
	output	reg	[6:0]	lfo_mod
);

reg [6:0] cnt, limit;

always @(*)
	case( lfo_freq )
		3'd0: limit = 7'd108;
		3'd1: limit = 7'd78;
		3'd2: limit = 7'd71;
		3'd3: limit = 7'd67;
		3'd4: limit = 7'd62;
		3'd5: limit = 7'd44;
		3'd6: limit = 7'd8;
		3'd7: limit = 7'd5;
	endcase

always @(posedge clk) 
	if( rst || !lfo_en )
		{ lfo_mod, cnt } <= 14'd0;
	else if( clk_en && zero) begin
		if( cnt == limit ) begin
			cnt <= 7'd0;
			lfo_mod <= lfo_mod + 1'b1;
		end
		else begin
			cnt <= cnt + 1'b1;
		end
	end
	
endmodule
