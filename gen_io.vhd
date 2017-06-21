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

-- gen-hw.txt from line 416
entity gen_io is
	port(
		RST_N		: in std_logic;
		CLK		: in std_logic;
		
		P1_UP		: in std_logic;
		P1_DOWN	: in std_logic;
		P1_LEFT	: in std_logic;
		P1_RIGHT	: in std_logic;
		P1_A		: in std_logic;
		P1_B		: in std_logic;
		P1_C		: in std_logic;
		P1_START	: in std_logic;

		P2_UP		: in std_logic;
		P2_DOWN	: in std_logic;
		P2_LEFT	: in std_logic;
		P2_RIGHT	: in std_logic;
		P2_A		: in std_logic;
		P2_B		: in std_logic;
		P2_C		: in std_logic;
		P2_START	: in std_logic;

		SEL		: in std_logic;
		A			: in std_logic_vector(4 downto 0);
		RNW		: in std_logic;
		UDS_N		: in std_logic;
		LDS_N		: in std_logic;
		DI			: in std_logic_vector(15 downto 0);
		DO			: out std_logic_vector(15 downto 0);
		DTACK_N	: out std_logic		
	);
end gen_io;
architecture rtl of gen_io is
signal FF_DTACK_N	: std_logic;

signal VERS			: std_logic_vector(7 downto 0);
signal DATA			: std_logic_vector(7 downto 0);
signal DATB			: std_logic_vector(7 downto 0);
signal DATC			: std_logic_vector(7 downto 0);
signal CTLA			: std_logic_vector(7 downto 0);
signal CTLB			: std_logic_vector(7 downto 0);
signal CTLC			: std_logic_vector(7 downto 0);
signal TXDA			: std_logic_vector(7 downto 0);
signal TXDB			: std_logic_vector(7 downto 0);
signal TXDC			: std_logic_vector(7 downto 0);
signal RXDA			: std_logic_vector(7 downto 0);
signal RXDB			: std_logic_vector(7 downto 0);
signal RXDC			: std_logic_vector(7 downto 0);
signal SCTA			: std_logic_vector(7 downto 0);
signal SCTB			: std_logic_vector(7 downto 0);
signal SCTC			: std_logic_vector(7 downto 0);

signal REG			: std_logic_vector(3 downto 0);
signal WD		: std_logic_vector(7 downto 0);
signal RD		: std_logic_vector(7 downto 0);


begin

DO <= RD & RD;
DTACK_N <= FF_DTACK_N;

REG <= A(4 downto 1);
WD <= DI(7 downto 0) when LDS_N = '0' else DI(15 downto 8);

