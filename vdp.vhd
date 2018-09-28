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

entity vdp is
	port(
		RST_N			: in std_logic;
		CLK			: in std_logic;
		MEMCLK		: in std_logic;

		SEL			: in std_logic;
		A				: in std_logic_vector(4 downto 0);
		RNW			: in std_logic;
		UDS_N			: in std_logic;
		LDS_N			: in std_logic;
		DI				: in std_logic_vector(15 downto 0);
		DO				: out std_logic_vector(15 downto 0);
		DTACK_N		: out std_logic;

		vram_req 	: out std_logic;
		vram_ack 	: in std_logic;
		vram_we 		: out std_logic;
		vram_a 		: buffer std_logic_vector(14 downto 0);
		vram_d 		: out std_logic_vector(15 downto 0);
		vram_q 		: in std_logic_vector(15 downto 0);
		vram_u_n 	: out std_logic;
		vram_l_n 	: out std_logic;

		INTERLACE	: in std_logic;

		HINT			: out std_logic;
		HINT_ACK		: in std_logic;

		VINT_TG68		: out std_logic;
		VINT_T80			: out std_logic;
		VINT_TG68_ACK	: in std_logic;
		VINT_T80_ACK	: in std_logic;

		VBUS_ADDR		: out std_logic_vector(23 downto 0);
		VBUS_UDS_N		: out std_logic;
		VBUS_LDS_N		: out std_logic;
		VBUS_DATA		: in std_logic_vector(15 downto 0);

		VBUS_SEL			: out std_logic;
		VBUS_DTACK_N	: in std_logic;

		PAL		: in std_logic := '0';
		R			: out std_logic_vector(2 downto 0);
		G			: out std_logic_vector(2 downto 0);
		B			: out std_logic_vector(2 downto 0);
		HS			: out std_logic;
		VS			: out std_logic;
		HBL   	: out std_logic;
		VBL   	: out std_logic;
		CE_PIX	: out std_logic
	);
end vdp;

architecture rtl of vdp is

----------------------------------------------------------------
-- Video parameters
----------------------------------------------------------------

constant H_DISP_CLOCKS          : integer := 2560;

--constant CLOCKS_PER_LINE_MAX    : integer := 3440;
constant CLOCKS_PER_LINE_H32    : integer := 342*10;
constant CLOCKS_PER_LINE_H40    : integer := 427*8; -- 3416

constant HS_CLOCKS              : integer := 254; -- 4.7 us

constant H_DISP_START_H32       : integer := HS_CLOCKS + 46*10;
constant H_DISP_START_H40       : integer := HS_CLOCKS + 46*8;

constant HBLANK_START_H32       : integer := 264; -- in cells
constant HBLANK_START_H40       : integer := 328;

constant HBLANK_END_H32         : integer := 1; -- in cells
constant HBLANK_END_H40         : integer := 1;

constant HINT_H32               : integer := 294; -- in cells
constant HINT_H40               : integer := 349;

constant VS_LINES               : integer := 3;

constant V_DISP_HEIGHT_V28      : integer := 224;
constant V_DISP_HEIGHT_V30      : integer := 240;

constant V_DISP_START_V28       : integer := 27;
constant V_DISP_START_V30       : integer := 46;

constant NTSC_LINES             : integer := 262;
constant PAL_LINES              : integer := 312;

----------------------------------------------------------------
----------------------------------------------------------------


signal vram_req_reg : std_logic;
signal vram_we_reg : std_logic;
signal vram_d_reg : std_logic_vector(15 downto 0);
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
signal FIFO_WR_POS	: std_logic_vector(1 downto 0);
signal FIFO_RD_POS	: std_logic_vector(1 downto 0);
signal FIFO_EMPTY	: std_logic;
signal FIFO_FULL	: std_logic;

signal IN_DMA		: std_logic;
signal IN_HBL		: std_logic;
signal IN_VBL		: std_logic;

signal SOVR			: std_logic;
signal SOVR_SET		: std_logic;
signal SOVR_CLR		: std_logic;

signal SCOL			: std_logic;
signal SCOL_SET		: std_logic;
signal SCOL_CLR		: std_logic;

----------------------------------------------------------------
-- INTERRUPTS
----------------------------------------------------------------
signal HINT_COUNT	: std_logic_vector(7 downto 0);
signal HINT_PENDING	: std_logic;
signal HINT_PENDING_SET	: std_logic;
signal HINT_FF		: std_logic;

signal VINT_TG68_PENDING		: std_logic;
signal VINT_TG68_PENDING_SET	: std_logic;
signal VINT_TG68_FF				: std_logic;

signal VINT_T80_SET				: std_logic;
signal VINT_T80_CLR				: std_logic;
signal VINT_T80_FF				: std_logic;

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

signal DMA			: std_logic;

signal IM			: std_logic;
signal IM2			: std_logic;
signal ODD			: std_logic;

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
	DTC_FIFO_RD,
	DTC_VRAM_WR1,
	DTC_VRAM_WR2,
	DTC_CRAM_WR,
	DTC_VSRAM_WR,
	DTC_VRAM_RD1,
	DTC_VRAM_RD2,
	DTC_CRAM_RD,
	DTC_VSRAM_RD,
	DTC_DMA_FILL_INIT,
	DTC_DMA_FILL_WR,
	DTC_DMA_FILL_WR2,
	DTC_DMA_FILL_LOOP,
	DTC_DMA_COPY_INIT,
	DTC_DMA_COPY_RD,
	DTC_DMA_COPY_RD2,
	DTC_DMA_COPY_WR,
	DTC_DMA_COPY_WR2,
	DTC_DMA_COPY_LOOP,
	DTC_DMA_VBUS_INIT,
	DTC_DMA_VBUS_RD,
	DTC_DMA_VBUS_RD2,
	DTC_DMA_VBUS_SEL,
	DTC_DMA_VBUS_CRAM_WR,
	DTC_DMA_VBUS_VSRAM_WR,
	DTC_DMA_VBUS_VRAM_WR1,
	DTC_DMA_VBUS_VRAM_WR2,
	DTC_DMA_VBUS_LOOP
);
signal DTC	: dtc_t;

signal DT_VRAM_SEL		: std_logic;
signal DT_VRAM_ADDR		: std_logic_vector(14 downto 0);
signal DT_VRAM_DI		: std_logic_vector(15 downto 0);
signal DT_VRAM_DO		: std_logic_vector(15 downto 0);
signal DT_VRAM_DO_REG		: std_logic_vector(15 downto 0);
signal DT_VRAM_RNW		: std_logic;
signal DT_VRAM_UDS_N	: std_logic;
signal DT_VRAM_LDS_N	: std_logic;
signal DT_VRAM_DTACK_N	: std_logic;

signal DT_WR_ADDR	: std_logic_vector(15 downto 0);
signal DT_WR_DATA	: std_logic_vector(15 downto 0);
signal DT_WR_SIZE	: std_logic;

signal DT_FF_DATA	: std_logic_vector(15 downto 0);
signal DT_FF_CODE	: std_logic_vector(2 downto 0);
signal DT_FF_SEL	: std_logic;
signal DT_FF_DTACK_N	: std_logic;

signal DT_RD_DATA	: std_logic_vector(15 downto 0);
signal DT_RD_CODE	: std_logic_vector(3 downto 0);
signal DT_RD_SEL	: std_logic;
signal DT_RD_DTACK_N	: std_logic;

signal ADDR			: std_logic_vector(15 downto 0);
signal ADDR_SET_REQ	: std_logic;
signal ADDR_SET_ACK : std_logic;
signal REG_SET_REQ	: std_logic;
signal REG_SET_ACK : std_logic;

signal DT_DMAF_DATA	: std_logic_vector(15 downto 0);
signal DT_DMAV_DATA	: std_logic_vector(15 downto 0);
signal DMAF_SET_REQ	: std_logic;
signal DMAF_SET_ACK : std_logic;


signal FF_VBUS_ADDR		: std_logic_vector(23 downto 0);
signal FF_VBUS_UDS_N	: std_logic;
signal FF_VBUS_LDS_N	: std_logic;
signal FF_VBUS_SEL		: std_logic;

signal DMA_VBUS		: std_logic;
signal DMA_FILL_PRE	: std_logic;
signal DMA_FILL		: std_logic;
signal DMA_COPY		: std_logic;

signal DMA_LENGTH	: std_logic_vector(15 downto 0);
signal DMA_SOURCE	: std_logic_vector(15 downto 0);

----------------------------------------------------------------
-- VIDEO COUNTING
----------------------------------------------------------------
signal H_CNT		: std_logic_vector(11 downto 0);

signal V_ACTIVE		: std_logic;
signal H_ACTIVE		: std_logic;
signal Y			: std_logic_vector(7 downto 0);

signal PRE_V_ACTIVE	: std_logic;
signal PRE_Y		: std_logic_vector(7 downto 0);

