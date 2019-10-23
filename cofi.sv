// Composite-like horizontal blending by Kitrinx

module cofi (
	input        clk,
	input        pix_ce,
	input        enable,

	input        hblank,
	input        vblank,
	input        hs,
	input        vs,
	input  [7:0] red,
	input  [7:0] green,
	input  [7:0] blue,

	output reg       hblank_out,
	output reg       vblank_out,
	output reg       hs_out,
	output reg       vs_out,
	output reg [7:0] red_out,
	output reg [7:0] green_out,
	output reg [7:0] blue_out
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

reg [7:0] red_last;
reg [7:0] green_last;
reg [7:0] blue_last;

always @(posedge clk) if (pix_ce) begin
	
	hblank_out <= hblank;
	vblank_out <= vblank;
	vs_out     <= vs;
	hs_out     <= hs;

	red_last   <= red;
	blue_last  <= blue;
	green_last <= green;

	red_out    <= enable ? color_blend(red_last,   red,   hblank_out) : red;
	blue_out   <= enable ? color_blend(blue_last,  blue,  hblank_out) : blue;
	green_out  <= enable ? color_blend(green_last, green, hblank_out) : green;

end

endmodule
