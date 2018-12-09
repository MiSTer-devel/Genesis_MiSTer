/*  This file is part of JT89.

    JT89 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT89 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT89.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: December, 1st 2018
    
    This work was originally based in the implementation found on the
    SMS core of MiST
    
    */

module jt89_vol(
    input         clk,
    input         clk_en,
    input         rst,
    input         din,
    input  [3:0]  vol,
    output reg [8:0]  snd   
);


reg [8:0] max;

always @(*)
    case ( vol ) // 2dB per LSB (20*log10)
        4'd0:  max = 9'd511;
        4'd1:  max = 9'd406;
        4'd2:  max = 9'd322;
        4'd3:  max = 9'd256;
        4'd4:  max = 9'd203;
        4'd5:  max = 9'd162;
        4'd6:  max = 9'd128;
        4'd7:  max = 9'd102;
        4'd8:  max = 9'd81;
        4'd9:  max = 9'd64;
        4'd10: max = 9'd51;
        4'd11: max = 9'd41;
        4'd12: max = 9'd32;
        4'd13: max = 9'd26;
        4'd14: max = 9'd20;
        4'd15: max = 9'd0;
    endcase

always @(posedge clk)
    if( rst )
        snd <= 9'd0;
    else if( clk_en )
        snd <= din ? max : 9'd0;

endmodule