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

library STD;
use STD.TEXTIO.ALL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
use IEEE.NUMERIC_STD.ALL;

entity Virtual_Toplevel is
	generic (
		colAddrBits : integer := 9;
		rowAddrBits : integer := 13
	);
	port(
		RESET_N 		: in std_logic;
		MCLK 			: in std_logic;
		RAMCLK		: in std_logic;

		DAC_LDATA 	: out std_logic_vector(15 downto 0);
		DAC_RDATA 	: out std_logic_vector(15 downto 0);

		RED			: out std_logic_vector(2 downto 0);
		GREEN			: out std_logic_vector(2 downto 0);
		BLUE			: out std_logic_vector(2 downto 0);		
		VS				: out std_logic;
		HS				: out std_logic;
		HBL			: out std_logic;
		VBL			: out std_logic;
		CE_PIX		: out std_logic;
		VGA			: in  std_logic;

		PSG_ENABLE	: in std_logic;
		FM_ENABLE   : in std_logic;
		FM_LIMITER  : in std_logic;

		J3BUT       : in std_logic;
		JOY_1 		: in std_logic_vector(11 downto 0);
		JOY_2 		: in std_logic_vector(11 downto 0);

		ROM_ADDR 	: out std_logic_vector(19 downto 0);
		ROM_DATA 	: in  std_logic_vector(63 downto 0);
		ROM_REQ		: out std_logic;
		ROM_ACK 		: in  std_logic
	);
end entity;

architecture rtl of Virtual_Toplevel is
component jt12 port(
	rst	    : in std_logic;
	cpu_clk   : in std_logic;
	cpu_din   : in std_logic_vector(7 downto 0);
	cpu_dout  : out std_logic_vector(7 downto 0);
	cpu_addr  : in std_logic_vector(1 downto 0);
	cpu_cs_n  : in std_logic;
	cpu_wr_n  : in std_logic;	
   cpu_irq_n : out std_logic;
	cpu_limiter_en: in std_logic;
	
	syn_clk   : in std_logic;
	syn_snd_right:out std_logic_vector(11 downto 0);
	syn_snd_left:out std_logic_vector(11 downto 0);
	syn_snd_sample	: out std_logic;	
	-- Mux'ed output
	syn_mux_right	:out std_logic_vector(8 downto 0);
	syn_mux_left	:out std_logic_vector(8 downto 0);
	syn_mux_sample	:out std_logic
);
end component;

component jt12_amp_stereo port(
	clk : in std_logic;
	sample : in std_logic;
	volume : in std_logic_vector(2 downto 0);
	psg	   : in std_logic_vector(5 downto 0);
	enable_psg: in std_logic;
	fmleft : in std_logic_vector(11 downto 0);
	fmright: in std_logic_vector(11 downto 0);
	postleft: out std_logic_vector(15 downto 0);
	postright: out std_logic_vector(15 downto 0) );	
end component;

component jt12_mixer port(
	clk 		: in std_logic;
	rst			: in std_logic;
	sample 		: in std_logic;
	left_in 	: in std_logic_vector(8 downto 0);
	right_in	: in std_logic_vector(8 downto 0);
	psg			: in std_logic_vector(5 downto 0);
	enable_psg	: in std_logic;
	left_out	: out std_logic_vector(15 downto 0);
	right_out	: out std_logic_vector(15 downto 0) );	
end component;

component audio_mixer port(
	left_in 		: in  std_logic_vector(11 downto 0);
	right_in		: in  std_logic_vector(11 downto 0);
	psg			: in  std_logic_vector(5 downto 0);
	left_out		: out std_logic_vector(15 downto 0);
	right_out	: out std_logic_vector(15 downto 0) );
end component;

-- "FLASH"
signal romrd_req : std_logic := '0';
signal romrd_ack : std_logic;
signal romrd_a : std_logic_vector(22 downto 3);
signal romrd_q : std_logic_vector(63 downto 0);
signal romrd_a_cached : std_logic_vector(22 downto 3);
signal romrd_q_cached : std_logic_vector(63 downto 0);
type fc_t is ( FC_IDLE, 
	FC_TG68_RD,
	FC_DMA_RD,
	FC_T80_RD
);
signal FC : fc_t;

-- 68000 RAM
signal ram68k_req : std_logic;
signal ram68k_ack : std_logic;
signal ram68k_we : std_logic;
signal ram68k_a : std_logic_vector(15 downto 1);
signal ram68k_d : std_logic_vector(15 downto 0);
signal ram68k_q : std_logic_vector(15 downto 0);
signal ram68k_l_n : std_logic;
signal ram68k_u_n : std_logic;

-- VRAM
signal vram_req : std_logic;
signal vram_ack : std_logic;
signal vram_we : std_logic;
signal vram_a : std_logic_vector(15 downto 1);
signal vram_d : std_logic_vector(15 downto 0);
signal vram_q : std_logic_vector(15 downto 0);
signal vram_l_n : std_logic;
signal vram_u_n : std_logic;


type sdrc_t is ( SDRC_IDLE,
	SDRC_TG68,
	SDRC_DMA, 
	SDRC_T80);
signal SDRC : sdrc_t;

-- Z80 RAM

signal zram_a : std_logic_vector(12 downto 0);
signal zram_d : std_logic_vector(7 downto 0);
signal zram_q : std_logic_vector(7 downto 0);
signal zram_we : std_logic;

signal TG68_ZRAM_SEL		: std_logic;
signal TG68_ZRAM_D			: std_logic_vector(15 downto 0);
signal TG68_ZRAM_DTACK_N	: std_logic;

signal T80_ZRAM_SEL		: std_logic;
signal T80_ZRAM_D			: std_logic_vector(7 downto 0);
signal T80_ZRAM_DTACK_N	: std_logic;

type zrc_t is ( ZRC_IDLE,
	ZRC_ACC1, ZRC_ACC2, ZRC_ACC3
);
signal ZRC : zrc_t;

type zrcp_t is ( ZRCP_T80, ZRCP_TG68 );
signal ZRCP : zrcp_t;

constant useCache : boolean := false;

-- Genesis core
constant NO_DATA	: std_logic_vector(15 downto 0) := x"4E71";	-- SYNTHESIS gp/m68k.c line 12

-- 68K
signal TG68_RES_N		: std_logic;
signal TG68_CLKE		: std_logic;
signal TG68_DI			: std_logic_vector(15 downto 0);
signal TG68_IPL_N		: std_logic_vector(2 downto 0);
signal TG68_DTACK_N	: std_logic;
signal TG68_A			: std_logic_vector(31 downto 0);
signal TG68_DO			: std_logic_vector(15 downto 0);
signal TG68_AS_N		: std_logic;
signal TG68_UDS_N		: std_logic;
signal TG68_LDS_N		: std_logic;
signal TG68_RNW		: std_logic;
signal TG68_INTACK	: std_logic;

signal TG68_ENARDREG	: std_logic;
signal TG68_ENAWRREG	: std_logic;

-- Z80
signal T80_RESET_N	: std_logic;
signal T80_CLK_N		: std_logic;
signal T80_CLKEN		: std_logic;
signal T80_WAIT_N		: std_logic;
signal T80_INT_N     : std_logic;
signal T80_NMI_N     : std_logic;
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

signal SCLK_EN		: std_logic;
signal FCLK_EN		: std_logic;
signal ZCLK_EN		: std_logic;
signal SCLKCNT		: std_logic_vector(5 downto 0);

-- CLOCK GENERATION
signal VCLK			: std_logic;
signal RST_VCLK	: std_logic; -- Reset for blocks using VCLK as clock
signal RST_VCLK_aux : std_logic;
signal VCLKCNT		: std_logic_vector(2 downto 0);
-- signal VCLKCNT		: unsigned(2 downto 0);
signal ZCLK			: std_logic := '0';

signal ZCLKCNT		: std_logic_vector(3 downto 0);

-- FLASH CONTROL
signal TG68_FLASH_SEL		: std_logic;
signal TG68_FLASH_D			: std_logic_vector(15 downto 0);
signal TG68_FLASH_DTACK_N	: std_logic;

signal T80_FLASH_SEL		: std_logic;
signal T80_FLASH_D			: std_logic_vector(7 downto 0);
signal T80_FLASH_DTACK_N	: std_logic;

