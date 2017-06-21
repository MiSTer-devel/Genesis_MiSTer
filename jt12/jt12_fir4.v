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
	Date: March, 7th 2017
	*/

`timescale 1ns / 1ps

module jt12_fir4
#(parameter data_width=9, extra=3)
(
	input	clk,	// Use clk_out from jt12, this is x24 higher than
	input	rst,
	input	sample,
	input	signed [data_width-1:0] left_in,
	input	signed [data_width-1:0] right_in,
	output	reg signed [data_width*2+1:0] left_out,
	output	reg signed [data_width*2+1:0] right_out,
	output	reg sample_out
);

localparam coeff_width=9;
localparam stages=11;

reg signed [coeff_width-1:0] coeff[0:(stages-1)/2];
reg signed [11:0] chain_left[0:stages-1];
reg signed [11:0] chain_right[0:stages-1];

// shift register
genvar i;
generate
	for (i=0; i < stages; i=i+1) begin: bit_shifter
		always @(posedge clk)
			if( sample )
				if(i>0) begin
					chain_left[i] <= chain_left[i-1];
					chain_right[i] <= chain_right[i-1];
				end
				else begin
					chain_left[0] <= left_in;
					chain_right[0] <= right_in;
				end
	end
endgenerate

localparam mac_width=data_width+coeff_width+1;
localparam acc_width=mac_width+2;
reg	signed [acc_width-1:0] acc;
reg signed [mac_width-1:0] mac;
//integer acc,mac;
reg [5:0] 	cnt;
reg [6:0]   rev;
reg	[1:0]	state;

localparam IDLE=2'b00, LEFT=2'b01, RIGHT=2'b10;

reg signed [data_width:0] sum;

wire last_stage = cnt==(stages-1)/2;

//integer a,b;

always @(*) begin
	if( state==LEFT)
		sum <= chain_left[cnt] +
				( last_stage ? {data_width{1'b0}}:chain_left[rev]);
	else
		sum <= chain_right[cnt] +
				( last_stage ? {data_width{1'b0}}:chain_right[rev]);	
	mac <= coeff[cnt]*sum;
end

always @(posedge clk)
if( rst ) begin
	cnt <= 6'd0;
	rev <= 6'd0;
	acc <= {acc_width{1'b0}};
	left_out<= {data_width+extra{1'b0}};
	right_out<= {data_width+extra{1'b0}};
	sample_out <= 1'b0;
	state	<= IDLE;
end else begin
	case(state)
		default: begin
			if( sample ) begin
				cnt <= 6'd0;
				rev <= stages-1'd1;
				acc <= {acc_width{1'b0}};
				state <= LEFT;
			end
			sample_out <= 1'b0;
		end
		LEFT: begin
				if( cnt==(stages-1)/2 ) begin
					cnt <= 6'd0;
					rev <= stages-1'd1;
					acc <= {acc_width{1'b0}};
					left_out <= acc+mac;
					state <= RIGHT;
				end
				else begin
					acc <= acc + mac;
					cnt<=cnt+1'b1;
					rev<=rev-1'b1;
				end
			end
		RIGHT: begin
				if( cnt==(stages-1)/2 ) begin
					cnt <= 6'd0;
					rev <= stages-1'd1;
					acc <= {acc_width{1'b0}};
					right_out <= acc+mac;
					sample_out <= 1'b1;
					state <= IDLE;
				end
				else begin
					acc <= acc + mac;
					cnt<=cnt+1'b1;
					rev<=rev-1'b1;
				end
			end
	endcase
end


initial begin
        coeff[0] <= 9'd19;
        coeff[1] <= 9'd42;
        coeff[2] <= 9'd100;
        coeff[3] <= 9'd172;
        coeff[4] <= 9'd232;
        coeff[5] <= 9'd255;
end

endmodule
