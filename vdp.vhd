-- Copyright (c) 2010 Gregory Estrade (greg@torlus.com)
-- Copyright (c) 2018 Sorgelig
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

entity vdp is
	port(
		RST_N				: in std_logic;
		CLK				: in std_logic;
		MEMCLK			: in std_logic;

		SEL				: in std_logic;
		A					: in std_logic_vector(4 downto 0);
		RNW				: in std_logic;
		DI					: in std_logic_vector(15 downto 0);
		DO					: out std_logic_vector(15 downto 0);
		DTACK_N			: out std_logic;

		vram_req 		: out std_logic;
		vram_ack 		: in std_logic;
		vram_we 			: out std_logic;
		vram_a 			: buffer std_logic_vector(14 downto 0);
		vram_d 			: out std_logic_vector(15 downto 0);
		vram_q 			: in std_logic_vector(15 downto 0);
		vram_u_n 		: out std_logic;
		vram_l_n 		: out std_logic;

		HINT				: out std_logic;
		HINT_ACK			: in std_logic;

		VINT_TG68		: out std_logic;
		VINT_T80			: out std_logic;
		VINT_TG68_ACK	: in std_logic;
		VINT_T80_ACK	: in std_logic;

		VBUS_ADDR		: out std_logic_vector(23 downto 0);
		VBUS_DATA		: in std_logic_vector(15 downto 0);
		VBUS_SEL			: out std_logic;
		VBUS_DTACK_N	: in std_logic;
		VBUS_BUSY      : out std_logic;

		PAL				: in std_logic := '0';
		FIELD      		: out std_logic;
		INTERLACE 		: out std_logic;
		R					: out std_logic_vector(2 downto 0);
		G					: out std_logic_vector(2 downto 0);
		B					: out std_logic_vector(2 downto 0);
		HS					: out std_logic;
		VS					: out std_logic;
		HBL   			: out std_logic;
		VBL   			: out std_logic;
		CE_PIX			: out std_logic
	);
end vdp;

architecture rtl of vdp is

----------------------------------------------------------------
-- Video parameters
----------------------------------------------------------------

constant HDISP_START_256 : integer := 46;
constant HDISP_END_256   : integer := HDISP_START_256+256;
constant HSYNC_START_256 : integer := 322;
constant HSYNC_SZ_256    : integer := 32;
constant HTOTAL_256      : integer := 342;
constant VSYNC_START_256i: integer := (HSYNC_START_256 + (HTOTAL_256/2)) mod HTOTAL_256;

constant HDISP_START_320 : integer := 46;
constant HDISP_END_320   : integer := HDISP_START_320+320;
constant HSYNC_START_320 : integer := 390;
constant HSYNC_SZ_320    : integer := 26;
constant HTOTAL_320      : integer := 427;
constant VSYNC_START_320i: integer := (HSYNC_START_320 + (HTOTAL_320/2)) mod HTOTAL_320;

constant VDISP_START_224 : integer := 27;
constant VDISP_END_224   : integer := VDISP_START_224+224;
constant VSYNC_START_224N: integer := 1;
constant VSYNC_SZ_224    : integer := 3;
constant VTOTAL_224      : integer := 262;

constant VDISP_START_240 : integer := 46;
constant VDISP_END_240   : integer := VDISP_START_240+240;
constant VSYNC_START_240 : integer := 310;
constant VSYNC_START_224P: integer := 286;
constant VSYNC_SZ_240    : integer := 3;
constant VTOTAL_240      : integer := 312;

signal HDISP_START : std_logic_vector(8 downto 0);
signal HDISP_END   : std_logic_vector(8 downto 0);
signal HTOTAL    	 : std_logic_vector(8 downto 0);
signal HSYNC_START : std_logic_vector(8 downto 0);
signal HSYNC_SZ    : std_logic_vector(8 downto 0);
signal VDISP_START : std_logic_vector(8 downto 0);
signal VDISP_END   : std_logic_vector(8 downto 0);
signal VTOTAL      : std_logic_vector(8 downto 0);
signal VSYNC_START : std_logic_vector(8 downto 0);
signal VSYNC_STARTi: std_logic_vector(8 downto 0);
signal VSYNC_SZ    : std_logic_vector(8 downto 0);

----------------------------------------------------------------
----------------------------------------------------------------


signal vram_req_reg : std_logic;
signal vram_we_reg  : std_logic;
signal vram_d_reg   : std_logic_vector(15 downto 0);
signal vram_u_n_reg : std_logic;
signal vram_l_n_reg : std_logic;

----------------------------------------------------------------
-- ON-CHIP RAMS
----------------------------------------------------------------
type cram_t is array(0 to 63) of std_logic_vector(15 downto 0);
signal CRAM			: cram_t;
type vsram_t is array(0 to 63) of std_logic_vector(15 downto 0);
signal VSRAM		: vsram_t;

----------------------------------------------------------------
-- CPU INTERFACE
----------------------------------------------------------------
signal FF_DTACK_N	: std_logic;
signal FF_DO		: std_logic_vector(15 downto 0);

type reg_t is array(0 to 31) of std_logic_vector(7 downto 0);
signal REG			: reg_t;
signal PENDING		: std_logic;
signal ADDR_LATCH	: std_logic_vector(15 downto 0);
signal REG_LATCH	: std_logic_vector(15 downto 0);
signal CODE			: std_logic_vector(5 downto 0);

type fifo_size_t is array(0 to 3) of std_logic;
signal FIFO_SIZE	: fifo_size_t;
type fifo_addr_t is array(0 to 3) of std_logic_vector(15 downto 0);
signal FIFO_ADDR	: fifo_addr_t;
type fifo_data_t is array(0 to 3) of std_logic_vector(15 downto 0);
signal FIFO_DATA	: fifo_data_t;
type fifo_code_t is array(0 to 3) of std_logic_vector(2 downto 0);
signal FIFO_CODE	: fifo_code_t;
signal FIFO_WR_POS: std_logic_vector(1 downto 0);
signal FIFO_RD_POS: std_logic_vector(1 downto 0);
signal FIFO_EMPTY	: std_logic;
signal FIFO_FULL	: std_logic;

signal IN_DMA		: std_logic;
signal IN_HBL		: std_logic;
signal IN_VBL		: std_logic;

signal SOVR			: std_logic;
signal SOVR_SET	: std_logic;
signal SOVR_CLR	: std_logic;

signal SCOL			: std_logic;
signal SCOL_SET	: std_logic;
signal SCOL_CLR	: std_logic;

----------------------------------------------------------------
-- INTERRUPTS
----------------------------------------------------------------
signal HINT_COUNT		: std_logic_vector(7 downto 0);
signal HINT_PENDING	: std_logic;
signal HINT_PENDING_SET	: std_logic;
signal HINT_FF			: std_logic;

signal VINT_TG68_PENDING		: std_logic;
signal VINT_TG68_PENDING_SET	: std_logic;
signal VINT_TG68_FF				: std_logic;

signal VINT_T80_SET	: std_logic;
signal VINT_T80_CLR	: std_logic;
signal VINT_T80_FF	: std_logic;

----------------------------------------------------------------
-- REGISTERS
----------------------------------------------------------------
signal H40			: std_logic;
signal V30			: std_logic;

signal ADDR_STEP	: std_logic_vector(7 downto 0);

signal HSCR 		: std_logic_vector(1 downto 0);
signal HSIZE		: std_logic_vector(1 downto 0);
signal VSIZE		: std_logic_vector(1 downto 0);
signal VSCR 		: std_logic;

signal WVP			: std_logic_vector(4 downto 0);
signal WDOWN		: std_logic;
signal WHP			: std_logic_vector(4 downto 0);
signal WRIGT		: std_logic;

signal BGCOL		: std_logic_vector(5 downto 0);

signal HIT			: std_logic_vector(7 downto 0);
signal IE1			: std_logic;
signal IE0			: std_logic;
signal DE			: std_logic;
signal M3			: std_logic;

signal DMA			: std_logic;

signal LSM			: std_logic_vector(1 downto 0);

signal HV8			: std_logic;
signal HV			: std_logic_vector(15 downto 0);

signal STATUS		: std_logic_vector(15 downto 0);

-- Base addresses
signal HSCB			: std_logic_vector(5 downto 0);
signal NTBB			: std_logic_vector(2 downto 0);
signal NTWB			: std_logic_vector(4 downto 0);
signal NTAB			: std_logic_vector(2 downto 0);
signal SATB			: std_logic_vector(6 downto 0);


----------------------------------------------------------------
-- DATA TRANSFER CONTROLLER
----------------------------------------------------------------
signal DT_ACTIVE	: std_logic;

type dtc_t is (
	DTC_IDLE,
	DTC_VRAM_WR,
	DTC_VRAM_RD,
	DTC_DMA_FILL_WR,
	DTC_DMA_FILL_LOOP,
	DTC_DMA_COPY_RD,
	DTC_DMA_COPY_RD2,
	DTC_DMA_COPY_WR,
	DTC_DMA_COPY_LOOP,
	DTC_DMA_VBUS_RD,
	DTC_DMA_VBUS_RD2,
	DTC_DMA_VBUS_LOOP
);
signal DTC	: dtc_t;

signal DT_VRAM_SEL	: std_logic;
signal DT_VRAM_ADDR	: std_logic_vector(14 downto 0);
signal DT_VRAM_DI		: std_logic_vector(15 downto 0);
signal DT_VRAM_DO		: std_logic_vector(15 downto 0);
signal DT_VRAM_DO_REG: std_logic_vector(15 downto 0);
signal DT_VRAM_RNW	: std_logic;
signal DT_VRAM_UDS_N	: std_logic;
signal DT_VRAM_LDS_N	: std_logic;
signal DT_VRAM_DTACK_N: std_logic;

signal DT_FF_DATA		: std_logic_vector(15 downto 0);
signal DT_FF_CODE		: std_logic_vector(2 downto 0);
signal DT_FF_SEL		: std_logic;
signal DT_FF_DTACK_N	: std_logic;

signal DT_RD_DATA		: std_logic_vector(15 downto 0);
signal DT_RD_CODE		: std_logic_vector(3 downto 0);
signal DT_RD_SEL		: std_logic;
signal DT_RD_DTACK_N	: std_logic;

signal ADDR				: std_logic_vector(15 downto 0);
signal ADDR_SET_REQ	: std_logic;
signal ADDR_SET_ACK	: std_logic;
signal REG_SET_REQ	: std_logic;
signal REG_SET_ACK	: std_logic;

signal DT_DMAF_DATA	: std_logic_vector(15 downto 0);
signal DMAF_SET_REQ	: std_logic;
signal DMAF_SET_ACK	: std_logic;


signal FF_VBUS_ADDR	: std_logic_vector(23 downto 0);
signal FF_VBUS_SEL	: std_logic;

signal DMA_VBUS		: std_logic;
signal DMA_FILL_PRE	: std_logic;
signal DMA_FILL		: std_logic;
signal DMA_COPY		: std_logic;

----------------------------------------------------------------
-- VIDEO COUNTING
----------------------------------------------------------------
signal H_CNT		: std_logic_vector(8 downto 0);
signal V_CNT		: std_logic_vector(8 downto 0);

signal PRE_Y		: std_logic_vector(8 downto 0);

signal ODD			: std_logic;
signal PIXDIV		: std_logic_vector(3 downto 0);

----------------------------------------------------------------
-- VRAM CONTROLLER
----------------------------------------------------------------