signal DMA_FLASH_SEL		: std_logic;
signal DMA_FLASH_D			: std_logic_vector(15 downto 0);
signal DMA_FLASH_DTACK_N	: std_logic;

-- SDRAM CONTROL
signal TG68_SDRAM_SEL		: std_logic;
signal TG68_SDRAM_D			: std_logic_vector(15 downto 0);
signal TG68_SDRAM_DTACK_N	: std_logic;

signal T80_SDRAM_SEL		: std_logic;
signal T80_SDRAM_D			: std_logic_vector(7 downto 0);
signal T80_SDRAM_DTACK_N	: std_logic;

signal DMA_SDRAM_SEL		: std_logic;
signal DMA_SDRAM_D			: std_logic_vector(15 downto 0);
signal DMA_SDRAM_DTACK_N	: std_logic;

-- OPERATING SYSTEM ROM
signal TG68_OS_SEL			: std_logic;
signal TG68_OS_D			: std_logic_vector(15 downto 0);
signal TG68_OS_DTACK_N		: std_logic;
signal OS_OEn				: std_logic;

-- CONTROL AREA
signal ZBUSREQ				: std_logic;
signal ZRESET_N				: std_logic;
signal ZBUSACK_N				: std_logic;
signal CART_EN				: std_logic;

signal TG68_CTRL_SEL		: std_logic;
signal TG68_CTRL_D			: std_logic_vector(15 downto 0);
signal TG68_CTRL_DTACK_N		: std_logic;

signal T80_CTRL_SEL		: std_logic;
signal T80_CTRL_D			: std_logic_vector(7 downto 0);
signal T80_CTRL_DTACK_N		: std_logic;

-- I/O AREA
signal IO_SEL				: std_logic;
signal IO_A 				: std_logic_vector(4 downto 0);
signal IO_RNW				: std_logic;
signal IO_UDS_N				: std_logic;
signal IO_LDS_N				: std_logic;
signal IO_DI				: std_logic_vector(15 downto 0);
signal IO_DO				: std_logic_vector(15 downto 0);
signal IO_DTACK_N			: std_logic;

signal TG68_IO_SEL		: std_logic;
signal TG68_IO_D			: std_logic_vector(15 downto 0);
signal TG68_IO_DTACK_N		: std_logic;

signal T80_IO_SEL		: std_logic;
signal T80_IO_D			: std_logic_vector(7 downto 0);
signal T80_IO_DTACK_N		: std_logic;

type ioc_t is ( IOC_IDLE, IOC_TG68_ACC, IOC_T80_ACC, IOC_DESEL );
signal IOC : ioc_t;

-- VDP AREA
signal VDP_SEL				: std_logic;
signal VDP_A 				: std_logic_vector(4 downto 0);
signal VDP_RNW				: std_logic;
signal VDP_UDS_N			: std_logic;
signal VDP_LDS_N			: std_logic;
signal VDP_DI				: std_logic_vector(15 downto 0);
signal VDP_DO				: std_logic_vector(15 downto 0);
signal VDP_DTACK_N			: std_logic;

signal TG68_VDP_SEL		: std_logic;
signal TG68_VDP_D			: std_logic_vector(15 downto 0);
signal TG68_VDP_DTACK_N		: std_logic;

signal T80_VDP_SEL		: std_logic;
signal T80_VDP_D			: std_logic_vector(7 downto 0);
signal T80_VDP_DTACK_N		: std_logic;

type vdpc_t is ( VDPC_IDLE, VDPC_TG68_ACC, VDPC_T80_ACC, VDPC_DESEL );
signal VDPC : vdpc_t;

-- FM AREA
signal FM_SEL			: std_logic;
signal FM_A 			: std_logic_vector(1 downto 0);
signal FM_RNW			: std_logic;
signal FM_UDS_N			: std_logic;
signal FM_LDS_N			: std_logic;
signal FM_DI			: std_logic_vector(7 downto 0);
signal FM_DO			: std_logic_vector(7 downto 0);

-- PSG
signal PSG_SEL			: std_logic;
signal T80_PSG_SEL		: std_logic;
signal TG68_PSG_SEL		: std_logic;
signal PSG_DI			: std_logic_vector(7 downto 0);
signal PSG_SND			: std_logic_vector(5 downto 0);

--signal FM_DTACK_N			: std_logic;

signal TG68_FM_SEL		: std_logic;
signal TG68_FM_D			: std_logic_vector(15 downto 0);
signal TG68_FM_DTACK_N		: std_logic;

signal T80_FM_SEL		: std_logic;
signal T80_FM_D			: std_logic_vector(7 downto 0);
signal T80_FM_DTACK_N		: std_logic;

type fmc_t is ( FMC_IDLE, FMC_TG68_ACC, FMC_T80_ACC, FMC_DESEL );
signal FMC : fmc_t;


-- BANK ADDRESS REGISTER
signal BAR 					: std_logic_vector(23 downto 15);
signal TG68_BAR_SEL			: std_logic;
signal TG68_BAR_D			: std_logic_vector(15 downto 0);
signal TG68_BAR_DTACK_N		: std_logic;
signal T80_BAR_SEL			: std_logic;
signal T80_BAR_D			: std_logic_vector(7 downto 0);
signal T80_BAR_DTACK_N		: std_logic;

-- INTERRUPTS
signal HINT		: std_logic;
signal HINT_ACK	: std_logic;
signal VINT_TG68	: std_logic;
signal VINT_T80		: std_logic;
signal VINT_TG68_ACK	: std_logic;
signal VINT_T80_ACK	: std_logic;

-- VDP VBUS DMA
signal VBUS_ADDR	: std_logic_vector(23 downto 0);
signal VBUS_DATA	: std_logic_vector(15 downto 0);		
signal VBUS_SEL		: std_logic;
signal VBUS_DTACK_N	: std_logic;	

type romStates is (ROM_IDLE, ROM_READ);
signal romState : romStates := ROM_IDLE;

-- DEBUG
--signal HEXVALUE			: std_logic_vector(15 downto 0);

signal snd_right : std_logic_vector(11 downto 0);
signal snd_left  : std_logic_vector(11 downto 0);

signal vramwe      : std_logic := '0';
signal old_vramreq : std_logic := '0';
signal ram68kwe      : std_logic := '0';
signal old_ram68kreq : std_logic := '0';

begin

-- -----------------------------------------------------------------------
-- RAM
-- -----------------------------------------------------------------------		

ROM_ADDR <= romrd_a(22 downto 3);
ROM_REQ  <= romrd_req;
romrd_q  <= ROM_DATA;
romrd_ack<= ROM_ACK;


vram : entity work.gen_ram
port map
(
	clock	    => RAMCLK,

	wraddress => vram_a(15 downto 1),
	data	    => vram_d,
	byteena_a => not vram_u_n & not vram_l_n,
	wren      => vramwe,

	rdaddress => vram_a(15 downto 1),
	q         => vram_q
);

process(RAMCLK)
begin
	if rising_edge(RAMCLK) then
		vram_ack <= old_vramreq;
		old_vramreq <= vram_req;
		vramwe <= '0';
		if(old_vramreq /= vram_req) then
			vramwe <= vram_we;
		end if;
	end if;
end process;

ram68k : entity work.gen_ram
port map
(
	clock	    => RAMCLK,

	wraddress => ram68k_a(15 downto 1),
	data	    => ram68k_d,
	byteena_a => not ram68k_u_n & not ram68k_l_n,
	wren      => ram68kwe,

	rdaddress => ram68k_a(15 downto 1),
	q         => ram68k_q
);

process(RAMCLK)
begin
	if rising_edge(RAMCLK) then
		ram68k_ack <= old_ram68kreq;
		old_ram68kreq <= ram68k_req;
		ram68kwe <= '0';
		if(old_ram68kreq /= ram68k_req) then
			ram68kwe <= ram68k_we;
		end if;
	end if;
end process;


-- -----------------------------------------------------------------------
-- Z80 RAM
-- -----------------------------------------------------------------------
zr : entity work.zram port map (
	address	=> zram_a,
	clock		=> MCLK,
	data		=> zram_d,
	wren		=> zram_we,
	q			=> zram_q
);

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- Genesis Core
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------

