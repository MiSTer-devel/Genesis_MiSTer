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

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 21-03-2019
*/

module jt10_adpcm_cnt(
    input           rst_n,
    input           clk,        // CPU clock
    input           cen,        // optional clock enable, if not needed leave as 1'b1
    input           div3,
    input   [11:0]  addr_in,
    input           up_start,
    input           up_end,
    input           aon,
    input           aoff,
    output  [19:0]  addr_out,
    output          sel,
    output          roe_n
);

reg [20:0] addr1, addr2, addr3, addr4, addr5, addr6;
reg [11:0] start1, start2, start3, start4, start5, start6,
           end1,   end2,   end3,   end4,   end5,   end6;
reg on1, on2, on3, on4, on5, on6;
reg done5, done6;
reg roe_n6;

reg clr2;

assign addr_out = addr6[20:1];
assign sel      = addr6[0];
assign roe_n    = roe_n6;

wire sumup5 = on5 && !done5 && div3;
reg  sumup6;

always @(posedge clk or negedge rst_n) 
    if( !rst_n ) begin
        addr1  <= 'd0;    addr2 <= 'd0;    addr3 <= 'd0;
        addr4  <= 'd0;    addr5 <= 'd0;    addr6 <= 'd0;
        done5  <= 'd0;
        start1 <= 'd0;   start2 <= 'd0;   start3 <= 'd0;
        start4 <= 'd0;   start5 <= 'd0;   start6 <= 'd0;
        end1   <= 'd0;     end2 <= 'd0;     end3 <= 'd0;
        end4   <= 'd0;     end5 <= 'd0;     end6 <= 'd0;
        roe_n6 <= 'd1;
    end else if( cen ) begin
        addr2  <= addr1;
        on2    <= aoff ? 1'b0 : (aon | on1);
        clr2   <= aon && !on1;
        start2 <= up_start ? addr_in : start1;
        end2   <= up_end   ? addr_in : end1;

        addr3  <= clr2 ? {start2,9'd0} : addr2;
        on3    <= on2;
        start3 <= start2;
        end3   <= end2;

        addr4  <= addr3;
        on4    <= on3;
        start4 <= start3;
        end4   <= end3;

        addr5  <= addr4;
        on5    <= on4;
        done5  <= addr4[20:9] == end4;
        start5 <= start4;
        end5   <= end4;
        // V
        addr6  <= addr5;
        on6    <= on5;
        start6 <= start5;
        end6   <= end5;
        roe_n6 <= !sumup5;
        sumup6 <= sumup5;

        addr1  <= sumup6 ? addr6+21'd1 :addr6;
        on1    <= on6;
        start1 <= start6;
        end1   <= end6;
    end

endmodule // jt10_adpcm_cnt
