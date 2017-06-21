-- Copyright (c) 2010 Gregory Estrade (greg@torlus.com)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
library STD;
use STD.TEXTIO.ALL;

entity sram_sim is
	port(
		A 	: in std_logic_vector(17 downto 0);

		OEn	: in std_logic;
		WEn	: in std_logic;			
		CEn	: in std_logic;

		UBn	: in std_logic;
		LBn	: in std_logic;
		
		DQ	: inout std_logic_vector(15 downto 0)
	);
end sram_sim;

architecture sim of sram_sim is
type memory is array(natural range <>) of std_logic_vector(15 downto 0);
signal RAMEXT : memory(0 to 2**18 - 1) := (others => x"ffff");
begin
	
	process(CEn, OEn, WEn, UBn, LBn, A, DQ)
	file F		: text open write_mode is "sram_dbg.out";
	variable L	: line;
	variable logged : std_logic := '0';
	begin
		if CEn = '0' then

			if OEn = '0' and LBn = '0' then
				DQ(7 downto 0) <= RAMEXT(conv_integer(to_x01(A)))(7 downto 0);
			else
				DQ(7 downto 0) <= "ZZZZZZZZ";
			end if;
			if OEn = '0' and UBn = '0' then
				DQ(15 downto 8) <= RAMEXT(conv_integer(to_x01(A)))(15 downto 8);
			else
				DQ(15 downto 8) <= "ZZZZZZZZ";
			end if;
			
			if WEn = '0' and LBn = '0' then
				RAMEXT(conv_integer(to_x01(A)))(7 downto 0) <= DQ(7 downto 0);
			end if;
			if WEn = '0' and UBn = '0' then
				RAMEXT(conv_integer(to_x01(A)))(15 downto 8) <= DQ(15 downto 8);
			end if;

			if WEn = '0' and logged = '0' then
				logged := '1';
				write(L, string'("   VRAM WR ["));
				hwrite(L, x"00" & A(14 downto 0) & '0');
				write(L, string'("] = ["));
				if UBn = '0' and LBn ='1' then 
					hwrite(L, DQ(15 downto 8));
					write(L, string'("  "));
				elsif UBn = '1' and LBn ='0' then 
					write(L, string'("  "));
					hwrite(L, DQ(7 downto 0));				
				elsif UBn = '0' and LBn ='0' then 
					hwrite(L, DQ);
				else
					write(L, string'("????"));
				end if;
				write(L, string'("]"));
				writeline(F,L);		
			end if;

			
		else

			DQ(15 downto 0) <= "ZZZZZZZZZZZZZZZZ";
			logged := '0';

		end if;
	end process;

end sim;