type vmc_t is (
	VMC_IDLE,
	VMC_BGB,
	VMC_BGA,
	VMC_SP1,
	VMC_SP2,
	VMC_DT
);
signal VMC	: vmc_t := VMC_IDLE;
signal VMC_NEXT : vmc_t := VMC_IDLE;
--signal VMC_SEL	: vmc_t := VMC_IDLE;

signal early_ack_bga : std_logic;
signal early_ack_bgb : std_logic;
signal early_ack_sp1 : std_logic;
signal early_ack_sp2 : std_logic;
signal early_ack_dt	: std_logic;
signal early_ack 		: std_logic;

----------------------------------------------------------------
-- BACKGROUND RENDERING
----------------------------------------------------------------
signal BGEN_ACTIVE	: std_logic;
signal BG_Y				: std_logic_vector(7 downto 0);

-- BACKGROUND B
type bgbc_t is (
	BGBC_INIT,
	BGBC_HS_RD,
	BGBC_CALC_Y,
	BGBC_BASE_RD,
	BGBC_LOOP,
	BGBC_LOOP_WR,
	BGBC_TILE_RD,
	BGBC_DONE
);
signal BGBC		: bgbc_t;

-- signal BGB_COLINFO		: colinfo_t;
signal BGB_COLINFO_ADDR_A	: std_logic_vector(8 downto 0);
signal BGB_COLINFO_ADDR_B	: std_logic_vector(8 downto 0);
signal BGB_COLINFO_D_A		: std_logic_vector(6 downto 0);
signal BGB_COLINFO_WE_A		: std_logic;
signal BGB_COLINFO_Q_B		: std_logic_vector(6 downto 0);

signal BGB_VRAM_ADDR			: std_logic_vector(14 downto 0);
signal BGB_VRAM_DO			: std_logic_vector(15 downto 0);
signal BGB_VRAM_DO_REG		: std_logic_vector(15 downto 0);
signal BGB_SEL					: std_logic;
signal BGB_DTACK_N			: std_logic;

-- BACKGROUND A
type bgac_t is (
	BGAC_INIT,
	BGAC_HS_RD,
	BGAC_CALC_Y,
	BGAC_BASE_RD,
	BGAC_LOOP,
	BGAC_TILE_RD,
	BGAC_DONE
);
signal BGAC		: bgac_t;

-- signal BGA_COLINFO		: colinfo_t;
signal BGA_COLINFO_ADDR_A	: std_logic_vector(8 downto 0);
signal BGA_COLINFO_ADDR_B	: std_logic_vector(8 downto 0);
signal BGA_COLINFO_D_A		: std_logic_vector(6 downto 0);
signal BGA_COLINFO_WE_A		: std_logic;
signal BGA_COLINFO_Q_B		: std_logic_vector(6 downto 0);

signal BGA_VRAM_ADDR			: std_logic_vector(14 downto 0);
signal BGA_VRAM_DO			: std_logic_vector(15 downto 0);
signal BGA_VRAM_DO_REG		: std_logic_vector(15 downto 0);
signal BGA_SEL					: std_logic;
signal BGA_DTACK_N			: std_logic;


----------------------------------------------------------------
-- SPRITE ENGINE
----------------------------------------------------------------
-- PART 1
signal SP1E_ACTIVE			: std_logic;

type sp1c_t is (
	SP1C_INIT,
	SP1C_LOOP,
	SP1C_Y_RD,
	SP1C_SZL_RD,
	SP1C_DONE
);
signal SP1C						: sp1c_t;

signal OBJ_Y_D					: std_logic_vector(8 downto 0);
signal OBJ_Y_ADDR_RD			: std_logic_vector(6 downto 0);
signal OBJ_Y_ADDR_WR			: std_logic_vector(6 downto 0);
signal OBJ_Y_WE				: std_logic;
signal OBJ_Y_Q					: std_logic_vector(8 downto 0);

signal OBJ_SZ_LINK_D			: std_logic_vector(10 downto 0);
signal OBJ_SZ_LINK_ADDR_RD	: std_logic_vector(6 downto 0);
signal OBJ_SZ_LINK_ADDR_WR	: std_logic_vector(6 downto 0);
signal OBJ_SZ_LINK_WE		: std_logic;
signal OBJ_SZ_LINK_Q			: std_logic_vector(10 downto 0);

signal OBJ_COLINFO_ADDR_A	: std_logic_vector(8 downto 0);
signal OBJ_COLINFO_ADDR_B	: std_logic_vector(8 downto 0);
signal OBJ_COLINFO_D_A		: std_logic_vector(6 downto 0);
signal OBJ_COLINFO_WE_A		: std_logic;
signal OBJ_COLINFO_WE_B		: std_logic;
signal OBJ_COLINFO_Q_A		: std_logic_vector(6 downto 0);
signal OBJ_COLINFO_Q_B		: std_logic_vector(6 downto 0);

signal SP1_X					: std_logic_vector(7 downto 0);

signal SP1_VRAM_ADDR			: std_logic_vector(14 downto 0);
signal SP1_VRAM_DO			: std_logic_vector(15 downto 0);
signal SP1_VRAM_DO_REG		: std_logic_vector(15 downto 0);
signal SP1_SEL					: std_logic;
signal SP1_DTACK_N			: std_logic;

signal OBJ_CUR					: std_logic_vector(6 downto 0);

-- PART 2
signal SP2E_ACTIVE			: std_logic;

type sp2c_t is (
	SP2C_INIT,
	SP2C_Y_RD,
	SP2C_Y_RD2,
	SP2C_Y_TST,
	SP2C_X_RD,
	SP2C_X_TST,
	SP2C_CALC_XY,
	SP2C_LOOP,
	SP2C_WAIT,
	SP2C_PLOT,
	SP2C_TILE_RD,
	SP2C_NEXT,
	SP2C_DONE
);
signal SP2C						: sp2c_t;

signal SP2_VRAM_ADDR			: std_logic_vector(14 downto 0);
signal SP2_VRAM_DO			: std_logic_vector(15 downto 0);
signal SP2_VRAM_DO_REG		: std_logic_vector(15 downto 0);
signal SP2_SEL					: std_logic;
signal SP2_DTACK_N			: std_logic;

signal SP_BUF              : std_logic;

----------------------------------------------------------------
-- VIDEO OUTPUT
----------------------------------------------------------------
signal T_COLOR			: std_logic_vector(15 downto 0);

signal DBG				: std_logic_vector(15 downto 0);

begin

bgb_ci : entity work.dpram generic map(9,7)
port map(
	clock			=> CLK,
	address_a	=> BGB_COLINFO_ADDR_A,
	data_a		=> BGB_COLINFO_D_A,
	wren_a		=> BGB_COLINFO_WE_A,
	address_b	=> BGB_COLINFO_ADDR_B,
	q_b			=> BGB_COLINFO_Q_B
);

bga_ci : entity work.dpram generic map(9,7)
port map(
	clock			=> CLK,
	address_a	=> BGA_COLINFO_ADDR_A,
	data_a		=> BGA_COLINFO_D_A,
	wren_a		=> BGA_COLINFO_WE_A,
	address_b	=> BGA_COLINFO_ADDR_B,
	q_b			=> BGA_COLINFO_Q_B
);

obj_ci : entity work.dpram generic map(10,7)
port map(
	clock			=> MEMCLK,
	address_a	=> SP_BUF & OBJ_COLINFO_ADDR_A,
	data_a		=> OBJ_COLINFO_D_A,
	wren_a		=> OBJ_COLINFO_WE_A,
	q_a			=> OBJ_COLINFO_Q_A,
	address_b	=> not SP_BUF & OBJ_COLINFO_ADDR_B,
	wren_b		=> OBJ_COLINFO_WE_B,
	q_b			=> OBJ_COLINFO_Q_B
);

obj_oi_y : entity work.dpram generic map(7,9)
port map(
	clock			=> MEMCLK,
	address_a	=> OBJ_Y_ADDR_WR,
	wren_a		=> OBJ_Y_WE,
	data_a		=> OBJ_Y_D,
	address_b	=> OBJ_Y_ADDR_RD,
	q_b			=> OBJ_Y_Q
);

obj_oi_sl : entity work.dpram generic map(7,11)
port map(
	clock			=> MEMCLK,
	address_a	=> OBJ_SZ_LINK_ADDR_WR,
	wren_a		=> OBJ_SZ_LINK_WE,
	data_a		=> OBJ_SZ_LINK_D,
	address_b	=> OBJ_SZ_LINK_ADDR_RD,
	q_b			=> OBJ_SZ_LINK_Q
);


----------------------------------------------------------------
-- REGISTERS
----------------------------------------------------------------

M3    <= REG(0)(1);
IE1   <= REG(0)(4);

V30   <= REG(1)(3) and PAL;
DMA   <= REG(1)(4);
IE0   <= REG(1)(5);
DE    <= REG(1)(6);

NTAB  <= REG(2)(5 downto 3);
NTWB  <= REG(3)(5 downto 1);
NTBB  <= REG(4)(2 downto 0);
SATB  <= REG(5)(6 downto 0);

BGCOL <= REG(7)(5 downto 0);

HIT   <= REG(10);

HSCR  <= REG(11)(1 downto 0);
VSCR  <= REG(11)(2);
H40   <= REG(12)(0);
LSM   <= REG(12)(2 downto 1);

HSCB  <= REG(13)(5 downto 0);

ADDR_STEP <= REG(15);

HSIZE <= REG(16)(1 downto 0);
VSIZE <= REG(16)(5 downto 4);

WHP   <= REG(17)(4 downto 0);
WRIGT <= REG(17)(7);

WVP   <= REG(18)(4 downto 0);
WDOWN <= REG(18)(7);


INTERLACE <= LSM(1) and LSM(0);

-- Read-only registers
IN_DMA <= DMA_FILL or DMA_COPY or DMA_VBUS;
STATUS <= "111111" & FIFO_EMPTY & FIFO_FULL & VINT_TG68_PENDING & SOVR & SCOL & ODD & IN_VBL & IN_HBL & IN_DMA & PAL;

----------------------------------------------------------------
-- CPU INTERFACE
----------------------------------------------------------------

