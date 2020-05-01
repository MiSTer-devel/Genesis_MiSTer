library IEEE;
use IEEE.std_logic_1164.all;

package jt89 is 

component jt89
port
(
    rst        : in  std_logic;
    clk        : in  std_logic;         -- CPU clock
    clk_en     : in  std_logic := '1';  -- optional clock enable, if not needed leave as '1'
    din        : in  std_logic_vector(7 downto 0);
    wr_n       : in  std_logic;
    ready      : out std_logic;
    sound      : out std_logic_vector(10 downto 0) -- signed
);
end component;

end;
