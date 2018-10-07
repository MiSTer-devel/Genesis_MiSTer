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
		ram[0] = { ~7'd0, 37'd0 };
		ram[1] = { ~7'd0, 37'd0 };
		ram[2] = { ~7'd0, 37'd0 };
		ram[3] = { ~7'd0, 37'd0 };
		ram[4] = { ~7'd0, 37'd0 };
		ram[5] = { ~7'd0, 37'd0 };
		ram[6] = { ~7'd0, 37'd0 };
		ram[7] = { ~7'd0, 37'd0 };
		ram[8] = { ~7'd0, 37'd0 };
		ram[9] = { ~7'd0, 37'd0 };
		ram[10] = { ~7'd0, 37'd0 };
		ram[11] = { ~7'd0, 37'd0 };
		ram[12] = { ~7'd0, 37'd0 };
		ram[13] = { ~7'd0, 37'd0 };
		ram[14] = { ~7'd0, 37'd0 };
		ram[15] = { ~7'd0, 37'd0 };
		ram[16] = { ~7'd0, 37'd0 };
		ram[17] = { ~7'd0, 37'd0 };
		ram[18] = { ~7'd0, 37'd0 };
		ram[19] = { ~7'd0, 37'd0 };
		ram[20] = { ~7'd0, 37'd0 };
		ram[21] = { ~7'd0, 37'd0 };
		ram[22] = { ~7'd0, 37'd0 };
		ram[23] = { ~7'd0, 37'd0 };
		ram[24] = { ~7'd0, 37'd0 };
		ram[25] = { ~7'd0, 37'd0 };
		ram[26] = { ~7'd0, 37'd0 };
		ram[27] = { ~7'd0, 37'd0 };
		ram[28] = { ~7'd0, 37'd0 };
		ram[29] = { ~7'd0, 37'd0 };
		ram[30] = { ~7'd0, 37'd0 };
		ram[31] = { ~7'd0, 37'd0 };
	end

	always @ (posedge clk) if(clk_en) begin
		q <= ram[rd_addr];
		ram[wr_addr] <= data;
	end

endmodule
