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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
use IEEE.NUMERIC_STD.ALL;
use work.jt12.all; 

entity Genesis is
	generic (
		colAddrBits : integer := 9;
		rowAddrBits : integer := 13
	);
	port(
		RESET_N 		: in  std_logic;
		MCLK 			: in  std_logic;
		RAMCLK		: in  std_logic;

		DAC_LDATA 	: out std_logic_vector(12 downto 0);
		DAC_RDATA 	: out std_logic_vector(12 downto 0);

		PAL         : in  std_logic;
		EXPORT      : in  std_logic;
		RED			: out std_logic_vector(3 downto 0);
		GREEN			: out std_logic_vector(3 downto 0);
		BLUE			: out std_logic_vector(3 downto 0);		
		VS				: out std_logic;
		HS				: out std_logic;
		HBL			: out std_logic;
		VBL			: out std_logic;
		CE_PIX		: out std_logic;

		INTERLACE	: out std_logic;
		FIELD   		: out std_logic;

		PSG_ENABLE	: in  std_logic;
		FM_ENABLE   : in  std_logic;
		FM_LIMITER  : in  std_logic;

		J3BUT       : in  std_logic;
		JOY_1 		: in  std_logic_vector(11 downto 0);
		JOY_2 		: in  std_logic_vector(11 downto 0);

		MAPPER_A		: out std_logic_vector(2 downto 0);
		MAPPER_WE	: out std_logic;
		MAPPER_D		: out std_logic_vector(7 downto 0);

		ROM_ADDR 	: out std_logic_vector(22 downto 1);
		ROM_DATA 	: in  std_logic_vector(15 downto 0);
		ROM_REQ		: out std_logic;
		ROM_ACK 		: in  std_logic
	);
end entity;

architecture rtl of Genesis is

-- VRAM
signal vram_req : std_logic;
signal vram_ack : std_logic;
signal vram_we_u: std_logic;
signal vram_we_l: std_logic;
signal vram_a   : std_logic_vector(15 downto 1);
signal vram_d   : std_logic_vector(15 downto 0);
signal vram_q   : std_logic_vector(15 downto 0);

-- 68000 RAM
signal ram68k_req : std_logic;
signal ram68k_ack : std_logic;
signal ram68k_we  : std_logic;
signal ram68k_a   : std_logic_vector(15 downto 1);
signal ram68k_d   : std_logic_vector(15 downto 0);
signal ram68k_q   : std_logic_vector(15 downto 0);
signal ram68k_l_n : std_logic;
signal ram68k_u_n : std_logic;

type RAMC_t is (
	RAMC_IDLE,
	RAMC_TG68,
	RAMC_DMA, 
	RAMC_T80);
signal RAMC : RAMC_t;

-- Z80 RAM
signal zram_a  : std_logic_vector(12 downto 0);
signal zram_d  : std_logic_vector(7 downto 0);
signal zram_q  : std_logic_vector(7 downto 0);
signal zram_we : std_logic;

signal TG68_ZRAM_SEL		 : std_logic;
signal TG68_ZRAM_D		 : std_logic_vector(15 downto 0);
signal TG68_ZRAM_DTACK_N : std_logic;

signal T80_ZRAM_SEL		 : std_logic;
signal T80_ZRAM_D			 : std_logic_vector(7 downto 0);
signal T80_ZRAM_DTACK_N	 : std_logic;

type zrc_t is (
	ZRC_IDLE,
	ZRC_ACC1,
	ZRC_ACC2,
	ZRC_ACC3
);
signal ZRC : zrc_t;

type zrcp_t is (
	ZRCP_T80,
	ZRCP_TG68
);
signal ZRCP : zrcp_t;

-- Genesis core
constant NO_DATA	: std_logic_vector(15 downto 0) := x"4E71";	-- SYNTHESIS gp/m68k.c line 12

-- 68K
signal TG68_DI			: std_logic_vector(15 downto 0);
signal TG68_IPL_N		: std_logic_vector(2 downto 0);
signal TG68_DTACK_N	: std_logic;
signal TG68_A			: std_logic_vector(31 downto 1);
signal TG68_DO			: std_logic_vector(15 downto 0);
signal TG68_AS_N		: std_logic;
signal TG68_UDS_N		: std_logic;
signal TG68_LDS_N		: std_logic;
signal TG68_RNW		: std_logic;
signal TG68_INTACK	: std_logic;
signal TG68_STATE		: std_logic_vector(1 downto 0);
signal TG68_FC			: std_logic_vector(2 downto 0);
signal TG68_ENA		: std_logic;
signal TG68_ENA_DIV	: std_logic_vector(1 downto 0);
signal TG68_ENARDREG	: std_logic;
signal TG68_ENAWRREG	: std_logic;

-- Z80
signal T80_RESET_N	: std_logic;
signal T80_CLKEN		: std_logic;
signal T80_WAIT_N		: std_logic;
signal T80_INT_N     : std_logic;
signal T80_BUSRQ_N   : std_logic;
signal T80_M1_N      : std_logic;
signal T80_MREQ_N    : std_logic;
signal T80_IORQ_N    : std_logic;
signal T80_RD_N      : std_logic;
signal T80_WR_N      : std_logic;
signal T80_BUSAK_N   : std_logic;
signal T80_A         : std_logic_vector(15 downto 0);
signal T80_DI        : std_logic_vector(7 downto 0);
signal T80_DO        : std_logic_vector(7 downto 0);

signal FCLK_EN			: std_logic;

-- FLASH CONTROL
signal TG68_FLASH_SEL		: std_logic;
signal TG68_FLASH_D			: std_logic_vector(15 downto 0);
signal TG68_FLASH_DTACK_N	: std_logic;

signal T80_FLASH_SEL			: std_logic;
signal T80_FLASH_D			: std_logic_vector(7 downto 0);
signal T80_FLASH_DTACK_N	: std_logic;

signal DMA_FLASH_SEL			: std_logic;
signal DMA_FLASH_D			: std_logic_vector(15 downto 0);
signal DMA_FLASH_DTACK_N	: std_logic;

type fc_t is (
	FC_IDLE, 
	FC_TG68_RD,
	FC_DMA_RD,
	FC_T80_RD
);
signal FC : fc_t;

signal romrd_req			: std_logic := '0';
signal romrd_ack			: std_logic;


-- 68K RAM CONTROL
signal TG68_RAM_SEL		: std_logic;
signal TG68_RAM_D			: std_logic_vector(15 downto 0);
signal TG68_RAM_DTACK_N	: std_logic;

signal T80_RAM_SEL		: std_logic;
signal T80_RAM_D			: std_logic_vector(7 downto 0);
signal T80_RAM_DTACK_N	: std_logic;