signal FIELD		: std_logic;

signal X			: std_logic_vector(8 downto 0);
signal PIXDIV		: std_logic_vector(3 downto 0);

-- HV COUNTERS
signal HV_PIXDIV	: std_logic_vector(3 downto 0);
signal HV_HCNT		: std_logic_vector(8 downto 0); 
signal HV_VCNT		: std_logic_vector(8 downto 0); 

-- TIMING VALUES
signal CLOCKS_PER_LINE : std_logic_vector(11 downto 0);
signal H_DISP_START : std_logic_vector(11 downto 0);
signal HINT_START	: std_logic_vector(8 downto 0);
signal HBLANK_START	: std_logic_vector(8 downto 0);
signal HBLANK_END	: std_logic_vector(8 downto 0);
signal V_DISP_START : std_logic_vector(8 downto 0);
signal V_DISP_HEIGHT: std_logic_vector(8 downto 0);
signal V_TOTAL_HEIGHT: std_logic_vector(8 downto 0);

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
signal early_ack_dt : std_logic;
signal early_ack : std_logic;

----------------------------------------------------------------
-- BACKGROUND RENDERING
----------------------------------------------------------------
signal BGEN_ACTIVE	: std_logic;

-- BACKGROUND B
type bgbc_t is (
	BGBC_INIT,
	BGBC_HS_RD,
	BGBC_CALC_Y,
	BGBC_CALC_BASE,
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


signal BGB_X		: std_logic_vector(9 downto 0);
signal BGB_POS		: std_logic_vector(9 downto 0);
signal BGB_Y		: std_logic_vector(9 downto 0);
signal T_BGB_PRI	: std_logic;
signal T_BGB_PAL	: std_logic_vector(1 downto 0);
signal T_BGB_COLNO	: std_logic_vector(3 downto 0);
signal BGB_BASE		: std_logic_vector(15 downto 0);
signal BGB_TILEBASE	: std_logic_vector(15 downto 0);
signal BGB_HF		: std_logic;

signal BGB_VRAM_ADDR	: std_logic_vector(14 downto 0);
signal BGB_VRAM_DO	: std_logic_vector(15 downto 0);
signal BGB_VRAM_DO_REG	: std_logic_vector(15 downto 0);
signal BGB_SEL		: std_logic;
signal BGB_DTACK_N	: std_logic;

-- BACKGROUND A
type bgac_t is (
	BGAC_INIT,
	BGAC_HS_RD,
	BGAC_CALC_Y,
	BGAC_CALC_BASE,
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

signal BGA_X		: std_logic_vector(9 downto 0);
signal BGA_POS		: std_logic_vector(9 downto 0);
signal BGA_Y		: std_logic_vector(9 downto 0);
signal T_BGA_PRI	: std_logic;
signal T_BGA_PAL	: std_logic_vector(1 downto 0);
signal T_BGA_COLNO	: std_logic_vector(3 downto 0);
signal BGA_BASE		: std_logic_vector(15 downto 0);
signal BGA_TILEBASE	: std_logic_vector(15 downto 0);
signal BGA_HF		: std_logic;

signal BGA_VRAM_ADDR	: std_logic_vector(14 downto 0);
signal BGA_VRAM_DO	: std_logic_vector(15 downto 0);
signal BGA_VRAM_DO_REG	: std_logic_vector(15 downto 0);
signal BGA_SEL		: std_logic;
signal BGA_DTACK_N	: std_logic;

signal WIN_V		: std_logic;
signal WIN_H		: std_logic;

----------------------------------------------------------------
-- SPRITE ENGINE
----------------------------------------------------------------
-- PART 1
signal SP1E_ACTIVE	: std_logic;

type sp1c_t is (
	SP1C_INIT,
	SP1C_LOOP,
	SP1C_Y_RD,
	SP1C_SZL_RD,
	SP1C_DONE
);
signal SP1C		: sp1c_t;

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
signal OBJ_COLINFO_D_B		: std_logic_vector(6 downto 0);
signal OBJ_COLINFO_WE_A		: std_logic;
signal OBJ_COLINFO_WE_B		: std_logic;
signal OBJ_COLINFO_Q_A		: std_logic_vector(6 downto 0);
signal OBJ_COLINFO_Q_B		: std_logic_vector(6 downto 0);

signal SP1_X		: std_logic_vector(7 downto 0);

signal SP1_VRAM_ADDR	: std_logic_vector(14 downto 0);
signal SP1_VRAM_DO	: std_logic_vector(15 downto 0);
signal SP1_VRAM_DO_REG	: std_logic_vector(15 downto 0);
signal SP1_SEL		: std_logic;
signal SP1_DTACK_N	: std_logic;

signal OBJ_CUR			: std_logic_vector(6 downto 0);

-- PART 2
signal SP2E_ACTIVE	: std_logic;

type sp2c_t is (
	SP2C_INIT,
	SP2C_Y_RD,
	SP2C_Y_RD2,
	SP2C_Y_RD3,
	SP2C_Y_RD4,
	SP2C_Y_TST,
	SP2C_SHOW,
	SP2C_X_RD,
	SP2C_X_TST,
	SP2C_TDEF_RD,
	SP2C_CALC_XY,
	SP2C_CALC_BASE,
	SP2C_LOOP,
	SP2C_PLOT,
	SP2C_TILE_RD,
	SP2C_NEXT,
	SP2C_DONE
);
signal SP2C		: sp2c_t;

signal SP2_Y		: std_logic_vector(7 downto 0);

signal SP2_VRAM_ADDR	: std_logic_vector(14 downto 0);
signal SP2_VRAM_DO	: std_logic_vector(15 downto 0);
signal SP2_VRAM_DO_REG	: std_logic_vector(15 downto 0);
signal SP2_SEL		: std_logic;
signal SP2_DTACK_N	: std_logic;

signal OBJ_TOT			: std_logic_vector(6 downto 0);
signal OBJ_NEXT			: std_logic_vector(6 downto 0);
signal OBJ_NB			: std_logic_vector(6 downto 0);
signal OBJ_PIX			: std_logic_vector(8 downto 0);

signal OBJ_Y_OFS		: std_logic_vector(8 downto 0);
signal T_OBJ_HS			: std_logic_vector(1 downto 0);
signal T_OBJ_VS			: std_logic_vector(1 downto 0);
signal OBJ_LINK			: std_logic_vector(6 downto 0);

signal OBJ_HS			: std_logic_vector(1 downto 0);
signal OBJ_VS			: std_logic_vector(1 downto 0);
signal OBJ_X			: std_logic_vector(8 downto 0);
signal OBJ_X_OFS		: std_logic_vector(4 downto 0);
signal OBJ_PRI			: std_logic;
signal OBJ_PAL			: std_logic_vector(1 downto 0);
signal OBJ_VF			: std_logic;
signal OBJ_HF			: std_logic;
signal OBJ_PAT			: std_logic_vector(10 downto 0);
signal OBJ_POS			: std_logic_vector(8 downto 0);
signal OBJ_TILEBASE		: std_logic_vector(14 downto 0);
signal OBJ_COLNO		: std_logic_vector(3 downto 0);
signal T_PREV_OBJ_COLINFO		: std_logic_vector(6 downto 0);

----------------------------------------------------------------
-- VIDEO OUTPUT
----------------------------------------------------------------
signal T_COLOR			: std_logic_vector(15 downto 0);

signal COLOR		: std_logic_vector(8 downto 0);
signal FF_HS		: std_logic;
signal FF_VS		: std_logic;

signal FF_R			: std_logic_vector(2 downto 0);
signal FF_G			: std_logic_vector(2 downto 0);
signal FF_B			: std_logic_vector(2 downto 0);

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

obj_ci : entity work.dpram generic map(9,7," ","CLOCK0")
port map(
	clock			=> MEMCLK,
	address_a	=> OBJ_COLINFO_ADDR_A,
	data_a		=> OBJ_COLINFO_D_A,
	wren_a		=> OBJ_COLINFO_WE_A,
	q_a			=> OBJ_COLINFO_Q_A,
	address_b	=> OBJ_COLINFO_ADDR_B,
	data_b		=> OBJ_COLINFO_D_B,
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
ADDR_STEP <= REG(15);
H40 <= REG(12)(0);
-- H40 <= '0';
V30 <= REG(1)(3);
-- V30 <= '0';
HSCR <= REG(11)(1 downto 0);
HSIZE <= REG(16)(1 downto 0);
VSIZE <= REG(16)(5 downto 4);
VSCR <= REG(11)(2);

WVP <= REG(18)(4 downto 0);
WDOWN <= REG(18)(7);
WHP <= REG(17)(4 downto 0);
WRIGT <= REG(17)(7);

BGCOL <= REG(7)(5 downto 0);

HIT <= REG(10);
IE1 <= REG(0)(4);
IE0 <= REG(1)(5);

DMA <= REG(1)(4);

IM <= REG(12)(1);
--IM2 <= REG(12)(2);

-- Base addresses
HSCB <= REG(13)(5 downto 0);
NTBB <= REG(4)(2 downto 0);
NTWB <= REG(3)(5 downto 1);
NTAB <= REG(2)(5 downto 3);
SATB <= REG(5)(6 downto 0);

-- Read-only registers
ODD <= FIELD when IM = '1' else '0';
IN_DMA <= DMA_FILL or DMA_COPY or DMA_VBUS;

STATUS <= "111111" & FIFO_EMPTY & FIFO_FULL & VINT_TG68_PENDING & SOVR & SCOL & ODD & IN_VBL & IN_HBL & IN_DMA & PAL;
HV8 <= HV_VCNT(8) when INTERLACE = '1' else HV_VCNT(0);
HV <= HV_VCNT(7 downto 1) & HV8 & HV_HCNT(8 downto 1);

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
				if A(3 downto 2) = "00" then
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
					
				elsif A(3 downto 2) = "01" then
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
					
				else
					-- Unused (Lock-up)
					FF_DTACK_N <= '0';
				end if;			
			else -- Read
				PENDING <= '0';

				if A(3 downto 2) = "00" then
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
					-- HV Counter
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

--VMC_SEL <= VMC; -- VMC_NEXT when vram_req_reg=vram_ack else VMC;

early_ack_bga <= '0' when VMC=VMC_BGA and vram_req_reg=vram_ack else '1';
early_ack_bgb <= '0' when VMC=VMC_BGB and vram_req_reg=vram_ack else '1';
early_ack_sp1 <= '0' when VMC=VMC_SP1 and vram_req_reg=vram_ack else '1';
early_ack_sp2 <= '0' when VMC=VMC_SP2 and vram_req_reg=vram_ack else '1';
early_ack_dt <= '0' when VMC=VMC_DT and vram_req_reg=vram_ack else '1';

BGA_VRAM_DO <= vram_q when early_ack_bga='0' and BGA_DTACK_N = '1' else BGA_VRAM_DO_REG;
BGB_VRAM_DO <= vram_q when early_ack_bgb='0' and BGB_DTACK_N = '1' else BGB_VRAM_DO_REG;
SP1_VRAM_DO <= vram_q when early_ack_sp1='0' and SP1_DTACK_N = '1' else SP1_VRAM_DO_REG;
SP2_VRAM_DO <= vram_q when early_ack_sp2='0' and SP2_DTACK_N = '1' else SP2_VRAM_DO_REG;
DT_VRAM_DO <= vram_q when early_ack_dt='0' and SP2_DTACK_N = '1' else DT_VRAM_DO_REG;


process( CLK, 
		RST_N,BGB_SEL,BGB_DTACK_N,early_ack_bgb,BGA_SEL,
		BGA_DTACK_N,early_ack_bga,SP1_SEL,SP1_DTACK_N,
		early_ack_sp1,SP2_SEL,SP2_DTACK_N,early_ack_sp2,
		DT_VRAM_SEL,DT_VRAM_DTACK_N,early_ack_dt
	)
begin
	if RST_N = '0' then
		
		BGB_DTACK_N <= '1';
		BGA_DTACK_N <= '1';
		SP1_DTACK_N <= '1';
		SP2_DTACK_N <= '1';
		DT_VRAM_DTACK_N <= '1';

		vram_req_reg <= '0';
		
		VMC<=VMC_IDLE;
		VMC_NEXT<=VMC_IDLE;
	else

		-- Priority encoder for next port...
		VMC_NEXT<=VMC_IDLE;
		if BGB_SEL = '1' and BGB_DTACK_N = '1' and early_ack_bgb='1' then
			VMC_NEXT <= VMC_BGB;
		elsif BGA_SEL = '1' and BGA_DTACK_N = '1' and early_ack_bga='1' then
			VMC_NEXT <= VMC_BGA;
		elsif SP1_SEL = '1' and SP1_DTACK_N = '1' and early_ack_sp1='1'then
			VMC_NEXT <= VMC_SP1;			
		elsif SP2_SEL = '1' and SP2_DTACK_N = '1' and early_ack_sp2='1' then
			VMC_NEXT <= VMC_SP2;			
		elsif DT_VRAM_SEL = '1' and DT_VRAM_DTACK_N = '1' and early_ack_dt='1' then
			VMC_NEXT <= VMC_DT;
		end if;

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
					when VMC_IDLE =>
						null;
					when VMC_BGA =>
						vram_a <= BGA_VRAM_ADDR;
					when VMC_BGB =>
						vram_a <= BGB_VRAM_ADDR;
					when VMC_SP1 =>
						vram_a <= SP1_VRAM_ADDR;
					when VMC_SP2 =>
						vram_a <= SP2_VRAM_ADDR;
					when VMC_DT =>
						vram_a <= DT_VRAM_ADDR;
				end case;
				if VMC_NEXT /= VMC_IDLE then
					vram_req_reg <= not vram_req_reg;
				end if;
			end if;
			
			case VMC is
			when VMC_IDLE =>
				null;

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
begin
	if RST_N = '0' then
		BGB_SEL <= '0';
		BGBC <= BGBC_INIT;
		BGB_COLINFO_WE_A <= '0';
		BGB_COLINFO_ADDR_A <= (others => '0');
	elsif rising_edge(CLK) then
		if BGEN_ACTIVE = '1' then
			case BGBC is
			when BGBC_INIT =>
				case HSCR is -- Horizontal scroll mode
				when "00" =>
					BGB_VRAM_ADDR <= HSCB & "000000001";
				when "01" =>
					BGB_VRAM_ADDR <= HSCB & "00000" & Y(2 downto 0) & '1';
				when "10" =>
					BGB_VRAM_ADDR <= HSCB & Y(7 downto 3) & "0001";
				when "11" =>
					BGB_VRAM_ADDR <= HSCB & Y & '1';
				when others => null;
				end case;
				BGB_SEL <= '1';
				BGBC <= BGBC_HS_RD;
			
			when BGBC_HS_RD =>
				V_BGB_XSTART := "0000000000" - BGB_VRAM_DO(9 downto 0);
				if early_ack_bgb = '0' then
					BGB_SEL <= '0';
					BGB_X <= ( V_BGB_XSTART(9 downto 3) & "000" ) and (HSIZE & "11111111");
					BGB_POS <= "0000000000" - ( "0000000" & V_BGB_XSTART(2 downto 0) );
					BGBC <= BGBC_CALC_Y;
				end if;

			when BGBC_CALC_Y =>
				BGB_COLINFO_WE_A <= '0';
				if BGB_POS(9) = '1' then
					BGB_Y <= (VSRAM(1)(9 downto 0) + Y) and (VSIZE & "11111111");
				else
					if VSCR = '1' then
						BGB_Y <= (VSRAM( CONV_INTEGER(BGB_POS(8 downto 4) & "1") )(9 downto 0) + Y) and (VSIZE & "11111111");
					else
						BGB_Y <= (VSRAM(1)(9 downto 0) + Y) and (VSIZE & "11111111");
					end if;
				end if;
				BGBC <= BGBC_CALC_BASE;
				
			when BGBC_CALC_BASE =>
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
					T_BGB_PRI <= BGB_VRAM_DO(15);
					T_BGB_PAL <= BGB_VRAM_DO(14 downto 13);
					BGB_HF <= BGB_VRAM_DO(11);
					if BGB_VRAM_DO(12) = '1' then	-- VF
						BGB_TILEBASE <= BGB_VRAM_DO(10 downto 0) & not(BGB_Y(2 downto 0)) & "00";
					else
						BGB_TILEBASE <= BGB_VRAM_DO(10 downto 0) & BGB_Y(2 downto 0) & "00";
					end if;
					BGBC <= BGBC_LOOP;
				end if;
						
			when BGBC_LOOP =>
				if BGB_X(1 downto 0) = "00" and BGB_SEL = '0' then
					BGB_COLINFO_WE_A <= '0';
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
					BGB_X <= (BGB_X + 1) and (HSIZE & "11111111");
					if (H40 = '1' and BGB_POS = 319) or (H40 = '0' and BGB_POS = 255) then
						BGBC <= BGBC_DONE;
					else
						BGB_POS <= BGB_POS + 1;
						if BGB_X(2 downto 0) = "111" then
							BGBC <= BGBC_CALC_Y;
						else
							BGBC <= BGBC_LOOP;							
						end if;
					end if;															
					BGB_SEL <= '0';					
				end if;

			when BGBC_TILE_RD =>
				if early_ack_bgb = '0' then
					BGBC <= BGBC_LOOP;
				end if;
			
			when others =>	-- BGBC_DONE
				BGB_SEL <= '0';
				BGB_COLINFO_WE_A <= '0';
			end case;
		else	-- BGEN_ACTIVE = '0'
			BGB_SEL <= '0';
			BGBC <= BGBC_INIT;			
			BGB_COLINFO_WE_A <= '0';
		end if;
	end if;
end process;


----------------------------------------------------------------
-- BACKGROUND A RENDERING
----------------------------------------------------------------
process( RST_N, CLK )
variable V_BGA_XSTART	: std_logic_vector(9 downto 0);
variable V_BGA_BASE		: std_logic_vector(15 downto 0);
begin
	if RST_N = '0' then
		BGA_SEL <= '0';
		BGAC <= BGAC_INIT;
		BGA_COLINFO_WE_A <= '0';
		BGA_COLINFO_ADDR_A <= (others => '0');
	elsif rising_edge(CLK) then
		if BGEN_ACTIVE = '1' then
			case BGAC is
			when BGAC_INIT =>
			
				if Y = "00000000" then
					if WVP = "00000" then
						WIN_V <= WDOWN;
					else
						WIN_V <= not(WDOWN);
					end if;
				elsif Y(2 downto 0) = "000" and Y(7 downto 3) = WVP then
					WIN_V <= not WIN_V;
				end if;				
				if WHP = "00000" then
					WIN_H <= WRIGT;
				else
					WIN_H <= not(WRIGT);
				end if;
			
			case HSCR is -- Horizontal scroll mode
				when "00" =>
					BGA_VRAM_ADDR <= HSCB & "000000000";
				when "01" =>
					BGA_VRAM_ADDR <= HSCB & "00000" & Y(2 downto 0) & '0';
				when "10" =>
					BGA_VRAM_ADDR <= HSCB & Y(7 downto 3) & "0000";
				when "11" =>
					BGA_VRAM_ADDR <= HSCB & Y & '0';
				when others => null;
				end case;
				BGA_SEL <= '1';
				BGAC <= BGAC_HS_RD;
			
			when BGAC_HS_RD =>
				V_BGA_XSTART := "0000000000" - BGA_VRAM_DO(9 downto 0);
				if early_ack_bga='0' then
--				if BGA_DTACK_N = '0' then
					BGA_SEL <= '0';
					BGA_X <= ( V_BGA_XSTART(9 downto 3) & "000" ) and (HSIZE & "11111111");
					BGA_POS <= "0000000000" - ( "0000000" & V_BGA_XSTART(2 downto 0) );
					BGAC <= BGAC_CALC_Y;
				end if;

			when BGAC_CALC_Y =>
				BGA_COLINFO_WE_A <= '0';
				if WIN_H = '1' or WIN_V = '1' then
					BGA_Y <= "00" & Y;					
				else
					if BGA_POS(9) = '1' then
						BGA_Y <= (VSRAM(0)(9 downto 0) + Y) and (VSIZE & "11111111");
					else
						if VSCR = '1' then
							BGA_Y <= (VSRAM( CONV_INTEGER(BGA_POS(8 downto 4) & "0") )(9 downto 0) + Y) and (VSIZE & "11111111");
						else
							BGA_Y <= (VSRAM(0)(9 downto 0) + Y) and (VSIZE & "11111111");
						end if;
					end if;
				end if;
				BGAC <= BGAC_CALC_BASE;
				
			when BGAC_CALC_BASE =>
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
					T_BGA_PRI <= BGA_VRAM_DO(15);
					T_BGA_PAL <= BGA_VRAM_DO(14 downto 13);
					BGA_HF <= BGA_VRAM_DO(11);
					if BGA_VRAM_DO(12) = '1' then	-- VF
						BGA_TILEBASE <= BGA_VRAM_DO(10 downto 0) & not(BGA_Y(2 downto 0)) & "00";
					else
						BGA_TILEBASE <= BGA_VRAM_DO(10 downto 0) & BGA_Y(2 downto 0) & "00";
					end if;
					BGAC <= BGAC_LOOP;
				end if;
						
			when BGAC_LOOP =>
				if BGA_POS(9) = '0' and WIN_H = '0' and WRIGT = '1' 
					and BGA_POS(3 downto 0) = "0000" and BGA_POS(8 downto 4) = WHP 
				then
					WIN_H <= not WIN_H;
					BGAC <= BGAC_CALC_Y;				
				elsif BGA_POS(9) = '0' and WIN_H = '1' and WRIGT = '0' 
					and BGA_POS(3 downto 0) = "0000" and BGA_POS(8 downto 4) = WHP
				then
					WIN_H <= not WIN_H;
					BGAC <= BGAC_CALC_Y;
				elsif BGA_POS(1 downto 0) = "00" and BGA_SEL = '0' and (WIN_H = '1' or WIN_V = '1') then
					BGA_COLINFO_WE_A <= '0';
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
					BGA_COLINFO_WE_A <= '0';
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
					BGA_X <= (BGA_X + 1) and (HSIZE & "11111111");
					if (H40 = '1' and BGA_POS = 319) or (H40 = '0' and BGA_POS = 255) then
						BGAC <= BGAC_DONE;
					else
						BGA_POS <= BGA_POS + 1;
						if BGA_X(2 downto 0) = "111" and (WIN_H = '0' and WIN_V = '0') then
							BGAC <= BGAC_CALC_Y;
						elsif BGA_POS(2 downto 0) = "111" and (WIN_H = '1' or WIN_V = '1') then
							BGAC <= BGAC_CALC_Y;
						else
							BGAC <= BGAC_LOOP;							
						end if;
					end if;					
					BGA_SEL <= '0';
				end if;

			when BGAC_TILE_RD =>
				if early_ack_bga='0' then
					BGAC <= BGAC_LOOP;
				end if;
			
			when others =>	-- BGAC_DONE
				BGA_SEL <= '0';
				BGA_COLINFO_WE_A <= '0';
			end case;
		else	-- BGEN_ACTIVE = '0'
			BGA_SEL <= '0';
			BGAC <= BGAC_INIT;			
			BGA_COLINFO_WE_A <= '0';
		end if;
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
		OBJ_Y_ADDR_WR <= (others => '0');
		OBJ_SZ_LINK_ADDR_WR <= (others => '0');
		
	elsif rising_edge(MEMCLK) then
		if SP1E_ACTIVE = '1' then
			case SP1C is
			when SP1C_INIT =>
				SP1_X <= (others => '0');
				OBJ_CUR <= (others => '0');
				SP1C <= SP1C_LOOP;
			
			when SP1C_LOOP =>
			
				OBJ_Y_WE <= '0';
				OBJ_SZ_LINK_WE <= '0';
			
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
					OBJ_Y_D <= SP1_VRAM_DO(8 downto 0);
					OBJ_Y_WE <= '1';

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
						 (H40 = '0' and SP1_X(7 downto 1) = 64)) then
						SP1C <= SP1C_DONE;
					else
						SP1_X <= SP1_X + 1;
						SP1C <= SP1C_LOOP;
					end if;
					SP1_SEL <= '0';
				end if;
			
			when others => -- SP1C_DONE
				SP1_SEL <= '0';
			end case;
		else	-- SP1E_ACTIVE = '0'
			SP1_SEL <= '0';
			SP1C <= SP1C_INIT;

			OBJ_Y_WE <= '0';
			OBJ_SZ_LINK_WE <= '0';
			OBJ_Y_ADDR_WR <= (others => '0');
			OBJ_SZ_LINK_ADDR_WR <= (others => '0');
			
		end if;
	end if;
end process;

----------------------------------------------------------------
-- SPRITE ENGINE - PART TWO
----------------------------------------------------------------
process( RST_N, MEMCLK )
-- variable V_SZ_LINK		: std_logic_vector(10 downto 0);
begin
	if RST_N = '0' then
		SP2_SEL <= '0';
		SP2C <= SP2C_INIT;
		OBJ_COLINFO_ADDR_A <= (others => '0');
		OBJ_COLINFO_WE_A <= '0';		
		
		OBJ_Y_ADDR_RD <= (others => '0');
		OBJ_SZ_LINK_ADDR_RD <= (others => '0');
		
		SCOL_SET <= '0';
		SOVR_SET <= '0';
		
	elsif rising_edge(MEMCLK) then
	
		SCOL_SET <= '0';
		SOVR_SET <= '0';
	
		if SP2E_ACTIVE = '1' and (SP1E_ACTIVE = '0' or SP1C = SP1C_DONE) then
			case SP2C is
			when SP2C_INIT =>
				SP2_Y <= PRE_Y;	-- Latch the current PRE_Y value as it will change during the rendering process
				OBJ_TOT <= (others => '0');
				OBJ_NEXT <= (others => '0');
				OBJ_NB <= (others => '0');
				OBJ_PIX <= (others => '0');
				
				SP2C <= SP2C_Y_RD;
			
			when SP2C_Y_RD =>
				OBJ_COLINFO_WE_A <= '0';
				OBJ_Y_ADDR_RD <= OBJ_TOT;
				OBJ_SZ_LINK_ADDR_RD <= OBJ_TOT;
				SP2C <= SP2C_Y_RD2;
			
			when SP2C_Y_RD2 =>
				SP2C <= SP2C_Y_RD3;
			when SP2C_Y_RD3 =>
				SP2C <= SP2C_Y_RD4;
			
			when SP2C_Y_RD4 =>
				OBJ_Y_OFS <= "010000000" + ("0" & SP2_Y) - OBJ_Y_Q;
				OBJ_HS <= OBJ_SZ_LINK_Q(10 downto 9);
				OBJ_VS <= OBJ_SZ_LINK_Q(8 downto 7);
				OBJ_LINK <= OBJ_SZ_LINK_Q(6 downto 0);				
				SP2C <= SP2C_Y_TST;

			when SP2C_Y_TST =>
				SP2C <= SP2C_NEXT;
				case OBJ_VS is
				when "00" =>	-- 8 pixels
					if OBJ_Y_OFS(8 downto 3) = "000000" then
						SP2C <= SP2C_SHOW;
					end if;
				when "01" =>	-- 16 pixels
					if OBJ_Y_OFS(8 downto 4) = "00000" then
						SP2C <= SP2C_SHOW;
					end if;
				when "11" =>	-- 32 pixels
					if OBJ_Y_OFS(8 downto 5) = "0000" then
						SP2C <= SP2C_SHOW;
					end if;
				when others =>	-- 24 pixels
					if OBJ_Y_OFS(8 downto 5) = "0000" and OBJ_Y_OFS(4 downto 3) /= "11" then
						SP2C <= SP2C_SHOW;
					end if;
				end case;
			
			when SP2C_SHOW =>
				SP2_VRAM_ADDR <= (SATB & "00000000") + (OBJ_NEXT & "11");
				SP2_SEL <= '1';
				SP2C <= SP2C_X_RD;
				
			when SP2C_X_RD =>
				if early_ack_sp2='0' then
					SP2_SEL <= '0';
					OBJ_X <= SP2_VRAM_DO(8 downto 0);
					SP2C <= SP2C_X_TST;
				end if;
			
			when SP2C_X_TST =>
				if OBJ_X = "000000000" then
					SP2C <= SP2C_DONE;
				else
					SP2_VRAM_ADDR <= (SATB & "00000000") + (OBJ_NEXT & "10");
					SP2_SEL <= '1';
					SP2C <= SP2C_TDEF_RD;					
				end if;
			
			when SP2C_TDEF_RD =>
				if early_ack_sp2='0' then
					SP2_SEL <= '0';
					OBJ_PRI <= SP2_VRAM_DO(15);
					OBJ_PAL <= SP2_VRAM_DO(14 downto 13);
					OBJ_VF <= SP2_VRAM_DO(12);
					OBJ_HF <= SP2_VRAM_DO(11);
					OBJ_PAT <= SP2_VRAM_DO(10 downto 0);
					SP2C <= SP2C_CALC_XY;
				end if;
			
			when SP2C_CALC_XY =>
				case OBJ_HS is
				when "00" =>	-- 8 pixels
					if OBJ_HF = '0' then
						OBJ_X_OFS <= "00000";
					else
						OBJ_X_OFS <= "00111";
					end if;					
					OBJ_PIX <= OBJ_PIX + 8;
				when "01" =>	-- 16 pixels
					if OBJ_HF = '0' then
						OBJ_X_OFS <= "00000";
					else
						OBJ_X_OFS <= "01111";
					end if;					
					OBJ_PIX <= OBJ_PIX + 16;
				when "11" =>	-- 32 pixels
					if OBJ_HF = '0' then
						OBJ_X_OFS <= "00000";
					else
						OBJ_X_OFS <= "11111";
					end if;					
					OBJ_PIX <= OBJ_PIX + 32;
				when others =>	-- 24 pixels
					if OBJ_HF = '0' then
						OBJ_X_OFS <= "00000";
					else
						OBJ_X_OFS <= "10111";
					end if;					
					OBJ_PIX <= OBJ_PIX + 24;
				end case;

				case OBJ_VS is
				when "00" =>	-- 8 pixels
					if OBJ_VF = '1' then
						OBJ_Y_OFS(4 downto 0) <= "00" & not(OBJ_Y_OFS(2 downto 0));
					end if;					
				when "01" =>	-- 16 pixels
					if OBJ_VF = '1' then
						OBJ_Y_OFS(4 downto 0) <= "0" & not(OBJ_Y_OFS(3 downto 0));
					end if;										
				when "11" =>	-- 32 pixels
					if OBJ_VF= '1' then
						OBJ_Y_OFS(4 downto 0) <= not(OBJ_Y_OFS(4 downto 0));
					end if;														
				when others =>	-- 24 pixels
					if OBJ_VF = '1' then
						OBJ_Y_OFS(2 downto 0) <= not(OBJ_Y_OFS(2 downto 0));
						case OBJ_Y_OFS(4 downto 3) is
						when "00" =>
							OBJ_Y_OFS(4 downto 3) <= "10";
						when "10" =>
							OBJ_Y_OFS(4 downto 3) <= "00";
						when others =>
							OBJ_Y_OFS(4 downto 3) <= "01";
						end case;
					end if;
				end case;
				
				OBJ_NB <= OBJ_NB + 1;
				SP2C <= SP2C_CALC_BASE;
				
			when SP2C_CALC_BASE =>
				OBJ_POS <= OBJ_X - "010000000";
				OBJ_TILEBASE <= (OBJ_PAT & "0000") + (OBJ_Y_OFS & "0");
				SP2C <= SP2C_LOOP;
				
			when SP2C_LOOP =>
				OBJ_COLINFO_WE_A <= '0';
				OBJ_COLINFO_ADDR_A <= OBJ_POS;
				if (OBJ_X_OFS(1 downto 0) = "00" and OBJ_HF = '0' and SP2_SEL = '0')
				or (OBJ_X_OFS(1 downto 0) = "11" and OBJ_HF = '1' and SP2_SEL = '0')
				then
					case OBJ_VS is
					when "00" =>	-- 8 pixels
						SP2_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "000" & OBJ_X_OFS(2));
					when "01" =>	-- 16 pixels
						SP2_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "0000" & OBJ_X_OFS(2));
					when "11" =>	-- 32 pixels
						SP2_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "00000" & OBJ_X_OFS(2));
					when others =>	-- 24 pixels
						case OBJ_X_OFS(4 downto 3) is
						when "00" =>
							SP2_VRAM_ADDR <= OBJ_TILEBASE + OBJ_X_OFS(2);
						when "01" =>
							SP2_VRAM_ADDR <= OBJ_TILEBASE + ("0011000" & OBJ_X_OFS(2));
						when "11" =>
							SP2_VRAM_ADDR <= OBJ_TILEBASE + ("1001000" & OBJ_X_OFS(2));
						when others =>
							SP2_VRAM_ADDR <= OBJ_TILEBASE + ("0110000" & OBJ_X_OFS(2));
						end case;
					end case;
					
					SP2_SEL <= '1';
					SP2C <= SP2C_TILE_RD;
				else
					case OBJ_X_OFS(1 downto 0) is
					when "00" =>
						OBJ_COLNO <= SP2_VRAM_DO(15 downto 12);
					when "01" =>
						OBJ_COLNO <= SP2_VRAM_DO(11 downto 8);
					when "10" =>
						OBJ_COLNO <= SP2_VRAM_DO(7 downto 4);						
					when others =>
						OBJ_COLNO <= SP2_VRAM_DO(3 downto 0);
					end case;
					SP2C <= SP2C_PLOT;
				end if;
			
			when SP2C_PLOT =>
				SP2_SEL <= '0';
				if OBJ_POS < 320 then
					if OBJ_COLINFO_Q_A(3 downto 0) = "0000" then
						OBJ_COLINFO_WE_A <= '1';
						OBJ_COLINFO_D_A <= OBJ_PRI & OBJ_PAL & OBJ_COLNO;
					else
						if OBJ_COLNO /= "0000" then
							SCOL_SET <= '1';
						end if;
					end if;
				end if;
				OBJ_POS <= OBJ_POS + 1;
				if OBJ_HF = '1' then
					if OBJ_X_OFS = "00000" then
						SP2C <= SP2C_NEXT;
					else
						OBJ_X_OFS <= OBJ_X_OFS - 1;
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
						OBJ_X_OFS <= OBJ_X_OFS + 1;
						SP2C <= SP2C_LOOP;
					end if;
				end if;
			
			when SP2C_TILE_RD =>
				if early_ack_sp2='0' then
					case OBJ_X_OFS(1 downto 0) is
					when "00" =>
						OBJ_COLNO <= SP2_VRAM_DO(15 downto 12);
					when "01" =>
						OBJ_COLNO <= SP2_VRAM_DO(11 downto 8);
					when "10" =>
						OBJ_COLNO <= SP2_VRAM_DO(7 downto 4);						
					when others =>
						OBJ_COLNO <= SP2_VRAM_DO(3 downto 0);
					end case;
					SP2C <= SP2C_PLOT;
				end if;
			
			when SP2C_NEXT =>
				OBJ_COLINFO_WE_A <= '0';
				OBJ_TOT <= OBJ_TOT + 1;
				OBJ_NEXT <= OBJ_LINK;

				-- 1) limit number of sprites per frame to 80 / 64
				-- FIXME: This is supposed to pass test 9 of the sprite
				--        masking and overflow test rom. But it doesn't in H32
		      -- 2) limit number of sprites per line to 20 / 16
 		      -- 3) limit sprite pixels per line to 320 / 256
				if (H40 = '1' and OBJ_TOT >=  79) or (H40 = '0' and OBJ_TOT >=  63) or
				   (H40 = '1' and OBJ_NB  >=  20) or (H40 = '0' and OBJ_NB  >=  16) or
				   (H40 = '1' and OBJ_PIX >= 320) or (H40 = '0' and OBJ_PIX >= 256) then
					SP2C <= SP2C_DONE;
					SOVR_SET <= '1';
				elsif OBJ_LINK = "0000000" then
					SP2C <= SP2C_DONE;
				else
					SP2C <= SP2C_Y_RD;
				end if;
			
			when others => -- SP2C_DONE
				SP2_SEL <= '0';
				OBJ_COLINFO_WE_A <= '0';
			end case;
		else	-- SP2E_ACTIVE = '0'
			SP2_SEL <= '0';
			SP2C <= SP2C_INIT;

			OBJ_COLINFO_WE_A <= '0';		
			OBJ_COLINFO_ADDR_A <= (others => '0');
		
			OBJ_Y_ADDR_RD <= (others => '0');
			OBJ_SZ_LINK_ADDR_RD <= (others => '0');
		end if;
	end if;
