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

-- Changed to 8-bit data bus in preparation for integrating JT12 sound chip

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity gen_fm is
	port(
		RST_N		: in std_logic;
		CLK			: in std_logic;
		
		SEL			: in std_logic;
		A			: in std_logic_vector(1 downto 0);
		RNW			: in std_logic;
--		UDS_N		: in std_logic;
--		LDS_N		: in std_logic;
		DI			: in std_logic_vector(7 downto 0);
		DO			: out std_logic_vector(7 downto 0)
--		DTACK_N		: out std_logic		
	);
end gen_fm;

architecture rtl of gen_fm is

signal FF_DTACK_N	: std_logic;

signal STATUS		: std_logic_vector(7 downto 0);
signal TA_OVF		: std_logic;
signal TB_OVF		: std_logic;

signal TA_BASE		: std_logic_vector(9 downto 0);
signal TA_VALUE		: std_logic_vector(9 downto 0);
signal TA_DIV		: std_logic_vector(7 downto 0);
signal TA_LOAD		: std_logic;
signal TA_RESETCLK	: std_logic;
signal TA_EN		: std_logic;

signal TB_BASE		: std_logic_vector(7 downto 0);
signal TB_VALUE		: std_logic_vector(7 downto 0);
signal TB_DIV		: std_logic_vector(11 downto 0);
signal TB_LOAD		: std_logic;
signal TB_RESETCLK	: std_logic;
signal TB_EN		: std_logic;

-- Register address
signal REG			: std_logic_vector(7 downto 0);			

begin

-- DTACK_N <= FF_DTACK_N;

STATUS(6 downto 2) <= "00000";
STATUS(7) <= '0'; -- BUSY flag
STATUS(1) <= TB_OVF;
STATUS(0) <= TA_OVF;
DO <= STATUS;

-- CPU INTERFACE
process( RST_N, CLK )
begin
	if RST_N = '0' then
		FF_DTACK_N <= '1';		
		
		TA_BASE <= (others => '0');		
		TA_LOAD <= '0';
		TA_EN <= '0';
		TA_RESETCLK <= '0';
		
		TB_BASE <= (others => '0');		
		TB_LOAD <= '0';
		TB_EN <= '0';
		TB_RESETCLK <= '0';
		
	elsif rising_edge(CLK) then
	
		TA_RESETCLK <= '0';
		TB_RESETCLK <= '0';
	
		if SEL = '0' then
			FF_DTACK_N <= '1';
		elsif SEL = '1' and FF_DTACK_N = '1' then
			if RNW = '0' then
				if A = "00" then
					-- Timer address port
					REG <= DI(7 downto 0);
				elsif A = "01" then
					-- Timer data port
					case REG is
					when x"27" =>
						TA_RESETCLK <= DI(4);
						TB_RESETCLK <= DI(5);
					
						TA_EN <= DI(2);
						TB_EN <= DI(3);
						
						TA_LOAD <= DI(0);
						TB_LOAD <= DI(1);
					when x"24" =>
						TA_BASE(9 downto 2) <= DI(7 downto 0);
					when x"25" =>
						TA_BASE(1 downto 0) <= DI(1 downto 0);
					when x"26" =>
						TB_BASE <= DI(7 downto 0);
					when others => null;
					end case;
				end if;
			end if;
			FF_DTACK_N <= '0';
		end if;
	end if;
end process;

-- http://gendev.spritesmind.net/forum/viewtopic.php?t=386&start=90
-- To calculate Timer A period in microseconds:

-- TimerA = 144 * (1024 - NA) / M
   -- NA:     0~1023
   -- M:      Master clock (MHz)

-- Eg, where clock = 7.61Mhz
   -- TimerA(MAX) = 144 * (1024 - 0) / 7.61 = 19376.61 microseconds
   -- TimerA(MIN) = 144 * (1024 - 1023) / 7.61 = 18.92 microseconds


-- To calculate Timer B period in microseconds:

-- TimerB = (144*16) * (256 - NA) / M
   -- NB:     0~255
   -- M:      Master clock (MHz)

-- Eg, where clock = 7.61Mhz
   -- TimerB(MAX) = (144*16) * (256 - 0) / 7.61 = 77506.44 microseconds
   -- TimerB(MIN) = (144*16) * (256 - 255) / 7.61 = 302.76 microseconds

-- TIMER A
process( RST_N, CLK )
begin
	if RST_N = '0' then
		TA_OVF <= '0';		
	elsif rising_edge(CLK) then
		if TA_RESETCLK = '1' then
			TA_OVF <= '0';
		end if;
		
		if TA_LOAD = '0' then
			TA_VALUE <= TA_BASE;
			TA_DIV <= (others => '0');
		else
			TA_DIV <= TA_DIV + 1;
			if TA_DIV = "10001111" then -- 144-1
				TA_DIV <= (others => '0');
				TA_VALUE <= TA_VALUE + 1;
				if TA_VALUE = "1111111111" then
					TA_VALUE <= TA_BASE;
					if TA_EN = '1' then
						TA_OVF <= '1';
					end if;
				end if;
			end if;
		end if;
	end if;
end process;

-- TIMER B
process( RST_N, CLK )
begin
	if RST_N = '0' then
		TB_OVF <= '0';
	elsif rising_edge(CLK) then
		if TB_RESETCLK = '1' then
			TB_OVF <= '0';
		end if;
		
		if TB_LOAD = '0' then
			TB_VALUE <= TB_BASE;
			TB_DIV <= (others => '0');
		else
			TB_DIV <= TB_DIV + 1;
			if TB_DIV = "100011111111" then -- 144*16-1
				TB_DIV <= (others => '0');
				TB_VALUE <= TB_VALUE + 1;
				if TB_VALUE = "11111111" then
					TB_VALUE <= TB_BASE;
					if TB_EN = '1' then
						TB_OVF <= '1';
					end if;
				end if;
			end if;
		end if;
	end if;
end process;
	
end rtl;