DTACK_N <= FF_DTACK_N;
DO <= FF_DO;
process( RST_N, CLK )
begin
	if RST_N = '0' then
		FF_DTACK_N <= '1';
		FF_DO <= (others => '1');

		PENDING <= '0';
		ADDR_LATCH <= (others => '0');
		ADDR_SET_REQ <= '0';
		REG_SET_REQ <= '0';
		DMAF_SET_REQ <= '0';
		CODE <= (others => '0');

		DT_RD_SEL <= '0';
		DT_FF_SEL <= '0';

		SOVR_CLR <= '0';
		SCOL_CLR <= '0';

	elsif rising_edge(CLK) then
		SOVR_CLR <= '0';
		SCOL_CLR <= '0';

		if SEL = '0' then
			FF_DTACK_N <= '1';
		elsif SEL = '1' and FF_DTACK_N = '1' then
			if RNW = '0' then -- Write
				if A(4 downto 2) = "000" then
					-- Data Port
					PENDING <= '0';

					if CODE = "000011" -- CRAM Write
					or CODE = "000101" -- VSRAM Write
					or CODE = "000001" -- VRAM Write
					then
						DT_FF_DATA <= DI;
						DT_FF_CODE <= CODE(2 downto 0);

						if DT_FF_DTACK_N = '1' then
							DT_FF_SEL <= '1';
						else
							DT_FF_SEL <= '0';
							FF_DTACK_N <= '0';
						end if;
					else
						DT_DMAF_DATA <= DI;
						if DMA_FILL_PRE = '1' then
							if DMAF_SET_ACK = '0' then
								DMAF_SET_REQ <= '1';
							else
								DMAF_SET_REQ <= '0';
								FF_DTACK_N <= '0';
							end if;
						else
							FF_DTACK_N <= '0';
						end if;
					end if;

				elsif A(4 downto 2) = "001" then
					-- Control Port
					if PENDING = '1' then
						CODE(5 downto 2) <= DI(7 downto 4);
						ADDR_LATCH <= DI(1 downto 0) & ADDR(13 downto 0);

						-- In case of DMA VBUS request, hold the TG68 with DTACK_N
						-- it should avoid the use of a CLKEN signal
						if ADDR_SET_ACK = '0' or DMA_VBUS = '1' then
							ADDR_SET_REQ <= '1';
						else
							ADDR_SET_REQ <= '0';
							FF_DTACK_N <= '0';
							PENDING <= '0';
						end if;
					else
						if DI(15 downto 13) = "100" then
							-- Register Set
							REG_LATCH <= DI;
							if REG_SET_ACK = '0' then
								REG_SET_REQ <= '1';
							else
								REG_SET_REQ <= '0';
								FF_DTACK_N <= '0';
							end if;
						else
							-- Address Set
							CODE(1 downto 0) <= DI(15 downto 14);
							ADDR_LATCH(13 downto 0) <= DI(13 downto 0);
							if ADDR_SET_ACK = '0' then
								ADDR_SET_REQ <= '1';
							else
								ADDR_SET_REQ <= '0';
								FF_DTACK_N <= '0';
								PENDING <= '1';
							end if;
						end if;
						-- Note : Genesis Plus does address setting
						-- even in Register Set mode. Normal ?
					end if;

				elsif A(4 downto 2) = "111" then
					DBG <= DI;
					FF_DTACK_N <= '0';
					
				else
					-- Unused (Lock-up)
					FF_DTACK_N <= '0';
				end if;
			else -- Read
				PENDING <= '0';

				if A(4) = '1' then
					FF_DO <= x"FFFF";
					FF_DTACK_N <= '0';
				
				elsif A(3 downto 2) = "00" then
					-- Data Port
					if CODE = "001000" -- CRAM Read
					or CODE = "000100" -- VSRAM Read
					or CODE = "000000" -- VRAM Read
					then
						if DT_RD_DTACK_N = '1' then
							DT_RD_SEL <= '1';
							DT_RD_CODE <= CODE(3 downto 0);
						else
							DT_RD_SEL <= '0';
							FF_DO <= DT_RD_DATA;
							FF_DTACK_N <= '0';
						end if;
					else
						FF_DTACK_N <= '0';
					end if;
				elsif A(3 downto 2) = "01" then
					-- Control Port (Read Status Register)
					FF_DO <= STATUS;
					SOVR_CLR <= '1';
					SCOL_CLR <= '1';
					FF_DTACK_N <= '0';
				elsif A(3) = '1' then
					FF_DO <= HV;
					FF_DTACK_N <= '0';
				end if;
			end if;
		end if;
	end if;
end process;

----------------------------------------------------------------
-- VRAM CONTROLLER
----------------------------------------------------------------
vram_req <= vram_req_reg;

vram_d <= DT_VRAM_DI; --  when VMC=VMC_DT else (others=>'X');
vram_we <= not DT_VRAM_RNW when VMC=VMC_DT else '0';
vram_u_n <= DT_VRAM_UDS_N when VMC=VMC_DT else '0';
vram_l_n <= DT_VRAM_LDS_N when VMC=VMC_DT else '0';

early_ack_bga <= '0' when VMC=VMC_BGA and vram_req_reg=vram_ack else '1';
early_ack_bgb <= '0' when VMC=VMC_BGB and vram_req_reg=vram_ack else '1';
early_ack_sp1 <= '0' when VMC=VMC_SP1 and vram_req_reg=vram_ack else '1';
early_ack_sp2 <= '0' when VMC=VMC_SP2 and vram_req_reg=vram_ack else '1';
early_ack_dt  <= '0' when VMC=VMC_DT  and vram_req_reg=vram_ack else '1';

BGA_VRAM_DO <= vram_q when early_ack_bga='0' and BGA_DTACK_N = '1' else BGA_VRAM_DO_REG;
BGB_VRAM_DO <= vram_q when early_ack_bgb='0' and BGB_DTACK_N = '1' else BGB_VRAM_DO_REG;
SP1_VRAM_DO <= vram_q when early_ack_sp1='0' and SP1_DTACK_N = '1' else SP1_VRAM_DO_REG;
SP2_VRAM_DO <= vram_q when early_ack_sp2='0' and SP2_DTACK_N = '1' else SP2_VRAM_DO_REG;
DT_VRAM_DO  <= vram_q when early_ack_dt='0'  and SP2_DTACK_N = '1' else DT_VRAM_DO_REG;

-- Priority encoder for next port...
VMC_NEXT <= VMC_BGB when BGB_SEL = '1'     and BGB_DTACK_N = '1'     and early_ack_bgb='1'
       else VMC_BGA when BGA_SEL = '1'     and BGA_DTACK_N = '1'     and early_ack_bga='1'
       else VMC_SP1 when SP1_SEL = '1'     and SP1_DTACK_N = '1'     and early_ack_sp1='1'
       else VMC_SP2 when SP2_SEL = '1'     and SP2_DTACK_N = '1'     and early_ack_sp2='1'
       else VMC_DT  when DT_VRAM_SEL = '1' and DT_VRAM_DTACK_N = '1' and early_ack_dt='1'
       else VMC_IDLE;

process( CLK, RST_N )
begin
	if RST_N = '0' then
		BGB_DTACK_N <= '1';
		BGA_DTACK_N <= '1';
		SP1_DTACK_N <= '1';
		SP2_DTACK_N <= '1';
		DT_VRAM_DTACK_N <= '1';
		vram_req_reg <= '0';
		VMC<=VMC_IDLE;
	else
		if rising_edge(CLK) then

			if BGB_SEL = '0' then
				BGB_DTACK_N <= '1';
			end if;
			if BGA_SEL = '0' then
				BGA_DTACK_N <= '1';
			end if;
			SP1_DTACK_N <= '1';
			SP2_DTACK_N <= '1';
			if DT_VRAM_SEL = '0' then
				DT_VRAM_DTACK_N <= '1';
			end if;

			if vram_req_reg = vram_ack then
				VMC <= VMC_NEXT;
				case VMC_NEXT is
					when VMC_BGA => vram_a <= BGA_VRAM_ADDR;
					when VMC_BGB => vram_a <= BGB_VRAM_ADDR;
					when VMC_SP1 => vram_a <= SP1_VRAM_ADDR;
					when VMC_SP2 => vram_a <= SP2_VRAM_ADDR;
					when VMC_DT  => vram_a <= DT_VRAM_ADDR;
					when others  => null;
				end case;
				if VMC_NEXT /= VMC_IDLE then
					vram_req_reg <= not vram_req_reg;
				end if;
			end if;

			case VMC is
			when VMC_BGB =>		-- BACKGROUND B
				if vram_req_reg = vram_ack then
					BGB_VRAM_DO_REG <= vram_q;
					BGB_DTACK_N <= '0';
				end if;

			when VMC_BGA =>		-- BACKGROUND A
				if vram_req_reg = vram_ack then
					BGA_VRAM_DO_REG <= vram_q;
					BGA_DTACK_N <= '0';
				end if;

			when VMC_SP1 =>		-- SPRITE ENGINE PART 1
				if vram_req_reg = vram_ack then
					SP1_VRAM_DO_REG <= vram_q;
					SP1_DTACK_N <= '0';
				end if;

			when VMC_SP2 =>		-- SPRITE ENGINE PART 2
				if vram_req_reg = vram_ack then
					SP2_VRAM_DO_REG <= vram_q;
					SP2_DTACK_N <= '0';
				end if;

			when VMC_DT =>		-- DATA TRANSFER
				if vram_req_reg = vram_ack then
					DT_VRAM_DO_REG <= vram_q;
					DT_VRAM_DTACK_N <= '0';
				end if;

			when others => null;
			end case;
		end if;
	end if;
end process;


----------------------------------------------------------------
-- BACKGROUND B RENDERING
----------------------------------------------------------------
process( RST_N, CLK )
	variable V_BGB_XSTART	: std_logic_vector(9 downto 0);
	variable V_BGB_BASE		: std_logic_vector(15 downto 0);
	variable BGB_X				: std_logic_vector(9 downto 0);
	variable BGB_POS			: std_logic_vector(9 downto 0);
	variable BGB_Y				: std_logic_vector(9 downto 0);
	variable T_BGB_PRI		: std_logic;
	variable T_BGB_PAL		: std_logic_vector(1 downto 0);
	variable BGB_TILEBASE	: std_logic_vector(15 downto 0);
	variable BGB_HF			: std_logic;
	variable TEMP1				: std_logic_vector(15 downto 0);
	variable TEMP2				: std_logic_vector(13 downto 0);