signal DMA_RAM_SEL		: std_logic;
signal DMA_RAM_D			: std_logic_vector(15 downto 0);
signal DMA_RAM_DTACK_N	: std_logic;

-- OPERATING SYSTEM ROM
signal TG68_OS_SEL		: std_logic;
signal TG68_OS_D			: std_logic_vector(15 downto 0);
signal TG68_OS_DTACK_N	: std_logic;

-- CONTROL AREA
signal CART_EN				: std_logic;

signal TG68_CTRL_SEL		: std_logic;
signal TG68_CTRL_D		: std_logic_vector(15 downto 0);
signal TG68_CTRL_DTACK_N: std_logic;

signal T80_CTRL_SEL		: std_logic;
signal T80_CTRL_D			: std_logic_vector(7 downto 0);
signal T80_CTRL_DTACK_N	: std_logic;

-- I/O AREA
signal IO_SEL				: std_logic;
signal IO_A 				: std_logic_vector(4 downto 1);
signal IO_RNW				: std_logic;
signal IO_UDS_N			: std_logic;
signal IO_LDS_N			: std_logic;
signal IO_DI				: std_logic_vector(15 downto 0);
signal IO_DO				: std_logic_vector(15 downto 0);
signal IO_DTACK_N			: std_logic;

signal TG68_IO_SEL		: std_logic;
signal TG68_IO_D			: std_logic_vector(15 downto 0);
signal TG68_IO_DTACK_N	: std_logic;

signal T80_IO_SEL			: std_logic;
signal T80_IO_D			: std_logic_vector(7 downto 0);
signal T80_IO_DTACK_N	: std_logic;

type ioc_t is (
	IOC_IDLE,
	IOC_TG68_ACC,
	IOC_T80_ACC,
	IOC_DESEL
);
signal IOC : ioc_t;

-- VDP AREA
signal VDP_SEL				: std_logic;
signal VDP_A 				: std_logic_vector(4 downto 1);
signal VDP_UDS_N			: std_logic;
signal VDP_LDS_N			: std_logic;
signal VDP_RNW				: std_logic;
signal VDP_DI				: std_logic_vector(15 downto 0);
signal VDP_DO				: std_logic_vector(15 downto 0);
signal VDP_DTACK_N		: std_logic;

signal TG68_VDP_SEL		: std_logic;
signal TG68_VDP_D			: std_logic_vector(15 downto 0);
signal TG68_VDP_DTACK_N	: std_logic;

signal T80_VDP_SEL		: std_logic;
signal T80_VDP_D			: std_logic_vector(7 downto 0);
signal T80_VDP_DTACK_N	: std_logic;

type vdpc_t is (
	VDPC_IDLE,
	VDPC_TG68_ACC,
	VDPC_T80_ACC,
	VDPC_DESEL
);
signal VDPC : vdpc_t;

-- FM AREA
signal FM_A 				: std_logic_vector(1 downto 0);
signal FM_RNW				: std_logic;
signal FM_DI				: std_logic_vector(7 downto 0);
signal FM_DO				: std_logic_vector(7 downto 0);
signal TG68_FM_SEL		: std_logic;
signal TG68_FM_D			: std_logic_vector(15 downto 0);
signal TG68_FM_DTACK_N	: std_logic;
signal T80_FM_SEL			: std_logic;
signal T80_FM_D			: std_logic_vector(7 downto 0);
signal T80_FM_DTACK_N	: std_logic;

-- PSG
signal PSG_WR_n		: std_logic;
signal PSG_DI			: std_logic_vector(7 downto 0);
signal PSG_SND			: std_logic_vector(5 downto 0);

-- BANK ADDRESS REGISTER
signal BAR 					: std_logic_vector(23 downto 15);
signal TG68_BAR_SEL		: std_logic;
signal TG68_BAR_D			: std_logic_vector(15 downto 0);
signal TG68_BAR_DTACK_N	: std_logic;
signal T80_BAR_SEL		: std_logic;
signal T80_BAR_D			: std_logic_vector(7 downto 0);
signal T80_BAR_DTACK_N	: std_logic;

-- INTERRUPTS
signal HINT				: std_logic;
signal HINT_ACK		: std_logic;
signal VINT_TG68		: std_logic;
signal VINT_T80		: std_logic;
signal VINT_TG68_ACK	: std_logic;
signal VINT_T80_ACK	: std_logic;

-- VDP VBUS DMA
signal VBUS_ADDR		: std_logic_vector(23 downto 0);
signal VBUS_DATA		: std_logic_vector(15 downto 0);		
signal VBUS_SEL		: std_logic;
signal VBUS_DTACK_N	: std_logic;
signal VBUS_BUSY		: std_logic;

type romStates is (ROM_IDLE, ROM_READ);
signal romState : romStates := ROM_IDLE;

signal snd_right : std_logic_vector(11 downto 0);
signal snd_left  : std_logic_vector(11 downto 0);

begin

-- -----------------------------------------------------------------------
-- RAM
-- -----------------------------------------------------------------------		

vram_l : entity work.dpram generic map(15)
port map
(
	clock		=> RAMCLK,
	address_a=> vram_a(15 downto 1),
	data_a	=> vram_d(7 downto 0),
	wren_a	=> vram_we_l and (vram_ack xor vram_req),
	q_a		=> vram_q(7 downto 0)
);

vram_r : entity work.dpram generic map(15)
port map
(
	clock		=> RAMCLK,
	address_a=> vram_a(15 downto 1),
	data_a	=> vram_d(15 downto 8),
	wren_a	=> vram_we_u and (vram_ack xor vram_req),
	q_a		=> vram_q(15 downto 8)
);

vram_ack <= vram_req when rising_edge(RAMCLK);

ram68k_l : entity work.dpram generic map(15)
port map
(
	clock		=> RAMCLK,
	address_a=> ram68k_a(15 downto 1),
	data_a	=> ram68k_d(7 downto 0),
	wren_a	=> not ram68k_l_n and ram68k_we and (ram68k_ack xor ram68k_req),
	q_a		=> ram68k_q(7 downto 0)
);

ram68k_r : entity work.dpram generic map(15)
port map
(
	clock		=> RAMCLK,
	address_a=> ram68k_a(15 downto 1),
	data_a	=> ram68k_d(15 downto 8),
	wren_a	=> not ram68k_u_n and ram68k_we and (ram68k_ack xor ram68k_req),
	q_a		=> ram68k_q(15 downto 8)
);

ram68k_ack <= ram68k_req when rising_edge(RAMCLK);

ramZ80 : entity work.dpram generic map(13)
port map
(
	clock		=> MCLK,
	address_a=> zram_a,
	data_a	=> zram_d,
	wren_a	=> zram_we,
	q_a		=> zram_q
);