end process;

----------------------------------------------------------------
-- VIDEO COUNTING
----------------------------------------------------------------
CLOCKS_PER_LINE <= conv_std_logic_vector(CLOCKS_PER_LINE_H40, 12) when H40='1' else conv_std_logic_vector(CLOCKS_PER_LINE_H32, 12);
H_DISP_START  <= conv_std_logic_vector(H_DISP_START_H40, 12)      when H40='1' else conv_std_logic_vector(H_DISP_START_H32, 12);
HINT_START    <= conv_std_logic_vector(HINT_H40, 9)               when H40='1' else conv_std_logic_vector(HINT_H32, 9);
HBLANK_START  <= conv_std_logic_vector(HBLANK_START_H40, 9)       when H40='1' else conv_std_logic_vector(HBLANK_START_H32, 9);
HBLANK_END    <= conv_std_logic_vector(HBLANK_END_H40, 9)         when H40='1' else conv_std_logic_vector(HBLANK_END_H32, 9);

V_DISP_HEIGHT <= conv_std_logic_vector(V_DISP_HEIGHT_V30, 9)      when V30='1' else conv_std_logic_vector(V_DISP_HEIGHT_V28, 9);
V_DISP_START  <= conv_std_logic_vector(-V_DISP_START_V30, 9)      when V30='1' else conv_std_logic_vector(-V_DISP_START_V28, 9);
V_TOTAL_HEIGHT <= conv_std_logic_vector(PAL_LINES, 9)             when PAL='1' else conv_std_logic_vector(NTSC_LINES, 9);

