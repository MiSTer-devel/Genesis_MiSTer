

module keyboard
(
	input  clk,
	input  reset,
	input  ps2_kbd_clk,
	input  ps2_kbd_data,

	output reg[7:0] joystick,
	output reg      joy_num
);

reg [11:0] shift_reg = 12'hFFF;
wire[11:0] kdata = {ps2_kbd_data,shift_reg[11:1]};
wire [7:0] kcode = kdata[9:2];
reg        release_btn = 0;

reg  [7:0] code;
reg        input_strobe = 0;

always @(negedge clk) begin
	reg old_reset = 0;

	old_reset <= reset;

	if(~old_reset & reset)begin
		joystick <= 0;
		joy_num  <= 0;
	end

	if(input_strobe) begin
		case(code)
			'h16: if(~release_btn) joy_num <= 0; // 1
			'h1E: if(~release_btn) joy_num <= 1; // 2

			'h75: joystick[3] <= ~release_btn; // arrow up
			'h72: joystick[2] <= ~release_btn; // arrow down
			'h6B: joystick[1] <= ~release_btn; // arrow left
			'h74: joystick[0] <= ~release_btn; // arrow right

			'h29: joystick[4] <= ~release_btn; // Space
			'h11: joystick[5] <= ~release_btn; // Left Alt
			'h0d: joystick[6] <= ~release_btn; // Tab
			'h76: joystick[7] <= ~release_btn; // Escape
		endcase
	end
end

always @(posedge clk) begin
	reg [3:0] prev_clk  = 0;
	reg       old_reset = 0;
	reg       action = 0;

	old_reset <= reset;
	input_strobe <= 0;

	if(~old_reset & reset)begin
		prev_clk  <= 0;
		shift_reg <= 12'hFFF;
	end else begin
		prev_clk <= {ps2_kbd_clk,prev_clk[3:1]};
		if(prev_clk == 1) begin
			if (kdata[11] & ^kdata[10:2] & ~kdata[1] & kdata[0]) begin
				shift_reg <= 12'hFFF;
				if (kcode == 8'he0) ;
				// Extended key code follows
				else if (kcode == 8'hf0)
					// Release code follows
					action <= 1;
				else begin
					// Cancel extended/release flags for next time
					action <= 0;
					release_btn <= action;
					code <= kcode;
					input_strobe <= 1;
				end
			end else begin
				shift_reg <= kdata;
			end
		end
	end
end
endmodule