-- a full cpu cycle consists of 4 TG68_ENARDREG "bus" cycles
process(MCLK)
begin
	if rising_edge( MCLK ) then
		if TG68_ENAWRREG = '1' then
			if TG68_ENA_DIV /= "11" or TG68_AS_N = '1' then
				TG68_ENA_DIV <= TG68_ENA_DIV + 1;
			end if;

			-- activate AS
			if TG68_STATE /= "01" and TG68_ENA_DIV = "00" then
				TG68_AS_N <= '0';
			end if;
			
		end if;
		if TG68_ENARDREG = '1' then
			-- de-activate as in bus cycle 3 if dtack is ok
			if TG68_ENA_DIV = "11" and TG68_DTACK_N = '0' then
				TG68_AS_N <= '1';
			end if;
		end if;		
	end if;
end process;
	
TG68_ENA <= '1' when TG68_ENARDREG = '1' and TG68_ENA_DIV = "11" and TG68_DTACK_N = '0' else '0';
TG68_INTACK <= '1' when TG68_FC = "111" else '0';

-- 68K
tg68 : entity work.TG68KdotC_Kernel
port map(
	clk			=> MCLK,
	nReset		=> RESET_N,
	clkena_in	=> TG68_ENA,
	data_in		=> TG68_DI,
	IPL			=> TG68_IPL_N,
	addr			=> TG68_A,
	data_write	=> TG68_DO,
	nUDS			=> TG68_UDS_N,
	nLDS			=> TG68_LDS_N,
	nWr			=> TG68_RNW,
	busstate		=> TG68_STATE,
	FC				=> TG68_FC
);

-- Z80
t80 : entity work.t80s
port map(
	RESET_n	=> T80_RESET_N,

	CLK		=> MCLK,
	CEN		=> T80_CLKEN,
	WAIT_n	=> T80_WAIT_N,
	INT_n		=> T80_INT_N,
	BUSRQ_n	=> T80_BUSRQ_N,
	M1_n		=> T80_M1_N,
	MREQ_n	=> T80_MREQ_N,
	IORQ_n	=> T80_IORQ_N,
	RD_n		=> T80_RD_N,
	WR_n		=> T80_WR_N,
	BUSAK_n	=> T80_BUSAK_N,
	A			=> T80_A,
	DI			=> T80_DI,
	DO			=> T80_DO
);

-- OS ROM
os : entity work.os_rom
port map(
	CLK	=> MCLK,
	A		=> TG68_A(8 downto 1),
	D		=> TG68_OS_D
);

-- I/O
io : entity work.gen_io
port map(
	RST_N		=> RESET_N,
	CLK		=> MCLK and FCLK_EN,

	J3BUT    => J3BUT,

	P1_UP		=> not JOY_1(3),
	P1_DOWN	=> not JOY_1(2),
	P1_LEFT	=> not JOY_1(1),
	P1_RIGHT	=> not JOY_1(0),
	P1_A		=> not JOY_1(4),
	P1_B		=> not JOY_1(5),
	P1_C		=> not JOY_1(6),
	P1_START	=> not JOY_1(7),
	P1_MODE  => not JOY_1(8),
	P1_X     => not JOY_1(9),
	P1_Y     => not JOY_1(10),
	P1_Z     => not JOY_1(11),

	P2_UP		=> not JOY_2(3),
	P2_DOWN	=> not JOY_2(2),
	P2_LEFT	=> not JOY_2(1),
	P2_RIGHT	=> not JOY_2(0),
	P2_A		=> not JOY_2(4),
	P2_B		=> not JOY_2(5),
	P2_C		=> not JOY_2(6),
	P2_START	=> not JOY_2(7),
	P2_MODE  => not JOY_2(8),
	P2_X     => not JOY_2(9),
	P2_Y     => not JOY_2(10),
	P2_Z     => not JOY_2(11),

	SEL		=> IO_SEL,
	A			=> IO_A,
	RNW		=> IO_RNW,
	UDS_N		=> IO_UDS_N,
	LDS_N		=> IO_LDS_N,
	DI			=> IO_DI,
	DO			=> IO_DO,
	DTACK_N	=> IO_DTACK_N,

	PAL		=> PAL,
	EXPORT	=> EXPORT
);

-- VDP
vdp : entity work.vdp
port map(
	RST_N		=> RESET_N,
	CLK		=> MCLK,
	MEMCLK   => RAMCLK,

	SEL		=> VDP_SEL,
	A			=> VDP_A,
	UDS_N		=> VDP_UDS_N,
	LDS_N		=> VDP_LDS_N,
	RNW		=> VDP_RNW,
	DI			=> VDP_DI,
	DO			=> VDP_DO,
	DTACK_N	=> VDP_DTACK_N,

	VRAM_REQ => vram_req,
	VRAM_ACK => vram_ack,
	VRAM_WE_U=> vram_we_u,
	VRAM_WE_L=> vram_we_l,
	VRAM_A	=> vram_a,
	VRAM_DO	=> vram_d,
	VRAM_DI	=> vram_q,
	
	HINT		=> HINT,
	HINT_ACK	=> HINT_ACK,

	VINT_TG68		=> VINT_TG68,
	VINT_T80			=> VINT_T80,
	VINT_TG68_ACK	=> VINT_TG68_ACK,
	VINT_T80_ACK	=> VINT_T80_ACK,
		
	VBUS_BUSY		=> VBUS_BUSY,
	VBUS_ADDR		=> VBUS_ADDR,
	VBUS_DATA		=> VBUS_DATA,
	VBUS_SEL			=> VBUS_SEL,
	VBUS_DTACK_N	=> VBUS_DTACK_N,

	FIELD    => FIELD,
	INTERLACE=> INTERLACE,

	PAL		=> PAL,
	R			=> RED,
	G			=> GREEN,
	B			=> BLUE,
	HS			=> HS,
	VS			=> VS,
	CE_PIX   => CE_PIX,
	HBL		=> HBL,
	VBL		=> VBL
);

-- PSG

u_psg : work.psg
port map(
	clk		=> MCLK,
	clken		=> T80_CLKEN,
	reset    => not RESET_N,
	WR_n		=> PSG_WR_n,
	D_in		=> PSG_DI,
	output	=> PSG_SND
);

fm : jt12
port map(
	rst		   => not T80_RESET_N,
	clk	      => MCLK,
	cen	     	=> FCLK_EN,

	limiter_en 	=> FM_LIMITER,
	cs_n	      => '0',
	addr	      => FM_A,
	wr_n	      => FM_RNW,
	din	      => FM_DI,
	dout	      => FM_DO,

	snd_left   => snd_left,
	snd_right  => snd_right
);