-- COUNTERS AND INTERRUPTS
process( RST_N, CLK )
begin
	if RST_N = '0' then
		H_CNT <= (others => '0');
		FIELD <= '0';
		
		HV_PIXDIV <= (others => '0');
		HV_HCNT <= (others => '0');
		HV_VCNT <= (others => '0');

		HINT_PENDING_SET <= '0';
		VINT_TG68_PENDING_SET <= '0';
		VINT_T80_SET <= '0';
		VINT_T80_CLR <= '0';
		
		IN_HBL <= '0';
		IN_VBL <= '1';
		
	elsif rising_edge(CLK) then

		CE_PIX <= '0';

		if H_CNT = CLOCKS_PER_LINE-1 then
			H_CNT <= (others => '0');
		else
			H_CNT <= H_CNT + 1;
		end if;

		HINT_PENDING_SET <= '0';
		VINT_TG68_PENDING_SET <= '0';
		VINT_T80_SET <= '0';
		VINT_T80_CLR <= '0';

		if H_CNT = HS_CLOCKS then
			-- we're just after HSYNC
			if (H40 = '1') then
				HV_HCNT <= conv_std_logic_vector(-(H_DISP_START_H40-HS_CLOCKS)/8, 9);
			else
				HV_HCNT <= conv_std_logic_vector(-(H_DISP_START_H32-HS_CLOCKS)/10, 9);
			end if;
			HV_PIXDIV <= (others => '0');
		else
			HV_PIXDIV <= HV_PIXDIV + 1;
			if (H40 = '1' and HV_PIXDIV = 8-1) or (H40 = '0' and HV_PIXDIV = 10-1) then
				CE_PIX <= '1';
				HV_PIXDIV <= (others => '0');
				HV_HCNT <= HV_HCNT + 1;

				if HV_HCNT = HINT_START then
					if HV_VCNT = V_DISP_START + V_TOTAL_HEIGHT - 1 then --VDISP_START is negative
						--just after VSYNC
						HV_VCNT <= V_DISP_START;
						FIELD <= not FIELD;
					else
						HV_VCNT <= HV_VCNT + 1;
					end if;
				
					if HV_VCNT = 0 then
						if HIT = 0 then
							HINT_PENDING_SET <= '1';
							HINT_COUNT <= (others => '0');
						else
							HINT_COUNT <= HIT - 1;
						end if;
						IN_VBL <= '0';
					else
						if ( HV_VCNT > 0 ) and ( HV_VCNT < V_DISP_HEIGHT ) then
							if HINT_COUNT = 0 then
								HINT_PENDING_SET <= '1';
								HINT_COUNT <= HIT;
							else
								HINT_COUNT <= HINT_COUNT - 1;
							end if;
						end if;
					end if;
					if HV_VCNT = V_DISP_HEIGHT then
						VINT_TG68_PENDING_SET <= '1';
						VINT_T80_SET <= '1';
						IN_VBL <= '1';
					elsif HV_VCNT = V_DISP_HEIGHT + 1 then
						VINT_T80_CLR <= '1';
					end if;
				elsif HV_HCNT = HBLANK_START then
					if (HV_VCNT >= 0) and (HV_VCNT < V_DISP_HEIGHT) then
						IN_HBL <= '1';
					end if;
				elsif HV_HCNT = HBLANK_END then
					IN_HBL <= '0';	
				end if;
			end if;
		end if;
	end if;