-- 68K
tg68 : entity work.TG68 
port map(
	-- clk			=> TG68_CLK,
	clk			=> MCLK,
	reset			=> TG68_RES_N,
	clkena_in	=> TG68_CLKE,
	data_in		=> TG68_DI,
	IPL			=> TG68_IPL_N,
	dtack			=> TG68_DTACK_N,
	addr			=> TG68_A,
	data_out		=> TG68_DO,
	as				=> TG68_AS_N,
	uds			=> TG68_UDS_N,
	lds			=> TG68_LDS_N,
	rw				=> TG68_RNW,
	enaRDreg		=> TG68_ENARDREG,
	enaWRreg		=> TG68_ENAWRREG,
	intack		=> TG68_INTACK
);

-- Z80
t80 : entity work.t80se
port map(
	RESET_n	=> T80_RESET_N,
	CLK_n		=> T80_CLK_N,
	CLKEN		=> T80_CLKEN,
	WAIT_n	=> T80_WAIT_N,
	INT_n		=> T80_INT_N,
	NMI_n		=> T80_NMI_N,
	BUSRQ_n	=> T80_BUSRQ_N,
	M1_n		=> T80_M1_N,
	MREQ_n	=> T80_MREQ_N,
	IORQ_n	=> T80_IORQ_N,
	RD_n		=> T80_RD_N,
	WR_n		=> T80_WR_N,
	RFSH_n	=> open,
	HALT_n	=> open,
	BUSAK_n	=> T80_BUSAK_N,
	A			=> T80_A,
	DI			=> T80_DI,
	DO			=> T80_DO
);

-- OS ROM
os : entity work.os_rom
port map(
	A			=> TG68_A(8 downto 1),
	OEn		=> OS_OEn,
	D			=> TG68_OS_D
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
	DTACK_N	=> IO_DTACK_N
);

-- VDP
vdp : entity work.vdp
port map(
	RST_N		=> RESET_N,
	CLK		=> MCLK,
	MEMCLK   => RAMCLK,

	SEL		=> VDP_SEL,
	A			=> VDP_A,
	RNW		=> VDP_RNW,
	UDS_N		=> VDP_UDS_N,
	LDS_N		=> VDP_LDS_N,
	DI			=> VDP_DI,
	DO			=> VDP_DO,
	DTACK_N		=> VDP_DTACK_N,

	vram_req => vram_req,
	vram_ack => vram_ack,
	vram_we	=> vram_we,
	vram_a	=> vram_a,
	vram_d	=> vram_d,
	vram_q	=> vram_q,
	vram_u_n	=> vram_u_n,
	vram_l_n	=> vram_l_n,
	
	INTERLACE	=> '0',

	HINT			=> HINT,
	HINT_ACK		=> HINT_ACK,

	VINT_TG68		=> VINT_TG68,
	VINT_T80			=> VINT_T80,
	VINT_TG68_ACK	=> VINT_TG68_ACK,
	VINT_T80_ACK	=> VINT_T80_ACK,
		
	VBUS_ADDR		=> VBUS_ADDR,
	VBUS_UDS_N		=> open,
	VBUS_LDS_N		=> open,
	VBUS_DATA		=> VBUS_DATA,
		
	VBUS_SEL			=> VBUS_SEL,
	VBUS_DTACK_N	=> VBUS_DTACK_N,

	R					=> RED,
	G					=> GREEN,
	B					=> BLUE,
	HS					=> HS,
	VS					=> VS,
	CE_PIX         => CE_PIX,
	HBL				=> HBL,
	VBL				=> VBL,
	VGA				=> VGA
);

-- PSG

u_psg : work.psg
port map(
	clk		=> T80_CLK_N,
	clken	=> T80_CLKEN,
	WR_n	=> not PSG_SEL,
	D_in	=> PSG_DI,
	output	=> PSG_SND
);

fm : jt12
port map(
	rst		      => RST_VCLK,	-- gen-hw.txt line 328
	cpu_clk	      => MCLK and FCLK_EN,
	cpu_limiter_en => FM_LIMITER,
	cpu_cs_n	      => not FM_SEL,
	cpu_addr	      => FM_A,
	cpu_wr_n	      => FM_RNW,
	cpu_din	      => FM_DI,
	cpu_dout	      => FM_DO,

	syn_clk	      => MCLK and SCLK_EN,
	syn_snd_left   => snd_left,
	syn_snd_right  => snd_right
);

process( RESET_N, MCLK )
begin
	if RESET_N = '0' then
		SCLK_EN <= '1';
		SCLKCNT <= "000001";
		T80_CLKEN <= '1';
		ZCLKCNT <= (others => '0');
	elsif falling_edge(MCLK) then

		SCLKCNT <= SCLKCNT + 1;
		if SCLKCNT = X"29" then
			SCLKCNT <= (others => '0');
		end if;
		
		if SCLKCNT = "0" then
			SCLK_EN <= '1';
		else
			SCLK_EN <= '0';
		end if;
		
		if VCLKCNT = "001" then
			FCLK_EN <= '1';
		else
			FCLK_EN <= '0';
		end if;

		if (VCLKCNT = "000") and (ZCLK = '0') then
			ZCLK_EN <= '1';
		else
			ZCLK_EN <= '0';
		end if;
		
		if (VCLKCNT = "000") and (ZCLK = '1') then
			ZCLKCNT <= ZCLKCNT + 1;
			T80_CLKEN <= '1';
			if ZCLKCNT = "1110" then
				ZCLKCNT <= (others => '0');
				T80_CLKEN <= '0';
			end if;
		end if;
		
	end if;
end process;


aud_mixer:audio_mixer
port map(
	left_in 		=> snd_left,
	right_in		=> snd_right,
	psg			=> PSG_SND,
	left_out		=> DAC_LDATA,
	right_out	=> DAC_RDATA
);

-- #############################################################################
-- #############################################################################
-- #############################################################################

-- UNUSED SIGNALS
-- VBUS_DMA_ACK <= '0';
-- VRAM_DTACK_N <= '0';

----------------------------------------------------------------
-- INTERRUPTS CONTROL
----------------------------------------------------------------

-- HINT_ACK <= HINT;
-- VINT_TG68_ACK <= VINT_TG68;
-- VINT_T80_ACK <= VINT_T80;

-- TG68_IPL_N <= "111";
process(RESET_N, MCLK)
begin
	if RESET_N = '0' then
		TG68_IPL_N <= "111";
		T80_INT_N <= '1';
		
		HINT_ACK <= '0';
		VINT_TG68_ACK <= '0';
		VINT_T80_ACK <= '0';
	elsif rising_edge( MCLK ) then
		if HINT = '0' then
			HINT_ACK <= '0';
		end if;
		if VINT_TG68 = '0' then
			VINT_TG68_ACK <= '0';
		end if;
		if VINT_T80 = '0' then
			VINT_T80_ACK <= '0';
		end if;
		if TG68_INTACK = '1' then
			VINT_TG68_ACK <= '1';
		end if;				
		if TG68_INTACK = '1' then
			HINT_ACK <= '1';
		end if;

		if VCLKCNT = "110" then
			if VINT_TG68 = '1' and VINT_TG68_ACK = '0' then
				TG68_IPL_N <= "001";	-- IPL Level 6
				-- if TG68_INTACK = '1' then
					-- VINT_TG68_ACK <= '1';
				-- end if;				
			elsif HINT = '1' and HINT_ACK = '0' then
				TG68_IPL_N <= "011";	-- IPL Level 4
				-- if TG68_INTACK = '1' then
					-- HINT_ACK <= '1';
				-- end if;
			else
				TG68_IPL_N <= "111";
			end if;
			
			if ZCLK = '0' then
				if VINT_T80 = '1' and VINT_T80_ACK = '0' then
					T80_INT_N <= '0';
					if T80_M1_N = '0' and T80_IORQ_N = '0' then
						VINT_T80_ACK <= '1';
					end if;
				else
					T80_INT_N <= '1';
				end if;
			end if;
			
		end if;
			
	end if;
end process;

-- #############################################################################
-- #############################################################################
-- #############################################################################