DAC_LDATA <= (snd_left(11)  &  snd_left) + (PSG_SND&"00");
DAC_RDATA <= (snd_right(11) & snd_right) + (PSG_SND&"00");

----------------------------------------------------------------
-- INTERRUPTS CONTROL
----------------------------------------------------------------

VINT_T80_ACK <= not T80_M1_N and not T80_IORQ_N;
T80_INT_N <= not VINT_T80;
TG68_IPL_N <= "001" when VINT_TG68 = '1' else "011" when HINT = '1' else "111";

process(RESET_N, MCLK)
	variable old_ack : std_logic;
begin
	if RESET_N = '0' then
		HINT_ACK <= '0';
		VINT_TG68_ACK <= '0';
		old_ack := '0';
	elsif rising_edge( MCLK ) then
		VINT_TG68_ACK <= '0';
		HINT_ACK <= '0';
		if old_ack = '0' and TG68_INTACK = '1' then
			if VINT_TG68 = '1' then
				VINT_TG68_ACK <= '1';
			elsif HINT = '1' then
				HINT_ACK <= '1';
			end if;
		end if;
		old_ack := TG68_INTACK;
	end if;
end process;


----------------------------------------------------------------
-- CLOCK GENERATION
----------------------------------------------------------------

process( RESET_N, MCLK )
	variable FCLKCNT  : std_logic_vector(2 downto 0) := (others => '0');
	variable VCLKCNT  : std_logic_vector(3 downto 0) := (others => '0');
	variable ZCLKCNT  : std_logic_vector(3 downto 0) := (others => '0');
begin
	if falling_edge(MCLK) then

		T80_CLKEN <= '0';
		ZCLKCNT := ZCLKCNT + 1;
		if ZCLKCNT = 15 then
			ZCLKCNT := (others => '0');
			T80_CLKEN <= '1';
		end if;

		FCLKCNT := FCLKCNT + 1;
		if FCLKCNT = 7 then
			FCLKCNT := (others => '0');
		end if;

		FCLK_EN <= '0';
		if FCLKCNT = 1 then
			FCLK_EN <= '1';
		end if;

		VCLKCNT := VCLKCNT + 1;
		if VCLKCNT = 7 then
			VCLKCNT := (others => '0');
		end if;

		TG68_ENAWRREG <= '0';
		if VCLKCNT = 0 then
			TG68_ENAWRREG <= '1';
		end if;

		TG68_ENARDREG <= '0';
		if VCLKCNT = 4 then
			TG68_ENARDREG <= '1';
		end if;
	end if;
end process;

-- DMA VBUS
VBUS_DTACK_N <= DMA_FLASH_DTACK_N when DMA_FLASH_SEL = '1'
	else DMA_RAM_DTACK_N when DMA_RAM_SEL = '1'
	else '0';
VBUS_DATA <= DMA_FLASH_D when DMA_FLASH_SEL = '1'
	else DMA_RAM_D when DMA_RAM_SEL = '1'
	else x"FFFF";

-- 68K INPUTS
TG68_DTACK_N <= TG68_FLASH_DTACK_N when TG68_FLASH_SEL = '1'
	else TG68_RAM_DTACK_N when TG68_RAM_SEL = '1' 
	else TG68_ZRAM_DTACK_N when TG68_ZRAM_SEL = '1' 
	else TG68_CTRL_DTACK_N when TG68_CTRL_SEL = '1' 
	else TG68_OS_DTACK_N when TG68_OS_SEL = '1' 
	else TG68_IO_DTACK_N when TG68_IO_SEL = '1' 
	else TG68_BAR_DTACK_N when TG68_BAR_SEL = '1' 
	else TG68_VDP_DTACK_N when TG68_VDP_SEL = '1' 
	else TG68_FM_DTACK_N when TG68_FM_SEL = '1' 
	else '0';
TG68_DI(15 downto 8) <= TG68_FLASH_D(15 downto 8) when TG68_FLASH_SEL = '1' and TG68_UDS_N = '0'
	else TG68_RAM_D(15 downto 8) when TG68_RAM_SEL = '1' and TG68_UDS_N = '0'
	else TG68_ZRAM_D(15 downto 8) when TG68_ZRAM_SEL = '1' and TG68_UDS_N = '0'
	else TG68_CTRL_D(15 downto 8) when TG68_CTRL_SEL = '1' and TG68_UDS_N = '0'
	else TG68_OS_D(15 downto 8) when TG68_OS_SEL = '1' and TG68_UDS_N = '0'
	else TG68_IO_D(15 downto 8) when TG68_IO_SEL = '1' and TG68_UDS_N = '0'
	else TG68_BAR_D(15 downto 8) when TG68_BAR_SEL = '1' and TG68_UDS_N = '0'
	else TG68_VDP_D(15 downto 8) when TG68_VDP_SEL = '1' and TG68_UDS_N = '0'
	else TG68_FM_D(15 downto 8) when TG68_FM_SEL = '1' and TG68_UDS_N = '0'
	else NO_DATA(15 downto 8);
TG68_DI(7 downto 0) <= TG68_FLASH_D(7 downto 0) when TG68_FLASH_SEL = '1' and TG68_LDS_N = '0'
	else TG68_RAM_D(7 downto 0) when TG68_RAM_SEL = '1' and TG68_LDS_N = '0'
	else TG68_ZRAM_D(7 downto 0) when TG68_ZRAM_SEL = '1' and TG68_LDS_N = '0'
	else TG68_CTRL_D(7 downto 0) when TG68_CTRL_SEL = '1' and TG68_LDS_N = '0'
	else TG68_OS_D(7 downto 0) when TG68_OS_SEL = '1' and TG68_LDS_N = '0'
	else TG68_IO_D(7 downto 0) when TG68_IO_SEL = '1' and TG68_LDS_N = '0'
	else TG68_BAR_D(7 downto 0) when TG68_BAR_SEL = '1' and TG68_LDS_N = '0'
	else TG68_VDP_D(7 downto 0) when TG68_VDP_SEL = '1' and TG68_LDS_N = '0'
	else TG68_FM_D(7 downto 0) when TG68_FM_SEL = '1' and TG68_LDS_N = '0'
	else NO_DATA(7 downto 0);

T80_WAIT_N <= not T80_RAM_DTACK_N when T80_RAM_SEL = '1'
	else not T80_ZRAM_DTACK_N when T80_ZRAM_SEL = '1'
	else not T80_FLASH_DTACK_N when T80_FLASH_SEL = '1'
	else not T80_CTRL_DTACK_N when T80_CTRL_SEL = '1' 
	else not T80_IO_DTACK_N when T80_IO_SEL = '1' 
	else not T80_BAR_DTACK_N when T80_BAR_SEL = '1'
	else not T80_VDP_DTACK_N when T80_VDP_SEL = '1'
	else not T80_FM_DTACK_N when T80_FM_SEL = '1'
	else '1';
