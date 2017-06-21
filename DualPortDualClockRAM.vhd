-- Generic dual-port RAM implementation -
-- will hopefully work for both Altera and Xilinx parts

library ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY DualPortDualClockRAM IS
	GENERIC
	(
		addrbits : integer := 11;
		databits : integer := 18
	);
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (addrbits-1 downto 0);
		address_b		: IN STD_LOGIC_VECTOR (addrbits-1 downto 0);
		clock_a		: IN STD_LOGIC  := '1';
		clock_b		: IN STD_LOGIC  := '1';
		data_a		: IN STD_LOGIC_VECTOR (databits-1 downto 0);
		data_b		: IN STD_LOGIC_VECTOR (databits-1 downto 0);
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		: OUT STD_LOGIC_VECTOR (databits-1 downto 0);
		q_b		: OUT STD_LOGIC_VECTOR (databits-1 downto 0)
	);
END DualPortDualClockRAM;

architecture arch of DualPortDualClockRAM is

type ram_type is array(natural range ((2**addrbits)-1) downto 0) of std_logic_vector(databits-1 downto 0);
shared variable ram : ram_type;

begin

-- Port A
process (clock_a)
begin
	if (clock_a'event and clock_a = '1') then
		if wren_a='1' then
			ram(to_integer(unsigned(address_a))) := data_a;
			q_a <= data_a;
		else
			q_a <= ram(to_integer(unsigned(address_a)));
		end if;
	end if;
end process;

-- Port B
process (clock_b)
begin
	if (clock_b'event and clock_b = '1') then
		if wren_b='1' then
			ram(to_integer(unsigned(address_b))) := data_b;
			q_b <= data_b;
		else
			q_b <= ram(to_integer(unsigned(address_b)));
		end if;
	end if;
end process;


end architecture;