end process;

-- TIMING MANAGEMENT
process( RST_N, CLK )
begin
	if RST_N = '0' then
		V_ACTIVE <= '0';		
		H_ACTIVE <= '0';		
		PRE_V_ACTIVE <= '0';
		BGEN_ACTIVE <= '0';
		SP1E_ACTIVE <= '0';
		SP2E_ACTIVE <= '0';
		DT_ACTIVE <= '0';
	elsif rising_edge(CLK) then
		
		-- HORIZONTAL DISPLAY ACTIVE
		if H_CNT = H_DISP_START then
			H_ACTIVE <= '1';
		elsif H_CNT = H_DISP_START+H_DISP_CLOCKS then
			H_ACTIVE <= '0';
		end if;

		-- BACKGROUND ACTIVE
		if H_CNT = H_DISP_START-60 and V_ACTIVE = '1' then
			BGEN_ACTIVE <= '1';
		elsif H_CNT = H_DISP_START+H_DISP_CLOCKS then
			BGEN_ACTIVE <= '0';
		end if;

		-- SPRITE ENGINE PART ONE ACTIVE
		if H_CNT = H_DISP_START+(3*H_DISP_CLOCKS/4) and PRE_V_ACTIVE = '1' then
			SP1E_ACTIVE <= '1';
		elsif H_CNT = H_DISP_START+H_DISP_CLOCKS then
			SP1E_ACTIVE <= '0';
		end if;

		-- SPRITE ENGINE PART TWO ACTIVE
		if H_CNT = H_DISP_START+(3*H_DISP_CLOCKS/4)+2 and PRE_V_ACTIVE = '1' then
			SP2E_ACTIVE <= '1';
		elsif H_CNT = H_DISP_START then
			SP2E_ACTIVE <= '0';
		end if;
		
		-- DATA TRANSFER ACTIVE
		DT_ACTIVE <= '1';
		
		-- VERTICAL DISPLAY ACTIVE
		if HV_HCNT = HINT_START + 1 then
			if HV_VCNT = 0 then
				V_ACTIVE <= '1';
			elsif HV_VCNT = V_DISP_HEIGHT then
				V_ACTIVE <= '0';
			end if;

			if HV_VCNT = "1"&x"FF" then
				PRE_V_ACTIVE <= '1';
			elsif HV_VCNT = V_DISP_HEIGHT - 1 then
				PRE_V_ACTIVE <= '0';
			end if;
		end if;
	end if;
