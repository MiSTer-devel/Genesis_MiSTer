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
    Date: 27-1-2017 
    
    Each channel can use the full range of the DAC as they do not
    get summed in the real chip.

    Operator data is summed up without adding extra bits. This is
    the case of real YM3438, which was used on Megadrive 2 models.


*/

/* 
 YM2612 had a limiter to prevent overflow
 YM3438 did not
 JT12 always has a limiter enabled
 */

module jt12_acc(
    input               rst,
    input               clk,
    input               clk_en,
    input               ladder,
    input               channel_en,
    input signed [8:0]  op_result,
    input        [ 1:0] rl,
    input               zero,
    input               s1_enters,
    input               s2_enters,
    input               s3_enters,
    input               s4_enters,
    input               ch6op,
    input   [2:0]       alg,
    input               pcm_en, // only enabled for channel 6
    input   signed [8:0] pcm,
    // combined output
    output reg signed   [15:0]  left,
    output reg signed   [15:0]  right
);

reg sum_en;

always @(*) begin
    case ( alg )
        default: sum_en = s4_enters;
        3'd4: sum_en = s2_enters | s4_enters;
        3'd5,3'd6: sum_en = ~s1_enters;        
        3'd7: sum_en = 1'b1;
    endcase
end

reg pcm_sum;

always @(posedge clk) if(clk_en)
    if( zero ) pcm_sum <= 1'b1;
    else if( ch6op ) pcm_sum <= 1'b0;

wire use_pcm = ch6op && pcm_en;
wire sum_or_pcm = sum_en | use_pcm;
wire signed [8:0] pcm_data = pcm_sum ? pcm : 9'd0;

wire signed [8:0] acc_input = ~channel_en ? 9'd0 : (use_pcm ? pcm_data : op_result);

// Continuous output
wire signed   [8:0]  acc_out;
jt12_single_acc #(.win(9),.wout(9)) u_acc(
    .clk        ( clk            ),
    .clk_en     ( clk_en         ),
    .op_result  ( acc_input      ),
    .sum_en     ( sum_or_pcm     ),
    .zero       ( zero           ),
    .snd        ( acc_out        )
);

wire signed [15:0] acc_expand = {{7{acc_out[8]}}, acc_out};

reg [1:0] rl_latch, rl_old;

wire signed [4:0] ladder_left = ~ladder ? 5'd0 : (acc_expand >= 0 ? 5'd7 : (rl_old[1] ? 5'd0 : -5'd6));
wire signed [4:0] ladder_right = ~ladder ? 5'd0 : (acc_expand >= 0 ? 5'd7 : (rl_old[0] ? 5'd0 : -5'd6));

always @(posedge clk) if(clk_en) begin
    if (channel_en)
        rl_latch <= rl;
    if (zero)
        rl_old <= rl_latch;

    left  <= rl_old[1] ? acc_expand + ladder_left : ladder_left;
    right <= rl_old[0] ? acc_expand + ladder_right : ladder_right;
end

endmodule
