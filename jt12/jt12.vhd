library IEEE;
use IEEE.std_logic_1164.all;

package jt12 is 

component jt12
port
(
	rst	     : in  std_logic;
	clk        : in  std_logic;         -- CPU clock
	cen        : in  std_logic := '1';  -- optional clock enable, if not needed leave as '1'
	din        : in  std_logic_vector(7 downto 0);
	addr       : in  std_logic_vector(1 downto 0);
	cs_n       : in  std_logic;
	wr_n       : in  std_logic;

	dout       : out std_logic_vector(7 downto 0);
	irq_n      : out std_logic;

	-- combined output
	snd_right  : out std_logic_vector(15 downto 0); -- signed
	snd_left   : out std_logic_vector(15 downto 0); -- signed
	snd_sample : out std_logic
);
end component;

end;
