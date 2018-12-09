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
   
    */

module jt89_mixer #(parameter bw=9)(
    input            rst,
    input            clk,
    input            clk_en,
    input     [bw-1:0] ch0,
    input     [bw-1:0] ch1,
    input     [bw-1:0] ch2,
    input     [bw-1:0] noise,
    output    [bw+1:0] sound
);

reg signed [bw+2:0] a,b,c;
reg signed [bw+1:0] fresh;

always @(*)
    fresh = {2'b0,  ch0} +
            {2'b0,  ch1} +
            {2'b0,  ch2} +
            {2'b0,noise};

assign sound = a[bw+2:1];

// Low pass filter to avoid sharp edges
// settles in 16 clock cycles
always @(posedge clk) 
    if(rst) begin
        a <= {(bw+3){1'b0}};
        b <= {(bw+3){1'b0}};
        c <= {(bw+3){1'b0}};
    end else if(clk_en) begin
        a <= (a + {b[bw+2:1],1'b1})>>1;
        b <= (b + {c[bw+2:1],1'b1})>>1;
        c <= (c + {fresh,  1'b1})>>1;
    end

endmodule