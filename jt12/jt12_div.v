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
    Date: 14-2-2017
    */

`timescale 1ns / 1ps

module jt12_div(
    input           rst,
    input           clk,
    input           cen,
    input   [1:0]   div_setting,
    output  reg     clk_en,
    output  reg     clk_en_ssg
);

parameter use_ssg=0;

reg [2:0] opn_pres, ssg_pres;
reg [2:0] opn_cnt, ssg_cnt;
reg cen_int, cen_ssg_int;

always @(*)
    casez( div_setting )
        2'b0?: { opn_pres, ssg_pres } = { 3'd1, 3'd0 };
        2'b10: { opn_pres, ssg_pres } = { 3'd5, 3'd3 };
        2'b11: { opn_pres, ssg_pres } = { 3'd2, 3'd1 };
    endcase // div_setting


always @(negedge clk) begin
    cen_int     <= opn_cnt == 3'd0;
    cen_ssg_int <= ssg_cnt == 3'd0;
    `ifdef FASTDIV
    // always enabled for fast sims (use with GYM output, timer will not work well)
    clk_en <= 1'b1;
    clk_en_ssg <= 1'b1;
    `else
    clk_en      <= cen & cen_int;   
    clk_en_ssg  <= use_ssg ? (cen & cen_ssg_int) : 1'b0;
    `endif
end

// OPN
always @(posedge clk)
    if( cen ) begin
        if( opn_cnt == opn_pres ) begin
            opn_cnt <= 3'd0;            
        end
        else opn_cnt <= opn_cnt + 3'd1;
    end

// SSG
always @(posedge clk)
    if( cen ) begin
        if( ssg_cnt == ssg_pres ) begin
            ssg_cnt <= 3'd0;            
        end
        else ssg_cnt <= ssg_cnt + 3'd1;
    end

endmodule // jt12_div
