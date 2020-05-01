/*MIT License

Copyright (c) 2019 Gregory Hogan (Soltan_G42)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/

// This module is intended to be used from system.sv to low pass Genesis audio.
// Both Model 1 and Model 2 Genesis models have a global 1st order low-pass
// audio filter. The model 2 has an addition 2nd order low-pass for FM audio

module genesis_lpf(
	input clk,
	input reset,
	input [1:0] lpf_mode,
   input signed [15:0] in,
   output signed [15:0] out);
	
	reg [9:0] div = 504; //For genesis we'll sample at 53.69mhz/504 = 106528 Hz
	
	//Coefficients computed with Octave/Matlab/Online filter calculators.
	//or with scipy.signal.bessel or similar tools
	reg signed [17:0] A2;
	reg signed [17:0] B2;
	reg signed [17:0] B1;
	
	wire signed [15:0] audio_post_lpf1;
		
	always @ (*) begin
		case(lpf_mode[1:0])
			2'b00 : begin //Model 1 Low Pass at 3.1khz with adjusted slope
				A2 = -18'd27504;
				B1 =  18'd10528;
				B2 = -18'd5264;
			end
			2'b01 : begin  //model 2 is measured around 3.96khz
				A2 = -18'sd26328;
				B1 =  18'sd12888;
				B2 = -18'sd6440;
			end
			2'b10  : begin  //8.5khz low pass as a "Minimal" filter.
				A2 = -18'd19088;
				B1 =  18'd6840;
				B2 =  18'd6840;
			end
			default: begin //Space for a 4th filter. This filter is not used
				A2 = -18'sd32768; 
				B1 =  18'sd0; 
				B2 =  18'sd0;
			end
		endcase
	end
	
	iir_1st_order lpf6db(.clk(clk),
								.reset(reset),
								.div(div),
								.A2(A2),
								.B1(B1),
								.B2(B2),
								.in(in),
								.out(audio_post_lpf1)); 
	 
	assign out = ( lpf_mode[1:0] == 2'b11 ) ? in : audio_post_lpf1;

endmodule //genesis_lpf

//This module is intended to be used from system.sv to filter the FM sound before it's mixed with PSG.
//The model 2 genesis has such a filter. The model 1 has only a global low-pass 
module genesis_fm_lpf(
	input clk,
	input reset,
   input signed [15:0] in,
   output signed [15:0] out);

	wire signed [15:0] middle;
	 
	iir_2nd_order fm2(.clk(clk),
							.reset(reset),
							.div(10'd504), //Divider for 106528hz
							.A2(-18'sd24704),
							.A3(18'sd10728),
							.B1(18'sd1083),
							.B2(18'sd1204),
							.B3(18'sd121),
							.in(in),
						.out(out));
endmodule //genesis_fm_lpf