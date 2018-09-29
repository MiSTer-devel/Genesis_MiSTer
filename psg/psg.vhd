-- Modified from SMS version in MiST:
-- DAC removed
-- Added clock enable
-- Jose Tejada, 26 Feb 2017

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity psg is
	port (
		clk	: in  STD_LOGIC;
		clken	: in  STD_LOGIC;
		reset	: in  STD_LOGIC;
		WR_n	: in  STD_LOGIC;
		D_in	: in  STD_LOGIC_VECTOR(7 downto 0);
		output: out STD_LOGIC_VECTOR(5 downto 0)
	);
end entity;

architecture rtl of psg is

	signal en         : std_logic;
	signal clk_divide	: unsigned(3 downto 0) := "0000";
	signal regn			: std_logic_vector(2 downto 0);
	signal tone0		: std_logic_vector(9 downto 0):="0000100000";
	signal tone1		: std_logic_vector(9 downto 0):="0000100000";
	signal tone2		: std_logic_vector(9 downto 0):="0000100000";
	signal ctrl3		: std_logic_vector(2 downto 0):="100";
	signal volume0		: std_logic_vector(3 downto 0):="1111";
	signal volume1		: std_logic_vector(3 downto 0):="1111";
	signal volume2		: std_logic_vector(3 downto 0):="1111";
	signal volume3		: std_logic_vector(3 downto 0):="1111";
	signal output0		: std_logic_vector(3 downto 0);
	signal output1		: std_logic_vector(3 downto 0);
	signal output2		: std_logic_vector(3 downto 0);
	signal output3		: std_logic_vector(3 downto 0);
	
begin

	t0: work.psg_tone
	port map (
		clk		=> clk,
		clk_en	=> en,
		tone		=> tone0,
		volume	=> volume0,
		output	=> output0);
		
	t1: work.psg_tone
	port map (
		clk		=> clk,
		clk_en	=> en,
		tone		=> tone1,
		volume	=> volume1,
		output	=> output1);
		
	t2: work.psg_tone
	port map (
		clk		=> clk,
		clk_en	=> en,
		tone		=> tone2,
		volume	=> volume2,
		output	=> output2);

	t3: work.psg_noise
	port map (
		clk		=> clk,
		clk_en	=> en,
		style		=> ctrl3,
		tone		=> tone2,
		volume	=> volume3,
		output	=> output3);
		
	process (clk)
	begin
		if rising_edge(clk) then
			en <= '0';
			if clken='1' then
				clk_divide <= clk_divide+1;
				if clk_divide = 0 then
					en <= '1';
				end if;
			end if;
		end if;
	end process;

	process (clk, WR_n)
	begin
		if rising_edge(clk) and WR_n='0' then
			if reset = '1' then
				volume0 <= (others => '1');
				volume1 <= (others => '1');
				volume2 <= (others => '1');
				volume3 <= (others => '1');
				tone0 <= (others => '0');
				tone1 <= (others => '0');
				tone2 <= (others => '0');
				ctrl3 <= (others => '0');
			else
				if D_in(7)='1' then
					case D_in(6 downto 4) is
						when "000" => tone0(3 downto 0) <= D_in(3 downto 0);
						when "010" => tone1(3 downto 0) <= D_in(3 downto 0);
						when "100" => tone2(3 downto 0) <= D_in(3 downto 0);
						when "110" => ctrl3 <= D_in(2 downto 0);
						when "001" => volume0 <= D_in(3 downto 0);
						when "011" => volume1 <= D_in(3 downto 0);
						when "101" => volume2 <= D_in(3 downto 0);
						when "111" => volume3 <= D_in(3 downto 0);
						when others =>
					end case;
					regn <= D_in(6 downto 4);
				else
					case regn is
						when "000" => tone0(9 downto 4) <= D_in(5 downto 0);
						when "010" => tone1(9 downto 4) <= D_in(5 downto 0);
						when "100" => tone2(9 downto 4) <= D_in(5 downto 0);
						when "110" => 
						when "001" => volume0 <= D_in(3 downto 0);
						when "011" => volume1 <= D_in(3 downto 0);
						when "101" => volume2 <= D_in(3 downto 0);
						when "111" => volume3 <= D_in(3 downto 0);
						when others =>
					end case;
				end if;
			end if;
		end if;
	end process;
	
	output <= std_logic_vector(
		  unsigned("00"&output0)
		+ unsigned("00"&output1)
		+ unsigned("00"&output2)
		+ unsigned("00"&output3)
	);

end rtl;