begin
	if RST_N = '0' then
		BGB_SEL <= '0';
		BGBC <= BGBC_INIT;
		BGB_COLINFO_WE_A <= '0';
	elsif rising_edge(CLK) then
		BGB_COLINFO_WE_A <= '0';

		case BGBC is
		when BGBC_INIT =>
			if BGEN_ACTIVE = '1' then
				case HSCR is -- Horizontal scroll mode
				when "00" => BGB_VRAM_ADDR <= HSCB & "000000001";
				when "01" => BGB_VRAM_ADDR <= HSCB & "00000" & BG_Y(2 downto 0) & '1';
				when "10" => BGB_VRAM_ADDR <= HSCB & BG_Y(7 downto 3) & "0001";
				when "11" => BGB_VRAM_ADDR <= HSCB & BG_Y & '1';
				when others => null;
				end case;
				BGB_SEL <= '1';
				BGBC <= BGBC_HS_RD;
			end if;

		when BGBC_HS_RD =>
			if early_ack_bgb = '0' then
				V_BGB_XSTART := "0000000000" - BGB_VRAM_DO(9 downto 0);
				BGB_SEL <= '0';
				BGB_X := ( V_BGB_XSTART(9 downto 3) & "000" ) and (HSIZE & "11111111");
				BGB_POS := "0000000000" - ( "0000000" & V_BGB_XSTART(2 downto 0) );
				BGBC <= BGBC_CALC_Y;
			end if;

		when BGBC_CALC_Y =>
			if BGB_POS(9) = '1' or VSCR = '0' then
				TEMP1 := VSRAM(1);
			else
				TEMP1 := VSRAM(CONV_INTEGER(BGB_POS(8 downto 4) & "1"));
			end if;

			if LSM /= 3 then
				BGB_Y := (TEMP1(9 downto 0) + BG_Y) and (VSIZE & "11111111");
			else
				BGB_Y := (TEMP1(9 downto 1) + BG_Y) and (VSIZE & "11111111");
			end if;

			case HSIZE is
			when "00" => -- HS 32 cells
				V_BGB_BASE := (NTBB & "0000000000000") + (BGB_X(9 downto 3) & "0") + (BGB_Y(9 downto 3) & "00000" & "0");
			when "01" => -- HS 64 cells
				V_BGB_BASE := (NTBB & "0000000000000") + (BGB_X(9 downto 3) & "0") + (BGB_Y(9 downto 3) & "000000" & "0");
			when others => -- HS 128 cells
				V_BGB_BASE := (NTBB & "0000000000000") + (BGB_X(9 downto 3) & "0") + (BGB_Y(9 downto 3) & "0000000" & "0");
			end case;
			BGB_VRAM_ADDR <= V_BGB_BASE(15 downto 1);
			BGB_SEL <= '1';
			BGBC <= BGBC_BASE_RD;

		when BGBC_BASE_RD =>
			if early_ack_bgb='0' then
				BGB_SEL <= '0';
				T_BGB_PRI := BGB_VRAM_DO(15);
				T_BGB_PAL := BGB_VRAM_DO(14 downto 13);
				BGB_HF := BGB_VRAM_DO(11);
				if BGB_VRAM_DO(12) = '1' then	-- VF
					TEMP2 := BGB_VRAM_DO(10 downto 0) & not(BGB_Y(2 downto 0));
				else
					TEMP2 := BGB_VRAM_DO(10 downto 0) & (BGB_Y(2 downto 0));
				end if;

				if LSM /= 3 then
					BGB_TILEBASE := TEMP2(13 downto 0) & "00";
				else
					BGB_TILEBASE := TEMP2(12 downto 0) & (ODD xor BGB_VRAM_DO(12)) & "00";
				end if;

				BGBC <= BGBC_LOOP;
			end if;

		when BGBC_LOOP =>
			if BGB_X(1 downto 0) = "00" and BGB_SEL = '0' then
				if BGB_X(2) = '0' then
					if BGB_HF = '1' then
						BGB_VRAM_ADDR <= BGB_TILEBASE(15 downto 2) & "1";
					else
						BGB_VRAM_ADDR <= BGB_TILEBASE(15 downto 2) & "0";
					end if;
				else
					if BGB_HF = '1' then
						BGB_VRAM_ADDR <= BGB_TILEBASE(15 downto 2) & "0";
					else
						BGB_VRAM_ADDR <= BGB_TILEBASE(15 downto 2) & "1";
					end if;
				end if;
				BGB_SEL <= '1';
				BGBC <= BGBC_TILE_RD;
			else
				if BGB_POS(9) = '0' then
					BGB_COLINFO_ADDR_A <= BGB_POS(8 downto 0);
					BGB_COLINFO_WE_A <= '1';
					case BGB_X(1 downto 0) is
					when "00" =>
						if BGB_HF = '1' then
							BGB_COLINFO_D_A <= T_BGB_PRI & T_BGB_PAL & BGB_VRAM_DO(3 downto 0);
						else
							BGB_COLINFO_D_A <= T_BGB_PRI & T_BGB_PAL & BGB_VRAM_DO(15 downto 12);
						end if;
					when "01" =>
						if BGB_HF = '1' then
							BGB_COLINFO_D_A <= T_BGB_PRI & T_BGB_PAL & BGB_VRAM_DO(7 downto 4);
						else
							BGB_COLINFO_D_A <= T_BGB_PRI & T_BGB_PAL & BGB_VRAM_DO(11 downto 8);
						end if;
					when "10" =>
						if BGB_HF = '1' then
							BGB_COLINFO_D_A <= T_BGB_PRI & T_BGB_PAL & BGB_VRAM_DO(11 downto 8);
						else
							BGB_COLINFO_D_A <= T_BGB_PRI & T_BGB_PAL & BGB_VRAM_DO(7 downto 4);
						end if;
					when others =>
						if BGB_HF = '1' then
							BGB_COLINFO_D_A <= T_BGB_PRI & T_BGB_PAL & BGB_VRAM_DO(15 downto 12);
						else
							BGB_COLINFO_D_A <= T_BGB_PRI & T_BGB_PAL & BGB_VRAM_DO(3 downto 0);
						end if;
					end case;
				end if;
				if (H40 = '1' and BGB_POS = 319) or (H40 = '0' and BGB_POS = 255) then
					BGBC <= BGBC_DONE;
				else
					BGB_POS := BGB_POS + 1;
					if BGB_X(2 downto 0) = "111" then
						BGBC <= BGBC_CALC_Y;
					else
						BGBC <= BGBC_LOOP;
					end if;
				end if;
				BGB_X := (BGB_X + 1) and (HSIZE & "11111111");
				BGB_SEL <= '0';
			end if;

		when BGBC_TILE_RD =>
			if early_ack_bgb = '0' then
				BGBC <= BGBC_LOOP;
			end if;

		when others =>	-- BGBC_DONE
			BGB_SEL <= '0';
			if BGEN_ACTIVE = '0' then
				BGBC <= BGBC_INIT;
			end if;
		end case;
	end if;
end process;


----------------------------------------------------------------
-- BACKGROUND A RENDERING
----------------------------------------------------------------
process( RST_N, CLK )
	variable V_BGA_XSTART	: std_logic_vector(9 downto 0);
	variable V_BGA_BASE		: std_logic_vector(15 downto 0);
	variable BGA_X				: std_logic_vector(9 downto 0);
	variable BGA_POS			: std_logic_vector(9 downto 0);
	variable BGA_Y				: std_logic_vector(9 downto 0);
	variable T_BGA_PRI		: std_logic;
	variable T_BGA_PAL		: std_logic_vector(1 downto 0);
	variable T_BGA_COLNO		: std_logic_vector(3 downto 0);
	variable BGA_BASE			: std_logic_vector(15 downto 0);
	variable BGA_TILEBASE	: std_logic_vector(15 downto 0);
	variable BGA_HF			: std_logic;
	variable WIN_V				: std_logic;
	variable WIN_H				: std_logic;
	variable TEMP1				: std_logic_vector(15 downto 0);
	variable TEMP2				: std_logic_vector(13 downto 0);
begin
	if RST_N = '0' then
		BGA_SEL <= '0';
		BGAC <= BGAC_INIT;
		BGA_COLINFO_WE_A <= '0';
	elsif rising_edge(CLK) then
		BGA_COLINFO_WE_A <= '0';

		case BGAC is
		when BGAC_INIT =>
			if BGEN_ACTIVE = '1' then
				if BG_Y = "00000000" then
					if WVP = "00000" then
						WIN_V := WDOWN;
					else
						WIN_V := not(WDOWN);
					end if;
				elsif BG_Y(2 downto 0) = "000" and BG_Y(7 downto 3) = WVP then
					WIN_V := not WIN_V;
				end if;
				if WHP = "00000" then
					WIN_H := WRIGT;
				else
					WIN_H := not(WRIGT);
				end if;

				case HSCR is -- Horizontal scroll mode
				when "00" => BGA_VRAM_ADDR <= HSCB & "000000000";
				when "01" => BGA_VRAM_ADDR <= HSCB & "00000" & BG_Y(2 downto 0) & '0';
				when "10" => BGA_VRAM_ADDR <= HSCB & BG_Y(7 downto 3) & "0000";
				when "11" => BGA_VRAM_ADDR <= HSCB & BG_Y & '0';
				when others => null;
				end case;
				BGA_SEL <= '1';
				BGAC <= BGAC_HS_RD;
			end if;

		when BGAC_HS_RD =>
			if early_ack_bga='0' then
				V_BGA_XSTART := "0000000000" - BGA_VRAM_DO(9 downto 0);
				BGA_SEL <= '0';
				BGA_X := ( V_BGA_XSTART(9 downto 3) & "000" ) and (HSIZE & "11111111");
				BGA_POS := "0000000000" - ( "0000000" & V_BGA_XSTART(2 downto 0) );
				BGAC <= BGAC_CALC_Y;
			end if;

		when BGAC_CALC_Y =>
			if WIN_H = '1' or WIN_V = '1' then
				BGA_Y := "00" & BG_Y;
			else
				if BGA_POS(9) = '1' or VSCR = '0' then
					TEMP1 := VSRAM(0);
				else
					TEMP1 := VSRAM(CONV_INTEGER(BGA_POS(8 downto 4) & "0"));
				end if;

				if LSM /= 3 then
					BGA_Y := (TEMP1(9 downto 0) + BG_Y) and (VSIZE & "11111111");
				else
					BGA_Y := (TEMP1(9 downto 1) + BG_Y) and (VSIZE & "11111111");
				end if;
			end if;

			if WIN_H = '1' or WIN_V = '1' then
				V_BGA_BASE := (NTWB & "00000000000") + (BGA_POS(9 downto 3) & "0");
				if H40 = '0' then -- WIN is 32 tiles wide in H32 mode
					V_BGA_BASE := V_BGA_BASE + (BGA_Y(9 downto 3) & "00000" & "0");
				else              -- WIN is 64 tiles wide in H40 mode
					V_BGA_BASE := V_BGA_BASE + (BGA_Y(9 downto 3) & "000000" & "0");
				end if;
			else
				V_BGA_BASE := (NTAB & "0000000000000") + (BGA_X(9 downto 3) & "0");

				case HSIZE is
				when "00" => -- HS 32 cells
					V_BGA_BASE := V_BGA_BASE + (BGA_Y(9 downto 3) & "00000" & "0");
				when "01" => -- HS 64 cells
					V_BGA_BASE := V_BGA_BASE + (BGA_Y(9 downto 3) & "000000" & "0");
				when others => -- HS 128 cells
					V_BGA_BASE := V_BGA_BASE + (BGA_Y(9 downto 3) & "0000000" & "0");
				end case;
			end if;

			BGA_VRAM_ADDR <= V_BGA_BASE(15 downto 1);
			BGA_SEL <= '1';
			BGAC <= BGAC_BASE_RD;

		when BGAC_BASE_RD =>
			if early_ack_bga='0' then
				BGA_SEL <= '0';
				T_BGA_PRI := BGA_VRAM_DO(15);
				T_BGA_PAL := BGA_VRAM_DO(14 downto 13);
				BGA_HF := BGA_VRAM_DO(11);

				if BGA_VRAM_DO(12) = '1' then	-- VF
					TEMP2 := BGA_VRAM_DO(10 downto 0) & not(BGA_Y(2 downto 0));
				else
					TEMP2 := BGA_VRAM_DO(10 downto 0) & (BGA_Y(2 downto 0));
				end if;

				if LSM /= 3 then
					BGA_TILEBASE := TEMP2(13 downto 0) & "00";
				else
					BGA_TILEBASE := TEMP2(12 downto 0) & (ODD xor BGA_VRAM_DO(12)) & "00";
				end if;

				BGAC <= BGAC_LOOP;
			end if;

		when BGAC_LOOP =>
			if BGA_POS(9) = '0' and WIN_H = '0' and WRIGT = '1'
				and BGA_POS(3 downto 0) = "0000" and BGA_POS(8 downto 4) = WHP
			then
				WIN_H := not WIN_H;
				BGAC <= BGAC_CALC_Y;
			elsif BGA_POS(9) = '0' and WIN_H = '1' and WRIGT = '0'
				and BGA_POS(3 downto 0) = "0000" and BGA_POS(8 downto 4) = WHP
			then
				WIN_H := not WIN_H;
				BGAC <= BGAC_CALC_Y;
			elsif BGA_POS(1 downto 0) = "00" and BGA_SEL = '0' and (WIN_H = '1' or WIN_V = '1') then
				if BGA_POS(2) = '0' then
					if BGA_HF = '1' then
						BGA_VRAM_ADDR <= BGA_TILEBASE(15 downto 2) & "1";
					else
						BGA_VRAM_ADDR <= BGA_TILEBASE(15 downto 2) & "0";
					end if;
				else
					if BGA_HF = '1' then
						BGA_VRAM_ADDR <= BGA_TILEBASE(15 downto 2) & "0";
					else
						BGA_VRAM_ADDR <= BGA_TILEBASE(15 downto 2) & "1";
					end if;
				end if;
				BGA_SEL <= '1';
				BGAC <= BGAC_TILE_RD;
			elsif BGA_X(1 downto 0) = "00" and BGA_SEL = '0' and (WIN_H = '0' and WIN_V = '0') then
				if BGA_X(2) = '0' then
					if BGA_HF = '1' then
						BGA_VRAM_ADDR <= BGA_TILEBASE(15 downto 2) & "1";
					else
						BGA_VRAM_ADDR <= BGA_TILEBASE(15 downto 2) & "0";
					end if;
				else
					if BGA_HF = '1' then
						BGA_VRAM_ADDR <= BGA_TILEBASE(15 downto 2) & "0";
					else
						BGA_VRAM_ADDR <= BGA_TILEBASE(15 downto 2) & "1";
					end if;
				end if;
				BGA_SEL <= '1';
				BGAC <= BGAC_TILE_RD;
			else
				if BGA_POS(9) = '0' then
					BGA_COLINFO_WE_A <= '1';
					BGA_COLINFO_ADDR_A <= BGA_POS(8 downto 0);
					if WIN_H = '1' or WIN_V = '1' then
						case BGA_POS(1 downto 0) is
						when "00" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(3 downto 0);
							else
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(15 downto 12);
							end if;
						when "01" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(7 downto 4);
							else
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(11 downto 8);
							end if;
						when "10" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(11 downto 8);
							else
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(7 downto 4);
							end if;
						when others =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(15 downto 12);
							else
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(3 downto 0);
							end if;
						end case;
					else
						case BGA_X(1 downto 0) is
						when "00" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(3 downto 0);
							else
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(15 downto 12);
							end if;
						when "01" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(7 downto 4);
							else
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(11 downto 8);
							end if;
						when "10" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(11 downto 8);
							else
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(7 downto 4);
							end if;
						when others =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(15 downto 12);
							else
								BGA_COLINFO_D_A <= T_BGA_PRI & T_BGA_PAL & BGA_VRAM_DO(3 downto 0);
							end if;
						end case;
					end if;
				end if;
				if (H40 = '1' and BGA_POS = 319) or (H40 = '0' and BGA_POS = 255) then
					BGAC <= BGAC_DONE;
				else
					if BGA_X(2 downto 0) = "111" and (WIN_H = '0' and WIN_V = '0') then
						BGAC <= BGAC_CALC_Y;
					elsif BGA_POS(2 downto 0) = "111" and (WIN_H = '1' or WIN_V = '1') then
						BGAC <= BGAC_CALC_Y;
					else
						BGAC <= BGAC_LOOP;
					end if;
					BGA_POS := BGA_POS + 1;
				end if;
				BGA_X := (BGA_X + 1) and (HSIZE & "11111111");
				BGA_SEL <= '0';
			end if;

		when BGAC_TILE_RD =>
			if early_ack_bga='0' then
				BGAC <= BGAC_LOOP;
			end if;

		when others =>	-- BGAC_DONE
			BGA_SEL <= '0';
			if BGEN_ACTIVE = '0' then
				BGAC <= BGAC_INIT;
			end if;
		end case;
	end if;
