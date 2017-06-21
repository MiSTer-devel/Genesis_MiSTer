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

module jt12_sumch
(	
	input		[4:0] chin,
   	output reg 	[4:0] chout
);

reg [2:0] aux;

always @(*) begin
	aux <= chin[2:0] + 3'd1;
	chout[2:0] <= aux[1:0]==2'b11 ? aux+3'd1 : aux;
	chout[4:3] <= chin[2:0]==3'd6 ? chin[4:3]+2'd1 : chin[4:3];
end

endmodule