process( RESET_N, MCLK )
begin
	if RESET_N = '0' then
		RST_VCLK <= '1';
		RST_VCLK_aux <= '1';
	elsif rising_edge(MCLK) then
		RST_VCLK_aux <= '0';
		RST_VCLK <= RST_VCLK_aux;
	end if;
end process;

-- CLOCK GENERATION
process( RESET_N, MCLK, VCLKCNT )
begin
	if RESET_N = '0' then
		VCLK <= '1';
		ZCLK <= '0';
		VCLKCNT <= "001"; -- important for SDRAM controller (EDIT: not needed anymore)
		TG68_ENARDREG <= '0';
		TG68_ENAWRREG <= '0';
	elsif rising_edge(MCLK) then
		VCLKCNT <= VCLKCNT + 1;
		if VCLKCNT = "000" then
			ZCLK <= not ZCLK;
		end if;
		if VCLKCNT = "110" then
			VCLKCNT <= "000";
		end if;
		if VCLKCNT <= "011" then
			VCLK <= '1';
		else
			VCLK <= '0';
		end if;
		
		if VCLKCNT = "110" then
			TG68_ENAWRREG <= '1';
		else
			TG68_ENAWRREG <= '0';
		end if;
		
		if VCLKCNT = "011" then
			TG68_ENARDREG <= '1';
		else
			TG68_ENARDREG <= '0';
		end if;
		
	end if;
end process;

-- DMA VBUS
VBUS_DTACK_N <= DMA_FLASH_DTACK_N when DMA_FLASH_SEL = '1'
	else DMA_SDRAM_DTACK_N when DMA_SDRAM_SEL = '1'
	else '0';
VBUS_DATA <= DMA_FLASH_D when DMA_FLASH_SEL = '1'
	else DMA_SDRAM_D when DMA_SDRAM_SEL = '1'
	else x"FFFF";

-- 68K INPUTS
TG68_RES_N <= RESET_N;
TG68_CLKE <= '1';

TG68_DTACK_N <= TG68_FLASH_DTACK_N when TG68_FLASH_SEL = '1'
	else TG68_SDRAM_DTACK_N when TG68_SDRAM_SEL = '1' 
	else TG68_ZRAM_DTACK_N when TG68_ZRAM_SEL = '1' 
	else TG68_CTRL_DTACK_N when TG68_CTRL_SEL = '1' 
	else TG68_OS_DTACK_N when TG68_OS_SEL = '1' 
	else TG68_IO_DTACK_N when TG68_IO_SEL = '1' 
	else TG68_BAR_DTACK_N when TG68_BAR_SEL = '1' 
	else TG68_VDP_DTACK_N when TG68_VDP_SEL = '1' 
	else TG68_FM_DTACK_N when TG68_FM_SEL = '1' 
	else '0';
TG68_DI(15 downto 8) <= TG68_FLASH_D(15 downto 8) when TG68_FLASH_SEL = '1' and TG68_UDS_N = '0'
	else TG68_SDRAM_D(15 downto 8) when TG68_SDRAM_SEL = '1' and TG68_UDS_N = '0'
	else TG68_ZRAM_D(15 downto 8) when TG68_ZRAM_SEL = '1' and TG68_UDS_N = '0'
	else TG68_CTRL_D(15 downto 8) when TG68_CTRL_SEL = '1' and TG68_UDS_N = '0'
	else TG68_OS_D(15 downto 8) when TG68_OS_SEL = '1' and TG68_UDS_N = '0'
	else TG68_IO_D(15 downto 8) when TG68_IO_SEL = '1' and TG68_UDS_N = '0'
	else TG68_BAR_D(15 downto 8) when TG68_BAR_SEL = '1' and TG68_UDS_N = '0'
	else TG68_VDP_D(15 downto 8) when TG68_VDP_SEL = '1' and TG68_UDS_N = '0'
	else TG68_FM_D(15 downto 8) when TG68_FM_SEL = '1' and TG68_UDS_N = '0'
	else NO_DATA(15 downto 8);
TG68_DI(7 downto 0) <= TG68_FLASH_D(7 downto 0) when TG68_FLASH_SEL = '1' and TG68_LDS_N = '0'
	else TG68_SDRAM_D(7 downto 0) when TG68_SDRAM_SEL = '1' and TG68_LDS_N = '0'
	else TG68_ZRAM_D(7 downto 0) when TG68_ZRAM_SEL = '1' and TG68_LDS_N = '0'
	else TG68_CTRL_D(7 downto 0) when TG68_CTRL_SEL = '1' and TG68_LDS_N = '0'
	else TG68_OS_D(7 downto 0) when TG68_OS_SEL = '1' and TG68_LDS_N = '0'
	else TG68_IO_D(7 downto 0) when TG68_IO_SEL = '1' and TG68_LDS_N = '0'
	else TG68_BAR_D(7 downto 0) when TG68_BAR_SEL = '1' and TG68_LDS_N = '0'
	else TG68_VDP_D(7 downto 0) when TG68_VDP_SEL = '1' and TG68_LDS_N = '0'
	else TG68_FM_D(7 downto 0) when TG68_FM_SEL = '1' and TG68_LDS_N = '0'
	else NO_DATA(7 downto 0);

-- Z80 INPUTS
process(RESET_N, MCLK, ZRESET_N, ZBUSREQ)
begin
	if RESET_N = '0' then
		T80_RESET_N <= '0';
	elsif rising_edge(MCLK) then
		if T80_RESET_N = '0' then
			if ZBUSREQ = '0' and ZRESET_N = '1' then
				T80_RESET_N <= '1';
			end if;
			ZBUSACK_N <= not ZBUSREQ;
		else
			if ZRESET_N = '0' then
				T80_RESET_N <= '0';
			end if;
			ZBUSACK_N <= T80_BUSAK_N;
		end if;
	end if;
end process;

T80_CLK_N <= MCLK and ZCLK_EN;
--T80_INT_N <= '1';
T80_NMI_N <= '1';
T80_BUSRQ_N <= not ZBUSREQ;

T80_WAIT_N <= not T80_SDRAM_DTACK_N when T80_SDRAM_SEL = '1'
	else not T80_ZRAM_DTACK_N when T80_ZRAM_SEL = '1'
	else not T80_FLASH_DTACK_N when T80_FLASH_SEL = '1'
	else not T80_CTRL_DTACK_N when T80_CTRL_SEL = '1' 
	else not T80_IO_DTACK_N when T80_IO_SEL = '1' 
	else not T80_BAR_DTACK_N when T80_BAR_SEL = '1'
	else not T80_VDP_DTACK_N when T80_VDP_SEL = '1'
	else not T80_FM_DTACK_N when T80_FM_SEL = '1'
	else '1';