end process;


----------------------------------------------------------------
-- SPRITE ENGINE - PART ONE
----------------------------------------------------------------

-- Scan through the linked chain of sprites and read their y position
-- and size from the sprite attribute table.

process( RST_N, MEMCLK )
begin
	if RST_N = '0' then
		SP1_SEL <= '0';
		SP1C <= SP1C_INIT;
		OBJ_Y_WE <= '0';
		OBJ_SZ_LINK_WE <= '0';

	elsif rising_edge(MEMCLK) then
		OBJ_Y_WE <= '0';
		OBJ_SZ_LINK_WE <= '0';

		case SP1C is
		when SP1C_INIT =>
			if SP1E_ACTIVE = '1' then
				SP1_X <= (others => '0');
				OBJ_CUR <= (others => '0');
				SP1_SEL <= '0';
				OBJ_SZ_LINK_WE <= '0';
				OBJ_Y_ADDR_WR <= (others => '0');
				OBJ_SZ_LINK_ADDR_WR <= (others => '0');
				SP1C <= SP1C_LOOP;
			end if;

		when SP1C_LOOP =>
			if SP1_X(0) = '0' and SP1_SEL = '0' then
				SP1_VRAM_ADDR <= (SATB & "00000000") + (OBJ_CUR & "00");
				SP1_SEL <= '1';
				SP1C <= SP1C_Y_RD;
			elsif SP1_X(0) = '1' and SP1_SEL = '0' then
				SP1_VRAM_ADDR <= (SATB & "00000000") + (OBJ_CUR & "01");
				SP1_SEL <= '1';
				SP1C <= SP1C_SZL_RD;
			end if;

		when SP1C_Y_RD =>
			if early_ack_sp1='0' then
				OBJ_Y_ADDR_WR <= SP1_X(7 downto 1);
				OBJ_Y_WE <= '1';
				if LSM /=3 then
					OBJ_Y_D <= SP1_VRAM_DO(8 downto 0);
				else
					OBJ_Y_D <= SP1_VRAM_DO(9 downto 1);
				end if;
				SP1_X <= SP1_X + 1;
				SP1C <= SP1C_LOOP;
				SP1_SEL <= '0';
			end if;

		when SP1C_SZL_RD =>
			if early_ack_sp1='0' then
				OBJ_SZ_LINK_ADDR_WR <= SP1_X(7 downto 1);
				OBJ_SZ_LINK_D <= SP1_VRAM_DO(11 downto 8) & SP1_VRAM_DO(6 downto 0);
				OBJ_SZ_LINK_WE <= '1';

				OBJ_CUR <= SP1_VRAM_DO(6 downto 0);

				-- check a total of 80 sprites in H40 mode and 64 sprites in H32 mode
				if ((H40 = '1' and SP1_X(7 downto 1) = 80) or
					 (H40 = '0' and SP1_X(7 downto 1) = 64) or
					 -- the following checks are inspired by the gens-ii emulator
				    (H40 = '1' and SP1_VRAM_DO(6 downto 0) >= 80) or
					 (H40 = '0' and SP1_VRAM_DO(6 downto 0) >= 64) or
					 -- don't loop through short sprite attribute table
					 (SP1_VRAM_DO(6 downto 0) = "0000000") ) then
				   OBJ_SZ_LINK_D(6 downto 0) <= (others => '0');
					SP1C <= SP1C_DONE;
				else
					SP1_X <= SP1_X + 1;
					SP1C <= SP1C_LOOP;
				end if;
				SP1_SEL <= '0';
			end if;

		when others => -- SP1C_DONE
			SP1_SEL <= '0';
			if SP1E_ACTIVE = '0' then
				SP1C <= SP1C_INIT;
			end if;
		end case;
	end if;
end process;

----------------------------------------------------------------
-- SPRITE ENGINE - PART TWO
----------------------------------------------------------------
process( RST_N, MEMCLK )
	variable OBJ_TOT			: std_logic_vector(6 downto 0);
	variable OBJ_NEXT			: std_logic_vector(6 downto 0);
	variable OBJ_NB			: std_logic_vector(6 downto 0);
	variable OBJ_PIX			: std_logic_vector(8 downto 0);
	variable OBJ_Y_OFS		: std_logic_vector(8 downto 0);
	variable OBJ_LINK			: std_logic_vector(6 downto 0);
	variable OBJ_HS			: std_logic_vector(1 downto 0);
	variable OBJ_VS			: std_logic_vector(2 downto 0);
	variable OBJ_X				: std_logic_vector(8 downto 0);
	variable OBJ_X_OFS		: std_logic_vector(4 downto 0);
	variable OBJ_PRI			: std_logic;
	variable OBJ_PAL			: std_logic_vector(1 downto 0);
	variable OBJ_VF			: std_logic;
	variable OBJ_HF			: std_logic;
	variable OBJ_POS			: std_logic_vector(8 downto 0);
	variable OBJ_TILEBASE	: std_logic_vector(14 downto 0);
	variable OBJ_COLNO		: std_logic_vector(3 downto 0);
	variable SP2_Y				: std_logic_vector(8 downto 0);
	variable OBJ_MASKED		: std_logic;
	variable OBJ_VALID_X		: std_logic;
	variable OBJ_DOT_OVERFLOW: std_logic;
