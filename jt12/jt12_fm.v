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

module jt12_fm(
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

always @(*) begin
	casex( {s1_enters, s3_enters, s2_enters, s4_enters} )
		4'b1xxx: begin // S1
				use_prevprev1 <= 1'b1;
				use_prev2     <= 1'b0;
				use_internal_x<= 1'b0;
                use_internal_y<= 1'b0;
				use_prev1     <= 1'b1;                
			end
		4'b01xx: begin // S3
				use_prevprev1 <= alg_I==3'd5;
				use_prev2     <= (alg_I<=3'd2);
				use_internal_x<= 1'b0;
				use_prev1     <= alg_I==3'd1;                    
    	        use_internal_y<= 1'b0;
				end
		4'b001x: begin  // S2
				use_prevprev1 <= 1'b0;
				use_prev2     <= 1'b0;
				use_internal_x<= 1'b0;
				use_prev1     <= (alg_I==3'd0 || 
					alg_I==3'd3 || alg_I==3'd4 ||
					alg_I==3'd5 || alg_I==3'd6 );
	        	use_internal_y<= 1'b0;
				end
		4'b0001: begin // S4
				use_prevprev1  <= 1'b0;		
				use_prev2      <= ( alg_I==3'd3 );
				use_internal_x <= alg_I==3'd2;
				use_prev1      <= (alg_I==3'd2 || alg_I==3'd5);
                use_internal_y <= ( alg_I<=3'd4 && alg_I!=3'd2);
			end
		default:begin
					use_prevprev1 <= 1'b0;
					use_prev2     <= 1'b0;
					use_internal_x<= 1'b0;
					use_prev1     <= 1'b0;
	                use_internal_y<= 1'b0;
				end
	endcase
end


endmodule
