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

	Based on Sauraen VHDL version of OPN/OPN2, which is based on die shots.

	Author: Jose Tejada Gomez. Twitter: @topapate
	Version: 1.0
	Date: 27-1-2017	

*/


module jt12_op(
	input			rst,
    input			clk,
    input			clk_en,
    input	[9:0]	pg_phase_VIII,
    input	[9:0]	eg_atten_IX,		// output from envelope generator
    input	[2:0]	fb_II,		// voice feedback
	input			use_prevprev1,
	input			use_internal_x,
	input			use_internal_y,    
	input			use_prev2,
	input			use_prev1,
    input			test_214,
	
	input 			s1_enters,
	input 			s2_enters,
	input 			s3_enters,
	input 			s4_enters,
	input			zero,
    
    output	signed [8:0]	op_result
);

/*	enters  exits
	S1		S2
	S3		S4
	S2		S1
	S4		S3
*/

reg [13:0]	op_result_internal, op_XII;
reg [11:0]	atten_internal_IX;

assign op_result = op_result_internal[13:5];

parameter NUM_VOICES = 6;

reg 		signbit_IX, signbit_X, signbit_XI;
reg [11:0]	totalatten_X;

wire [13:0]	prev1, prevprev1, prev2;

jt12_sh #( .width(14), .stages(NUM_VOICES)) prev1_buffer(
//	.rst	( rst	),
	.clk	( clk	),
	.clk_en	( clk_en),
	.din	( s2_enters ? op_result_internal : prev1 ),
	.drop	( prev1	)
);

jt12_sh #( .width(14), .stages(NUM_VOICES)) prevprev1_buffer(
//	.rst	( rst	),
	.clk	( clk	),
	.clk_en	( clk_en),
	.din	( s2_enters ? prev1 : prevprev1 ),
	.drop	( prevprev1	)
);

jt12_sh #( .width(14), .stages(NUM_VOICES)) prev2_buffer(
//	.rst	( rst	),
	.clk	( clk	),
	.clk_en	( clk_en),
	.din	( s1_enters ? op_result_internal : prev2 ),
	.drop	( prev2	)
);


reg [18:0]	stb;
reg [10:0]	stf, stg;
reg [11:0]	logsin;
reg [10:0]	subtresult;

reg [12:0]	etb;
reg [ 9:0]	etf, mantissa_XI;
reg [ 2:0] 	etg;
reg [ 3:0]	exponent_XI;

reg [12:0]	shifter, shifter_2, shifter_3;

// REGISTER/CYCLE 1
// Creation of phase modulation (FM) feedback signal, before shifting
reg [13:0]  x,  y;
reg [14:0]	xs, ys, pm_preshift_II;
reg			s1_II;

always @(*) begin
	x  = ( {14{use_prevprev1}}  & prevprev1 ) |
		  ( {14{use_internal_x}} & op_result_internal ) |
          ( {14{use_prev2}}      & prev2 );
	y  = ( {14{use_prev1}}      & prev1 ) |
		  ( {14{use_internal_y}} & op_result_internal );
	xs = { x[13], x }; // sign-extend
	ys = { y[13], y }; // sign-extend
end

always @(posedge clk) if( clk_en ) begin
	pm_preshift_II <= xs + ys; // carry is discarded
    s1_II <= s1_enters;
end

/* REGISTER/CYCLE 2-7 (also YM2612 extra cycles 1-6)
   Shifting of FM feedback signal, adding phase from PG to FM phase
   In YM2203, phasemod_II is not registered at all, it is latched on the first edge 
   in add_pg_phase and the second edge is the output of add_pg_phase. In the YM2612, there
   are 6 cycles worth of registers between the generated (non-registered) phasemod_II signal
   and the input to add_pg_phase.     */

reg  [9:0]	phasemod_II;
wire [9:0]	phasemod_VIII;

always @(*) begin
	// Shift FM feedback signal
	if (!s1_II ) // Not S1
		phasemod_II = pm_preshift_II[10:1]; // Bit 0 of pm_preshift_II is never used
	else // S1
		case( fb_II )
			3'd0: phasemod_II = 10'd0;		
			3'd1: phasemod_II = { {4{pm_preshift_II[14]}}, pm_preshift_II[14:9] };
			3'd2: phasemod_II = { {3{pm_preshift_II[14]}}, pm_preshift_II[14:8] };
			3'd3: phasemod_II = { {2{pm_preshift_II[14]}}, pm_preshift_II[14:7] };
			3'd4: phasemod_II = {    pm_preshift_II[14],   pm_preshift_II[14:6] };
			3'd5: phasemod_II = pm_preshift_II[14:5];
			3'd6: phasemod_II = pm_preshift_II[13:4];
			3'd7: phasemod_II = pm_preshift_II[12:3];
		endcase
