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
	Date: March, 10th 2017
	*/

/* Limiting amplifier by 3dB * shift */

`timescale 1ns / 1ps

module jt12_limitamp #( parameter width=20, shift=5 ) (
	input signed [width-1:0] left_in,
	input signed [width-1:0] right_in,
	output reg signed [width-1:0] left_out,
	output reg signed [width-1:0] right_out
);

always @(*) begin
	left_out = ^left_in[width-1:width-1-shift] ?
		{ left_in[width-1], {(width-1){~left_in[width-1]}}} :
		left_in <<< shift;

	right_out = ^right_in[width-1:width-1-shift] ?
		{ right_in[width-1], {(width-1){~right_in[width-1]}}} :
		right_in <<< shift;
end

endmodule
