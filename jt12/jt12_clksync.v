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

	Author: Jose Tejada Gomez. Twitter: @topapate
	Version: 1.0
	Date: 14-2-2017	

*/

module jt12_clksync(
	input			rst,
	input			cpu_clk,
	input			syn_clk,

	// CPU interface	
	input	[7:0]	cpu_din,
	input	[1:0]	cpu_addr,
	output[7:0]	cpu_dout,
	input			cpu_cs_n,
	input			cpu_wr_n,
	output		cpu_irq_n,
	input			cpu_limiter_en,
	
	// Synthesizer interface
	output reg [7:0]	syn_din,
	output reg [1:0]	syn_addr,
	output reg 			syn_rst,
	output reg			syn_write,
	output				syn_limiter_en,

	input			syn_busy,
	input			syn_flag_A,
	input			syn_flag_B,
	input			syn_irq_n
);

// reset generation
reg rst_aux;

assign syn_limiter_en = cpu_limiter_en;

always @(negedge syn_clk or posedge rst) 
	if( rst ) begin
		syn_rst <= 1'b1;
		rst_aux <= 1'b1;
	end
	else begin
		syn_rst <= rst_aux;
		rst_aux <= 1'b0;
	end

reg	 cpu_busy;
assign cpu_dout = cpu_cs_n ? 8'hFF : { cpu_busy, 5'h0, syn_flag_B, syn_flag_A };
assign cpu_irq_n = syn_irq_n;

wire write_raw = !cpu_cs_n && !cpu_wr_n;
always @(posedge cpu_clk) begin
	reg old_write;
	reg old_busy;
	
	old_write <= write_raw;
	old_busy  <= syn_busy;

	if( rst ) cpu_busy	<= 0;
	else begin
		if( ~old_write & write_raw ) begin
			cpu_busy  <= 1;
			syn_write <= ~syn_write;
			syn_addr	 <= cpu_addr;
			syn_din	 <= cpu_din;
		end

		if(cpu_busy & old_busy & ~syn_busy) cpu_busy <= 0;
	end
end

endmodule
