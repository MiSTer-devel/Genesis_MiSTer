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

entity flash_sim is
	generic(
		INIT_FILE	:	string := "main.txt"
	);
	port(
		A 		: in std_logic_vector(21 downto 0);
		OEn		: in std_logic;
		D		: out std_logic_vector(7 downto 0)
	);
end flash_sim;

architecture sim of flash_sim is
begin
	process(OEn, A)
		file F		: text open read_mode is INIT_FILE;
		variable L	: line;
		variable V	: std_logic_vector(7 downto 0);
		variable init_done : std_logic := '0';
		type memory is array(natural range <>) of std_logic_vector(7 downto 0);
		variable RAMEXT : memory(0 to 2**22 - 1) := (others => x"ff");
	begin
		if init_done = '0' then
			for i in 0 to 4194303 loop     
				exit when endfile(F); 
				readline(F,L);  
				hread(L,V);
				RAMEXT(i) := V;
			end loop;
			init_done := '1';
		end if;

		if OEn = '0' then
			D <= RAMEXT(conv_integer(to_x01(A)));
		else
			D <= "ZZZZZZZZ";
		end if;
	end process;
end sim;


