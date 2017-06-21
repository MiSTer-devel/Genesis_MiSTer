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
	Date: 1-31-2017
	*/

`timescale 1ns / 1ps

module jt12_sh6_rst #(parameter width=5 )
(
	input					rst,	
	input 					clk,
	input		[width-1:0]	din,
	input					load,
   	output reg [width-1:0]	st1,
   	output reg [width-1:0]	st2,
   	output reg [width-1:0]	st3,
   	output reg [width-1:0]	st4,
   	output reg [width-1:0]	st5,
   	output reg [width-1:0]	st6 					
);

always @(posedge clk) 
	if (rst) begin
		st1 <= {width{1'b0}};
		st2 <= {width{1'b0}};
		st3 <= {width{1'b0}};
		st4 <= {width{1'b0}};
		st5 <= {width{1'b0}};
		st6 <= {width{1'b0}};
	end
	else begin
		st6 <= st5;
		st5 <= st4;
		st4 <= st3;
		st3 <= st2;
		st2 <= st1;
		st1 <= load ? din : st6;
	end

endmodule
