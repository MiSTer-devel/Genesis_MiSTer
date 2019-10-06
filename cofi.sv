// Composite-like horizontal blending by Kitrinx

module cofi (
	input clk,
	input pix_ce,
	input enable,

	input blank,
	input [7:0] red,
	input [7:0] green,
	input [7:0] blue,

	output [7:0] red_out,
	output [7:0] green_out,
	output [7:0] blue_out
);

	function bit [7:0] color_blend (
		input [7:0] color_prev,
		input [7:0] color_curr,
		input blank_last
	);
	begin
		color_blend = blank_last ? color_curr : (color_prev >> 1) + (color_curr >> 1);
	end
	endfunction

reg blank_last;

reg [7:0] red_last;
reg [7:0] green_last;
reg [7:0] blue_last;

reg [7:0] red_mix;
reg [7:0] green_mix;
reg [7:0] blue_mix;

assign red_out = enable ? red_mix : red;
assign blue_out = enable ? blue_mix : blue;
assign green_out = enable ? green_mix : green;

always @(posedge clk) if (pix_ce) begin
	
	blank_last <= blank;

	red_last <= red;
	blue_last <= blue;
	green_last <= green;

	red_mix <= color_blend(red_last, red, blank_last);
	blue_mix <= color_blend(blue_last, blue, blank_last);
	green_mix <= color_blend(green_last, green, blank_last);
	
end


endmodule