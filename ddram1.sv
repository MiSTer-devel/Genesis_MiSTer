//
// ddram.v
//
// DE10-nano DDR3 memory interface for FPGAGen
//
// Copyright (c) 2017 Sorgelig
//
//
// This source file is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version. 
//
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of 
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License 
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
// ------------------------------------------
//

// 8-bit version

module ddram
(
	input         DDRAM_CLK,

	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	input         reset,

   input  [27:0] wraddr,
   input  [15:0] din,
   input         we_req,
   output reg    we_ack,

   input  [27:0] rdaddr,
   output [63:0] dout,
   input         rd_req,
   output reg    rd_ack
);

assign DDRAM_BURSTCNT = 1;
assign DDRAM_BE       = (8'd3<<{ram_address[2:1],1'b0}) | {8{ram_read}};
assign DDRAM_ADDR     = {4'b0011, ram_address[27:3]}; // RAM at 0x30000000
assign DDRAM_RD       = ram_read;
assign DDRAM_DIN      = ram_data;
assign DDRAM_WE       = ram_write;

assign dout           = ram_q;

reg [63:0] ram_q;
reg [63:0] ram_data;
reg [27:0] ram_address;
reg        ram_read;
reg        ram_write;

reg [1:0]  state  = 0;

always @(posedge DDRAM_CLK)
begin
	reg old_rd, old_we;

	if(reset)
	begin
		state  <= 0;
		rd_ack <= 0;
		we_ack <= 0;
		ram_write <= 0;
		ram_read  <= 0;
	end
	else
	if(!DDRAM_BUSY)
	begin
		ram_write <= 0;
		ram_read  <= 0;

		case(state)
		 3,0: if(we_ack != we_req)
				begin
					ram_data		<= {4{din}};
					ram_address <= wraddr;
					ram_write 	<= 1;
					state       <= 1;
				end
				else
				if(rd_ack != rd_req)
				begin
					ram_address <= rdaddr;
					ram_read    <= 1;
					state       <= 2;
				end

			1: begin
					we_ack <= we_req;
					state  <= 0;
				end
		
			2: if(DDRAM_DOUT_READY)
				begin
					ram_q  <= DDRAM_DOUT;
					rd_ack <= rd_req;
					state  <= 0;
				end
		endcase
	end
end


endmodule