end

// REGISTER/CYCLE 2-7
jt12_sh #( .width(10), .stages(NUM_VOICES)) phasemod_sh(
	.clk	( clk	),
	.clk_en	( clk_en),
	.din	( phasemod_II ),
	.drop	( phasemod_VIII	)
);

// REGISTER/CYCLE 8
reg [ 9:0]	phase;
// Sets the maximum number of fanouts for a register or combinational
// cell.  The Quartus II software will replicate the cell and split
// the fanouts among the duplicates until the fanout of each cell
// is below the maximum.

reg [ 7:0]	phaselo_IX, aux_VIII;

always @(*) begin
	phase	= phasemod_VIII + pg_phase_VIII;
	aux_VIII= phase[7:0] ^ {8{~phase[8]}};
end

always @(posedge clk) if( clk_en ) begin    
	phaselo_IX <= aux_VIII;
	signbit_IX <= phase[9];     

end

wire [45:0] sta_IX;

jt12_phrom u_phrom(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.addr	( aux_VIII[5:1] ),
	.ph		( sta_IX		)
);

// REGISTER/CYCLE 9
// Sine table    
// Main sine table body


always @(*) begin
	//sta_IX <= sinetable[ phaselo_IX[5:1] ];
	// 2-bit row chooser
	case( phaselo_IX[7:6] )
		2'b00: stb = { 10'b0, sta_IX[29], sta_IX[25], 2'b0, sta_IX[18], 
        	sta_IX[14], 1'b0, sta_IX[7] , sta_IX[3] };
		2'b01: stb = { 6'b0 , sta_IX[37], sta_IX[34], 2'b0, sta_IX[28], 
        	sta_IX[24], 2'b0, sta_IX[17], sta_IX[13], sta_IX[10], sta_IX[6], sta_IX[2] };
		2'b10: stb = { 2'b0, sta_IX[43], sta_IX[41], 2'b0, sta_IX[36],
        	sta_IX[33], 2'b0, sta_IX[27], sta_IX[23], 1'b0, sta_IX[20],
            sta_IX[16], sta_IX[12], sta_IX[9], sta_IX[5], sta_IX[1] };
		default: stb = {
			  sta_IX[45], sta_IX[44], sta_IX[42], sta_IX[40]
			, sta_IX[39], sta_IX[38], sta_IX[35], sta_IX[32]
			, sta_IX[31], sta_IX[30], sta_IX[26], sta_IX[22]
			, sta_IX[21], sta_IX[19], sta_IX[15], sta_IX[11]
			, sta_IX[8], sta_IX[4], sta_IX[0] };
	endcase
	// Fixed value to sum
	stf = { stb[18:15], stb[12:11], stb[8:7], stb[4:3], stb[0] };
	// Gated value to sum; bit 14 is indeed used twice
	if( phaselo_IX[0] )
		stg = { 2'b0, stb[14], stb[14:13], stb[10:9], stb[6:5], stb[2:1] };
	else
		stg = 11'd0;
	// Sum to produce final logsin value
	logsin = stf + stg; // Carry-out of 11-bit addition becomes 12th bit
	// Invert-subtract logsin value from EG attenuation value, with inverted carry
	// In the actual chip, the output of the above logsin sum is already inverted.
	// The two LSBs go through inverters (so they're non-inverted); the eg_atten_IX signal goes through inverters.
	// The adder is normal except the carry-in is 1. It's a 10-bit adder.
	// The outputs are inverted outputs, including the carry bit.
	//subtresult = not (('0' & not eg_atten_IX) - ('1' & logsin([11:2])));
	// After a little pencil-and-paper, turns out this is equivalent to a regular adder!
	subtresult = eg_atten_IX + logsin[11:2];
	// Place all but carry bit into result; also two LSBs of logsin
	// If addition overflowed, make it the largest value (saturate)
	atten_internal_IX = { subtresult[9:0], logsin[1:0] } | {12{subtresult[10]}};
end

wire [44:0] exp_X;

jt12_exprom u_exprom(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.addr	( atten_internal_IX[5:1] ),
	.exp	( exp_X		)
);

always @(posedge clk) if( clk_en ) begin
	totalatten_X <= atten_internal_IX;
	signbit_X <= signbit_IX;    
end

//wire [1:0] et_sel  = totalatten_X[7:6];
//wire [4:0] et_fine = totalatten_X[5:1];

// REGISTER/CYCLE 10
// Exponential table
// Main sine table body
always @(*) begin    
	//eta <= explut_jt51[ totalatten_X[5:1] ];	
	// 2-bit row chooser	
	case( totalatten_X[7:6] )
		2'b00: begin
				etf = { 1'b1, exp_X[44:36]  };
				etg = { 1'b1, exp_X[35:34] };				
			end
		2'b01: begin
				etf = exp_X[33:24];
				etg = { 2'b10, exp_X[23] };				
			end
		2'b10: begin
				etf = { 1'b0, exp_X[22:14]  };
				etg = exp_X[13:11];				
			end
		2'b11: begin
				etf = { 2'b00, exp_X[10:3]  };
				etg = exp_X[2:0];
			end

	endcase	
end

always @(posedge clk) if( clk_en ) begin
    //RESULT
	mantissa_XI <= etf + { 7'd0, ( totalatten_X[0] ? 3'd0 : etg )}; //carry-out discarded
	exponent_XI <= totalatten_X[11:8];
	signbit_XI <= signbit_X;     
end

// REGISTER/CYCLE 11
// Introduce test bit as MSB, 2's complement & Carry-out discarded

always @(*) begin    
	// Floating-point to integer, and incorporating sign bit
	// Two-stage shifting of mantissa_XI by exponent_XI
	shifter = { 3'b001, mantissa_XI };
	case( ~exponent_XI[1:0] )
		2'b00: shifter_2 = { 1'b0, shifter[12:1] }; // LSB discarded
		2'b01: shifter_2 = shifter;
		2'b10: shifter_2 = { shifter[11:0], 1'b0 };
		2'b11: shifter_2 = { shifter[10:0], 2'b0 };
	endcase
	case( ~exponent_XI[3:2] )
		2'b00: shifter_3 = {12'b0, shifter_2[12]   };
		2'b01: shifter_3 = { 8'b0, shifter_2[12:8] };
		2'b10: shifter_3 = { 4'b0, shifter_2[12:4] };
		2'b11: shifter_3 = shifter_2;
	endcase