begin
	if RST_N = '0' then
		SP2_SEL <= '0';
		SP2C <= SP2C_INIT;
		OBJ_COLINFO_WE_A <= '0';
		SCOL_SET <= '0';
		SOVR_SET <= '0';
		OBJ_DOT_OVERFLOW := '0';

	elsif rising_edge(MEMCLK) then

		SCOL_SET <= '0';
		SOVR_SET <= '0';
		OBJ_COLINFO_WE_A <= '0';

		case SP2C is
		when SP2C_INIT =>
			if SP2E_ACTIVE = '1' and SP1C = SP1C_DONE then
				SP2_Y := PRE_Y;	-- Latch the current PRE_Y value as it will change during the rendering process
				OBJ_TOT := (others => '0');
				OBJ_NEXT := (others => '0');
				OBJ_NB := (others => '0');
				OBJ_PIX := (others => '0');

				SP2_SEL <= '0';
				OBJ_COLINFO_ADDR_A <= (others => '0');

				OBJ_Y_ADDR_RD <= (others => '0');
				OBJ_SZ_LINK_ADDR_RD <= (others => '0');

				OBJ_MASKED := '0';
				OBJ_VALID_X := OBJ_DOT_OVERFLOW;
				OBJ_DOT_OVERFLOW := '0';

				SP2C <= SP2C_Y_RD;
			end if;

		when SP2C_Y_RD =>
			OBJ_Y_ADDR_RD <= OBJ_TOT;
			OBJ_SZ_LINK_ADDR_RD <= OBJ_TOT;
			SP2C <= SP2C_Y_RD2;

		-- empty cycle required for BRAM to read the data
		when SP2C_Y_RD2 =>
			SP2C <= SP2C_Y_TST;

		when SP2C_Y_TST =>
			OBJ_Y_OFS := SP2_Y + 128 - OBJ_Y_Q;
			OBJ_HS := OBJ_SZ_LINK_Q(10 downto 9);
			OBJ_VS := '0'&OBJ_SZ_LINK_Q(8 downto 7);
			if LSM = 3 then
				OBJ_VS(2) := '1';
			end if;
			OBJ_LINK := OBJ_SZ_LINK_Q(6 downto 0);

			SP2_VRAM_ADDR <= (SATB & "00000000") + (OBJ_NEXT & "11");

			SP2C <= SP2C_NEXT;
			case OBJ_VS(1 downto 0) is
			when "00" =>	-- 8 pixels
				if OBJ_Y_OFS(8 downto 3) = "000000" then
					SP2C <= SP2C_X_RD;
					SP2_SEL <= '1';
				end if;
			when "01" =>	-- 16 pixels
				if OBJ_Y_OFS(8 downto 4) = "00000" then
					SP2C <= SP2C_X_RD;
					SP2_SEL <= '1';
				end if;
			when "11" =>	-- 32 pixels
				if OBJ_Y_OFS(8 downto 5) = "0000" then
					SP2C <= SP2C_X_RD;
					SP2_SEL <= '1';
				end if;
			when others =>	-- 24 pixels
				if OBJ_Y_OFS(8 downto 5) = "0000" and OBJ_Y_OFS(4 downto 3) /= "11" then
					SP2C <= SP2C_X_RD;
					SP2_SEL <= '1';
				end if;
			end case;

		when SP2C_X_RD =>
			if early_ack_sp2='0' then
				SP2_SEL <= '0';
				OBJ_X := SP2_VRAM_DO(8 downto 0);
				SP2C <= SP2C_X_TST;
			end if;

		when SP2C_X_TST =>
			-- sprite masking algorithm as implemented by gens-ii
			if OBJ_X = "000000000" and OBJ_VALID_X = '1' then
				OBJ_MASKED := '1';
			end if;

			if OBJ_X /= "000000000" then
				OBJ_VALID_X := '1';
			end if;
			SP2_VRAM_ADDR <= (SATB & "00000000") + (OBJ_NEXT & "10");
			SP2_SEL <= '1';
			SP2C <= SP2C_CALC_XY;

		when SP2C_CALC_XY =>
			if early_ack_sp2='0' then
				SP2_SEL <= '0';
				OBJ_PRI := SP2_VRAM_DO(15);
				OBJ_PAL := SP2_VRAM_DO(14 downto 13);
				OBJ_VF  := SP2_VRAM_DO(12);
				OBJ_HF  := SP2_VRAM_DO(11);

				case OBJ_HS is
				when "00" =>	-- 8 pixels
					if OBJ_HF = '0' then
						OBJ_X_OFS := "00000";
					else
						OBJ_X_OFS := "00111";
					end if;
				when "01" =>	-- 16 pixels
					if OBJ_HF = '0' then
						OBJ_X_OFS := "00000";
					else
						OBJ_X_OFS := "01111";
					end if;
				when "11" =>	-- 32 pixels
					if OBJ_HF = '0' then
						OBJ_X_OFS := "00000";
					else
						OBJ_X_OFS := "11111";
					end if;
				when others =>	-- 24 pixels
					if OBJ_HF = '0' then
						OBJ_X_OFS := "00000";
					else
						OBJ_X_OFS := "10111";
					end if;
				end case;

				case OBJ_VS(1 downto 0) is
				when "00" =>	-- 8 pixels
					if OBJ_VF = '1' then
						OBJ_Y_OFS(4 downto 0) := "00" & not(OBJ_Y_OFS(2 downto 0));
					end if;
				when "01" =>	-- 16 pixels
					if OBJ_VF = '1' then
						OBJ_Y_OFS(4 downto 0) := "0" & not(OBJ_Y_OFS(3 downto 0));
					end if;
				when "11" =>	-- 32 pixels
					if OBJ_VF= '1' then
						OBJ_Y_OFS(4 downto 0) := not(OBJ_Y_OFS(4 downto 0));
					end if;
				when others =>	-- 24 pixels
					if OBJ_VF = '1' then
						OBJ_Y_OFS(2 downto 0) := not(OBJ_Y_OFS(2 downto 0));
						case OBJ_Y_OFS(4 downto 3) is
						when "00"   => OBJ_Y_OFS(4 downto 3) := "10";
						when "10"   => OBJ_Y_OFS(4 downto 3) := "00";
						when others => OBJ_Y_OFS(4 downto 3) := "01";
						end case;
					end if;
				end case;

				OBJ_NB := OBJ_NB + 1;
				OBJ_POS := OBJ_X - "010000000";
				if LSM /=3 then
					OBJ_TILEBASE := (SP2_VRAM_DO(10 downto 0) & "0000") + (OBJ_Y_OFS & "0");
				else
					OBJ_TILEBASE := (SP2_VRAM_DO(9 downto 0) & "00000") + (OBJ_Y_OFS(7 downto 0) & ODD & "0");
				end if;
				SP2C <= SP2C_LOOP;
			end if;

		-- loop over all sprite pixels on the current line
		when SP2C_LOOP =>
			if (H40 = '1' and OBJ_PIX = 320) or (H40 = '0' and OBJ_PIX = 256) then
				-- limit total sprite pixels per line
				OBJ_DOT_OVERFLOW := '1';
				SP2C <= SP2C_DONE;
				SOVR_SET <= '1';
			else
				OBJ_COLINFO_ADDR_A <= OBJ_POS;
				if (OBJ_X_OFS(1 downto 0) = "00" and OBJ_HF = '0') or (OBJ_X_OFS(1 downto 0) = "11" and OBJ_HF = '1') then

					case OBJ_VS is
					-- 8 pixels
					when "000"       => SP2_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "000" & OBJ_X_OFS(2));
					-- 16 pixels
					when "001"|"100" => SP2_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "0000" & OBJ_X_OFS(2));
					-- 24 pixels
					when "010" =>
						case OBJ_X_OFS(4 downto 3) is
						when "00"   => SP2_VRAM_ADDR <= OBJ_TILEBASE + OBJ_X_OFS(2);
						when "01"   => SP2_VRAM_ADDR <= OBJ_TILEBASE + ("0011000" & OBJ_X_OFS(2));
						when "11"   => SP2_VRAM_ADDR <= OBJ_TILEBASE + ("1001000" & OBJ_X_OFS(2));
						when others => SP2_VRAM_ADDR <= OBJ_TILEBASE + ("0110000" & OBJ_X_OFS(2));
						end case;
					-- 32 pixels
					when "011"|"101" => SP2_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "00000" & OBJ_X_OFS(2));
					-- 48 pixels (doubleres)
					when "110" =>
						case OBJ_X_OFS(4 downto 3) is
						when "00"   => SP2_VRAM_ADDR <= OBJ_TILEBASE + OBJ_X_OFS(2);
						when "01"   => SP2_VRAM_ADDR <= OBJ_TILEBASE + ("00110000" & OBJ_X_OFS(2));
						when "11"   => SP2_VRAM_ADDR <= OBJ_TILEBASE + ("10010000" & OBJ_X_OFS(2));
						when others => SP2_VRAM_ADDR <= OBJ_TILEBASE + ("01100000" & OBJ_X_OFS(2));
						end case;
					-- 64 pixels (doubleres)
					when others    => SP2_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "000000" & OBJ_X_OFS(2));
					end case;

					SP2_SEL <= '1';
					SP2C <= SP2C_TILE_RD;
				else
					case OBJ_X_OFS(1 downto 0) is
					when "00"   => OBJ_COLNO := SP2_VRAM_DO(15 downto 12);
					when "01"   => OBJ_COLNO := SP2_VRAM_DO(11 downto 8);
					when "10"   => OBJ_COLNO := SP2_VRAM_DO(7 downto 4);
					when others => OBJ_COLNO := SP2_VRAM_DO(3 downto 0);
					end case;
					SP2C <= SP2C_WAIT;
				end if;
			end if;

		when SP2C_WAIT =>
			SP2C <= SP2C_PLOT;

		when SP2C_PLOT =>
			if OBJ_POS < 320 then
				if OBJ_COLINFO_Q_A(3 downto 0) = "0000" then
					if OBJ_MASKED = '0' then
						OBJ_COLINFO_WE_A <= '1';
						OBJ_COLINFO_D_A <= OBJ_PRI & OBJ_PAL & OBJ_COLNO;
					end if;
				else
					if OBJ_COLNO /= "0000" then
						SCOL_SET <= '1';
					end if;
				end if;
			end if;
			OBJ_POS := OBJ_POS + 1;
			OBJ_PIX := OBJ_PIX + 1;
			if OBJ_HF = '1' then
				if OBJ_X_OFS = "00000" then
					SP2C <= SP2C_NEXT;
				else
					OBJ_X_OFS := OBJ_X_OFS - 1;
					SP2C <= SP2C_LOOP;
				end if;
			else
				if (OBJ_X_OFS = "00111" and OBJ_HS = "00")
				or (OBJ_X_OFS = "01111" and OBJ_HS = "01")
				or (OBJ_X_OFS = "11111" and OBJ_HS = "11")
				or (OBJ_X_OFS = "10111" and OBJ_HS = "10")
				then
					SP2C <= SP2C_NEXT;
				else
					OBJ_X_OFS := OBJ_X_OFS + 1;
					SP2C <= SP2C_LOOP;
				end if;
			end if;

		when SP2C_TILE_RD =>
			if early_ack_sp2='0' then
				SP2_SEL <= '0';
				case OBJ_X_OFS(1 downto 0) is
				when "00"   => OBJ_COLNO := SP2_VRAM_DO(15 downto 12);
				when "01"   => OBJ_COLNO := SP2_VRAM_DO(11 downto 8);
				when "10"   => OBJ_COLNO := SP2_VRAM_DO(7 downto 4);
				when others => OBJ_COLNO := SP2_VRAM_DO(3 downto 0);
				end case;
				SP2C <= SP2C_PLOT;
			end if;

		when SP2C_NEXT =>
			OBJ_TOT := OBJ_TOT + 1;
			OBJ_NEXT := OBJ_LINK;

			-- limit number of sprites per line to 20 / 16
			if (H40 = '1' and OBJ_NB = 20) or (H40 = '0' and OBJ_NB = 16) then
				SP2C <= SP2C_DONE;
				SOVR_SET <= '1';
			elsif OBJ_LINK = "0000000" then
				SP2C <= SP2C_DONE;
			else
				SP2C <= SP2C_Y_RD;
			end if;

		when others => -- SP2C_DONE
			SP2_SEL <= '0';
			if SP2E_ACTIVE = '0' then
				SP2C <= SP2C_INIT;
			end if;
		end case;
	end if;
end process;

----------------------------------------------------------------
-- VIDEO COUNTING
----------------------------------------------------------------
HDISP_START <= conv_std_logic_vector(HDISP_START_320,9)  when H40='1' else conv_std_logic_vector(HDISP_START_256,9);
HDISP_END   <= conv_std_logic_vector(HDISP_END_320,9)    when H40='1' else conv_std_logic_vector(HDISP_END_256,9);
HTOTAL      <= conv_std_logic_vector(HTOTAL_320,9)       when H40='1' else conv_std_logic_vector(HTOTAL_256,9);
HSYNC_START <= conv_std_logic_vector(HSYNC_START_320,9)  when H40='1' else conv_std_logic_vector(HSYNC_START_256,9);
HSYNC_SZ    <= conv_std_logic_vector(HSYNC_SZ_320,9)     when H40='1' else conv_std_logic_vector(HSYNC_SZ_256,9);

VDISP_START <= conv_std_logic_vector(VDISP_START_240,9)  when V30='1' else conv_std_logic_vector(VDISP_START_224,9);
VDISP_END   <= conv_std_logic_vector(VDISP_END_240,9)    when V30='1' else conv_std_logic_vector(VDISP_END_224,9);
VTOTAL      <= conv_std_logic_vector(VTOTAL_240,9)       when PAL='1' else conv_std_logic_vector(VTOTAL_224,9);
VSYNC_START <= conv_std_logic_vector(VSYNC_START_240,9)  when V30='1'
          else conv_std_logic_vector(VSYNC_START_224P,9) when PAL='1'
          else conv_std_logic_vector(VSYNC_START_224N,9);
VSYNC_SZ    <= conv_std_logic_vector(VSYNC_SZ_240,9)     when PAL='1' else conv_std_logic_vector(VSYNC_SZ_224,9);

VSYNC_STARTi<= conv_std_logic_vector(VSYNC_START_320i,9) when H40='1' else conv_std_logic_vector(VSYNC_START_256i,9);

-- COUNTERS AND INTERRUPTS
process( RST_N, CLK )
	variable hscnt : std_logic_vector(8 downto 0);
	variable vscnt : std_logic_vector(8 downto 0);
	variable ytemp : std_logic_vector(8 downto 0);

