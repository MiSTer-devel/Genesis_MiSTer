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

	Based on information provided by
		Sauraen VHDL version of OPN/OPN2, which is based on die shots.
		Nemesis reports, based on measurements
		Comparisons with real hardware lent by Mikes (Va de retro)

	Author: Jose Tejada Gomez. Twitter: @topapate
	Version: 1.0
	Date: 1-4-2017
	
	Use tab = 4 spaces

*/

// syn_clk "1.285714"

module jt12(
	input			rst,
	// CPU interface
	input			cpu_clk,
	input	[7:0]	cpu_din,
	input	[1:0]	cpu_addr,
	input			cpu_cs_n,
	input			cpu_wr_n,
	input			cpu_limiter_en,

	output	[7:0]	cpu_dout,
	output			cpu_irq_n,
	// Synthesizer clock domain
	input			syn_clk,
	// combined output
	output	signed	[11:0]	syn_snd_right,
	output	signed	[11:0]	syn_snd_left,
	output			syn_snd_sample,
	// multiplexed output
	output signed	[8:0]	syn_mux_right,	
	output signed	[8:0]	syn_mux_left,
	output			syn_mux_sample
);

// Timers
wire	syn_flag_A, syn_flag_B;


wire	[7:0]	syn_din;
wire	[1:0]	syn_addr;
wire	syn_write, syn_limiter_en, syn_busy;
wire	syn_rst, syn_irq_n;

jt12_clksync u_clksync(
	.rst		( rst		),
	.cpu_clk	( cpu_clk	),
	.syn_clk	( syn_clk	),

	// CPU interface	
	.cpu_din	( cpu_din	),
	.cpu_addr	( cpu_addr	),
	.cpu_dout	( cpu_dout	),
	.cpu_cs_n	( cpu_cs_n	),
	.cpu_wr_n	( cpu_wr_n	),
	.cpu_irq_n	( cpu_irq_n	),
	.cpu_limiter_en( cpu_limiter_en ),
	
	// Synthesizer interface
	.syn_rst	( syn_rst	),
	.syn_write	( syn_write	),
	.syn_din	( syn_din	),
	.syn_addr	( syn_addr	),	
	.syn_limiter_en( syn_limiter_en ),
	
	.syn_busy	( syn_busy	),
	.syn_flag_A	( syn_flag_A),
	.syn_flag_B	( syn_flag_B),
	.syn_irq_n	( syn_irq_n	)
);

jt12_syn u_syn(
	.rst		( syn_rst	),
	.clk		( syn_clk	),
	.din		( syn_din	),
	.addr		( syn_addr	),
	.busy		( syn_busy	),
	.flag_A		( syn_flag_A),
	.flag_B		( syn_flag_B),
	.write		( syn_write	),
	.limiter_en	( syn_limiter_en),
	.irq_n		( syn_irq_n	),
	// Mixed sound
	.snd_right	( syn_snd_right	),
	.snd_left	( syn_snd_left	),
	.snd_sample	( syn_snd_sample),
	// Multiplexed sound
	.mux_right	( syn_mux_right	),
	.mux_left	( syn_mux_left	),
	.mux_sample	( syn_mux_sample)
);

endmodule