T80_DI <= T80_RAM_D when T80_RAM_SEL = '1'
	else T80_ZRAM_D when T80_ZRAM_SEL = '1'
	else T80_FLASH_D when T80_FLASH_SEL = '1'
	else T80_CTRL_D when T80_CTRL_SEL = '1'
	else T80_IO_D when T80_IO_SEL = '1'
	else T80_BAR_D when T80_BAR_SEL = '1'
	else T80_VDP_D when T80_VDP_SEL = '1'
	else T80_FM_D when T80_FM_SEL = '1'
	else x"FF";

-- OPERATING SYSTEM ROM
TG68_OS_DTACK_N <= '0';

TG68_OS_SEL <= '1' when  TG68_A(23 downto 22) = "00" 
							and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') 
							and TG68_RNW = '1' 
							and CART_EN = '0' else '0';


-- CONTROL AREA
process( RESET_N, MCLK, TG68_AS_N, TG68_RNW,
	TG68_A, TG68_DO, TG68_UDS_N, TG68_LDS_N,
	BAR, T80_A, T80_MREQ_N, T80_RD_N, T80_WR_N)
begin
	if (TG68_A(23 downto 12) = x"A11" or TG68_A(23 downto 12) = x"A14")
		and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') 
	then	
		TG68_CTRL_SEL <= '1';
	else
		TG68_CTRL_SEL <= '0';
	end if;

	if T80_A(15) = '1' and (BAR(23 downto 15) & T80_A(14 downto 12) = x"A11" or BAR(23 downto 15) & T80_A(14 downto 12) = x"A14")
		and T80_MREQ_N = '0' and (T80_RD_N = '0' or T80_WR_N = '0')
	then
		T80_CTRL_SEL <= '1';		
	else
		T80_CTRL_SEL <= '0';
	end if;
	
	if RESET_N = '0' then
		TG68_CTRL_DTACK_N <= '1';	
		T80_CTRL_DTACK_N <= '1';	
		
		T80_BUSRQ_N <= '1';
		T80_RESET_N <= '0';
		CART_EN <= '0';
		
	elsif rising_edge(MCLK) then
		if TG68_CTRL_SEL = '0' then 
			TG68_CTRL_DTACK_N <= '1';
		end if;
		if T80_CTRL_SEL = '0' then 
			T80_CTRL_DTACK_N <= '1';
		end if;
		
		if TG68_CTRL_SEL = '1' and TG68_CTRL_DTACK_N = '1' then
			TG68_CTRL_DTACK_N <= '0';
			if TG68_RNW = '0' then
				-- Write
				if TG68_A(15 downto 8) = x"11" then
					if TG68_UDS_N = '0' then
						T80_BUSRQ_N <= not TG68_DO(8);
					end if;
				elsif TG68_A(15 downto 8) = x"12" then
					if TG68_UDS_N = '0' then
						T80_RESET_N <= TG68_DO(8);
					end if;			
				elsif TG68_A(15 downto 8) = x"41" then
					-- Cartridge Control Register
					if TG68_LDS_N = '0' then
						CART_EN <= TG68_DO(0);
					end if;								
				end if;
			else
				-- Read
				TG68_CTRL_D <= NO_DATA;
				if TG68_A(15 downto 8) = x"11" then
					TG68_CTRL_D(8) <= T80_BUSAK_N and T80_RESET_N;
					TG68_CTRL_D(0) <= T80_BUSAK_N and T80_RESET_N;
				elsif TG68_A(15 downto 8) = x"12" then
					TG68_CTRL_D(8) <= T80_RESET_N;
					TG68_CTRL_D(0) <= T80_RESET_N;
				end if;
			end if;		
		elsif T80_CTRL_SEL = '1' and T80_CTRL_DTACK_N = '1' then
			T80_CTRL_DTACK_N <= '0';
			if T80_WR_N = '0' then
				-- Write
				if BAR(15) & T80_A(14 downto 8) = x"11" then
					if T80_A(0) = '0' then
						T80_BUSRQ_N <= not T80_DO(0);
					end if;
				elsif BAR(15) & T80_A(14 downto 8) = x"12" then
					if T80_A(0) = '0' then
						T80_RESET_N <= T80_DO(0);
					end if;			
				elsif BAR(15) & T80_A(14 downto 8) = x"41" then
					-- Cartridge Control Register
					if T80_A(0) = '1' then
						CART_EN <= T80_DO(0);
					end if;								
				end if;
			else
				-- Read
				T80_CTRL_D <= x"FF";
				if BAR(15) & T80_A(14 downto 8) = x"11" and T80_A(0) = '0' then
					T80_CTRL_D(0) <= T80_BUSAK_N;
				end if;
			end if;			
		end if;
		
	end if;
	
end process;

-- I/O AREA
process( RESET_N, MCLK, TG68_AS_N, TG68_RNW,
	TG68_A, TG68_DO, TG68_UDS_N, TG68_LDS_N,
	BAR, T80_A, T80_MREQ_N, T80_RD_N, T80_WR_N )