T80_DI <= T80_SDRAM_D when T80_SDRAM_SEL = '1'
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
OS_OEn <= '0';

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
		
		ZBUSREQ <= '0';
		ZRESET_N <= '0';
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
					-- ZBUSREQ
					if TG68_UDS_N = '0' then
						ZBUSREQ <= TG68_DO(8);
					end if;
				elsif TG68_A(15 downto 8) = x"12" then
					-- ZRESET_N
					if TG68_UDS_N = '0' then
						ZRESET_N <= TG68_DO(8);
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
					-- ZBUSACK_N
					TG68_CTRL_D(8) <= ZBUSACK_N;
					TG68_CTRL_D(0) <= ZBUSACK_N;
				end if;
			end if;		
		elsif T80_CTRL_SEL = '1' and T80_CTRL_DTACK_N = '1' then
			T80_CTRL_DTACK_N <= '0';
			if T80_WR_N = '0' then
				-- Write
				if BAR(15) & T80_A(14 downto 8) = x"11" then
					-- ZBUSREQ
					if T80_A(0) = '0' then
						ZBUSREQ <= T80_DO(0);
					end if;
				elsif BAR(15) & T80_A(14 downto 8) = x"12" then
					-- ZRESET_N
					if T80_A(0) = '0' then
						ZRESET_N <= T80_DO(0);
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
					-- ZBUSACK_N
					T80_CTRL_D(0) <= ZBUSACK_N;
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
				IO_A <= TG68_A(4 downto 0);
				IO_RNW <= TG68_RNW;
				IO_UDS_N <= TG68_UDS_N;
				IO_LDS_N <= TG68_LDS_N;
				IO_DI <= TG68_DO;
				IOC <= IOC_TG68_ACC;
			elsif T80_IO_SEL = '1' and T80_IO_DTACK_N = '1' then
				IO_SEL <= '1';
				IO_A <= T80_A(4 downto 0);
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
	if TG68_A(23 downto 21) = "110" and TG68_A(18 downto 16) = "000"
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
	elsif T80_A(15) = '1' and BAR(23 downto 21) = "110" and BAR(18 downto 16) = "000" -- 68000 Address space
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
		VDP_UDS_N <= '1';
		VDP_LDS_N <= '1';
		VDP_A <= (others => '0');

		VDPC <= VDPC_IDLE;

		--HEXVALUE <= x"0000";
		
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
				if TG68_A(4) = '1' then 
					-- PSG (used for debug)
					if TG68_A(3 downto 1) = "000" and TG68_LDS_N = '0' and TG68_RNW = '0' then
						--HEXVALUE(15 downto 8) <= TG68_DO(7 downto 0);
					end if;
					if TG68_A(3 downto 1) = "001" and TG68_LDS_N = '0' and TG68_RNW = '0' then
						--HEXVALUE(7 downto 0) <= TG68_DO(7 downto 0);
					end if;					
					TG68_VDP_D <= x"FFFF";
					TG68_VDP_DTACK_N <= '0';
				else
					-- VDP
					VDP_SEL <= '1';
					VDP_A <= TG68_A(4 downto 0);
					VDP_RNW <= TG68_RNW;
					VDP_UDS_N <= TG68_UDS_N;
					VDP_LDS_N <= TG68_LDS_N;
					VDP_DI <= TG68_DO;
					VDPC <= VDPC_TG68_ACC;
				end if;				
			elsif T80_VDP_SEL = '1' and T80_VDP_DTACK_N = '1' then
				if T80_A(4) = '1' then
					-- PSG (used for debug)
					if T80_A(3 downto 0) = "0001" and T80_WR_N = '0' then
						--HEXVALUE(15 downto 8) <= T80_DO;
					end if;
					if T80_A(3 downto 0) = "0011" and T80_WR_N = '0' then
						--HEXVALUE(7 downto 0) <= T80_DO;
					end if;					
					T80_VDP_D <= x"FF";
					T80_VDP_DTACK_N <= '0';
				else
					VDP_SEL <= '1';
					VDP_A <= T80_A(4 downto 0);
					VDP_RNW <= T80_WR_N;
					if T80_A(0) = '0' then
						VDP_UDS_N <= '0';
						VDP_LDS_N <= '1';
					else
						VDP_UDS_N <= '1';
						VDP_LDS_N <= '0';				
					end if;
					VDP_DI <= T80_DO & T80_DO;
					VDPC <= VDPC_T80_ACC;			
				end if;
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
				VDP_UDS_N <= '1';
				VDP_LDS_N <= '1';
				VDP_A <= (others => '0');

				VDPC <= VDPC_IDLE;
			end if;
			
		when others => null;
		end case;
	end if;
	
end process;

-- Z80:
-- 40 = 01000000
-- 5F = 01011111
-- 68000:
-- 40 = 01000000
-- 5F = 01011111
-- C0 = 11000000
-- DF = 11011111
-- FM AREA
process( RESET_N, MCLK, TG68_AS_N, TG68_RNW,
	TG68_A, TG68_DO, TG68_UDS_N, TG68_LDS_N,
	BAR, T80_A, T80_MREQ_N, T80_RD_N, T80_WR_N )
begin
	if TG68_A(23 downto 16) = x"A0" and TG68_A(14 downto 13) = "10"
		and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') 
	then	
		TG68_FM_SEL <= '1';		
	else
		TG68_FM_SEL <= '0';
	end if;

	if T80_A(15 downto 13) = "010"
		and T80_MREQ_N = '0' and (T80_RD_N = '0' or T80_WR_N = '0')
	then
		T80_FM_SEL <= '1';			
	else
		T80_FM_SEL <= '0';
	end if;
	
	if RESET_N = '0' then
		TG68_FM_DTACK_N <= '1';	
		T80_FM_DTACK_N <= '1';	
		
		FM_SEL <= '0';
		FM_RNW <= '1';
--		FM_UDS_N <= '1';
--		FM_LDS_N <= '1';
		FM_A <= (others => '0');
		
		FMC <= FMC_IDLE;
		
	elsif rising_edge(MCLK) then
		if TG68_FM_SEL = '0' then 
			TG68_FM_DTACK_N <= '1';
		end if;
		if T80_FM_SEL = '0' then 
			T80_FM_DTACK_N <= '1';
		end if;

		case FMC is
		when FMC_IDLE =>
			if VCLK='0' then
				if TG68_FM_SEL = '1' and TG68_FM_DTACK_N = '1' then
					FM_SEL <= '1';
					FM_A <= TG68_A(1 downto 0);
					FM_RNW <= TG68_RNW;
					if TG68_A(0)='0' then
						FM_DI <= TG68_DO(15 downto 8);
					else
						FM_DI <= TG68_DO(7 downto 0);
					end if;

	--				FM_UDS_N <= TG68_UDS_N;
	--				FM_LDS_N <= TG68_LDS_N;
	--				FM_DI <= TG68_DO(7 downto 0);
					FMC <= FMC_TG68_ACC;
				elsif T80_FM_SEL = '1' and T80_FM_DTACK_N = '1' then
					FM_SEL <= '1';
					FM_A <= T80_A(1 downto 0);
					FM_RNW <= T80_WR_N;
	--				if T80_A(0) = '0' then
	--					FM_UDS_N <= '0';
	--					FM_LDS_N <= '1';
	--				else
	--					FM_UDS_N <= '1';
	--					FM_LDS_N <= '0';				
	--				end if;
					FM_DI <= T80_DO;
					FMC <= FMC_T80_ACC;			
				end if;
			end if;
		when FMC_TG68_ACC =>
			-- sync this to 8MHz clock
			if VCLK = '1' then
				FM_SEL <= '0';
				TG68_FM_D <= (others=>'0');
				if TG68_A(0)='0' then
					TG68_FM_D(15 downto 8) <= FM_DO;
				else
					TG68_FM_D(7 downto 0) <= FM_DO;
				end if;

				TG68_FM_DTACK_N <= '0';
				FMC <= FMC_DESEL;
			end if;

		when FMC_T80_ACC =>
			-- sync this to 8MHz clock
			if VCLK = '1' then
				FM_SEL <= '0';
--				if T80_A(0) = '0' then
--					T80_FM_D <= FM_DO(15 downto 8);
--				else
					T80_FM_D <= FM_DO;
--				end if;
				T80_FM_DTACK_N <= '0';
				FMC <= FMC_DESEL;
			end if;

		when FMC_DESEL =>
--			if FM_DTACK_N = '1' then
				FM_RNW <= '1';
--				FM_UDS_N <= '1';
--				FM_LDS_N <= '1';
				FM_A <= (others => '0');

				FMC <= FMC_IDLE;
--			end if;
			
		when others => null;
		end case;
	end if;
	
end process;

-- PSG AREA
-- Z80: 7F11h
-- 68k: C00011
process( RESET_N, MCLK, TG68_AS_N, 
	TG68_A, TG68_DO, TG68_UDS_N, TG68_LDS_N,
	BAR, T80_A, T80_MREQ_N, T80_WR_N )
begin
	if T80_A = x"7F11" 
		and T80_MREQ_N = '0' and T80_WR_N = '0'
	then
		T80_PSG_SEL <= '1';			
	else
		T80_PSG_SEL <= '0';
	end if;	

	if TG68_A = x"C00011"
		and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') 
	then	
		TG68_PSG_SEL <= '1';		
	else
		TG68_PSG_SEL <= '0';
	end if;	
	
	if RESET_N = '0' then
		PSG_SEL<= '0';
	elsif rising_edge(MCLK) then
		if VCLK='0' then
			if TG68_PSG_SEL = '1' then
				PSG_SEL <= '1';
				if TG68_A(0)='0' then
					PSG_DI <= TG68_DO(15 downto 8);
				else
					PSG_DI <= TG68_DO(7 downto 0);
				end if;
			elsif T80_PSG_SEL = '1' then
				PSG_SEL <= '1';
				PSG_DI <= T80_DO;		
			end if;
		end if;
	end if;
	
