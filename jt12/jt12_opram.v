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

	Based on Sauraen VHDL version of OPN/OPN2, which is based on die shots.

	Author: Jose Tejada Gomez. Twitter: @topapate
	Version: 1.0
	Date: 27-1-2017	

*/

module jt12_opram
(
	input [4:0] wr_addr,
	input [4:0] rd_addr,
	input clk, 
	input clk_en,
	input [43:0] data,
	output reg [43:0] q
);

	reg [43:0] ram[31:0];
	initial
	begin
		ram[0]  = 43'd0;
		ram[1]  = 43'd0;
		ram[2]  = 43'd0;
		ram[3]  = 43'd0;
		ram[4]  = 43'd0;
		ram[5]  = 43'd0;
		ram[6]  = 43'd0;
		ram[7]  = 43'd0;
		ram[8]  = 43'd0;
		ram[9]  = 43'd0;
		ram[10] = 43'd0;
		ram[11] = 43'd0;
		ram[12] = 43'd0;
		ram[13] = 43'd0;
		ram[14] = 43'd0;
		ram[15] = 43'd0;
		ram[16] = 43'd0;
		ram[17] = 43'd0;
		ram[18] = 43'd0;
		ram[19] = 43'd0;
		ram[20] = 43'd0;
		ram[21] = 43'd0;
		ram[22] = 43'd0;
		ram[23] = 43'd0;
		ram[24] = 43'd0;
		ram[25] = 43'd0;
		ram[26] = 43'd0;
		ram[27] = 43'd0;
		ram[28] = 43'd0;
		ram[29] = 43'd0;
		ram[30] = 43'd0;
		ram[31] = 43'd0;
	end

	always @ (posedge clk) if(clk_en) begin
		q <= ram[rd_addr];
		ram[wr_addr] <= data;
	end

endmodule
