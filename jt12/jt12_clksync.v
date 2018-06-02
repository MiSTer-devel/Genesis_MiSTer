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
	output	[7:0]	cpu_dout,
	input			cpu_cs_n,
	input			cpu_wr_n,
	output			cpu_irq_n,
	input			cpu_limiter_en,
	
	// Synthesizer interface
	output	 [7:0]	syn_din,
	output	 [1:0]	syn_addr,
	output	reg		syn_rst,
	output			syn_write,
	output			syn_limiter_en,

	input			syn_busy,
	input			syn_flag_A,
	input			syn_flag_B,
	input			syn_irq_n
);

// reset generation
reg rst_aux;

	
always @(negedge syn_clk or posedge rst) 
	if( rst ) begin
		syn_rst <= 1'b1;
		rst_aux <= 1'b1;
	end
	else begin
		syn_rst <= rst_aux;
		rst_aux <= 1'b0;
	end

reg		cpu_busy;
wire	cpu_flag_B, cpu_flag_A;

assign 	cpu_dout = { cpu_busy, 5'h0, cpu_flag_B, cpu_flag_A };
/*
always @(posedge clk ) 
	
*/
//assign	write = !cs_n && !wr_n;

wire		write_raw = !cpu_cs_n && !cpu_wr_n;

reg	[7:0]	din_copy;
reg	[1:0]	addr_copy;
reg			write_copy;

/* DIN & ADDR do not need synchronizers because there
is a handshake protocol using the write and busy signals*/
assign syn_din = din_copy;
assign syn_addr= addr_copy;

reg aux_irq_n;

reg [1:0]busy_sh;
always @(posedge cpu_clk) begin
	busy_sh <= { busy_sh[0], syn_busy };
end

jt12_sh #(.width(3),.stages(2) ) u_syn2cpu(
	.clk	( cpu_clk ),
	.din	( { syn_flag_B, syn_flag_A, syn_irq_n } ),
	.drop	( { cpu_flag_B, cpu_flag_A, cpu_irq_n } )
);

jt12_sh #(.width(2),.stages(2) ) u_cpu2syn(
	.clk	( syn_clk ),
	.din	( { write_copy, cpu_limiter_en } ),
	.drop	( { syn_write,  syn_limiter_en } )
);

always @(posedge cpu_clk) begin : cpu_interface
	if( rst ) begin
		cpu_busy	<= 1'b0;
		write_copy	<= 1'b0;
	end
	else begin
		if( write_raw && !cpu_busy ) begin
			cpu_busy 	<= 1'b1;
			write_copy	<= 1'b1;
			addr_copy	<= cpu_addr;
			din_copy	<= cpu_din;
		end
		else begin
			if( busy_sh[1] ) write_copy	<= 1'b0;
			if( cpu_busy && busy_sh==2'b10 ) cpu_busy <= 1'b0;
		end
	end
end

endmodule