end process;

-- PIXEL COUNTER AND OUTPUT
-- ALSO CLEARS THE SPRITE COLINFO BUFFER RIGHT AFTER RENDERING
process( RST_N, CLK )
begin
	OBJ_COLINFO_D_B <= (others => '0');
	if RST_N = '0' then
		X <= (others => '0');
		Y <= (others => '0');
		PIXDIV <= (others => '0');
		BGB_COLINFO_ADDR_B <= (others => '0');
		BGA_COLINFO_ADDR_B <= (others => '0');
		OBJ_COLINFO_ADDR_B <= (others => '0');

		OBJ_COLINFO_WE_B <= '0';
		
	elsif rising_edge(CLK) then
		if H_ACTIVE = '0' or V_ACTIVE = '0' then
			X <= (others => '0');
			PIXDIV <= (others => '0');
			
			FF_R <= (others => '0');
			FF_G <= (others => '0');
			FF_B <= (others => '0');

			OBJ_COLINFO_WE_B <= '0';			
		else
			PIXDIV <= PIXDIV + 1;

			case PIXDIV is
			when "0000" =>
				BGB_COLINFO_ADDR_B <= X;
				BGA_COLINFO_ADDR_B <= X;
				OBJ_COLINFO_ADDR_B <= X;
				OBJ_COLINFO_WE_B <= '0';
				
			when "0011" =>
				if OBJ_COLINFO_Q_B(3 downto 0) /= "0000" and OBJ_COLINFO_Q_B(6) = '1' then
					T_COLOR <= CRAM( CONV_INTEGER(OBJ_COLINFO_Q_B(5 downto 0)) );
				elsif BGA_COLINFO_Q_B(3 downto 0) /= "0000" and BGA_COLINFO_Q_B(6) = '1' then
					T_COLOR <= CRAM( CONV_INTEGER(BGA_COLINFO_Q_B(5 downto 0)) );
				elsif BGB_COLINFO_Q_B(3 downto 0) /= "0000" and BGB_COLINFO_Q_B(6) = '1' then
					T_COLOR <= CRAM( CONV_INTEGER(BGB_COLINFO_Q_B(5 downto 0)) );
				elsif OBJ_COLINFO_Q_B(3 downto 0) /= "0000" then
					T_COLOR <= CRAM( CONV_INTEGER(OBJ_COLINFO_Q_B(5 downto 0)) );
				elsif BGA_COLINFO_Q_B(3 downto 0) /= "0000" then
					T_COLOR <= CRAM( CONV_INTEGER(BGA_COLINFO_Q_B(5 downto 0)) );
				elsif BGB_COLINFO_Q_B(3 downto 0) /= "0000" then
					T_COLOR <= CRAM( CONV_INTEGER(BGB_COLINFO_Q_B(5 downto 0)) );
				else
					T_COLOR <= CRAM( CONV_INTEGER(BGCOL) );
				end if;
				
			when "0100" =>
				FF_B <= T_COLOR(11 downto 9);
				FF_G <= T_COLOR(7 downto 5);
				FF_R <= T_COLOR(3 downto 1);

				OBJ_COLINFO_WE_B <= '1';
				
			when "0101" =>
				OBJ_COLINFO_WE_B <= '0';
			
			when others => null;
			end case;

			if H40 = '1' and PIXDIV = 8-1 then				
				PIXDIV <= (others => '0');
				X <= X + 1;
			elsif H40 = '0' and PIXDIV = 10-1 then				
				PIXDIV <= (others => '0');
				X <= X + 1;
			end if;
		end if;
		
		if V_ACTIVE = '0' then
			Y <= (others => '0');
		else
			if H_CNT = 0 then
				Y <= Y + 1;
			end if;
		end if;		
		if PRE_V_ACTIVE = '0' then
			PRE_Y <= (others => '0');
		else
			if H_CNT = 0 then
				PRE_Y <= PRE_Y + 1;
			end if;
		end if;		

	end if;