end

always @(posedge clk) if( clk_en ) begin
	// REGISTER CYCLE 11
	op_XII <= ({ test_214, shifter_3 } ^ {14{signbit_XI}}) + signbit_XI;               
	// REGISTER CYCLE 12
	// Extra register, take output after here
    op_result_internal <= op_XII;   
end

`ifdef SIMULATION
reg [4:0] sep24_cnt;

wire signed [13:0] op_ch0s1, op_ch1s1, op_ch2s1, op_ch3s1,
		 op_ch4s1, op_ch5s1, op_ch0s2, op_ch1s2,
		 op_ch2s2, op_ch3s2, op_ch4s2, op_ch5s2,
		 op_ch0s3, op_ch1s3, op_ch2s3, op_ch3s3,
		 op_ch4s3, op_ch5s3, op_ch0s4, op_ch1s4,
		 op_ch2s4, op_ch3s4, op_ch4s4, op_ch5s4;

always @(posedge clk ) if( clk_en ) begin
	sep24_cnt <= !zero ? sep24_cnt+1'b1 : 5'd0;
end

sep24 #( .width(14), .pos0(13)) opsep
(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.mixed	( op_result_internal	),
	.mask	( 24'd0		),
	.cnt	( sep24_cnt	),	
	
	.ch0s1 (op_ch0s1), 
	.ch1s1 (op_ch1s1), 
	.ch2s1 (op_ch2s1), 
	.ch3s1 (op_ch3s1), 
	.ch4s1 (op_ch4s1), 
	.ch5s1 (op_ch5s1), 

	.ch0s2 (op_ch0s2), 
	.ch1s2 (op_ch1s2), 
	.ch2s2 (op_ch2s2), 
	.ch3s2 (op_ch3s2), 
	.ch4s2 (op_ch4s2), 
	.ch5s2 (op_ch5s2), 

	.ch0s3 (op_ch0s3), 
	.ch1s3 (op_ch1s3), 
	.ch2s3 (op_ch2s3), 
	.ch3s3 (op_ch3s3), 
	.ch4s3 (op_ch4s3), 
	.ch5s3 (op_ch5s3), 

	.ch0s4 (op_ch0s4), 
	.ch1s4 (op_ch1s4), 
	.ch2s4 (op_ch2s4), 
	.ch3s4 (op_ch3s4), 
	.ch4s4 (op_ch4s4), 
	.ch5s4 (op_ch5s4)
);

wire signed [8:0] acc_ch0s1, acc_ch1s1, acc_ch2s1, acc_ch3s1,
		 acc_ch4s1, acc_ch5s1, acc_ch0s2, acc_ch1s2,
		 acc_ch2s2, acc_ch3s2, acc_ch4s2, acc_ch5s2,
		 acc_ch0s3, acc_ch1s3, acc_ch2s3, acc_ch3s3,
		 acc_ch4s3, acc_ch5s3, acc_ch0s4, acc_ch1s4,
		 acc_ch2s4, acc_ch3s4, acc_ch4s4, acc_ch5s4;

sep24 #( .width(9), .pos0(13)) accsep
(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.mixed	( op_result_internal[13:5] ),
	.mask	( 24'd0		),
	.cnt	( sep24_cnt	),	
	
	.ch0s1 (acc_ch0s1), 
	.ch1s1 (acc_ch1s1), 
	.ch2s1 (acc_ch2s1), 
	.ch3s1 (acc_ch3s1), 
	.ch4s1 (acc_ch4s1), 
	.ch5s1 (acc_ch5s1), 

	.ch0s2 (acc_ch0s2), 
	.ch1s2 (acc_ch1s2), 
	.ch2s2 (acc_ch2s2), 
	.ch3s2 (acc_ch3s2), 
	.ch4s2 (acc_ch4s2), 
	.ch5s2 (acc_ch5s2), 

	.ch0s3 (acc_ch0s3), 
	.ch1s3 (acc_ch1s3), 
	.ch2s3 (acc_ch2s3), 
	.ch3s3 (acc_ch3s3), 
	.ch4s3 (acc_ch4s3), 
	.ch5s3 (acc_ch5s3), 

	.ch0s4 (acc_ch0s4), 
	.ch1s4 (acc_ch1s4), 
	.ch2s4 (acc_ch2s4), 
	.ch3s4 (acc_ch3s4), 
	.ch4s4 (acc_ch4s4), 
	.ch5s4 (acc_ch5s4)
);

wire signed [9:0] pm_ch0s1, pm_ch1s1, pm_ch2s1, pm_ch3s1,
		 pm_ch4s1, pm_ch5s1, pm_ch0s2, pm_ch1s2,
		 pm_ch2s2, pm_ch3s2, pm_ch4s2, pm_ch5s2,
		 pm_ch0s3, pm_ch1s3, pm_ch2s3, pm_ch3s3,
		 pm_ch4s3, pm_ch5s3, pm_ch0s4, pm_ch1s4,
		 pm_ch2s4, pm_ch3s4, pm_ch4s4, pm_ch5s4;


sep24 #( .width(10), .pos0( 18 ) ) pmsep
(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.mixed	( phasemod_VIII	),
	.mask	( 24'd0		),
	.cnt	( sep24_cnt	),	
	
	.ch0s1 (pm_ch0s1), 
	.ch1s1 (pm_ch1s1), 
	.ch2s1 (pm_ch2s1), 
	.ch3s1 (pm_ch3s1), 
	.ch4s1 (pm_ch4s1), 
	.ch5s1 (pm_ch5s1), 

	.ch0s2 (pm_ch0s2), 
	.ch1s2 (pm_ch1s2), 
	.ch2s2 (pm_ch2s2), 
	.ch3s2 (pm_ch3s2), 
	.ch4s2 (pm_ch4s2), 
	.ch5s2 (pm_ch5s2), 

	.ch0s3 (pm_ch0s3), 
	.ch1s3 (pm_ch1s3), 
	.ch2s3 (pm_ch2s3), 
	.ch3s3 (pm_ch3s3), 
	.ch4s3 (pm_ch4s3), 
	.ch5s3 (pm_ch5s3), 

	.ch0s4 (pm_ch0s4), 
	.ch1s4 (pm_ch1s4), 
	.ch2s4 (pm_ch2s4), 
	.ch3s4 (pm_ch3s4), 
	.ch4s4 (pm_ch4s4), 
	.ch5s4 (pm_ch5s4)
);

wire [9:0] phase_ch0s1, phase_ch1s1, phase_ch2s1, phase_ch3s1,
		 phase_ch4s1, phase_ch5s1, phase_ch0s2, phase_ch1s2,
		 phase_ch2s2, phase_ch3s2, phase_ch4s2, phase_ch5s2,
		 phase_ch0s3, phase_ch1s3, phase_ch2s3, phase_ch3s3,
		 phase_ch4s3, phase_ch5s3, phase_ch0s4, phase_ch1s4,
		 phase_ch2s4, phase_ch3s4, phase_ch4s4, phase_ch5s4;


sep24 #( .width(10), .pos0( 18 ) ) phsep
(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.mixed	( phase		),
	.mask	( 24'd0		),
	.cnt	( sep24_cnt	),	
	
	.ch0s1 (phase_ch0s1), 
	.ch1s1 (phase_ch1s1), 
	.ch2s1 (phase_ch2s1), 
	.ch3s1 (phase_ch3s1), 
	.ch4s1 (phase_ch4s1), 
	.ch5s1 (phase_ch5s1), 

	.ch0s2 (phase_ch0s2), 
	.ch1s2 (phase_ch1s2), 
	.ch2s2 (phase_ch2s2), 
	.ch3s2 (phase_ch3s2), 
	.ch4s2 (phase_ch4s2), 
	.ch5s2 (phase_ch5s2), 

	.ch0s3 (phase_ch0s3), 
	.ch1s3 (phase_ch1s3), 
	.ch2s3 (phase_ch2s3), 
	.ch3s3 (phase_ch3s3), 
	.ch4s3 (phase_ch4s3), 
	.ch5s3 (phase_ch5s3), 

	.ch0s4 (phase_ch0s4), 
	.ch1s4 (phase_ch1s4), 
	.ch2s4 (phase_ch2s4), 
	.ch3s4 (phase_ch3s4), 
	.ch4s4 (phase_ch4s4), 
	.ch5s4 (phase_ch5s4)
);

wire [9:0] eg_ch0s1, eg_ch1s1, eg_ch2s1, eg_ch3s1, eg_ch4s1, eg_ch5s1,
		eg_ch0s2, eg_ch1s2, eg_ch2s2, eg_ch3s2, eg_ch4s2, eg_ch5s2,
		eg_ch0s3, eg_ch1s3, eg_ch2s3, eg_ch3s3, eg_ch4s3, eg_ch5s3,
		eg_ch0s4, eg_ch1s4, eg_ch2s4, eg_ch3s4, eg_ch4s4, eg_ch5s4;


sep24 #( .width(10), .pos0(17) ) egsep
(
	.clk	( clk		),
	.clk_en	( clk_en	),
	.mixed	( eg_atten_IX		),
	.mask	( 24'd0		),
	.cnt	( sep24_cnt	),	
	
	.ch0s1 (eg_ch0s1), 
	.ch1s1 (eg_ch1s1), 
	.ch2s1 (eg_ch2s1), 
	.ch3s1 (eg_ch3s1), 
	.ch4s1 (eg_ch4s1), 
	.ch5s1 (eg_ch5s1), 

	.ch0s2 (eg_ch0s2), 
	.ch1s2 (eg_ch1s2), 
	.ch2s2 (eg_ch2s2), 
	.ch3s2 (eg_ch3s2), 
	.ch4s2 (eg_ch4s2), 
	.ch5s2 (eg_ch5s2), 

	.ch0s3 (eg_ch0s3), 
	.ch1s3 (eg_ch1s3), 
	.ch2s3 (eg_ch2s3), 
	.ch3s3 (eg_ch3s3), 
	.ch4s3 (eg_ch4s3), 
	.ch5s3 (eg_ch5s3), 

	.ch0s4 (eg_ch0s4), 
	.ch1s4 (eg_ch1s4), 
	.ch2s4 (eg_ch2s4), 
	.ch3s4 (eg_ch3s4), 
	.ch4s4 (eg_ch4s4), 
	.ch5s4 (eg_ch5s4)
);

`endif


endmodule