end process;

-- Z80:
-- 60 = 01100000
-- 7E = 01111110
-- 68000:
-- 60 = 01100000
-- 7E = 01111110
-- E0 = 11100000
-- FE = 11111110
-- BANK ADDRESS REGISTER AND UNUSED AREA IN Z80 ADDRESS SPACE
process( RESET_N, MCLK, TG68_AS_N, TG68_RNW,
	TG68_A, TG68_DO, TG68_UDS_N, TG68_LDS_N,
	BAR, T80_A, T80_MREQ_N, T80_RD_N, T80_WR_N )
begin

	if (TG68_A(23 downto 16) = x"A0" and TG68_A(14 downto 13) = "11" and TG68_A(12 downto 8) /= "11111")
		and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') 
	then	
		TG68_BAR_SEL <= '1';		
	else
		TG68_BAR_SEL <= '0';
	end if;

	if (T80_A(15 downto 13) = "011" and T80_A(12 downto 8) /= "11111")
		and T80_MREQ_N = '0' and (T80_RD_N = '0' or T80_WR_N = '0')
	then
		T80_BAR_SEL <= '1';
	else
		T80_BAR_SEL <= '0';
	end if;
	
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
				if TG68_A(23 downto 16) = x"A0" and TG68_A(14 downto 8) = "1100000" and TG68_UDS_N = '0' then
					BAR <= TG68_DO(8) & BAR(23 downto 16);
				end if;
			else
				TG68_BAR_D <= x"FFFF";
			end if;
			TG68_BAR_DTACK_N <= '0';
		elsif T80_BAR_SEL = '1' and T80_BAR_DTACK_N = '1' then
			if T80_WR_N = '0' then
				if T80_A(15 downto 8) = x"60" then
					BAR <= T80_DO(0) & BAR(23 downto 16);
				end if;
			else
				T80_BAR_D <= x"FF";
			end if;
			T80_BAR_DTACK_N <= '0';
		end if;
	end if;
end process;


-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- MiST Memory Handling
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------

-- FLASH (SDRAM) CONTROL
process( RESET_N, MCLK, TG68_AS_N, TG68_RNW,
	TG68_A, TG68_DO, TG68_UDS_N, TG68_LDS_N,
	BAR, T80_A, T80_MREQ_N, T80_RD_N, T80_WR_N,
	VBUS_SEL, VBUS_ADDR,
	CART_EN )
begin

	if TG68_A(23) = '0' 
		and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') 
		and TG68_RNW = '1' 
		and CART_EN = '1'
	then
		TG68_FLASH_SEL <= '1';
	else
		TG68_FLASH_SEL <= '0';
	end if;

	if T80_A(15) = '1' and BAR(23) = '0'
		and T80_MREQ_N = '0' and T80_RD_N = '0' 
	then
		T80_FLASH_SEL <= '1';
	else
		T80_FLASH_SEL <= '0';
	end if;	

	if VBUS_ADDR(23) = '0' 
		and VBUS_SEL = '1'
	then
		DMA_FLASH_SEL <= '1';
	else
		DMA_FLASH_SEL <= '0';
	end if;

	if RESET_N = '0' then
		FC <= FC_IDLE;
		
		TG68_FLASH_DTACK_N <= '1';
		T80_FLASH_DTACK_N <= '1';
		DMA_FLASH_DTACK_N <= '1';

		romrd_req <= '0';
		romrd_a_cached <= (others => '1');
		romrd_q_cached <= (others => '0');
		
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
			if VCLKCNT = "001" then
				if TG68_FLASH_SEL = '1' and TG68_FLASH_DTACK_N = '1' then
					-- FF_FL_ADDR <= TG68_A(21 downto 0);
					if useCache and (TG68_A(22 downto 3) = romrd_a_cached(21 downto 3)) then
						case TG68_A(2 downto 1) is
						when "00" =>
							if TG68_UDS_N = '0' then TG68_FLASH_D(15 downto 8) <= romrd_q_cached(15 downto 8); end if;
							if TG68_LDS_N = '0' then TG68_FLASH_D(7 downto 0) <= romrd_q_cached(7 downto 0); end if;

						when "01" =>
							if TG68_UDS_N = '0' then TG68_FLASH_D(15 downto 8) <= romrd_q_cached(31 downto 24); end if;
							if TG68_LDS_N = '0' then TG68_FLASH_D(7 downto 0) <= romrd_q_cached(23 downto 16); end if;

						when "10" =>
							if TG68_UDS_N = '0' then TG68_FLASH_D(15 downto 8) <= romrd_q_cached(47 downto 40); end if;
							if TG68_LDS_N = '0' then TG68_FLASH_D(7 downto 0) <= romrd_q_cached(39 downto 32); end if;

						when "11" =>
							if TG68_UDS_N = '0' then TG68_FLASH_D(15 downto 8) <= romrd_q_cached(63 downto 56); end if;
							if TG68_LDS_N = '0' then TG68_FLASH_D(7 downto 0) <= romrd_q_cached(55 downto 48); end if;

						when others => null;
						end case;
						TG68_FLASH_DTACK_N <= '0';
					else
						romrd_req <= not romrd_req;
						romrd_a <= TG68_A(22 downto 3);
						romrd_a_cached <= TG68_A(22 downto 3);
						FC <= FC_TG68_RD;
					end if;
				elsif T80_FLASH_SEL = '1' and T80_FLASH_DTACK_N = '1' then
					-- FF_FL_ADDR <= BAR(21 downto 15) & T80_A(14 downto 0);
					if useCache and (BAR(22 downto 15) & T80_A(14 downto 3) = romrd_a_cached(21 downto 3)) then
-- /!\
						case T80_A(2 downto 0) is
						when "001" =>
							T80_FLASH_D <= romrd_q_cached(7 downto 0);
						when "000" =>
							T80_FLASH_D <= romrd_q_cached(15 downto 8);
						when "011" =>
							T80_FLASH_D <= romrd_q_cached(23 downto 16);
						when "010" =>
							T80_FLASH_D <= romrd_q_cached(31 downto 24);
						when "101" =>
							T80_FLASH_D <= romrd_q_cached(39 downto 32);
						when "100" =>
							T80_FLASH_D <= romrd_q_cached(47 downto 40);
						when "111" =>
							T80_FLASH_D <= romrd_q_cached(55 downto 48);
						when "110" =>
							T80_FLASH_D <= romrd_q_cached(63 downto 56);
						when others => null;
						end case;
						T80_FLASH_DTACK_N <= '0';
					else
						romrd_req <= not romrd_req;
						romrd_a <= BAR(22 downto 15) & T80_A(14 downto 3);
						romrd_a_cached <= BAR(22 downto 15) & T80_A(14 downto 3);		
						FC <= FC_T80_RD;
					end if;
				elsif DMA_FLASH_SEL = '1' and DMA_FLASH_DTACK_N = '1' then
					-- FF_FL_ADDR <= VBUS_ADDR(21 downto 0);
					if useCache and (VBUS_ADDR(22 downto 3) = romrd_a_cached(21 downto 3)) then
						case VBUS_ADDR(2 downto 1) is
						when "00" =>
							DMA_FLASH_D <= romrd_q_cached(15 downto 0);
						when "01" =>
							DMA_FLASH_D <= romrd_q_cached(31 downto 16);
						when "10" =>
							DMA_FLASH_D <= romrd_q_cached(47 downto 32);
						when "11" =>
							DMA_FLASH_D <= romrd_q_cached(63 downto 48);
						when others => null;
						end case;
						DMA_FLASH_DTACK_N <= '0';
					else
						romrd_req <= not romrd_req;
						romrd_a <= VBUS_ADDR(22 downto 3);
						romrd_a_cached <= VBUS_ADDR(22 downto 3);
						FC <= FC_DMA_RD;
					end if;					
				end if;				
			end if;
		
		when FC_TG68_RD =>
			if romrd_req = romrd_ack then
				romrd_q_cached <= romrd_q;
				case TG68_A(2 downto 1) is
				when "00" =>
					if TG68_UDS_N = '0' then TG68_FLASH_D(15 downto 8) <= romrd_q(15 downto 8); end if;
					if TG68_LDS_N = '0' then TG68_FLASH_D(7 downto 0) <= romrd_q(7 downto 0); end if;

				when "01" =>
					if TG68_UDS_N = '0' then TG68_FLASH_D(15 downto 8) <= romrd_q(31 downto 24); end if;
					if TG68_LDS_N = '0' then TG68_FLASH_D(7 downto 0) <= romrd_q(23 downto 16); end if;

				when "10" =>
					if TG68_UDS_N = '0' then TG68_FLASH_D(15 downto 8) <= romrd_q(47 downto 40); end if;
					if TG68_LDS_N = '0' then TG68_FLASH_D(7 downto 0) <= romrd_q(39 downto 32); end if;

				when "11" =>
					if TG68_UDS_N = '0' then TG68_FLASH_D(15 downto 8) <= romrd_q(63 downto 56); end if;
					if TG68_LDS_N = '0' then TG68_FLASH_D(7 downto 0) <= romrd_q(55 downto 48); end if;

				when others => null;
				end case;				
				TG68_FLASH_DTACK_N <= '0';
				FC <= FC_IDLE;
			end if;

		when FC_T80_RD =>
			if romrd_req = romrd_ack then
				romrd_q_cached <= romrd_q;