begin
	if TG68_A(23 downto 5) = x"A100" & "000"
		and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') 
	then	
		TG68_IO_SEL <= '1';		
	else
		TG68_IO_SEL <= '0';
	end if;

	if T80_A(15) = '1' and BAR & T80_A(14 downto 5) = x"A100" & "000"
		and T80_MREQ_N = '0' and (T80_RD_N = '0' or T80_WR_N = '0')
	then
		T80_IO_SEL <= '1';		
	else
		T80_IO_SEL <= '0';
	end if;
	
	if RESET_N = '0' then
		TG68_IO_DTACK_N <= '1';	
		T80_IO_DTACK_N <= '1';	
		
		IO_SEL <= '0';
		IO_RNW <= '1';
		IO_UDS_N <= '1';
		IO_LDS_N <= '1';
		IO_A <= (others => '0');

		IOC <= IOC_IDLE;
		
	elsif rising_edge(MCLK) then
		if TG68_IO_SEL = '0' then 
			TG68_IO_DTACK_N <= '1';
		end if;
		if T80_IO_SEL = '0' then 
			T80_IO_DTACK_N <= '1';
		end if;

		case IOC is
		when IOC_IDLE =>
			if TG68_IO_SEL = '1' and TG68_IO_DTACK_N = '1' then
				IO_SEL <= '1';
				IO_A <= TG68_A(4 downto 1);
				IO_RNW <= TG68_RNW;
				IO_UDS_N <= TG68_UDS_N;
				IO_LDS_N <= TG68_LDS_N;
				IO_DI <= TG68_DO;
				IOC <= IOC_TG68_ACC;
			elsif T80_IO_SEL = '1' and T80_IO_DTACK_N = '1' then
				IO_SEL <= '1';
				IO_A <= T80_A(4 downto 1);
				IO_RNW <= T80_WR_N;
				if T80_A(0) = '0' then
					IO_UDS_N <= '0';
					IO_LDS_N <= '1';
				else
					IO_UDS_N <= '1';
					IO_LDS_N <= '0';				
				end if;
				IO_DI <= T80_DO & T80_DO;
				IOC <= IOC_T80_ACC;			
			end if;

		when IOC_TG68_ACC =>
			if IO_DTACK_N = '0' then
				IO_SEL <= '0';
				TG68_IO_D <= IO_DO;
				TG68_IO_DTACK_N <= '0';
				IOC <= IOC_DESEL;
			end if;

		when IOC_T80_ACC =>
			if IO_DTACK_N = '0' then
				IO_SEL <= '0';
				if T80_A(0) = '0' then
					T80_IO_D <= IO_DO(15 downto 8);
				else
					T80_IO_D <= IO_DO(7 downto 0);
				end if;
				T80_IO_DTACK_N <= '0';
				IOC <= IOC_DESEL;
			end if;
		
		when IOC_DESEL =>
			if IO_DTACK_N = '1' then
				IO_RNW <= '1';
				IO_UDS_N <= '1';
				IO_LDS_N <= '1';
				IO_A <= (others => '0');

				IOC <= IOC_IDLE;
			end if;
		
		when others => null;
		end case;
	end if;
	
end process;


-- VDP in Z80 address space :
-- Z80:
-- 7F = 01111111 000
-- 68000:
-- 7F = 01111111 000
-- FF = 11111111 000
-- VDP AREA
process( RESET_N, MCLK, TG68_AS_N, TG68_RNW,
	TG68_A, TG68_DO, TG68_UDS_N, TG68_LDS_N,
	BAR, T80_A, T80_MREQ_N, T80_RD_N, T80_WR_N )
begin
	if TG68_A(23 downto 21) = "110" and TG68_A(18 downto 16) = "000" and TG68_A(7 downto 5) = "000"
		and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0')
	then	
		TG68_VDP_SEL <= '1';		
	elsif TG68_A(23 downto 16) = x"A0" and TG68_A(14 downto 5) = "1111111" & "000" -- Z80 Address space
		and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') 
	then
		TG68_VDP_SEL <= '1';
	else
		TG68_VDP_SEL <= '0';
	end if;

	if T80_A(15 downto 5) = x"7F" & "000"
		and T80_MREQ_N = '0' and (T80_RD_N = '0' or T80_WR_N = '0')
	then
		T80_VDP_SEL <= '1';			
	elsif T80_A(15) = '1' and BAR(23 downto 21) = "110" and BAR(18 downto 16) = "000" and TG68_A(7 downto 5) = "000" -- 68000 Address space
		and T80_MREQ_N = '0' and (T80_RD_N = '0' or T80_WR_N = '0')
	then
		T80_VDP_SEL <= '1';		
	else
		T80_VDP_SEL <= '0';
	end if;
	
	if RESET_N = '0' then
		TG68_VDP_DTACK_N <= '1';	
		T80_VDP_DTACK_N <= '1';	
		
		VDP_SEL <= '0';
		VDP_RNW <= '1';
		VDPC <= VDPC_IDLE;

	elsif rising_edge(MCLK) then
		if TG68_VDP_SEL = '0' then 
			TG68_VDP_DTACK_N <= '1';
		end if;
		if T80_VDP_SEL = '0' then 
			T80_VDP_DTACK_N <= '1';
		end if;

		case VDPC is
		when VDPC_IDLE =>
			if TG68_VDP_SEL = '1' and TG68_VDP_DTACK_N = '1' then
				-- VDP
				VDP_SEL <= '1';
				VDP_A <= TG68_A(4 downto 1);
				VDP_UDS_N <= TG68_UDS_N;
				VDP_LDS_N <= TG68_LDS_N;
				VDP_RNW <= TG68_RNW;
				VDP_DI <= TG68_DO;
				VDPC <= VDPC_TG68_ACC;
			elsif T80_VDP_SEL = '1' and T80_VDP_DTACK_N = '1' then
				VDP_SEL <= '1';
				VDP_A <= T80_A(4 downto 1);
				VDP_UDS_N <= T80_A(0);
				VDP_LDS_N <= not T80_A(0);
				VDP_RNW <= T80_WR_N;
				VDP_DI <= T80_DO & T80_DO;
				VDPC <= VDPC_T80_ACC;			
			end if;

		when VDPC_TG68_ACC =>
			if VDP_DTACK_N = '0' then
				VDP_SEL <= '0';
				TG68_VDP_D <= VDP_DO;
				TG68_VDP_DTACK_N <= '0';
				VDPC <= VDPC_DESEL;
			end if;

		when VDPC_T80_ACC =>
			if VDP_DTACK_N = '0' then
				VDP_SEL <= '0';
				if T80_A(0) = '0' then
					T80_VDP_D <= VDP_DO(15 downto 8);
				else
					T80_VDP_D <= VDP_DO(7 downto 0);
				end if;
				T80_VDP_DTACK_N <= '0';
				VDPC <= VDPC_DESEL;
			end if;

		when VDPC_DESEL =>
			if VDP_DTACK_N = '1' then
				VDP_RNW <= '1';
				VDPC <= VDPC_IDLE;
			end if;
			
		when others => null;
		end case;
	end if;
	
end process;

-- Z80:   4000-4003 (4000-5FFF)
-- 68000: A04000-A04003 (A04000-A05FFF)
-- FM AREA

TG68_FM_SEL <= '1' when TG68_A(23 downto 13) = x"A0"&"010" and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') else '0';
T80_FM_SEL  <= '1' when T80_A(15 downto 13) = "010" and T80_MREQ_N = '0' and (T80_RD_N = '0' or T80_WR_N = '0') else '0';

