library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity os_rom is
	port(
		A 		: in std_logic_vector(7 downto 0);
		OEn		: in std_logic;
		D		: out std_logic_vector(15 downto 0)
	);
end os_rom;

architecture rtl of os_rom is
begin
	process(OEn, A)
	begin
		if OEn = '0' then
			case A is
when x"00" => D <= x"1337";
when x"01" => D <= x"b00b";
when x"02" => D <= x"0000";
when x"03" => D <= x"0008";
when x"04" => D <= x"46fc";
when x"05" => D <= x"2700";
when x"06" => D <= x"7000";
when x"07" => D <= x"2200";
when x"08" => D <= x"2400";
when x"09" => D <= x"2600";
when x"0A" => D <= x"2800";
when x"0B" => D <= x"2a00";
when x"0C" => D <= x"2c00";
when x"0D" => D <= x"2e00";
when x"0E" => D <= x"2040";
when x"0F" => D <= x"2240";
when x"10" => D <= x"2440";
when x"11" => D <= x"2640";
when x"12" => D <= x"2840";
when x"13" => D <= x"2a40";
when x"14" => D <= x"2c40";
when x"15" => D <= x"4e66";
when x"16" => D <= x"41fa";
when x"17" => D <= x"0022";
when x"18" => D <= x"43f8";
when x"19" => D <= x"ff00";
when x"1A" => D <= x"203c";
when x"1B" => D <= x"0000";
when x"1C" => D <= x"00aa";
when x"1D" => D <= x"223c";
when x"1E" => D <= x"0000";
when x"1F" => D <= x"0050";
when x"20" => D <= x"9081";
when x"21" => D <= x"32d8";
when x"22" => D <= x"5540";
when x"23" => D <= x"6600";
when x"24" => D <= x"fffa";
when x"25" => D <= x"41f8";
when x"26" => D <= x"ff00";
when x"27" => D <= x"4ed0";
when x"28" => D <= x"41f9";
when x"29" => D <= x"00a1";
when x"2A" => D <= x"4100";
when x"2B" => D <= x"30bc";
when x"2C" => D <= x"0001";
when x"2D" => D <= x"41f8";
when x"2E" => D <= x"01f0";
when x"2F" => D <= x"1010";
when x"30" => D <= x"0c00";
when x"31" => D <= x"004a";
when x"32" => D <= x"6700";
when x"33" => D <= x"0022";
when x"34" => D <= x"0c00";
when x"35" => D <= x"0045";
when x"36" => D <= x"6700";
when x"37" => D <= x"0022";
when x"38" => D <= x"0c00";
when x"39" => D <= x"0041";
when x"3A" => D <= x"6700";
when x"3B" => D <= x"001a";
when x"3C" => D <= x"0c00";
when x"3D" => D <= x"0042";
when x"3E" => D <= x"6700";
when x"3F" => D <= x"0012";
when x"40" => D <= x"103c";
when x"41" => D <= x"00a0";
when x"42" => D <= x"6000";
when x"43" => D <= x"000e";
when x"44" => D <= x"103c";
when x"45" => D <= x"0020";
when x"46" => D <= x"6000";
when x"47" => D <= x"0006";
when x"48" => D <= x"103c";
when x"49" => D <= x"00e0";
when x"4A" => D <= x"41f9";
when x"4B" => D <= x"00a1";
when x"4C" => D <= x"0001";
when x"4D" => D <= x"1080";
when x"4E" => D <= x"41f8";
when x"4F" => D <= x"0000";
when x"50" => D <= x"2e50";
when x"51" => D <= x"41f8";
when x"52" => D <= x"0004";
when x"53" => D <= x"2050";
when x"54" => D <= x"4ed0";
when x"55" => D <= x"0000";
when x"56" => D <= x"0000";
when x"57" => D <= x"0000";
when x"58" => D <= x"0000";
when x"59" => D <= x"0000";
when x"5A" => D <= x"0000";
when x"5B" => D <= x"0000";
when x"5C" => D <= x"0000";
when x"5D" => D <= x"0000";
when x"5E" => D <= x"4e75";
when x"5F" => D <= x"4e75";
when others => D <= x"ffff";
			end case;
		else
			D <= (others => 'Z');
		end if;
	end process;

end rtl;
