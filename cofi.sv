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

	output       hblank_out,
	output       vblank_out,
	output       hs_out,
	output       vs_out,
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

reg [7:0] red_last;
reg [7:0] green_last;
reg [7:0] blue_last;

reg [7:0] red_mix;
reg [7:0] green_mix;
reg [7:0] blue_mix;

assign red_out    = enable ? red_mix    : red;
assign blue_out   = enable ? blue_mix   : blue;
assign green_out  = enable ? green_mix  : green;

reg hblank_mix, vblank_mix, vs_mix, hs_mix;

assign hs_out     = enable ? hs_mix     : hs;
assign vs_out     = enable ? vs_mix     : vs;
assign hblank_out = enable ? hblank_mix : hblank;
assign vblank_out = enable ? vblank_mix : vblank;

always @(posedge clk) if (pix_ce) begin
	
	hblank_mix <= hblank;
	vblank_mix <= vblank;
	vs_mix     <= vs;
	hs_mix     <= hs;

	red_last   <= red;
	blue_last  <= blue;
	green_last <= green;

	red_mix   <= color_blend(red_last,   red,   hblank_mix);
	blue_mix  <= color_blend(blue_last,  blue,  hblank_mix);
	green_mix <= color_blend(green_last, green, hblank_mix);
	
end


endmodule