process( RESET_N, MCLK ) begin
	if RESET_N = '0' then
		TG68_FM_DTACK_N <= '1';	
		T80_FM_DTACK_N <= '1';	
		
		FM_RNW <= '1';
		FM_A <= (others => '0');
		
	elsif rising_edge(MCLK) then
		if TG68_FM_SEL = '0' then 
			TG68_FM_DTACK_N <= '1';
		end if;
		if T80_FM_SEL = '0' then 
			T80_FM_DTACK_N <= '1';
		end if;
		
		if TG68_FM_DTACK_N <= '1' and T80_FM_DTACK_N <= '1' then
			FM_RNW <= '1';
		end if;

		if TG68_FM_SEL = '1' and TG68_FM_DTACK_N = '1' then
			TG68_FM_D <= FM_DO & FM_DO;
			FM_A(1) <= TG68_A(1);
			FM_RNW <= TG68_RNW;
			if TG68_LDS_N = '0' then
				FM_DI <= TG68_DO(7 downto 0);
				FM_A(0) <= '1';
			else
				FM_DI <= TG68_DO(15 downto 8);
				FM_A(0) <= '0';
			end if;
			TG68_FM_DTACK_N <= '0';

		elsif T80_FM_SEL = '1' and T80_FM_DTACK_N = '1' then
			T80_FM_D <= FM_DO;
			FM_A <= T80_A(1 downto 0);
			FM_RNW <= T80_WR_N;
			FM_DI <= T80_DO;
			T80_FM_DTACK_N <= '0';

		end if;
	end if;
	
end process;

-- PSG AREA
-- Z80: 7F11/3/5/7
-- 68k: C00011/3/5/7
process( RESET_N, MCLK ) begin
	if RESET_N = '0' then
		PSG_WR_n <= '1';
	elsif rising_edge(MCLK) then
		if TG68_A(31 downto 3) = x"C0001"&'0' and TG68_AS_N = '0' and TG68_RNW='0' and TG68_LDS_N = '0' then
			PSG_WR_n <= '0';
			PSG_DI <= TG68_DO(7 downto 0);
		elsif T80_A(15 downto 3) = x"7F1"&'0' and T80_A(0) = '1' and T80_MREQ_N = '0' and T80_WR_N = '0' then
			PSG_WR_n <= '0';
			PSG_DI <= T80_DO;
		else
			PSG_WR_n <= '1';
		end if;
	end if;
end process;

-- Z80: 6000-60FF
-- 68000: A06000-A060FF
-- BANK ADDRESS REGISTER

TG68_BAR_SEL <= '1' when TG68_A(23 downto 8) = x"A060" and TG68_AS_N = '0' else '0';
T80_BAR_SEL  <= '1' when T80_A(15 downto 8) = x"60" and T80_MREQ_N = '0' and (T80_RD_N = '0' or T80_WR_N = '0') else '0';

process( RESET_N, MCLK )
begin

	if RESET_N = '0' then
		TG68_BAR_DTACK_N <= '1';
		T80_BAR_DTACK_N <= '1';
		BAR <= (others => '0');
		
	elsif rising_edge(MCLK) then
		if TG68_BAR_SEL = '0' then 
			TG68_BAR_DTACK_N <= '1';
		end if;
		if T80_BAR_SEL = '0' then 
			T80_BAR_DTACK_N <= '1';
		end if;

		if TG68_BAR_SEL = '1' and TG68_BAR_DTACK_N = '1' then
			if TG68_RNW = '0' then
				if TG68_UDS_N = '0' then
					BAR <= TG68_DO(8) & BAR(23 downto 16);
				end if;
			else
				TG68_BAR_D <= x"FFFF";
			end if;
			TG68_BAR_DTACK_N <= '0';
		elsif T80_BAR_SEL = '1' and T80_BAR_DTACK_N = '1' then
			if T80_WR_N = '0' then
				BAR <= T80_DO(0) & BAR(23 downto 16);
			else
				T80_BAR_D <= x"FF";
			end if;
			T80_BAR_DTACK_N <= '0';
		end if;
	end if;
end process;

-------------------------------------------------------------------------
-- ROM Handling
-------------------------------------------------------------------------

ROM_REQ  <= romrd_req;
romrd_ack<= ROM_ACK;

TG68_FLASH_SEL <= '1' when TG68_A(23) = '0' and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0')
									and TG68_RNW = '1' and CART_EN = '1' else '0';
T80_FLASH_SEL  <= '1' when T80_A(15) = '1' and BAR(23) = '0' and T80_MREQ_N = '0' and T80_RD_N = '0' else '0';
DMA_FLASH_SEL  <= '1' when VBUS_ADDR(23) = '0' and VBUS_SEL = '1' else '0';

process (RESET_N, MCLK) begin
	if RESET_N = '0' then
		FC <= FC_IDLE;
		TG68_FLASH_DTACK_N <= '1';
		T80_FLASH_DTACK_N <= '1';
		DMA_FLASH_DTACK_N <= '1';

	elsif rising_edge( MCLK ) then
		if TG68_FLASH_SEL = '0' then 
			TG68_FLASH_DTACK_N <= '1';
		end if;
		if T80_FLASH_SEL = '0' then 
			T80_FLASH_DTACK_N <= '1';
		end if;
		if DMA_FLASH_SEL = '0' then 
			DMA_FLASH_DTACK_N <= '1';
		end if;

		case FC is
		when FC_IDLE =>
			if VBUS_BUSY = '1' then
				if DMA_FLASH_SEL = '1' and DMA_FLASH_DTACK_N = '1' then
					romrd_req <= not romrd_ack;
					ROM_ADDR <= VBUS_ADDR(22 downto 1);
					FC <= FC_DMA_RD;
				end if;
			elsif TG68_FLASH_SEL = '1' and TG68_FLASH_DTACK_N = '1' then
				romrd_req <= not romrd_ack;
				ROM_ADDR <= TG68_A(22 downto 1);
				FC <= FC_TG68_RD;
			elsif T80_FLASH_SEL = '1' and T80_FLASH_DTACK_N = '1' then
				romrd_req <= not romrd_ack;
				ROM_ADDR <= BAR(22 downto 15) & T80_A(14 downto 1);
				FC <= FC_T80_RD;
			end if;

		when FC_TG68_RD =>
			if romrd_req = romrd_ack then
				TG68_FLASH_D <= ROM_DATA;
				TG68_FLASH_DTACK_N <= '0';
				FC <= FC_IDLE;
			end if;

		when FC_T80_RD =>
			if romrd_req = romrd_ack then
				if T80_A(0) = '1' then
					T80_FLASH_D <= ROM_DATA(7 downto 0);
				else
					T80_FLASH_D <= ROM_DATA(15 downto 8);
				end if;
				T80_FLASH_DTACK_N <= '0';
				FC <= FC_IDLE;
			end if;

		when FC_DMA_RD =>
			if romrd_req = romrd_ack then
				DMA_FLASH_D <= ROM_DATA;
				DMA_FLASH_DTACK_N <= '0';
				FC <= FC_IDLE;
			end if;

		when others => null;
		end case;

	end if;
end process;

MAPPER_A  <= TG68_A(3 downto 1);
MAPPER_WE <= '1' when TG68_AS_N = '0' and TG68_RNW = '0' and TG68_A(23 downto 4) = x"A130F" else '0';
MAPPER_D  <= TG68_DO(7 downto 0);


