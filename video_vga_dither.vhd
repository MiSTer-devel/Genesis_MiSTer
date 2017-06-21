library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity video_vga_dither is
	generic (
		outbits : integer :=4
	);
	port (
		clk : in std_logic;
		hsync : in std_logic;
		vsync : in std_logic;
		vid_ena : in std_logic;
		iRed : in unsigned(7 downto 0);
		iGreen : in unsigned(7 downto 0);
		iBlue : in unsigned(7 downto 0);
		oRed : out unsigned(outbits-1 downto 0);
		oGreen : out unsigned(outbits-1 downto 0);
		oBlue : out unsigned(outbits-1 downto 0)
	);
end entity;

architecture rtl of video_vga_dither is
	signal field : std_logic := '0';
	signal row : std_logic := '0';
	signal red : unsigned(7 downto 0);
	signal green : unsigned(7 downto 0);
	signal blue : unsigned(7 downto 0);
	signal dither : unsigned(7 downto 0);
	signal ctr : unsigned(2 downto 0);
	signal prevhsync : std_logic :='0';
	signal prevvsync : std_logic :='0';
	signal vid_ena_d : std_logic :='0';
	signal vid_ena_d2 : std_logic :='0';
	constant vidmax : unsigned(7 downto 0) := "11111111";
begin

	oRed <= red(7 downto (8-outbits)) when vid_ena_d='1' else (others=>'0');
	oGreen <= green(7 downto (8-outbits)) when vid_ena_d='1' else (others=>'0');
	oBlue <= blue(7 downto (8-outbits)) when vid_ena_d='1' else (others=>'0');

	process(clk)
	begin
		if rising_edge(clk) then
			ctr <= ctr+1;

			vid_ena_d2<=vid_ena; -- Delay by the same amount as the video itself.
			vid_ena_d<=vid_ena_d2; -- Delay by the same amount as the video itself.

			if prevhsync='0' and hsync='1' then
				row<=not row;
			end if;
			prevhsync<=hsync;

			if prevvsync='0' and vsync='1' then
				field<=not field;
			end if;
			prevvsync<=vsync;

			dither<=(others => '0');
			dither(7-outbits)<=field xor row;
			dither(6-outbits)<=ctr(2) xor row;
		
			if iRed(7 downto (8-outbits))=vidmax(7 downto (8-outbits)) then
				red <= iRed;
			else
				red <= (iRed + dither);
			end if;
			
			if iGreen(7 downto (8-outbits))=vidmax(7 downto (8-outbits)) then
				green <= iGreen;
			else
				green <= (iGreen + dither);
			end if;

			if iBlue(7 downto (8-outbits))=vidmax(7 downto (8-outbits)) then
				blue <= iBlue;
			else
				blue <= (iBlue+ dither);
			end if;
			
		end if;
	end process;
end architecture;
