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
	Date: 14-10-2018
	*/

`timescale 1ns / 1ps

// This implementation follows that of Alexey Khokholov (Nuke.YKT) in C language.

module jt12_pm (
	input [4:0] lfo_mod,
	input [10:0] fnum,
	input [2:0] pms,
	output reg signed [8:0] pm_offset
);


reg [7:0] pm_unsigned;
reg [7:0] pm_base;
reg [9:0] pm_shifted;

wire [2:0] index = lfo_mod[3] ? (~lfo_mod[2:0]) : lfo_mod[2:0];

reg [2:0] lfo_sh1_lut [0:63];
reg [2:0] lfo_sh2_lut [0:63];
reg [2:0] lfo_sh1, lfo_sh2;

initial begin
	$readmemh("lfo_sh1_lut.hex",lfo_sh1_lut);
	$readmemh("lfo_sh2_lut.hex",lfo_sh2_lut);
end

always @(*) begin
	lfo_sh1 = lfo_sh1_lut[{pms,index}];
	lfo_sh2 = lfo_sh2_lut[{pms,index}];
	pm_base = ({1'b0,fnum[10:4]}>>lfo_sh1) + ({1'b0,fnum[10:4]}>>lfo_sh2);
	case( pms )
		default: pm_shifted = { 2'b0, pm_base };
		3'd6: pm_shifted = { 1'b0, pm_base, 1'b0 };
		3'd7: pm_shifted = {       pm_base, 2'b0 };
	endcase // pms
	pm_offset = lfo_mod[4] ? (-{1'b0,pm_shifted[9:2]}) : {1'b0,pm_shifted[9:2]};
end // always @(*)

endmodule