begin
	if RST_N = '0' then
		ODD <= '0';

		PIXDIV <= (others => '0');
		V_CNT <= (others => '0');
		H_CNT <= (others => '0');

		HINT_PENDING_SET <= '0';
		VINT_TG68_PENDING_SET <= '0';
		VINT_T80_SET <= '0';
		VINT_T80_CLR <= '0';

		IN_HBL <= '0';
		IN_VBL <= '1';

		BGEN_ACTIVE <= '0';
		SP1E_ACTIVE <= '0';
		SP2E_ACTIVE <= '0';
		DT_ACTIVE <= '0';
	elsif rising_edge(CLK) then

		-- DATA TRANSFER ACTIVE
		DT_ACTIVE <= '1';

		CE_PIX <= '0';

		HINT_PENDING_SET <= '0';
		VINT_TG68_PENDING_SET <= '0';
		VINT_T80_SET <= '0';
		VINT_T80_CLR <= '0';

		PIXDIV <= PIXDIV + 1;
		if (H40 = '1' and PIXDIV = 8-1) or (H40 = '0' and PIXDIV = 10-1) then
			PIXDIV <= (others => '0');

			CE_PIX <= '1';

			H_CNT <= H_CNT + 1;
			if H_CNT >= HTOTAL-1 then
				H_CNT <= (others => '0');

				V_CNT <= V_CNT + 1;
				if V_CNT >= VTOTAL + ODD - 1 then
					V_CNT <= (others => '0');
				end if;

				-- activate BG in advance to prefetch the data
				if V_CNT >= VDISP_START-1 and V_CNT < VDISP_END-1 then
					BGEN_ACTIVE <= '1';
					BG_Y <= PRE_Y(7 downto 0);
				end if;

				-- Y for sprites which should be started 1 line in advance to prefetch the data
				PRE_Y <= PRE_Y + 1;
				if V_CNT = VDISP_START-2 then
					PRE_Y <= (others => '0');
				end if;

				if V_CNT >= VDISP_START-2 and V_CNT <= VDISP_END-2 then
					SP1E_ACTIVE <= '1';
				end if;
			end if;

			if (LSM(0) /= ODD and H_CNT = VSYNC_STARTi) or -- interlace even
			   (LSM(0)  = ODD and H_CNT = 0) then          -- interlace odd / progressive

				if V_CNT = VSYNC_START then
					FIELD <= ODD;
					VS <= '1';
					vscnt := VSYNC_SZ;
				end if;

				if vscnt > 0 then
					vscnt := vscnt - 1;
				else
					VS <= '0';
				end if;
			end if;

			if H_CNT = HDISP_START-1 then
				IN_HBL <= '0';

				SP_BUF <= not SP_BUF;
				if V_CNT >= VDISP_START-1 and V_CNT < VDISP_END-1 then
					SP2E_ACTIVE <= '1';
				end if;

				if V_CNT = VDISP_START then
					IN_VBL <= '0';
				end if;

				if V_CNT = VDISP_END then
					IN_VBL <= '1';
					VINT_TG68_PENDING_SET <= '1';
					VINT_T80_SET <= '1';
					ODD <= not ODD and LSM(0);
				end if;

				if V_CNT = VDISP_END+1 then
					VINT_T80_CLR <= '1';
				end if;

				if V_CNT = VDISP_START then
					if HIT = 0 then
						HINT_PENDING_SET <= '1';
						HINT_COUNT <= (others => '0');
					else
						HINT_COUNT <= HIT - 1;
					end if;
				elsif V_CNT > VDISP_START and V_CNT <= VDISP_END then
					if HINT_COUNT = 0 then
						HINT_PENDING_SET <= '1';
						HINT_COUNT <= HIT;
					else
						HINT_COUNT <= HINT_COUNT - 1;
					end if;
				end if;
			end if;

			if H_CNT = HDISP_END-1 then
				IN_HBL <= '1';
				BGEN_ACTIVE <= '0';
				SP1E_ACTIVE <= '0';
				SP2E_ACTIVE <= '0';
			end if;

			if hscnt > 0 then
				hscnt := hscnt - 1;
			else
				HS <= '0';
			end if;

			if H_CNT = HSYNC_START-1 then
				HS <= '1';
				hscnt := HSYNC_SZ;
			end if;
		end if;
	end if;
end process;

-- PIXEL COUNTER AND OUTPUT
-- ALSO CLEARS THE SPRITE COLINFO BUFFER RIGHT AFTER RENDERING
process( RST_N, CLK )
	variable hcnt,vcnt : std_logic_vector(8 downto 0);
	variable v8  : std_logic;
	variable col : std_logic_vector(5 downto 0);
	variable cold: std_logic_vector(5 downto 0);
begin
	if rising_edge(CLK) then
		OBJ_COLINFO_WE_B <= '0';

		case PIXDIV is
		when "0000" =>
			hcnt := H_CNT - HDISP_START;
			vcnt := V_CNT - VDISP_START;

			BGB_COLINFO_ADDR_B <= hcnt;
			BGA_COLINFO_ADDR_B <= hcnt;
			OBJ_COLINFO_ADDR_B <= hcnt;

			if M3 = '0' then
				-- HV Counter
				if LSM = "11" then v8 := vcnt(8); else v8 := vcnt(0); end if;
				HV <= vcnt(7 downto 1) & v8 & hcnt(8 downto 1);
			end if;

		when "0011" =>
			if DE = '0' then
				col := BGCOL;
			elsif OBJ_COLINFO_Q_B(3 downto 0) /= "0000" and OBJ_COLINFO_Q_B(6) = '1' then
				col := OBJ_COLINFO_Q_B(5 downto 0);
			elsif BGA_COLINFO_Q_B(3 downto 0) /= "0000" and BGA_COLINFO_Q_B(6) = '1' then
				col := BGA_COLINFO_Q_B(5 downto 0);
			elsif BGB_COLINFO_Q_B(3 downto 0) /= "0000" and BGB_COLINFO_Q_B(6) = '1' then
				col := BGB_COLINFO_Q_B(5 downto 0);
			elsif OBJ_COLINFO_Q_B(3 downto 0) /= "0000" then
				col := OBJ_COLINFO_Q_B(5 downto 0);
			elsif BGA_COLINFO_Q_B(3 downto 0) /= "0000" then
				col := BGA_COLINFO_Q_B(5 downto 0);
			elsif BGB_COLINFO_Q_B(3 downto 0) /= "0000" then
				col := BGB_COLINFO_Q_B(5 downto 0);
			else
				col := BGCOL;
			end if;
			
			case DBG(8 downto 7) is
			when "00" => cold := BGCOL;
			when "01" => cold := OBJ_COLINFO_Q_B(5 downto 0);
			when "10" => cold := BGA_COLINFO_Q_B(5 downto 0);
			when "11" => cold := BGB_COLINFO_Q_B(5 downto 0);
			end case;

			if DBG(6) = '1' then
				col := cold;
			elsif DBG(8 downto 7) /= "00" then
				col := col and cold;
			end if;

			T_COLOR <= CRAM(CONV_INTEGER(col));

		when "0100" =>
			HBL <= IN_HBL;
			VBL <= IN_VBL;

			OBJ_COLINFO_WE_B <= not IN_HBL;

			if IN_VBL = '1' or IN_HBL = '1' then
				R <= (others => '0');
				G <= (others => '0');
				B <= (others => '0');
			else
				B <= T_COLOR(11 downto 9);
				G <= T_COLOR(7 downto 5);
				R <= T_COLOR(3 downto 1);
			end if;

		when others => null;
		end case;
	end if;
end process;

----------------------------------------------------------------
-- DATA TRANSFER CONTROLLER
----------------------------------------------------------------
VBUS_ADDR <= FF_VBUS_ADDR;
VBUS_SEL <= FF_VBUS_SEL;

process( RST_N, CLK )
	variable DT_WR_ADDR : std_logic_vector(15 downto 0);
	variable DT_WR_DATA : std_logic_vector(15 downto 0);
	variable DMA_LENGTH : std_logic_vector(15 downto 0);
	variable DMA_SOURCE : std_logic_vector(15 downto 0);
	variable need_wait  : std_logic;
begin
	if RST_N = '0' then

		REG <= (others => (others => '0'));
		CRAM <= (others => (others => '0'));
		VSRAM <= (others => (others => '0'));

		ADDR <= (others => '0');
		ADDR_SET_ACK <= '0';
		REG_SET_ACK <= '0';

		DT_VRAM_SEL <= '0';

		FIFO_RD_POS <= "00";
		FIFO_WR_POS <= "00";
		FIFO_EMPTY <= '1';
		FIFO_FULL <= '0';

		DT_RD_DTACK_N <= '1';
		DT_FF_DTACK_N <= '1';

		FF_VBUS_ADDR <= (others => '0');
		FF_VBUS_SEL	<= '0';

		DMA_FILL_PRE <= '0';
		DMA_FILL <= '0';
		DMA_COPY <= '0';
		DMA_VBUS <= '0';
		DMA_SOURCE := (others => '0');
		DMA_LENGTH := (others => '0');

		DTC <= DTC_IDLE;

	elsif rising_edge(CLK) then

		if FIFO_RD_POS = FIFO_WR_POS then
			FIFO_EMPTY <= '1';
		else
			FIFO_EMPTY <= '0';
		end if;
		if FIFO_WR_POS + 1 = FIFO_RD_POS then
			FIFO_FULL <= '1';
		else
			FIFO_FULL <= '0';
		end if;
		if DT_RD_SEL = '0' then
			DT_RD_DTACK_N <= '1';
		end if;
		if DT_FF_SEL = '0' then
			DT_FF_DTACK_N <= '1';
		end if;
		if ADDR_SET_REQ = '0' then
			ADDR_SET_ACK <= '0';
		end if;
		if REG_SET_REQ = '0' then
			REG_SET_ACK <= '0';
		end if;
		if DMAF_SET_REQ = '0' then
			DMAF_SET_ACK <= '0';
		end if;

		if DT_FF_SEL = '1' and (FIFO_WR_POS + 1 /= FIFO_RD_POS) and DT_FF_DTACK_N = '1' then
			FIFO_ADDR( CONV_INTEGER( FIFO_WR_POS ) ) <= ADDR;
			FIFO_DATA( CONV_INTEGER( FIFO_WR_POS ) ) <= DT_FF_DATA;
			FIFO_CODE( CONV_INTEGER( FIFO_WR_POS ) ) <= DT_FF_CODE;
			FIFO_WR_POS <= FIFO_WR_POS + 1;
			ADDR <= ADDR + ADDR_STEP;
			DT_FF_DTACK_N <= '0';
		end if;

		if DT_ACTIVE = '1' then
			case DTC is
			when DTC_IDLE =>
				if DMA_VBUS = '1' then
					DMA_LENGTH := REG(20) & REG(19);
					DMA_SOURCE := REG(22) & REG(21);
					DTC <= DTC_DMA_VBUS_RD;

				elsif DMA_FILL = '1' then
					DT_VRAM_DI <= DT_DMAF_DATA(7 downto 0) & DT_DMAF_DATA(7 downto 0);
					DMA_LENGTH := REG(20) & REG(19);
					DTC <= DTC_DMA_FILL_WR;

				elsif DMA_COPY = '1' then
					DMA_LENGTH := REG(20) & REG(19);
					DMA_SOURCE := REG(22) & REG(21);
					DTC <= DTC_DMA_COPY_RD;

				elsif FIFO_RD_POS /= FIFO_WR_POS then
					DT_WR_ADDR := FIFO_ADDR( CONV_INTEGER( FIFO_RD_POS ) );
					DT_WR_DATA := FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) );
					FIFO_RD_POS <= FIFO_RD_POS + 1;
					case FIFO_CODE( CONV_INTEGER( FIFO_RD_POS ) ) is
					when "011"  =>
						CRAM( CONV_INTEGER(DT_WR_ADDR(6 downto 1)) ) <= DT_WR_DATA;

					when "101"  =>
						VSRAM( CONV_INTEGER(DT_WR_ADDR(6 downto 1)) ) <= DT_WR_DATA;

					when others =>
						DT_VRAM_SEL <= '1';
						DT_VRAM_ADDR <= DT_WR_ADDR(15 downto 1);
						DT_VRAM_RNW <= '0';
						if DT_WR_ADDR(0) = '0' then
							DT_VRAM_DI <= DT_WR_DATA;
						else
							DT_VRAM_DI <= DT_WR_DATA(7 downto 0) & DT_WR_DATA(15 downto 8);
						end if;
						DT_VRAM_UDS_N <= '0';
						DT_VRAM_LDS_N <= '0';

						DTC <= DTC_VRAM_WR;
					end case;

				elsif DT_RD_SEL = '1' and DT_RD_DTACK_N = '1' then
					case DT_RD_CODE is
					when "1000" =>
						DT_RD_DATA <= CRAM( CONV_INTEGER(ADDR(6 downto 1)) );
						DT_RD_DTACK_N <= '0';
						ADDR <= ADDR + ADDR_STEP;

					when "0100" =>
						DT_RD_DATA <= VSRAM( CONV_INTEGER(ADDR(6 downto 1)) );
						DT_RD_DTACK_N <= '0';
						ADDR <= ADDR + ADDR_STEP;

					when others =>
						DT_VRAM_SEL <= '1';
						DT_VRAM_ADDR <= ADDR(15 downto 1);
						DT_VRAM_RNW <= '1';
						DT_VRAM_UDS_N <= '0';
						DT_VRAM_LDS_N <= '0';
						DTC <= DTC_VRAM_RD;
					end case;
				else
					if ADDR_SET_REQ = '1' and ADDR_SET_ACK = '0' and IN_DMA = '0' then
						ADDR <= ADDR_LATCH;
						if CODE(5) = '1' and DMA = '1' and PENDING = '1' then
							if REG(23)(7) = '0' then
								DMA_VBUS <= '1';
							else
								if REG(23)(6) = '0' then
									DMA_FILL_PRE <= '1';
								else
									DMA_COPY <= '1';
								end if;
							end if;
						end if;
						ADDR_SET_ACK <= '1';
					end if;

					if REG_SET_REQ = '1' and REG_SET_ACK = '0' and IN_DMA = '0' then
						REG( CONV_INTEGER( REG_LATCH(12 downto 8)) ) <= REG_LATCH(7 downto 0);
						REG_SET_ACK <= '1';
					end if;

					if DMAF_SET_REQ = '1' and DMAF_SET_ACK = '0' and IN_DMA = '0' then
						if DMA_FILL_PRE = '1' then
							DMA_FILL <= '1';
						end if;
						DMAF_SET_ACK <= '1';
					end if;
				end if;

			when DTC_VRAM_WR =>
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';
					DTC <= DTC_IDLE;
				end if;

			when DTC_VRAM_RD =>
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';
					DT_RD_DATA <= DT_VRAM_DO;
					DT_RD_DTACK_N <= '0';
					ADDR <= ADDR + ADDR_STEP;
					DTC <= DTC_IDLE;
				end if;