-- /!\
				case T80_A(2 downto 0) is
				when "001" =>
					T80_FLASH_D <= romrd_q(7 downto 0);
				when "000" =>
					T80_FLASH_D <= romrd_q(15 downto 8);
				when "011" =>
					T80_FLASH_D <= romrd_q(23 downto 16);
				when "010" =>
					T80_FLASH_D <= romrd_q(31 downto 24);
				when "101" =>
					T80_FLASH_D <= romrd_q(39 downto 32);
				when "100" =>
					T80_FLASH_D <= romrd_q(47 downto 40);
				when "111" =>
					T80_FLASH_D <= romrd_q(55 downto 48);
				when "110" =>
					T80_FLASH_D <= romrd_q(63 downto 56);
				when others => null;
				end case;
				T80_FLASH_DTACK_N <= '0';
				FC <= FC_IDLE;
			end if;
		
		when FC_DMA_RD =>
			if romrd_req = romrd_ack then
				romrd_q_cached <= romrd_q;
				case VBUS_ADDR(2 downto 1) is
				when "00" =>
					DMA_FLASH_D <= romrd_q(15 downto 0);
				when "01" =>
					DMA_FLASH_D <= romrd_q(31 downto 16);
				when "10" =>
					DMA_FLASH_D <= romrd_q(47 downto 32);
				when "11" =>
					DMA_FLASH_D <= romrd_q(63 downto 48);
				when others => null;
				end case;
				DMA_FLASH_DTACK_N <= '0';
				FC <= FC_IDLE;
			end if;
				
		when others => null;
		end case;
	
	end if;

end process;





-- SDRAM (68K RAM) CONTROL
process( RESET_N, MCLK, TG68_AS_N, TG68_RNW,
	TG68_A, TG68_DO, TG68_UDS_N, TG68_LDS_N,
	BAR, T80_A, T80_MREQ_N, T80_RD_N, T80_WR_N,
	VBUS_SEL, VBUS_ADDR)
begin
	if TG68_A(23 downto 21) = "111" -- 68000 RAM
		and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') 
	then	
		TG68_SDRAM_SEL <= '1';
	else
		TG68_SDRAM_SEL <= '0';
	end if;

	if T80_A(15) = '1' and BAR(23 downto 21) = "111" -- 68000 RAM
		and T80_MREQ_N = '0' and (T80_RD_N = '0' or T80_WR_N = '0')
	then
		T80_SDRAM_SEL <= '1';
	else
		T80_SDRAM_SEL <= '0';
	end if;

	if VBUS_ADDR(23 downto 21) = "111" -- 68000 RAM
		and VBUS_SEL = '1' 
	then
		DMA_SDRAM_SEL <= '1';
	else
		DMA_SDRAM_SEL <= '0';
	end if;

	if RESET_N = '0' then
		TG68_SDRAM_DTACK_N <= '1';
		T80_SDRAM_DTACK_N <= '1';
		DMA_SDRAM_DTACK_N <= '1';

		ram68k_req <= '0';
		
		SDRC <= SDRC_IDLE;
		
	elsif rising_edge(MCLK) then
		if TG68_SDRAM_SEL = '0' then 
			TG68_SDRAM_DTACK_N <= '1';
		end if;	
		if T80_SDRAM_SEL = '0' then 
			T80_SDRAM_DTACK_N <= '1';
		end if;	
		if DMA_SDRAM_SEL = '0' then 
			DMA_SDRAM_DTACK_N <= '1';
		end if;	

		case SDRC is
		when SDRC_IDLE =>
			if VCLKCNT = "001" then
				if TG68_SDRAM_SEL = '1' and TG68_SDRAM_DTACK_N = '1' then
					ram68k_req <= not ram68k_req;
					ram68k_a <= TG68_A(15 downto 1);
					ram68k_d <= TG68_DO;
					ram68k_we <= not TG68_RNW;
					ram68k_u_n <= TG68_UDS_N;
					ram68k_l_n <= TG68_LDS_N;
					SDRC <= SDRC_TG68;
				elsif T80_SDRAM_SEL = '1' and T80_SDRAM_DTACK_N = '1' then
					ram68k_req <= not ram68k_req;
					ram68k_a <= BAR(15) & T80_A(14 downto 1);
					ram68k_d <= T80_DO & T80_DO;
					ram68k_we <= not T80_WR_N;
					ram68k_u_n <= T80_A(0);
					ram68k_l_n <= not T80_A(0);
					SDRC <= SDRC_T80;
				elsif DMA_SDRAM_SEL = '1' and DMA_SDRAM_DTACK_N = '1' then
					ram68k_req <= not ram68k_req;
					ram68k_a <= VBUS_ADDR(15 downto 1);
					ram68k_we <= '0';
					ram68k_u_n <= '0';
					ram68k_l_n <= '0';					
					SDRC <= SDRC_DMA;
				end if;
			end if;

		when SDRC_TG68 =>
			if ram68k_req = ram68k_ack then
				TG68_SDRAM_D <= ram68k_q;
				TG68_SDRAM_DTACK_N <= '0';
				SDRC <= SDRC_IDLE;
			end if;
		
		when SDRC_T80 =>
			if ram68k_req = ram68k_ack then
				if T80_A(0) = '0' then
					T80_SDRAM_D <= ram68k_q(15 downto 8);
				else
					T80_SDRAM_D <= ram68k_q(7 downto 0);
				end if;
				T80_SDRAM_DTACK_N <= '0';
				SDRC <= SDRC_IDLE;
			end if;

		when SDRC_DMA =>
			if ram68k_req = ram68k_ack then
				DMA_SDRAM_D <= ram68k_q;
				DMA_SDRAM_DTACK_N <= '0';
				SDRC <= SDRC_IDLE;
			end if;
		
		when others => null;
		end case;
		
	end if;

end process;





-- Z80 RAM CONTROL
process( RESET_N, MCLK, TG68_AS_N, TG68_RNW,
	TG68_A, TG68_DO, TG68_UDS_N, TG68_LDS_N,
	BAR, T80_A, T80_MREQ_N, T80_RD_N, T80_WR_N,
	VBUS_SEL, VBUS_ADDR)
begin
	if TG68_A(23 downto 16) = x"A0" -- Z80 Address Space
		and TG68_A(14) = '0' -- Z80 RAM (gen-hw.txt lines 89 and 272-273)
		and TG68_AS_N = '0' and (TG68_UDS_N = '0' or TG68_LDS_N = '0') 
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
			if VCLKCNT = "001" then
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


-- #############################################################################
-- #############################################################################
-- #############################################################################
-- #############################################################################
-- #############################################################################
-- #############################################################################

-- DEBUG

-- synthesis translate_off
process( MCLK )
	file F		: text open write_mode is "gen.out";
	variable L	: line;
	variable rom_q : std_logic_vector(15 downto 0);
