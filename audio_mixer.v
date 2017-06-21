
module audio_mixer
(
	//input	               clk,
	input	 signed [11:0] left_in,
	input	 signed [11:0] right_in,
	input	         [5:0] psg,

	output signed [15:0] left_out,
	output signed [15:0] right_out
);

assign left_out  = { left_in[11],  left_in, 3'b000} + {1'b0, psg, 5'b00000};
assign right_out = {right_in[11], right_in, 3'b000} + {1'b0, psg, 5'b00000};

endmodule