-- 68K RAM CONTROL
TG68_RAM_SEL <= '1' when TG68_A(23 downto 21) = "111" and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') else '0';
T80_RAM_SEL  <= '1' when T80_A(15) = '1' and BAR(23 downto 21) = "111" and T80_MREQ_N = '0' and (T80_RD_N = '0' or T80_WR_N = '0') else '0';
DMA_RAM_SEL  <= '1' when VBUS_ADDR(23 downto 21) = "111" and VBUS_SEL = '1' else '0';

process( RESET_N, MCLK )
begin
	if RESET_N = '0' then
		TG68_RAM_DTACK_N <= '1';
		T80_RAM_DTACK_N <= '1';
		DMA_RAM_DTACK_N <= '1';
		ram68k_req <= '0';
		RAMC <= RAMC_IDLE;

	elsif rising_edge(MCLK) then
		if TG68_RAM_SEL = '0' then 
			TG68_RAM_DTACK_N <= '1';
		end if;	
		if T80_RAM_SEL = '0' then 
			T80_RAM_DTACK_N <= '1';
		end if;	
		if DMA_RAM_SEL = '0' then 
			DMA_RAM_DTACK_N <= '1';
		end if;

		case RAMC is
		when RAMC_IDLE =>
			if VBUS_BUSY = '1' then
				if DMA_RAM_SEL = '1' and DMA_RAM_DTACK_N = '1' then
					ram68k_req <= not ram68k_req;
					ram68k_a <= VBUS_ADDR(15 downto 1);
					ram68k_we <= '0';
					ram68k_u_n <= '0';
					ram68k_l_n <= '0';
					RAMC <= RAMC_DMA;
				end if;
			elsif TG68_RAM_SEL = '1' and TG68_RAM_DTACK_N = '1' then
				ram68k_req <= not ram68k_req;
				ram68k_a <= TG68_A(15 downto 1);
				ram68k_d <= TG68_DO;
				ram68k_we <= not TG68_RNW;
				ram68k_u_n <= TG68_UDS_N;
				ram68k_l_n <= TG68_LDS_N;
				RAMC <= RAMC_TG68;
			elsif T80_RAM_SEL = '1' and T80_RAM_DTACK_N = '1' then
				ram68k_req <= not ram68k_req;
				ram68k_a <= BAR(15) & T80_A(14 downto 1);
				ram68k_d <= T80_DO & T80_DO;
				ram68k_we <= not T80_WR_N;
				ram68k_u_n <= T80_A(0);
				ram68k_l_n <= not T80_A(0);
				RAMC <= RAMC_T80;
			end if;

		when RAMC_TG68 =>
			if ram68k_req = ram68k_ack then
				TG68_RAM_D <= ram68k_q;
				TG68_RAM_DTACK_N <= '0';
				RAMC <= RAMC_IDLE;
			end if;

		when RAMC_T80 =>
			if ram68k_req = ram68k_ack then
				if T80_A(0) = '0' then
					T80_RAM_D <= ram68k_q(15 downto 8);
				else
					T80_RAM_D <= ram68k_q(7 downto 0);
				end if;
				T80_RAM_DTACK_N <= '0';
				RAMC <= RAMC_IDLE;
			end if;

		when RAMC_DMA =>
			if ram68k_req = ram68k_ack then
				DMA_RAM_D <= ram68k_q;
				DMA_RAM_DTACK_N <= '0';
				RAMC <= RAMC_IDLE;
			end if;

		when others => null;
		end case;
		
	end if;
end process;

-- Z80 RAM CONTROL
process( RESET_N, MCLK, TG68_AS_N, TG68_RNW,
	TG68_A, TG68_DO, TG68_UDS_N, TG68_LDS_N,
	BAR, T80_A, T80_MREQ_N, T80_RD_N, T80_WR_N,
	VBUS_SEL, VBUS_ADDR, T80_BUSAK_N)
begin
	if TG68_A(23 downto 14) = x"A0"&"00" -- Z80 Address Space
		and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') 
		and T80_BUSAK_N = '0'
	then	
		TG68_ZRAM_SEL <= '1';
	else
		TG68_ZRAM_SEL <= '0';
	end if;

	if T80_A(15 downto 14) = "00" -- Z80 RAM
		and T80_MREQ_N = '0' and (T80_RD_N = '0' or T80_WR_N = '0')
	then
		T80_ZRAM_SEL <= '1';
	else
		T80_ZRAM_SEL <= '0';
	end if;
	
	if RESET_N = '0' then
		TG68_ZRAM_DTACK_N <= '1';
		T80_ZRAM_DTACK_N <= '1';
	
		zram_we <= '0';
		zram_a <= (others => '0');
	
		ZRC <= ZRC_IDLE;
	
	elsif rising_edge(MCLK) then
		if TG68_ZRAM_SEL = '0' then 
			TG68_ZRAM_DTACK_N <= '1';
		end if;	
		if T80_ZRAM_SEL = '0' then 
			T80_ZRAM_DTACK_N <= '1';
		end if;	

		case ZRC is
		when ZRC_IDLE =>
			if TG68_ZRAM_SEL = '1' and TG68_ZRAM_DTACK_N = '1' then
				if TG68_UDS_N = '0' then
					zram_a <= TG68_A(12 downto 1) & "0";
					zram_d <= TG68_DO(15 downto 8);
				else
					zram_a <= TG68_A(12 downto 1) & "1";
					zram_d <= TG68_DO(7 downto 0);
				end if;
				zram_we <= not TG68_RNW;
				ZRCP <= ZRCP_TG68;
				ZRC <= ZRC_ACC1;
			elsif T80_ZRAM_SEL = '1' and T80_ZRAM_DTACK_N = '1' then
				zram_a <= T80_A(12 downto 0);
				zram_d <= T80_DO;
				zram_we <= not T80_WR_N;
				ZRCP <= ZRCP_T80;
				ZRC <= ZRC_ACC1;
			end if;
		when ZRC_ACC1 =>
			zram_we <= '0';
			ZRC <= ZRC_ACC2;
		when ZRC_ACC2 =>
			ZRC <= ZRC_ACC3;
		when ZRC_ACC3 =>
			case ZRCP is
			when ZRCP_TG68 =>
				TG68_ZRAM_D <= zram_q & zram_q;
				TG68_ZRAM_DTACK_N <= '0';
			when ZRCP_T80 =>
				T80_ZRAM_D <= zram_q;
				T80_ZRAM_DTACK_N <= '0';
			end case;
			ZRC <= ZRC_IDLE;
		when others => null;
		end case;
	end if;
end process;

end rtl;