process( RST_N, CLK )
begin
	if RST_N = '0' then
		FF_DTACK_N <= '1';
		RD <= (others => '1');

		VERS <= x"A0";

		DATA <= x"7F";
		DATB <= x"7F";
		DATC <= x"7F";

		CTLA <= x"00";
		CTLB <= x"00";
		CTLC <= x"00";

		TXDA <= x"FF";
		RXDA <= x"00";
		SCTA <= x"00";
		
		TXDB <= x"FF";
		RXDB <= x"00";
		SCTB <= x"00";

		TXDC <= x"FF";
		RXDC <= x"00";
		SCTC <= x"00";
		
	elsif rising_edge(CLK) then
		if SEL = '0' then
			FF_DTACK_N <= '1';
		elsif SEL = '1' and FF_DTACK_N = '1' then

			if RNW = '0' then
				-- Write
				case REG is
				when x"0" =>
					VERS <= WD; -- Will be set by OS
				when x"1" =>
					DATA(7) <= WD(7);
					if CTLA(6) = '1' then DATA(6) <= WD(6); end if;
					if CTLA(5) = '1' then DATA(5) <= WD(5); end if;
					if CTLA(4) = '1' then DATA(4) <= WD(4); end if;
					if CTLA(3) = '1' then DATA(3) <= WD(3); end if;
					if CTLA(2) = '1' then DATA(2) <= WD(2); end if;
					if CTLA(1) = '1' then DATA(1) <= WD(1); end if;
					if CTLA(0) = '1' then DATA(0) <= WD(0); end if;
				when x"2" =>
					DATB(7) <= WD(7);
					if CTLB(6) = '1' then DATB(6) <= WD(6); end if;
					if CTLB(5) = '1' then DATB(5) <= WD(5); end if;
					if CTLB(4) = '1' then DATB(4) <= WD(4); end if;
					if CTLB(3) = '1' then DATB(3) <= WD(3); end if;
					if CTLB(2) = '1' then DATB(2) <= WD(2); end if;
					if CTLB(1) = '1' then DATB(1) <= WD(1); end if;
					if CTLB(0) = '1' then DATB(0) <= WD(0); end if;
				when x"3" =>
					DATC(7) <= WD(7);
					if CTLC(6) = '1' then DATC(6) <= WD(6); end if;
					if CTLC(5) = '1' then DATC(5) <= WD(5); end if;
					if CTLC(4) = '1' then DATC(4) <= WD(4); end if;
					if CTLC(3) = '1' then DATC(3) <= WD(3); end if;
					if CTLC(2) = '1' then DATC(2) <= WD(2); end if;
					if CTLC(1) = '1' then DATC(1) <= WD(1); end if;
					if CTLC(0) = '1' then DATC(0) <= WD(0); end if;
				when x"4" =>
					CTLA <= WD;
				when x"5" =>
					CTLB <= WD;
				when x"6" =>
					CTLC <= WD;
				when x"7" =>
					TXDA <= WD;
				when x"8" =>
					RXDA <= WD;
				when x"9" =>
					SCTA <= WD;
				when x"A" =>
					TXDB <= WD;
				when x"B" =>
					RXDB <= WD;
				when x"C" =>
					SCTB <= WD;
				when x"D" =>
					TXDC <= WD;
				when x"E" =>
					RXDC <= WD;
				when x"F" =>
					SCTC <= WD;					
				when others => null;
				end case;
			else
				case REG is
				when x"0" =>
					RD <= VERS;
				when x"1" =>
					RD <= DATA;
					if DATA(6) = '0' then -- 3-button pad
						if CTLA(5) = '0' then RD(5) <= P1_START; end if;
						if CTLA(4) = '0' then RD(4) <= P1_A; end if;
						if CTLA(3) = '0' then RD(3) <= '0'; end if;
						if CTLA(2) = '0' then RD(2) <= '0'; end if;
						if CTLA(1) = '0' then RD(1) <= P1_DOWN; end if;
						if CTLA(0) = '0' then RD(0) <= P1_UP; end if;
					else
						if CTLA(5) = '0' then RD(5) <= P1_C; end if;
						if CTLA(4) = '0' then RD(4) <= P1_B; end if;
						if CTLA(3) = '0' then RD(3) <= P1_RIGHT; end if;
						if CTLA(2) = '0' then RD(2) <= P1_LEFT; end if;
						if CTLA(1) = '0' then RD(1) <= P1_DOWN; end if;
						if CTLA(0) = '0' then RD(0) <= P1_UP; end if;					
					end if;
				when x"2" =>
					RD <= DATB;
					if DATB(6) = '0' then -- 3-button pad
						if CTLB(5) = '0' then RD(5) <= P2_START; end if;
						if CTLB(4) = '0' then RD(4) <= P2_A; end if;
						if CTLB(3) = '0' then RD(3) <= '0'; end if;
						if CTLB(2) = '0' then RD(2) <= '0'; end if;
						if CTLB(1) = '0' then RD(1) <= P2_DOWN; end if;
						if CTLB(0) = '0' then RD(0) <= P2_UP; end if;
					else
						if CTLB(5) = '0' then RD(5) <= P2_C; end if;
						if CTLB(4) = '0' then RD(4) <= P2_B; end if;
						if CTLB(3) = '0' then RD(3) <= P2_RIGHT; end if;
						if CTLB(2) = '0' then RD(2) <= P2_LEFT; end if;
						if CTLB(1) = '0' then RD(1) <= P2_DOWN; end if;
						if CTLB(0) = '0' then RD(0) <= P2_UP; end if;					
					end if;
				when x"3" => -- Unconnected port
					RD <= DATC;
					if CTLC(6) = '0' then RD(6) <= '1'; end if;
					if CTLC(5) = '0' then RD(5) <= '1'; end if;
					if CTLC(4) = '0' then RD(4) <= '1'; end if;
					if CTLC(3) = '0' then RD(3) <= '1'; end if;
					if CTLC(2) = '0' then RD(2) <= '1'; end if;
					if CTLC(1) = '0' then RD(1) <= '1'; end if;
					if CTLC(0) = '0' then RD(0) <= '1'; end if;
				when x"4" =>
					RD <= CTLA;
				when x"5" =>
					RD <= CTLB;
				when x"6" =>
					RD <= CTLC;
				when x"7" =>
					RD <= TXDA;
				when x"8" =>
					RD <= RXDA;
				when x"9" =>
					RD <= SCTA;
				when x"A" =>
					RD <= TXDB;
				when x"B" =>
					RD <= RXDB;
				when x"C" =>
					RD <= SCTB;
				when x"D" =>
					RD <= TXDC;
				when x"E" =>
					RD <= RXDC;
				when x"F" =>
					RD <= SCTC;
				when others => null;
				end case;
			end if;
			
			FF_DTACK_N <= '0';
		end if;
	end if;
end process;

end rtl;