end process;

----------------------------------------------------------------
-- VIDEO OUTPUT
----------------------------------------------------------------
-- 15KHZ WRITES
process( CLK )
begin
	if rising_edge(CLK) then
		if H_CNT(0) = '1' then
			COLOR <= FF_R & FF_G & FF_B;
		end if;
	end if;
end process;

-- VERTICAL SYNC
process( RST_N, CLK )
begin
	if RST_N = '0' then
		FF_VS <= '0';
	elsif rising_edge(CLK) then
		if HV_VCNT = V_DISP_START+V_TOTAL_HEIGHT-VS_LINES-1 then
			FF_VS <= '1';
		end if;
		if HV_VCNT = V_DISP_START+V_TOTAL_HEIGHT-1 then
			FF_VS <= '0';
		end if;
	end if;
end process;

-- HORIZONTAL SYNC
process( RST_N, CLK )
begin
	if RST_N = '0' then
		FF_HS <= '0';
	elsif rising_edge(CLK) then
		if H_CNT = 0 then
			FF_HS <= '1';
		end if;
		if H_CNT = HS_CLOCKS then
			FF_HS <= '0';
		end if;
	end if;
end process;

R <= COLOR(8 downto 6);
G <= COLOR(5 downto 3);
B <= COLOR(2 downto 0);
HS <= FF_HS;
VS <= FF_VS;
HBL <= not H_ACTIVE;
VBL <= not V_ACTIVE;

----------------------------------------------------------------
-- DATA TRANSFER CONTROLLER
----------------------------------------------------------------
VBUS_ADDR <= FF_VBUS_ADDR;
VBUS_UDS_N <= FF_VBUS_UDS_N;
VBUS_LDS_N <= FF_VBUS_LDS_N;
VBUS_SEL <= FF_VBUS_SEL;

process( RST_N, CLK )
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
		FF_VBUS_UDS_N <= '1';
		FF_VBUS_LDS_N <= '1';
		FF_VBUS_SEL	<= '0';
		
		DMA_FILL_PRE <= '0';
		DMA_FILL <= '0';
		DMA_COPY <= '0';
		DMA_VBUS <= '0';
		DMA_SOURCE <= (others => '0');
		DMA_LENGTH <= (others => '0');
		
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
					DTC <= DTC_DMA_VBUS_INIT;
				elsif DMA_FILL = '1' then
					DTC <= DTC_DMA_FILL_INIT;
				elsif DMA_COPY = '1' then
					DTC <= DTC_DMA_COPY_INIT;
				elsif FIFO_RD_POS /= FIFO_WR_POS then
					DTC <= DTC_FIFO_RD;
				elsif DT_RD_SEL = '1' and DT_RD_DTACK_N = '1' then
					case DT_RD_CODE is
					when "1000" => -- CRAM Read
						DTC <= DTC_CRAM_RD;
					when "0100" => -- VSRAM Read
						DTC <= DTC_VSRAM_RD;
					when others => -- VRAM Read
						DTC <= DTC_VRAM_RD1;
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
			
			when DTC_FIFO_RD =>
				DT_WR_ADDR <= FIFO_ADDR( CONV_INTEGER( FIFO_RD_POS ) );
				DT_WR_DATA <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) );
				--DT_WR_SIZE <= FIFO_SIZE( CONV_INTEGER( FIFO_RD_POS ) );				
				FIFO_RD_POS <= FIFO_RD_POS + 1;
				case FIFO_CODE( CONV_INTEGER( FIFO_RD_POS ) ) is
				when "011" => -- CRAM Write
					DTC <= DTC_CRAM_WR;
				when "101" => -- VSRAM Write
					DTC <= DTC_VSRAM_WR;
				when others => -- VRAM Write
					DTC <= DTC_VRAM_WR1;
				end case;
			
			when DTC_VRAM_WR1 =>
				DT_VRAM_SEL <= '1';
				DT_VRAM_ADDR <= DT_WR_ADDR(15 downto 1);
				DT_VRAM_RNW <= '0';
				-- if DT_WR_SIZE = '1' then
					if DT_WR_ADDR(0) = '0' then 
						DT_VRAM_DI <= DT_WR_DATA;
					else
						DT_VRAM_DI <= DT_WR_DATA(7 downto 0) & DT_WR_DATA(15 downto 8);
					end if;
					DT_VRAM_UDS_N <= '0';
					DT_VRAM_LDS_N <= '0';
					
				DTC <= DTC_VRAM_WR2;
			
			when DTC_VRAM_WR2 =>
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';	
					DTC <= DTC_IDLE;
				end if;

			when DTC_CRAM_WR =>
				CRAM( CONV_INTEGER(DT_WR_ADDR(6 downto 1)) ) <= DT_WR_DATA;
				DTC <= DTC_IDLE;
				
			when DTC_VSRAM_WR =>
				VSRAM( CONV_INTEGER(DT_WR_ADDR(6 downto 1)) ) <= DT_WR_DATA;
				DTC <= DTC_IDLE;
			
			when DTC_VRAM_RD1 =>
				DT_VRAM_SEL <= '1';
				DT_VRAM_ADDR <= ADDR(15 downto 1);
				DT_VRAM_RNW <= '1';
				DT_VRAM_UDS_N <= '0';
				DT_VRAM_LDS_N <= '0';
				DTC <= DTC_VRAM_RD2;
			
			when DTC_VRAM_RD2 =>
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';	
					DT_RD_DATA <= DT_VRAM_DO;
					DT_RD_DTACK_N <= '0';
					ADDR <= ADDR + ADDR_STEP;
					DTC <= DTC_IDLE;
				end if;
			
			when DTC_CRAM_RD =>
				DT_RD_DATA <= CRAM( CONV_INTEGER(ADDR(6 downto 1)) );
				DT_RD_DTACK_N <= '0';
				ADDR <= ADDR + ADDR_STEP;	
				DTC <= DTC_IDLE;
				
			when DTC_VSRAM_RD =>
				DT_RD_DATA <= VSRAM( CONV_INTEGER(ADDR(6 downto 1)) );
				DT_RD_DTACK_N <= '0';
				ADDR <= ADDR + ADDR_STEP;	
				DTC <= DTC_IDLE;