begin
	if rising_edge( MCLK ) then

		-- ROM ACCESS
		if FC = FC_TG68_RD and romrd_req = romrd_ack then
			write(L, string'("68K "));
			write(L, string'("RD"));
			write(L, string'(" ROM     ["));
			hwrite(L, TG68_A(23 downto 0));
			write(L, string'("] = ["));
			rom_q := x"FFFF";
			case TG68_A(2 downto 1) is
			when "00" =>
				if TG68_UDS_N = '0' then rom_q(15 downto 8) := romrd_q(15 downto 8); end if;
				if TG68_LDS_N = '0' then rom_q(7 downto 0) := romrd_q(7 downto 0); end if;

			when "01" =>
				if TG68_UDS_N = '0' then rom_q(15 downto 8) := romrd_q(31 downto 24); end if;
				if TG68_LDS_N = '0' then rom_q(7 downto 0) := romrd_q(23 downto 16); end if;

			when "10" =>
				if TG68_UDS_N = '0' then rom_q(15 downto 8) := romrd_q(47 downto 40); end if;
				if TG68_LDS_N = '0' then rom_q(7 downto 0) := romrd_q(39 downto 32); end if;

			when "11" =>
				if TG68_UDS_N = '0' then rom_q(15 downto 8) := romrd_q(63 downto 56); end if;
				if TG68_LDS_N = '0' then rom_q(7 downto 0) := romrd_q(55 downto 48); end if;

			when others => null;
			end case;				
			if TG68_UDS_N = '0' and TG68_LDS_N = '0' then
				hwrite(L, rom_q);
			elsif TG68_UDS_N = '0' then
				hwrite(L, rom_q(15 downto 8));
				write(L, string'("  "));
			else
				write(L, string'("  "));
				hwrite(L, rom_q(7 downto 0));
			end if;								
			write(L, string'("]"));
			writeline(F,L);			
		end if;		

	
		-- 68K RAM ACCESS
		if SDRC = SDRC_TG68 and ram68k_req = ram68k_ack then
			write(L, string'("68K "));
			if TG68_RNW = '0' then
				write(L, string'("WR"));
			else
				write(L, string'("RD"));
			end if;
			write(L, string'(" RAM-68K ["));
			hwrite(L, TG68_A(23 downto 0));
			write(L, string'("] = ["));
			if TG68_RNW = '0' then
				if TG68_UDS_N = '0' and TG68_LDS_N = '0' then
					hwrite(L, TG68_DO);
				elsif TG68_UDS_N = '0' then
					hwrite(L, TG68_DO(15 downto 8));
					write(L, string'("  "));
				else
					write(L, string'("  "));
					hwrite(L, TG68_DO(7 downto 0));
				end if;				
			else
				if TG68_UDS_N = '0' and TG68_LDS_N = '0' then
					hwrite(L, ram68k_q);
				elsif TG68_UDS_N = '0' then
					hwrite(L, ram68k_q(15 downto 8));
					write(L, string'("  "));
				else
					write(L, string'("  "));
					hwrite(L, ram68k_q(7 downto 0));
				end if;								
			end if;
			write(L, string'("]"));
			writeline(F,L);			
		end if;		

		
		-- Z80 RAM ACCESS
		if ZRC = ZRC_ACC3 and ZRCP = ZRCP_TG68 then
			write(L, string'("68K "));
			if TG68_RNW = '0' then
				write(L, string'("WR"));
			else
				write(L, string'("RD"));
			end if;
			write(L, string'(" RAM-Z80 ["));
			hwrite(L, TG68_A(23 downto 0));
			write(L, string'("] = ["));
			if TG68_RNW = '0' then
				if TG68_UDS_N = '0' and TG68_LDS_N = '0' then
					hwrite(L, TG68_DO);
				elsif TG68_UDS_N = '0' then
					hwrite(L, TG68_DO(15 downto 8));
					write(L, string'("  "));
				else
					write(L, string'("  "));
					hwrite(L, TG68_DO(7 downto 0));
				end if;				
			else
				if TG68_UDS_N = '0' and TG68_LDS_N = '0' then
					hwrite(L, zram_q & zram_q);
				elsif TG68_UDS_N = '0' then
					hwrite(L, zram_q);
					write(L, string'("  "));
				else
					write(L, string'("  "));
					hwrite(L, zram_q);
				end if;				
			end if;
			write(L, string'("]"));
			writeline(F,L);			
		end if;		

		
		-- 68K CTRL ACCESS
		if TG68_CTRL_SEL = '1' and TG68_CTRL_DTACK_N = '1' then
			write(L, string'("68K "));
			if TG68_RNW = '0' then
				write(L, string'("WR"));
			else
				write(L, string'("RD"));
			end if;
			write(L, string'("    CTRL ["));
			hwrite(L, TG68_A(23 downto 0));
			write(L, string'("] = ["));
			if TG68_RNW = '0' then
				if TG68_UDS_N = '0' and TG68_LDS_N = '0' then
					hwrite(L, TG68_DO);
				elsif TG68_UDS_N = '0' then
					hwrite(L, TG68_DO(15 downto 8));
					write(L, string'("  "));
				else
					write(L, string'("  "));
					hwrite(L, TG68_DO(7 downto 0));
				end if;				
			else
				if TG68_UDS_N = '0' and TG68_LDS_N = '0' then
					write(L, string'("????"));
				elsif TG68_UDS_N = '0' then
					write(L, string'("??"));
					write(L, string'("  "));
				else
					write(L, string'("  "));
					write(L, string'("??"));
				end if;								
			end if;
			write(L, string'("]"));
			writeline(F,L);							
		end if;

		-- 68K I/O ACCESS
		if IOC = IOC_TG68_ACC and IO_DTACK_N = '0' then
			write(L, string'("68K "));
			if TG68_RNW = '0' then
				write(L, string'("WR"));
			else
				write(L, string'("RD"));
			end if;
			write(L, string'("     I/O ["));
			hwrite(L, TG68_A(23 downto 0));
			write(L, string'("] = ["));
			if TG68_RNW = '0' then
				if TG68_UDS_N = '0' and TG68_LDS_N = '0' then
					hwrite(L, TG68_DO);
				elsif TG68_UDS_N = '0' then
					hwrite(L, TG68_DO(15 downto 8));
					write(L, string'("  "));
				else
					write(L, string'("  "));
					hwrite(L, TG68_DO(7 downto 0));
				end if;				
			else
				if TG68_UDS_N = '0' and TG68_LDS_N = '0' then
					hwrite(L, IO_DO);
				elsif TG68_UDS_N = '0' then
					hwrite(L, IO_DO(15 downto 8));
					write(L, string'("  "));
				else
					write(L, string'("  "));
					hwrite(L, IO_DO(7 downto 0));
				end if;								
			end if;
			write(L, string'("]"));
			writeline(F,L);					
		end if;
		
		-- 68K VDP ACCESS
		if VDPC = VDPC_TG68_ACC and VDP_DTACK_N = '0' then
			write(L, string'("68K "));
			if TG68_RNW = '0' then
				write(L, string'("WR"));
			else
				write(L, string'("RD"));
			end if;
			write(L, string'("     VDP ["));
			hwrite(L, TG68_A(23 downto 0));
			write(L, string'("] = ["));
			if TG68_RNW = '0' then
				if TG68_UDS_N = '0' and TG68_LDS_N = '0' then
					hwrite(L, TG68_DO);
				elsif TG68_UDS_N = '0' then
					hwrite(L, TG68_DO(15 downto 8));
					write(L, string'("  "));
				else
					write(L, string'("  "));
					hwrite(L, TG68_DO(7 downto 0));
				end if;				
			else
				if TG68_UDS_N = '0' and TG68_LDS_N = '0' then
					hwrite(L, VDP_DO);
				elsif TG68_UDS_N = '0' then
					hwrite(L, VDP_DO(15 downto 8));
					write(L, string'("  "));
				else
					write(L, string'("  "));
					hwrite(L, VDP_DO(7 downto 0));
				end if;								
			end if;
			write(L, string'("]"));
			writeline(F,L);					
		end if;
		
	end if;
end process;
-- synthesis translate_on

end rtl;