----------------------------------------------------------------
-- DMA FILL
----------------------------------------------------------------

			when DTC_DMA_FILL_WR =>
				DT_VRAM_SEL <= '1';
				DT_VRAM_ADDR <= ADDR(15 downto 1);
				DT_VRAM_RNW <= '0';
				DT_VRAM_UDS_N <= not ADDR(0);
				DT_VRAM_LDS_N <= ADDR(0);
				DTC <= DTC_DMA_FILL_LOOP;

			when DTC_DMA_FILL_LOOP =>
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';
					DT_VRAM_DI <= DT_DMAF_DATA(7 downto 0) & DT_DMAF_DATA(7 downto 0);
					ADDR <= ADDR + ADDR_STEP;
					DMA_LENGTH := DMA_LENGTH - 1;
					DTC <= DTC_DMA_FILL_LOOP;
					if DMA_LENGTH = 0 then
						DMA_FILL_PRE <= '0';
						DMA_FILL <= '0';
						REG(20) <= x"00";
						REG(19) <= x"00";
						DTC <= DTC_IDLE;
					else
						DTC <= DTC_DMA_FILL_WR;
					end if;
				end if;

----------------------------------------------------------------
-- DMA COPY
----------------------------------------------------------------

			when DTC_DMA_COPY_RD =>
				DT_VRAM_SEL <= '1';
				DT_VRAM_ADDR <= DMA_SOURCE(15 downto 1);
				DT_VRAM_RNW <= '1';
				DT_VRAM_UDS_N <= '0';
				DT_VRAM_LDS_N <= '0';
				DTC <= DTC_DMA_COPY_RD2;

			when DTC_DMA_COPY_RD2 =>
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';
					if DMA_SOURCE(0) = '0' then
						DT_VRAM_DI <= DT_VRAM_DO(7 downto 0) & DT_VRAM_DO(7 downto 0);
					else
						DT_VRAM_DI <= DT_VRAM_DO(15 downto 8) & DT_VRAM_DO(15 downto 8);
					end if;
					DTC <= DTC_DMA_COPY_WR;
				end if;

			when DTC_DMA_COPY_WR =>
				DT_VRAM_SEL <= '1';
				DT_VRAM_ADDR <= ADDR(15 downto 1);
				DT_VRAM_RNW <= '0';
				DT_VRAM_UDS_N <= not ADDR(0);
				DT_VRAM_LDS_N <= ADDR(0);
				DTC <= DTC_DMA_COPY_LOOP;

			when DTC_DMA_COPY_LOOP =>
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';
					ADDR <= ADDR + ADDR_STEP;
					DMA_LENGTH := DMA_LENGTH - 1;
					DMA_SOURCE := DMA_SOURCE + 1;
					DTC <= DTC_DMA_COPY_LOOP;
					if DMA_LENGTH = 0 then
						DMA_COPY <= '0';
						REG(20) <= x"00";
						REG(19) <= x"00";
						REG(22) <= DMA_SOURCE(15 downto 8);
						REG(21) <= DMA_SOURCE(7 downto 0);
						DTC <= DTC_IDLE;
					else
						DTC <= DTC_DMA_COPY_RD;
					end if;
				end if;

----------------------------------------------------------------
-- DMA VBUS
----------------------------------------------------------------

			when DTC_DMA_VBUS_RD =>
				FF_VBUS_SEL <= '1';
				FF_VBUS_ADDR <= REG(23)(6 downto 0) & DMA_SOURCE & '0';
				DTC <= DTC_DMA_VBUS_RD2;

			when DTC_DMA_VBUS_RD2 =>
				if VBUS_DTACK_N = '0' then
					FF_VBUS_SEL <= '0';
					need_wait := '0';

					case CODE(2 downto 0) is
					when "011"  =>
						CRAM(CONV_INTEGER(ADDR(6 downto 1))) <= VBUS_DATA;

					when "101"  =>
						VSRAM(CONV_INTEGER(ADDR(6 downto 1))) <= VBUS_DATA;

					when others =>
						DT_VRAM_SEL <= '1';
						DT_VRAM_ADDR <= ADDR(15 downto 1);
						DT_VRAM_RNW <= '0';
						if ADDR(0) = '0' then
							DT_VRAM_DI <= VBUS_DATA;
						else
							DT_VRAM_DI <= VBUS_DATA(7 downto 0) & VBUS_DATA(15 downto 8);
						end if;
						DT_VRAM_UDS_N <= '0';
						DT_VRAM_LDS_N <= '0';
						need_wait := '1';

					end case;

					DTC <= DTC_DMA_VBUS_LOOP;
				end if;

			when DTC_DMA_VBUS_LOOP =>
				if need_wait='0' or early_ack_dt='0' then
					DT_VRAM_SEL <= '0';
					ADDR <= ADDR + ADDR_STEP;
					DMA_LENGTH := DMA_LENGTH - 1;
					DMA_SOURCE := DMA_SOURCE + 1;
					DTC <= DTC_DMA_VBUS_LOOP;
					if DMA_LENGTH = 0 or
						((CODE(2 downto 0) = "011" or CODE(2 downto 0) = "101") and ADDR(6 downto 1)="111111") then
						DMA_VBUS <= '0';
						REG(20) <= DMA_LENGTH(15 downto 8);
						REG(19) <= DMA_LENGTH(7 downto 0);
						REG(22) <= DMA_SOURCE(15 downto 8);
						REG(21) <= DMA_SOURCE(7 downto 0);
						DTC <= DTC_IDLE;
					else
						DTC <= DTC_DMA_VBUS_RD;
					end if;
				end if;

			when others => null;
			end case;
		else	-- DT_ACTIVE = '0'
			-- Do nothing
		end if;
	end if;
end process;

VBUS_BUSY <= DMA_VBUS;

----------------------------------------------------------------
-- INTERRUPTS AND VARIOUS LATCHES
----------------------------------------------------------------

-- HINT PENDING
process( RST_N, CLK )
begin
	if RST_N = '0' then
		HINT_PENDING <= '0';
	elsif rising_edge( CLK) then
		if HINT_PENDING_SET = '1' then
			HINT_PENDING <= '1';
		elsif HINT_ACK = '1' then
			HINT_PENDING <= '0';
		end if;
	end if;
end process;

-- HINT
HINT <= HINT_FF;
process( RST_N, CLK )
begin
	if RST_N = '0' then
		HINT_FF <= '0';
	elsif rising_edge( CLK) then
		if HINT_PENDING = '1' and IE1 = '1' then
			HINT_FF <= '1';
		else
			HINT_FF <= '0';
		end if;
	end if;
end process;

-- VINT - TG68 - PENDING
process( RST_N, CLK )
begin
	if RST_N = '0' then
		VINT_TG68_PENDING <= '0';
	elsif rising_edge( CLK) then
		if VINT_TG68_PENDING_SET = '1' then
			VINT_TG68_PENDING <= '1';
		elsif VINT_TG68_ACK = '1' then
			VINT_TG68_PENDING <= '0';
		end if;
	end if;
end process;

-- VINT - TG68
VINT_TG68 <= VINT_TG68_FF;
process( RST_N, CLK )
begin
	if RST_N = '0' then
		VINT_TG68_FF <= '0';
	elsif rising_edge( CLK) then
		if VINT_TG68_PENDING = '1' and IE0 = '1' then
			VINT_TG68_FF <= '1';
		else
			VINT_TG68_FF <= '0';
		end if;
	end if;
end process;

-- VINT - T80
VINT_T80 <= VINT_T80_FF;
process( RST_N, CLK )
begin
	if RST_N = '0' then
		VINT_T80_FF <= '0';
	elsif rising_edge( CLK) then
		if VINT_T80_SET = '1' then
			VINT_T80_FF <= '1';
		elsif VINT_T80_CLR = '1' or VINT_T80_ACK = '1' then
			VINT_T80_FF <= '0';
		end if;
	end if;
end process;

-- Sprite Collision
process( RST_N, CLK )
begin
	if RST_N = '0' then
		SCOL <= '0';
	elsif rising_edge( CLK) then
		if SCOL_SET = '1' then
			SCOL <= '1';
		elsif SCOL_CLR = '1' then
			SCOL <= '0';
		end if;
	end if;
end process;

-- Sprite Overflow
process( RST_N, CLK )
begin
	if RST_N = '0' then
		SOVR <= '0';
	elsif rising_edge( CLK) then
		if SOVR_SET = '1' then
			SOVR <= '1';
		elsif SOVR_CLR = '1' then
			SOVR <= '0';
		end if;
	end if;
end process;

end rtl;