----------------------------------------------------------------
-- DMA FILL
----------------------------------------------------------------
				
			when DTC_DMA_FILL_INIT =>
				DMA_LENGTH <= REG(20) & REG(19);
				DTC <= DTC_DMA_FILL_WR;
				
			when DTC_DMA_FILL_WR =>
				DT_VRAM_SEL <= '1';
				DT_VRAM_ADDR <= ADDR(15 downto 1);
				DT_VRAM_RNW <= '0';
				DT_VRAM_DI <= DT_DMAF_DATA(7 downto 0) & DT_DMAF_DATA(7 downto 0);
				if ADDR(0) = '0' then
					DT_VRAM_UDS_N <= '1';
					DT_VRAM_LDS_N <= '0';
				else
					DT_VRAM_UDS_N <= '0';
					DT_VRAM_LDS_N <= '1';									
				end if;					
				DTC <= DTC_DMA_FILL_WR2;
				
			when DTC_DMA_FILL_WR2 =>	
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';	
					ADDR <= ADDR + ADDR_STEP;
					DMA_LENGTH <= DMA_LENGTH - 1;
					DTC <= DTC_DMA_FILL_LOOP;
				end if;
			
			when DTC_DMA_FILL_LOOP =>
				if DMA_LENGTH = 0 then
					DMA_FILL_PRE <= '0';
					DMA_FILL <= '0';
					REG(20) <= x"00";
					REG(19) <= x"00";
					DTC <= DTC_IDLE;
				else
					DTC <= DTC_DMA_FILL_WR;
				end if;

----------------------------------------------------------------
-- DMA COPY
----------------------------------------------------------------

			when DTC_DMA_COPY_INIT =>
				DMA_LENGTH <= REG(20) & REG(19);
				DMA_SOURCE <= REG(22) & REG(21);
				DTC <= DTC_DMA_COPY_RD;
				
			when DTC_DMA_COPY_RD =>
				DT_VRAM_SEL <= '1';
				DT_VRAM_ADDR <= DMA_SOURCE(15 downto 1);
				DT_VRAM_RNW <= '1';
				if DMA_SOURCE(0) = '0' then
					DT_VRAM_UDS_N <= '1';
					DT_VRAM_LDS_N <= '0';
				else
					DT_VRAM_UDS_N <= '0';
					DT_VRAM_LDS_N <= '1';									
				end if;					
				DTC <= DTC_DMA_COPY_RD2;
			
			when DTC_DMA_COPY_RD2 =>	
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';	
					DTC <= DTC_DMA_COPY_WR;
				end if;

			when DTC_DMA_COPY_WR =>
				DT_VRAM_SEL <= '1';
				DT_VRAM_ADDR <= ADDR(15 downto 1);
				DT_VRAM_RNW <= '0';
				DT_VRAM_DI <= DT_VRAM_DO;
				if ADDR(0) = '0' then
					DT_VRAM_UDS_N <= '1';
					DT_VRAM_LDS_N <= '0';
				else
					DT_VRAM_UDS_N <= '0';
					DT_VRAM_LDS_N <= '1';									
				end if;					
				DTC <= DTC_DMA_COPY_WR2;

			when DTC_DMA_COPY_WR2 =>	
				if early_ack_dt='0' then
--				if DT_VRAM_DTACK_N = '0' then
					DT_VRAM_SEL <= '0';	
					ADDR <= ADDR + ADDR_STEP;
					DMA_LENGTH <= DMA_LENGTH - 1;
					DMA_SOURCE <= DMA_SOURCE + 1;
					DTC <= DTC_DMA_COPY_LOOP;
				end if;
			
			when DTC_DMA_COPY_LOOP =>
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

----------------------------------------------------------------
-- DMA VBUS
----------------------------------------------------------------
				
			when DTC_DMA_VBUS_INIT =>
				DMA_LENGTH <= REG(20) & REG(19);
				DMA_SOURCE <= REG(22) & REG(21);
				DTC <= DTC_DMA_VBUS_RD;
				
			when DTC_DMA_VBUS_RD =>
				FF_VBUS_SEL <= '1';
				FF_VBUS_ADDR <= REG(23)(6 downto 0) & DMA_SOURCE & '0';
				FF_VBUS_UDS_N <= '0';
				FF_VBUS_LDS_N <= '0';
				DTC <= DTC_DMA_VBUS_RD2;

			when DTC_DMA_VBUS_RD2 =>	
				if VBUS_DTACK_N = '0' then
					FF_VBUS_SEL <= '0';
					DT_DMAV_DATA <= VBUS_DATA;
					DTC <= DTC_DMA_VBUS_SEL;
				end if;
	
			when DTC_DMA_VBUS_SEL =>
				case CODE(2 downto 0) is
				when "011" => -- CRAM Write
					DTC <= DTC_DMA_VBUS_CRAM_WR;
				when "101" => -- VSRAM Write
					DTC <= DTC_DMA_VBUS_VSRAM_WR;
				when others => -- VRAM Write
					DTC <= DTC_DMA_VBUS_VRAM_WR1;
				end case;					
				
	
			when DTC_DMA_VBUS_CRAM_WR =>
				CRAM( CONV_INTEGER(ADDR(6 downto 1)) ) <= DT_DMAV_DATA;
				ADDR <= ADDR + ADDR_STEP;
				DMA_LENGTH <= DMA_LENGTH - 1;
				DMA_SOURCE <= DMA_SOURCE + 1;
				DTC <= DTC_DMA_VBUS_LOOP;

			when DTC_DMA_VBUS_VSRAM_WR =>
				VSRAM( CONV_INTEGER(ADDR(6 downto 1)) ) <= DT_DMAV_DATA;
				ADDR <= ADDR + ADDR_STEP;
				DMA_LENGTH <= DMA_LENGTH - 1;
				DMA_SOURCE <= DMA_SOURCE + 1;
				DTC <= DTC_DMA_VBUS_LOOP;
			
			when DTC_DMA_VBUS_VRAM_WR1 =>
				DT_VRAM_SEL <= '1';
				DT_VRAM_ADDR <= ADDR(15 downto 1);
				DT_VRAM_RNW <= '0';
				if ADDR(0) = '0' then 
					DT_VRAM_DI <= DT_DMAV_DATA;
				else
					DT_VRAM_DI <= DT_DMAV_DATA(7 downto 0) & DT_DMAV_DATA(15 downto 8);
				end if;
				DT_VRAM_UDS_N <= '0';
				DT_VRAM_LDS_N <= '0';
				DTC <= DTC_DMA_VBUS_VRAM_WR2;
			
			when DTC_DMA_VBUS_VRAM_WR2 =>
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';	
					ADDR <= ADDR + ADDR_STEP;
					DMA_LENGTH <= DMA_LENGTH - 1;
					DMA_SOURCE <= DMA_SOURCE + 1;
					DTC <= DTC_DMA_VBUS_LOOP;					
				end if;
			
			when DTC_DMA_VBUS_LOOP =>
				if DMA_LENGTH = 0 then
					DMA_VBUS <= '0';
					REG(20) <= x"00";
					REG(19) <= x"00";
					REG(22) <= DMA_SOURCE(15 downto 8);
					REG(21) <= DMA_SOURCE(7 downto 0);
					DTC <= DTC_IDLE;
				else
					DTC <= DTC_DMA_VBUS_RD;
				end if;
				
			when others => null;
			end case;
		else	-- DT_ACTIVE = '0'
			-- Do nothing
		end if;
	end if;
end process;

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

