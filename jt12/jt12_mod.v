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
	Date: 27-1-2017	

*/

module jt12_mod(
	input 		s1_enters,
	input 		s2_enters,
	input 		s3_enters,
	input 		s4_enters,
    
    input [2:0] alg_I,
    
	output reg	use_prevprev1,
	output reg	use_internal_x,
	output reg	use_internal_y,    
	output reg	use_prev2,
	output reg	use_prev1    	
);

reg [7:0] alg_hot;

always @(*) begin
	case( alg_I )
		3'd0: alg_hot = 8'h1;  // D0
		3'd1: alg_hot = 8'h2;  // D1
		3'd2: alg_hot = 8'h4;  // D2
		3'd3: alg_hot = 8'h8;  // D3
		3'd4: alg_hot = 8'h10; // D4
		3'd5: alg_hot = 8'h20; // D5
		3'd6: alg_hot = 8'h40; // D6
		3'd7: alg_hot = 8'h80; // D7
	endcase
end

always @(*) begin
	use_prevprev1 = s1_enters | (s3_enters&alg_hot[5]);
	use_prev2 = (s3_enters&(|alg_hot[2:0])) | (s4_enters&alg_hot[3]);
	use_internal_x = s4_enters & alg_hot[2];
	use_internal_y = s4_enters & (|{alg_hot[4:3],alg_hot[1:0]});
	use_prev1 = s1_enters | (s3_enters&alg_hot[1]) |
		(s2_enters&(|{alg_hot[6:3],alg_hot[0]}) )|
		(s4_enters&(|{alg_hot[5],alg_hot[2]}));
end

endmodule
