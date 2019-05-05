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

-- TODOs/Known issues (according to http://md.squee.co/VDP)
-- - window has priority over sprites?

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
library STD;
use STD.TEXTIO.ALL;
use work.vdp_common.all;

entity vdp is
	port(
		RST_N       : in std_logic;
		CLK         : in std_logic;
		
		SEL         : in std_logic;
		A           : in std_logic_vector(4 downto 1);
		RNW         : in std_logic;
		DI          : in std_logic_vector(15 downto 0);
		DO          : out std_logic_vector(15 downto 0);
		DTACK_N     : out std_logic;

		vram_req    : out std_logic;
		vram_ack    : in std_logic;
		vram_we     : out std_logic;
		vram_a      : buffer std_logic_vector(14 downto 0);
		vram_d      : out std_logic_vector(15 downto 0);
		vram_q      : in std_logic_vector(15 downto 0);
		vram_u_n    : out std_logic;
		vram_l_n    : out std_logic;
		
		HINT        : out std_logic;
		VINT_TG68   : out std_logic;
		VINT_T80    : out std_logic;
		INTACK      : in std_logic;

		VBUS_ADDR   : out std_logic_vector(23 downto 1);
		VBUS_DATA   : in std_logic_vector(15 downto 0);
		
		VBUS_SEL    : out std_logic;
		VBUS_DTACK_N: in std_logic;
		VBUS_BUSY   : out std_logic;

		PAL         : in std_logic := '0';
		FIELD_OUT   : out std_logic;
		INTERLACE   : out std_logic;
		CE_PIX      : out std_logic;
		HBL         : out std_logic;
		VBL         : out std_logic;

		R           : out std_logic_vector(3 downto 0);
		G           : out std_logic_vector(3 downto 0);
		B           : out std_logic_vector(3 downto 0);
		HS          : out std_logic;
		VS          : out std_logic;

		VRAM_SPEED  : in std_logic := '1' -- 0 - full speed, 1 - FIFO throttle emulation
	);
end vdp;

architecture rtl of vdp is

signal vram_req_reg : std_logic;
signal vram_a_reg	: std_logic_vector(16 downto 1);

----------------------------------------------------------------
-- ON-CHIP RAMS
----------------------------------------------------------------
signal CRAM_ADDR_A	: std_logic_vector(5 downto 0);
signal CRAM_ADDR_B	: std_logic_vector(5 downto 0);
signal CRAM_D_A		: std_logic_vector(8 downto 0);
signal CRAM_WE_A		: std_logic;
signal CRAM_WE_B		: std_logic;
signal CRAM_Q_A		: std_logic_vector(8 downto 0);
signal CRAM_Q_B		: std_logic_vector(8 downto 0);

type vsram_t is array(0 to 39) of std_logic_vector(10 downto 0);
signal VSRAM		: vsram_t;
----------------------------------------------------------------
-- CPU INTERFACE
----------------------------------------------------------------
signal FF_DTACK_N	: std_logic;
signal FF_DO		: std_logic_vector(15 downto 0);

type reg_t is array(0 to 31) of std_logic_vector(7 downto 0);
signal REG			: reg_t;
signal PENDING		: std_logic;
signal ADDR_LATCH	: std_logic_vector(16 downto 0);
signal REG_LATCH	: std_logic_vector(15 downto 0);
signal CODE			: std_logic_vector(5 downto 0);

type fifo_addr_t is array(0 to 3) of std_logic_vector(16 downto 0);
signal FIFO_ADDR	: fifo_addr_t;
type fifo_data_t is array(0 to 3) of std_logic_vector(15 downto 0);
signal FIFO_DATA	: fifo_data_t;
type fifo_code_t is array(0 to 3) of std_logic_vector(3 downto 0);
signal FIFO_CODE	: fifo_code_t;
signal FIFO_WR_POS	: std_logic_vector(1 downto 0);
signal FIFO_RD_POS	: std_logic_vector(1 downto 0);
signal FIFO_EMPTY	: std_logic;
signal FIFO_FULL	: std_logic;
signal REFRESH_SLOT	: std_logic;
signal FIFO_EN		: std_logic;
signal FIFO_SKIP	: std_logic;
signal FIFO_SKIP_PRE	: std_logic;

signal IN_DMA		: std_logic;
signal IN_HBL		: std_logic;
signal IN_VBL		: std_logic;

signal SOVR			: std_logic;
signal SP1_SOVR_SET	: std_logic;
signal SP3_SOVR_SET	: std_logic;
signal SOVR_CLR		: std_logic;

signal SCOL			: std_logic;
signal SCOL_SET		: std_logic;
signal SCOL_CLR		: std_logic;

----------------------------------------------------------------
-- INTERRUPTS
----------------------------------------------------------------
signal HINT_COUNT	: std_logic_vector(7 downto 0);
signal HINT_EN		: std_logic;
signal HINT_PENDING	: std_logic;
signal HINT_PENDING_SET	: std_logic;
signal HINT_FF		: std_logic;

signal VINT_TG68_PENDING		: std_logic;
signal VINT_TG68_PENDING_SET	: std_logic;
signal VINT_TG68_FF				: std_logic;

signal VINT_T80_SET				: std_logic;
signal VINT_T80_CLR				: std_logic;
signal VINT_T80_FF				: std_logic;

signal INTACK_D					: std_logic;
----------------------------------------------------------------
-- REGISTERS
----------------------------------------------------------------
signal RS0			: std_logic;
signal H40			: std_logic;
signal V30			: std_logic;
signal SHI			: std_logic;

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

signal M3			: std_logic;
signal DE			: std_logic;
signal M5			: std_logic;

signal M128			: std_logic;
signal DMA			: std_logic;

signal LSM			: std_logic_vector(1 downto 0);
signal ODD			: std_logic;

signal HV			: std_logic_vector(15 downto 0);
signal STATUS		: std_logic_vector(15 downto 0);
signal DBG			: std_logic_vector(15 downto 0);

-- Base addresses
signal HSCB			: std_logic_vector(5 downto 0);
signal NTBB			: std_logic_vector(2 downto 0);
signal NTWB			: std_logic_vector(4 downto 0);
signal NTAB			: std_logic_vector(2 downto 0);
signal SATB			: std_logic_vector(7 downto 0);



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
	DTC_WR_END,
	DTC_VRAM_RD1,
	DTC_VRAM_RD2,
	DTC_CRAM_RD,
	DTC_CRAM_RD1,
	DTC_CRAM_RD2,
	DTC_VSRAM_RD
);
signal DTC	: dtc_t;

type dmac_t is (
	DMA_IDLE,
	DMA_FILL_INIT,
	DMA_FILL_START,
	DMA_FILL_CRAM,
	DMA_FILL_VSRAM,
	DMA_FILL_WR,
	DMA_FILL_WR2,
	DMA_FILL_NEXT,
	DMA_FILL_LOOP,
	DMA_COPY_INIT,
	DMA_COPY_RD,
	DMA_COPY_RD2,
	DMA_COPY_WR,
	DMA_COPY_WR2,
	DMA_COPY_LOOP,
	DMA_VBUS_INIT,
	DMA_VBUS_RD,
	DMA_VBUS_RD2,
	DMA_VBUS_SEL,
	DMA_VBUS_LOOP
);
signal DMAC	: dmac_t;

signal DT_VRAM_SEL		: std_logic;
signal DT_VRAM_SEL_D	: std_logic;
signal DT_VRAM_ADDR		: std_logic_vector(16 downto 1);
signal DT_VRAM_DI		: std_logic_vector(15 downto 0);
signal DT_VRAM_DO		: std_logic_vector(15 downto 0);
signal DT_VRAM_DO_REG		: std_logic_vector(15 downto 0);
signal DT_VRAM_RNW		: std_logic;
signal DT_VRAM_UDS_N	: std_logic;
signal DT_VRAM_LDS_N	: std_logic;
signal DT_VRAM_DTACK_N	: std_logic;

signal DT_WR_ADDR	: std_logic_vector(16 downto 0);
signal DT_WR_DATA	: std_logic_vector(15 downto 0);

signal DT_FF_DATA	: std_logic_vector(15 downto 0);
signal DT_FF_CODE	: std_logic_vector(3 downto 0);
signal DT_FF_SEL	: std_logic;
signal DT_FF_DTACK_N	: std_logic;
signal DT_VBUS_SEL	: std_logic;

signal DT_RD_DATA	: std_logic_vector(15 downto 0);
signal DT_RD_CODE	: std_logic_vector(3 downto 0);
signal DT_RD_SEL	: std_logic;
signal DT_RD_DTACK_N	: std_logic;

signal ADDR			: std_logic_vector(16 downto 0);
signal ADDR_SET_REQ	: std_logic;
signal ADDR_SET_ACK : std_logic;
signal REG_SET_REQ	: std_logic;
signal REG_SET_ACK : std_logic;

signal DT_DMAF_DATA	: std_logic_vector(15 downto 0);
signal DT_DMAV_DATA	: std_logic_vector(15 downto 0);
signal DMAF_SET_REQ	: std_logic;

signal FF_VBUS_ADDR		: std_logic_vector(23 downto 0);
signal FF_VBUS_SEL		: std_logic;

signal DMA_VBUS		: std_logic;
signal DMA_FILL		: std_logic;
signal DMA_COPY		: std_logic;

signal DMA_LENGTH	: std_logic_vector(15 downto 0);
signal DMA_SOURCE	: std_logic_vector(15 downto 0);

----------------------------------------------------------------
-- VIDEO COUNTING
----------------------------------------------------------------
signal V_ACTIVE		: std_logic;
signal Y			: std_logic_vector(7 downto 0);
signal BG_Y		: std_logic_vector(8 downto 0);

signal PRE_V_ACTIVE	: std_logic;
signal PRE_Y		: std_logic_vector(8 downto 0);

signal FIELD		: std_logic;
signal FIELD_LATCH	: std_logic;

signal X			: std_logic_vector(8 downto 0);
signal PIXDIV		: std_logic_vector(3 downto 0);

signal DISP_ACTIVE	: std_logic;
signal DISP_ACTIVE_LAST_COLUMN	: std_logic;

-- HV COUNTERS
signal HV_PIXDIV	: std_logic_vector(3 downto 0);
signal HV_HCNT		: std_logic_vector(8 downto 0);
signal HV_VCNT		: std_logic_vector(8 downto 0);
signal HV_VCNT_EXT	: std_logic_vector(8 downto 0);
signal HV8			: std_logic;

-- TIMING VALUES
signal H_DISP_START    : std_logic_vector(8 downto 0);
signal H_DISP_WIDTH    : std_logic_vector(8 downto 0);
signal H_TOTAL_WIDTH   : std_logic_vector(8 downto 0);
signal H_SPENGINE_ON   : std_logic_vector(8 downto 0);
signal H_INT_POS       : std_logic_vector(8 downto 0);
signal HSYNC_START     : std_logic_vector(8 downto 0);
signal HSYNC_END       : std_logic_vector(8 downto 0);
signal HBLANK_START    : std_logic_vector(8 downto 0);
signal HBLANK_END      : std_logic_vector(8 downto 0);
signal HSCROLL_READ    : std_logic_vector(8 downto 0);
signal V_DISP_START    : std_logic_vector(8 downto 0);
signal V_DISP_HEIGHT   : std_logic_vector(8 downto 0);
signal VSYNC_HSTART    : std_logic_vector(8 downto 0);
signal VSYNC_START     : std_logic_vector(8 downto 0);
signal V_TOTAL_HEIGHT  : std_logic_vector(8 downto 0);
signal V_INT_POS       : std_logic_vector(8 downto 0);

----------------------------------------------------------------
-- VRAM CONTROLLER
----------------------------------------------------------------

type vmc_t is (
	VMC_IDLE,
	VMC_BGB,
	VMC_BGA,
	VMC_SP2,
	VMC_SP3,
	VMC_DT
);
signal VMC	: vmc_t := VMC_IDLE;
signal VMC_NEXT : vmc_t := VMC_IDLE;

signal early_ack_bga : std_logic;
signal early_ack_bgb : std_logic;
signal early_ack_sp2 : std_logic;
signal early_ack_sp3 : std_logic;
signal early_ack_dt : std_logic;
signal early_ack : std_logic;

----------------------------------------------------------------
-- BACKGROUND RENDERING
----------------------------------------------------------------

signal BGEN_ACTIVATE	: std_logic;

-- BACKGROUND B
type bgbc_t is (
	BGBC_INIT,
	BGBC_HS_RD,
	BGBC_CALC_Y,
	BGBC_CALC_BASE,
	BGBC_BASE_RD,
	BGBC_LOOP,
	BGBC_LOOP_WR,
	BGBC_SYNC_HCOUNT,
	BGBC_TILE_RD,
	BGBC_DONE
);
signal BGBC		: bgbc_t;

-- signal BGB_COLINFO		: colinfo_t;
signal BGB_COLINFO_ADDR_A	: std_logic_vector(8 downto 0);
signal BGB_COLINFO_ADDR_B	: std_logic_vector(8 downto 0);
signal BGB_COLINFO_D_A		: std_logic_vector(6 downto 0);
signal BGB_COLINFO_WE_A		: std_logic;
signal BGB_COLINFO_WE_B		: std_logic;
signal BGB_COLINFO_Q_B		: std_logic_vector(6 downto 0);


signal BGB_X		: std_logic_vector(9 downto 0);
signal BGB_POS		: std_logic_vector(9 downto 0);
signal BGB_Y		: std_logic_vector(10 downto 0);
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
signal BGB_VSRAM1_LATCH : std_logic_vector(10 downto 0);

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
signal BGA_COLINFO_WE_B		: std_logic;
signal BGA_COLINFO_Q_B		: std_logic_vector(6 downto 0);

signal BGA_X		: std_logic_vector(9 downto 0);
signal BGA_POS		: std_logic_vector(9 downto 0);
signal BGA_Y		: std_logic_vector(10 downto 0);
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
signal BGA_VSRAM0_LATCH : std_logic_vector(10 downto 0);

signal WIN_V		: std_logic;
signal WIN_H		: std_logic;

----------------------------------------------------------------
-- SPRITE ENGINE
----------------------------------------------------------------
signal OBJ_MAX_FRAME			: std_logic_vector(6 downto 0);
signal OBJ_MAX_LINE			: std_logic_vector(6 downto 0);

signal OBJ_CACHE_Y_L_D		: std_logic_vector(7 downto 0);
signal OBJ_CACHE_Y_L_WE		: std_logic;
signal OBJ_CACHE_Y_L_Q		: std_logic_vector(7 downto 0);
signal OBJ_CACHE_Y_H_D		: std_logic_vector(7 downto 0);
signal OBJ_CACHE_Y_H_WE		: std_logic;
signal OBJ_CACHE_Y_H_Q		: std_logic_vector(7 downto 0);

signal OBJ_CACHE_Y_D		: std_logic_vector(15 downto 0);
signal OBJ_CACHE_Y_ADDR_RD	: std_logic_vector(6 downto 0);
signal OBJ_CACHE_Y_ADDR_WR	: std_logic_vector(6 downto 0);
signal OBJ_CACHE_Y_Q		: std_logic_vector(15 downto 0);

signal OBJ_CACHE_SL_L_D		: std_logic_vector(7 downto 0);
signal OBJ_CACHE_SL_L_WE	: std_logic;
signal OBJ_CACHE_SL_L_Q		: std_logic_vector(7 downto 0);
signal OBJ_CACHE_SL_H_D		: std_logic_vector(7 downto 0);
signal OBJ_CACHE_SL_H_WE	: std_logic;
signal OBJ_CACHE_SL_H_Q		: std_logic_vector(7 downto 0);

signal OBJ_CACHE_SL_D		: std_logic_vector(15 downto 0);
signal OBJ_CACHE_SL_ADDR_RD	: std_logic_vector(6 downto 0);
signal OBJ_CACHE_SL_ADDR_WR	: std_logic_vector(6 downto 0);
signal OBJ_CACHE_SL_Q		: std_logic_vector(15 downto 0);

signal OBJ_VISINFO_ADDR_RD	: std_logic_vector(4 downto 0);
signal OBJ_VISINFO_ADDR_WR	: std_logic_vector(4 downto 0);
signal OBJ_VISINFO_D		: std_logic_vector(6 downto 0);
signal OBJ_VISINFO_WE		: std_logic;
signal OBJ_VISINFO_Q		: std_logic_vector(6 downto 0);

signal OBJ_SPINFO_ADDR_RD	: std_logic_vector(4 downto 0);
signal OBJ_SPINFO_ADDR_WR	: std_logic_vector(4 downto 0);
signal OBJ_SPINFO_D			: std_logic_vector(34 downto 0);
signal OBJ_SPINFO_WE		: std_logic;
signal OBJ_SPINFO_Q			: std_logic_vector(34 downto 0);

signal OBJ_COLINFO_CLK		: std_logic;
signal OBJ_COLINFO_ADDR_A	: std_logic_vector(8 downto 0);
signal OBJ_COLINFO_ADDR_B	: std_logic_vector(8 downto 0);
signal OBJ_COLINFO_D_B		: std_logic_vector(6 downto 0);
signal OBJ_COLINFO_WE_A		: std_logic;
signal OBJ_COLINFO_WE_B		: std_logic;
signal OBJ_COLINFO_Q_A		: std_logic_vector(6 downto 0);
signal OBJ_COLINFO_ADDR_RD_SP3  : std_logic_vector(8 downto 0);
signal OBJ_COLINFO_ADDR_RD_REND : std_logic_vector(8 downto 0);
signal OBJ_COLINFO_ADDR_WR_SP3  : std_logic_vector(8 downto 0);
signal OBJ_COLINFO_ADDR_WR_REND : std_logic_vector(8 downto 0);
signal OBJ_COLINFO_WE_SP3       : std_logic;
signal OBJ_COLINFO_WE_REND      : std_logic;
signal OBJ_COLINFO_D_SP3        : std_logic_vector(6 downto 0);
signal OBJ_COLINFO_D_REND       : std_logic_vector(6 downto 0);

-- PART 1
signal SP1E_ACTIVATE	: std_logic;

type sp1c_t is (
	SP1C_INIT,
	SP1C_Y_RD,
	SP1C_Y_RD2,
	SP1C_Y_RD3,
	SP1C_Y_TST,
	SP1C_SHOW,
	SP1C_NEXT,
	SP1C_DONE
);
signal SP1C	: SP1C_t;
signal SP1_Y			: std_logic_vector(8 downto 0);
signal SP1_STOP			: std_logic;
signal SP1_EN			: std_logic;

signal OBJ_TOT			: std_logic_vector(6 downto 0);
signal OBJ_NEXT			: std_logic_vector(6 downto 0);
signal OBJ_NB			: std_logic_vector(4 downto 0);
signal OBJ_Y_OFS		: std_logic_vector(8 downto 0);

signal OBJ_VS1			: std_logic_vector(1 downto 0);

signal OBJ_CACHE_ADDR_RD_SP1	: std_logic_vector(6 downto 0);

-- PART 2
signal SP2E_ACTIVATE	: std_logic;

type sp2c_t is (
	SP2C_INIT,
	SP2C_Y_RD,
	SP2C_Y_RD2,
	SP2C_Y_RD3,
	SP2C_Y_RD4,
	SP2C_X_RD,
	SP2C_X_TST,
	SP2C_TDEF_RD,
	SP2C_NEXT,
	SP2C_DONE
);
signal SP2C	: SP2C_t;
signal SP2_Y			: std_logic_vector(8 downto 0);
signal SP2_EN			: std_logic;
signal SP2_VRAM_ADDR	: std_logic_vector(14 downto 0);
signal SP2_VRAM_DO		: std_logic_vector(15 downto 0);
signal SP2_VRAM_DO_REG	: std_logic_vector(15 downto 0);
signal SP2_SEL			: std_logic;
signal SP2_DTACK_N		: std_logic;

signal OBJ_IDX			: std_logic_vector(4 downto 0);

signal OBJ_CACHE_ADDR_RD_SP2	: std_logic_vector(6 downto 0);

-- PART 3
signal SP3E_ACTIVATE	: std_logic;

type sp3c_t is (
	SP3C_INIT,
	SP3C_NEXT,
	SP3C_LOOP,
	SP3C_PLOT,
	SP3C_TILE_RD,
	SP3C_DONE
);
signal SP3C		: SP3C_t;

signal SP3_VRAM_ADDR	: std_logic_vector(14 downto 0);
signal SP3_VRAM_DO	: std_logic_vector(15 downto 0);
signal SP3_VRAM_DO_SAVE	: std_logic_vector(15 downto 0);
signal SP3_VRAM_DO_REG	: std_logic_vector(15 downto 0);
signal SP3_SEL		: std_logic;
signal SP3_DTACK_N	: std_logic;

signal OBJ_PIX			: std_logic_vector(8 downto 0);
signal OBJ_NO			: std_logic_vector(4 downto 0);

signal OBJ_LINK			: std_logic_vector(6 downto 0);

signal OBJ_HS			: std_logic_vector(1 downto 0);
signal OBJ_VS			: std_logic_vector(1 downto 0);
signal OBJ_MASKED		: std_logic;
signal OBJ_VALID_X	: std_logic;
signal OBJ_DOT_OVERFLOW	: std_logic;
signal OBJ_X_OFS		: std_logic_vector(4 downto 0);
signal OBJ_PRI			: std_logic;
signal OBJ_PAL			: std_logic_vector(1 downto 0);
signal OBJ_HF			: std_logic;
signal OBJ_POS			: std_logic_vector(8 downto 0);
signal OBJ_TILEBASE		: std_logic_vector(14 downto 0);

----------------------------------------------------------------
-- VIDEO OUTPUT
----------------------------------------------------------------
type pix_t is (
	PIX_SHADOW,
	PIX_NORMAL,
	PIX_HIGHLIGHT
);
signal PIX_MODE		: pix_t;
signal T_COLOR			: std_logic_vector(15 downto 0);

signal FF_R			: std_logic_vector(3 downto 0);
signal FF_G			: std_logic_vector(3 downto 0);
signal FF_B			: std_logic_vector(3 downto 0);
signal FF_VS		: std_logic;
signal FF_HS		: std_logic;
signal PIXOUT		: std_logic;

begin

bgb_ci : entity work.dpram
generic map (9,7)
port map(
	address_a	=> BGB_COLINFO_ADDR_A,
	address_b	=> BGB_COLINFO_ADDR_B,
	clock			=> CLK,
	data_a		=> BGB_COLINFO_D_A,
	data_b		=> (others => '0'),
	wren_a		=> BGB_COLINFO_WE_A,
	wren_b		=> BGB_COLINFO_WE_B,
	q_a			=> open,
	q_b			=> BGB_COLINFO_Q_B
);
BGB_COLINFO_WE_B <= '0';

bga_ci : entity work.dpram
generic map (9,7)
port map(
	address_a	=> BGA_COLINFO_ADDR_A,
	address_b	=> BGA_COLINFO_ADDR_B,
	clock			=> CLK,
	data_a		=> BGA_COLINFO_D_A,
	data_b		=> (others => '0'),
	wren_a		=> BGA_COLINFO_WE_A,
	wren_b		=> BGA_COLINFO_WE_B,
	q_a			=> open,
	q_b			=> BGA_COLINFO_Q_B
);
BGA_COLINFO_WE_B <= '0';

obj_ci : entity work.dpram
generic map (9,7)
port map(
	address_a	=> OBJ_COLINFO_ADDR_A,
	address_b	=> OBJ_COLINFO_ADDR_B,
	clock			=> OBJ_COLINFO_CLK,
	data_a		=> (others => '0'),
	data_b		=> OBJ_COLINFO_D_B,
	wren_a		=> OBJ_COLINFO_WE_A,
	wren_b		=> OBJ_COLINFO_WE_B,
	q_a			=> OBJ_COLINFO_Q_A,
	q_b			=> open
);
OBJ_COLINFO_CLK <= not CLK;
OBJ_COLINFO_ADDR_A <= OBJ_COLINFO_ADDR_RD_SP3 when SP3C /= SP3C_DONE else OBJ_COLINFO_ADDR_RD_REND;
OBJ_COLINFO_ADDR_B <= OBJ_COLINFO_ADDR_WR_SP3 when SP3C /= SP3C_DONE else OBJ_COLINFO_ADDR_WR_REND;
OBJ_COLINFO_WE_A <= '0';
OBJ_COLINFO_WE_B <= OBJ_COLINFO_WE_SP3 when SP3C /= SP3C_DONE else OBJ_COLINFO_WE_REND;
OBJ_COLINFO_D_B <= OBJ_COLINFO_D_SP3 when SP3C /= SP3C_DONE else OBJ_COLINFO_D_REND;

obj_cache_y_l : entity work.dpram
generic map (7,8)
port map(
	clock			=> CLK,
	data_a		=> (others => '0'),
	data_b		=> OBJ_CACHE_Y_L_D,
	address_a	=> OBJ_CACHE_Y_ADDR_RD,
	address_b	=> OBJ_CACHE_Y_ADDR_WR,
	wren_a		=> '0',
	wren_b		=> OBJ_CACHE_Y_L_WE,
	q_a			=> OBJ_CACHE_Y_L_Q,
	q_b			=> open
 );

obj_cache_y_h : entity work.dpram
generic map (7,8)
port map(
	clock			=> CLK,
	data_a		=> (others => '0'),
	data_b		=> OBJ_CACHE_Y_H_D,
	address_a	=> OBJ_CACHE_Y_ADDR_RD,
	address_b	=> OBJ_CACHE_Y_ADDR_WR,
	wren_a		=> '0',
	wren_b		=> OBJ_CACHE_Y_H_WE,
	q_a			=> OBJ_CACHE_Y_H_Q,
	q_b			=> open
 );

OBJ_CACHE_Y_L_D <= OBJ_CACHE_Y_D(7 downto 0);
OBJ_CACHE_Y_H_D <= OBJ_CACHE_Y_D(15 downto 8);
OBJ_CACHE_Y_Q <= OBJ_CACHE_Y_H_Q & OBJ_CACHE_Y_L_Q;

obj_cache_sl_l : entity work.dpram
generic map (7,8)
port map(
	clock			=> CLK,
	data_a		=> (others => '0'),
	data_b		=> OBJ_CACHE_SL_L_D,
	address_a	=> OBJ_CACHE_SL_ADDR_RD,
	address_b	=> OBJ_CACHE_SL_ADDR_WR,
	wren_a		=> '0',
	wren_b		=> OBJ_CACHE_SL_L_WE,
	q_a			=> OBJ_CACHE_SL_L_Q,
	q_b			=> open
 );

obj_cache_sl_h : entity work.dpram
generic map (7,8)
port map(
	clock			=> CLK,
	data_a		=> (others => '0'),
	data_b		=> OBJ_CACHE_SL_H_D,
	address_a	=> OBJ_CACHE_SL_ADDR_RD,
	address_b	=> OBJ_CACHE_SL_ADDR_WR,
	wren_a		=> '0',
	wren_b		=> OBJ_CACHE_SL_H_WE,
	q_a			=> OBJ_CACHE_SL_H_Q,
	q_b			=> open
 );

OBJ_CACHE_SL_L_D <= OBJ_CACHE_SL_D(7 downto 0);
OBJ_CACHE_SL_H_D <= OBJ_CACHE_SL_D(15 downto 8);
OBJ_CACHE_SL_Q <= OBJ_CACHE_SL_H_Q & OBJ_CACHE_SL_L_Q;

obj_visinfo : entity work.dpram
generic map (5,7)
port map(
	clock			=> CLK,
	data_a		=> (others => '0'),
	data_b		=> OBJ_VISINFO_D,
	address_a	=> OBJ_VISINFO_ADDR_RD,
	address_b	=> OBJ_VISINFO_ADDR_WR,
	wren_a		=> '0',
	wren_b		=> OBJ_VISINFO_WE,
	q_a			=> OBJ_VISINFO_Q,
	q_b			=> open
 );

obj_spinfo : entity work.dpram
generic map (5,35)
port map(
	clock			=> CLK,
	data_a		=> (others => '0'),
	data_b		=> OBJ_SPINFO_D,
	address_a	=> OBJ_SPINFO_ADDR_RD,
	address_b	=> OBJ_SPINFO_ADDR_WR,
	wren_a		=> '0',
	wren_b		=> OBJ_SPINFO_WE,
	q_a			=> OBJ_SPINFO_Q,
	q_b			=> open
 );

cram : entity work.dpram
generic map (6,9)
port map(
	address_a	=> CRAM_ADDR_A,
	address_b	=> CRAM_ADDR_B,
	clock			=> CLK,
	data_a		=> CRAM_D_A,
	data_b		=> (others => '0'),
	wren_a		=> CRAM_WE_A,
	wren_b		=> CRAM_WE_B,
	q_a			=> CRAM_Q_A,
	q_b			=> CRAM_Q_B
);
CRAM_WE_B <= '0';

----------------------------------------------------------------
-- REGISTERS
----------------------------------------------------------------
ADDR_STEP <= REG(15);
H40 <= REG(12)(0);
RS0 <= REG(12)(7);

SHI <= REG(12)(3);

-- H40 <= '0';
V30 <= REG(1)(3);
-- V30 <= '0';
HSCR <= REG(11)(1 downto 0);
HSIZE <= REG(16)(1 downto 0);
-- VSIZE is limited to 64 if HSIZE is 64, to 32 if HSIZE is 128
VSIZE <= "01" when REG(16)(5 downto 4) = "11" and HSIZE = "01" else
			"00" when HSIZE = "11" else
			REG(16)(5 downto 4);
VSCR <= REG(11)(2);

WVP <= REG(18)(4 downto 0);
WDOWN <= REG(18)(7);
WHP <= REG(17)(4 downto 0);
WRIGT <= REG(17)(7);

BGCOL <= REG(7)(5 downto 0);

HIT <= REG(10);
IE1 <= REG(0)(4);
IE0 <= REG(1)(5);

M3 <= REG(0)(1);

DMA <= REG(1)(4);
M128 <= REG(1)(7);

LSM <= REG(12)(2 downto 1);

DE <= REG(1)(6);
M5 <= REG(1)(2);

-- Base addresses
HSCB <= REG(13)(5 downto 0);
NTBB <= REG(4)(2 downto 0);
NTWB <= REG(3)(5 downto 2)&(REG(3)(1) and not H40);
NTAB <= REG(2)(5 downto 3);
SATB <= REG(5)(7 downto 1)&(REG(5)(0) and not H40);

-- Read-only registers
ODD <= FIELD when LSM(0) = '1' else '0';
IN_DMA <= DMA_FILL or DMA_COPY or DMA_VBUS;

STATUS <= "111111" & FIFO_EMPTY & FIFO_FULL & VINT_TG68_PENDING & SOVR & SCOL & ODD & (IN_VBL or not DE) & IN_HBL & IN_DMA & PAL;

INTERLACE <= LSM(1) and LSM(0);

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
		CODE <= (others => '0');
		
		DT_RD_SEL <= '0';
		DT_FF_SEL <= '0';
		
		SOVR_CLR <= '0';
		SCOL_CLR <= '0';

		DBG <= (others => '0');

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

					DT_FF_DATA <= DI;
					DT_FF_CODE <= CODE(3 downto 0);

					if DT_FF_DTACK_N = '1' then
						DT_FF_SEL <= '1';
					else
						DT_FF_SEL <= '0';
						FF_DTACK_N <= '0';
					end if;

				elsif A(4 downto 2) = "001" then
					-- Control Port
					if PENDING = '1' then
						CODE(4 downto 2) <= DI(6 downto 4);
						if DMA = '1' then
							CODE(5) <= DI(7);
						end if;
						ADDR_LATCH <= DI(2 downto 0) & ADDR(13 downto 0);

						-- In case of DMA VBUS request, hold the TG68 with DTACK_N
						-- it should avoid the use of a CLKEN signal
						if ADDR_SET_ACK = '0' then							
							ADDR_SET_REQ <= '1';
						else
							ADDR_SET_REQ <= '0';
							FF_DTACK_N <= '0';
							PENDING <= '0';
						end if;
					else						
						CODE(1 downto 0) <= DI(15 downto 14);
						if DI(15 downto 14) = "10" then
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
							ADDR_LATCH(13 downto 0) <= DI(13 downto 0);
							if ADDR_SET_ACK = '0' then
								ADDR_SET_REQ <= '1';
							else
								ADDR_SET_REQ <= '0';
								FF_DTACK_N <= '0';
								PENDING <= '1';
								CODE(5 downto 4) <= "00"; -- attempt to fix lotus i
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
				if A(3 downto 2) = "00" then
					PENDING <= '0';
					-- Data Port
					if CODE = "001000" -- CRAM Read
					or CODE = "000100" -- VSRAM Read
					or CODE = "000000" -- VRAM Read
					or CODE = "001100" -- VRAM Read 8 bit
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
					PENDING <= '0';
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

vram_d <= DT_VRAM_DI when M128 = '0' else DT_VRAM_DI(7 downto 0) & DT_VRAM_DI(7 downto 0);
vram_we <= not DT_VRAM_RNW when VMC=VMC_DT else '0';
vram_u_n <= (DT_VRAM_UDS_N or M128) and (not vram_a_reg(1) or not M128) when VMC=VMC_DT else '0';
vram_l_n <= (DT_VRAM_LDS_N or M128) and (vram_a_reg(1) or not M128) when VMC=VMC_DT else '0';
vram_a <= vram_a_reg(15 downto 1) when M128 = '0' else vram_a_reg(16 downto 11) & vram_a_reg(9 downto 2) & vram_a_reg(10);

early_ack_bga <= '0' when VMC=VMC_BGA and vram_req_reg=vram_ack else '1';
early_ack_bgb <= '0' when VMC=VMC_BGB and vram_req_reg=vram_ack else '1';
early_ack_sp2 <= '0' when VMC=VMC_SP2 and vram_req_reg=vram_ack else '1';
early_ack_sp3 <= '0' when VMC=VMC_SP3 and vram_req_reg=vram_ack else '1';
early_ack_dt <= '0' when VMC=VMC_DT and vram_req_reg=vram_ack else '1';

BGA_VRAM_DO <= vram_q when early_ack_bga='0' and BGA_DTACK_N = '1' else BGA_VRAM_DO_REG;
BGB_VRAM_DO <= vram_q when early_ack_bgb='0' and BGB_DTACK_N = '1' else BGB_VRAM_DO_REG;
SP2_VRAM_DO <= vram_q when early_ack_sp2='0' and SP2_DTACK_N = '1' else SP2_VRAM_DO_REG;
SP3_VRAM_DO <= vram_q when early_ack_sp3='0' and SP3_DTACK_N = '1' else SP3_VRAM_DO_REG;
DT_VRAM_DO <= vram_q when early_ack_dt='0' and DT_VRAM_DTACK_N = '1' else DT_VRAM_DO_REG;


process( RST_N, CLK,
	BGA_SEL, BGA_DTACK_N, BGB_SEL, BGB_DTACK_N,
	SP2_SEL, SP2_DTACK_N, SP3_SEL, SP3_DTACK_N, DT_VRAM_SEL, DT_VRAM_DTACK_N,
	early_ack_bga, early_ack_bgb, early_ack_sp2, early_ack_sp3, early_ack_dt)
-- synthesis translate_off
file F		: text open write_mode is "vram_dbg.out";
variable L	: line;
-- synthesis translate_on
begin
	if RST_N = '0' then
		
		BGB_DTACK_N <= '1';
		BGA_DTACK_N <= '1';
		SP2_DTACK_N <= '1';
		SP3_DTACK_N <= '1';
		DT_VRAM_DTACK_N <= '1';

		vram_req_reg <= '0';
		
		VMC<=VMC_IDLE;
		VMC_NEXT<=VMC_IDLE;
	else

		-- Priority encoder for next port...
		VMC_NEXT<=VMC_IDLE;
		if SP3_SEL = '1' and SP3_DTACK_N = '1' and early_ack_sp3='1' then
			VMC_NEXT <= VMC_SP3;
		elsif BGB_SEL = '1' and BGB_DTACK_N = '1' and early_ack_bgb='1' then
			VMC_NEXT <= VMC_BGB;
		elsif BGA_SEL = '1' and BGA_DTACK_N = '1' and early_ack_bga='1' then
			VMC_NEXT <= VMC_BGA;
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
--		if SP2_SEL = '0' then 
			SP2_DTACK_N <= '1';
--		end if;
--		if SP3_SEL = '0' then 
			SP3_DTACK_N <= '1';
--		end if;
		if DT_VRAM_SEL = '0' then 
			DT_VRAM_DTACK_N <= '1';
		end if;

		if vram_req_reg = vram_ack then
			VMC <= VMC_NEXT;
			case VMC_NEXT is
				when VMC_IDLE =>
					null;
				when VMC_BGA =>
					vram_a_reg <= '0'&BGA_VRAM_ADDR;
				when VMC_BGB =>
					vram_a_reg <= '0'&BGB_VRAM_ADDR;
				when VMC_SP2 =>
					vram_a_reg <= '0'&SP2_VRAM_ADDR;
				when VMC_SP3 =>
					vram_a_reg <= '0'&SP3_VRAM_ADDR;
				when VMC_DT =>
					vram_a_reg <= DT_VRAM_ADDR;
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

		when VMC_SP2 =>		-- SPRITE ENGINE PART 2
			if vram_req_reg = vram_ack then
				SP2_VRAM_DO_REG <= vram_q;
				SP2_DTACK_N <= '0';
			end if;

		when VMC_SP3 =>		-- SPRITE ENGINE PART 3
			if vram_req_reg = vram_ack then
				SP3_VRAM_DO_REG <= vram_q;
				SP3_DTACK_N <= '0';
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
variable vscroll_mask	: std_logic_vector(10 downto 0);
variable hscroll_mask	: std_logic_vector(9 downto 0);
variable vscroll_val	: std_logic_vector(10 downto 0);
variable y_cells	: std_logic_vector(6 downto 0);

-- synthesis translate_off
file F		: text open write_mode is "bgb_dbg.out";
variable L	: line;
-- synthesis translate_on
begin
	if RST_N = '0' then
		BGB_SEL <= '0';
		BGBC <= BGBC_DONE;
	elsif rising_edge(CLK) then
			case BGBC is
			when BGBC_DONE =>
				BGB_SEL <= '0';
				BGB_COLINFO_WE_A <= '0';
				BGB_COLINFO_ADDR_A <= (others => '0');
				if BGEN_ACTIVATE = '1' then
					BGBC <= BGBC_INIT;
				end if;
			when BGBC_INIT =>
				if HSIZE = "10" then
					-- illegal mode, 32x1
					hscroll_mask := "0011111111";
					vscroll_mask := "00000000111";
				else
					hscroll_mask := (HSIZE & "11111111");
					vscroll_mask := '0' & (VSIZE & "11111111");
				end if;

				if LSM = "11" then
					vscroll_mask := vscroll_mask(9 downto 0) & '1';
				end if;

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
				if early_ack_bgb = '0' then
					V_BGB_XSTART := "0000000000" - BGB_VRAM_DO(9 downto 0);
					BGB_SEL <= '0';
					BGB_X <= ( V_BGB_XSTART(9 downto 3) & "000" ) and hscroll_mask;
					BGB_POS <= "0000000000" - ( "0000000" & V_BGB_XSTART(2 downto 0) );
					BGBC <= BGBC_CALC_Y;
				end if;

			when BGBC_CALC_Y =>
				BGB_COLINFO_WE_A <= '0';
				if BGB_POS(9) = '1' or VSCR = '0' then
					if LSM = "11" then
						vscroll_val := BGB_VSRAM1_LATCH(10 downto 0);
					else
						vscroll_val := '0' & BGB_VSRAM1_LATCH(9 downto 0);
					end if;
				elsif LSM = "11" then
					vscroll_val := VSRAM( CONV_INTEGER(BGB_POS(8 downto 4) & "1") )(10 downto 0);
				else
					vscroll_val := '0' & VSRAM( CONV_INTEGER(BGB_POS(8 downto 4) & "1") )(9 downto 0);
				end if;
				BGB_Y <= (BG_Y + vscroll_val) and vscroll_mask;
				BGBC <= BGBC_CALC_BASE;

			when BGBC_CALC_BASE =>
				if LSM = "11" then
					y_cells := BGB_Y(10 downto 4);
				else
					y_cells := BGB_Y(9 downto 3);
				end if;
				case HSIZE is
				when "00"|"10" => -- HS 32 cells
					V_BGB_BASE := (NTBB & "0000000000000") + (BGB_X(9 downto 3) & "0") + (y_cells & "00000" & "0");
				when "01" => -- HS 64 cells
					V_BGB_BASE := (NTBB & "0000000000000") + (BGB_X(9 downto 3) & "0") + (y_cells & "000000" & "0");
				when "11" => -- HS 128 cells
					V_BGB_BASE := (NTBB & "0000000000000") + (BGB_X(9 downto 3) & "0") + (y_cells & "0000000" & "0");
				when others => null;
				end case;
				BGB_VRAM_ADDR <= V_BGB_BASE(15 downto 1);
				BGB_SEL <= '1';
				BGBC <= BGBC_BASE_RD;
				
			when BGBC_BASE_RD =>
				if early_ack_bgb='0' then
-- synthesis translate_off					
					write(L, string'("BGB BASE_RD Y="));
					hwrite(L, "000000" & BGB_Y(9 downto 0));
					write(L, string'(" X="));
					hwrite(L, "000000" & BGB_X(9 downto 0));
					write(L, string'(" POS="));
					hwrite(L, "000000" & BGB_POS(9 downto 0));				
					write(L, string'(" BASE_RD ["));
					hwrite(L, BGB_VRAM_ADDR & '0');					
					write(L, string'("] = ["));
					hwrite(L, BGB_VRAM_DO);
					write(L, string'("]"));
					writeline(F,L);									
-- synthesis translate_on											
					BGB_SEL <= '0';
					T_BGB_PRI <= BGB_VRAM_DO(15);
					T_BGB_PAL <= BGB_VRAM_DO(14 downto 13);
					BGB_HF <= BGB_VRAM_DO(11);
					if LSM = "11" then
						if BGB_VRAM_DO(12) = '1' then	-- VF
							BGB_TILEBASE <= BGB_VRAM_DO(9 downto 0) & not(BGB_Y(3 downto 0)) & "00";
						else
							BGB_TILEBASE <= BGB_VRAM_DO(9 downto 0) & BGB_Y(3 downto 0) & "00";
						end if;
					else
						if BGB_VRAM_DO(12) = '1' then	-- VF
							BGB_TILEBASE <= BGB_VRAM_DO(10 downto 0) & not(BGB_Y(2 downto 0)) & "00";
						else
							BGB_TILEBASE <= BGB_VRAM_DO(10 downto 0) & BGB_Y(2 downto 0) & "00";
						end if;
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
					BGB_X <= (BGB_X + 1) and hscroll_mask;
					if BGB_POS = H_DISP_WIDTH - 1 then
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
-- synthesis translate_off					
					write(L, string'("BGB TILE_RD Y="));
					hwrite(L, "000000" & BGB_Y(9 downto 0));
					write(L, string'(" X="));
					hwrite(L, "000000" & BGB_X(9 downto 0));
					write(L, string'(" POS="));
					hwrite(L, "000000" & BGB_POS(9 downto 0));				
					write(L, string'(" TILE_RD ["));
					hwrite(L, BGB_VRAM_ADDR & '0');					
					write(L, string'("] = ["));
					hwrite(L, BGB_VRAM_DO);
					write(L, string'("]"));
					writeline(F,L);									
-- synthesis translate_on											
					BGBC <= BGBC_LOOP;
				end if;
			
			when others =>	-- BGBC_DONE
				BGB_SEL <= '0';
				BGB_COLINFO_WE_A <= '0';
			end case;
	end if;
end process;


----------------------------------------------------------------
-- BACKGROUND A RENDERING
----------------------------------------------------------------
process( RST_N, CLK )
variable V_BGA_XSTART	: std_logic_vector(9 downto 0);
variable V_BGA_XBASE		: std_logic_vector(15 downto 0);
variable V_BGA_BASE		: std_logic_vector(15 downto 0);
variable vscroll_mask	: std_logic_vector(10 downto 0);
variable hscroll_mask	: std_logic_vector(9 downto 0);
variable vscroll_val    : std_logic_vector(10 downto 0);
variable y_cells    : std_logic_vector(6 downto 0);
-- synthesis translate_off
file F		: text open write_mode is "bga_dbg.out";
variable L	: line;
-- synthesis translate_on
begin
	if RST_N = '0' then
		BGA_SEL <= '0';
		BGAC <= BGAC_DONE;
	elsif rising_edge(CLK) then
			case BGAC is
			when BGAC_DONE =>
				BGA_SEL <= '0';
				BGA_COLINFO_ADDR_A <= (others => '0');
				BGA_COLINFO_WE_A <= '0';
				if BGEN_ACTIVATE = '1' then
					BGAC <= BGAC_INIT;
				end if;
			when BGAC_INIT =>
				if HSIZE = "10" then
					-- illegal mode, 32x1
					hscroll_mask := "0011111111";
					vscroll_mask := "00000000111";
				else
					hscroll_mask := (HSIZE & "11111111");
					vscroll_mask := '0' & (VSIZE & "11111111");
				end if;

				if LSM = "11" then
					vscroll_mask := vscroll_mask(9 downto 0) & '1';
				end if;

				if Y(2 downto 0) = "000" then
					if Y(7 downto 3) < WVP then
						WIN_V <= not WDOWN;
					else
						WIN_V <= WDOWN;
					end if;
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
				if early_ack_bga='0' then
					V_BGA_XSTART := "0000000000" - BGA_VRAM_DO(9 downto 0);
					BGA_SEL <= '0';
					BGA_X <= ( V_BGA_XSTART(9 downto 3) & "000" ) and hscroll_mask;
					BGA_POS <= "0000000000" - ( "0000000" & V_BGA_XSTART(2 downto 0) );
					BGAC <= BGAC_CALC_Y;
				end if;

			when BGAC_CALC_Y =>
				BGA_COLINFO_WE_A <= '0';
				if WIN_H = '1' or WIN_V = '1' then
					BGA_Y <= "00" & BG_Y;
				else
					if BGA_POS(9) = '1' or VSCR = '0' then
						if LSM = "11" then
							vscroll_val := BGA_VSRAM0_LATCH(10 downto 0);
						else
							vscroll_val := '0' & BGA_VSRAM0_LATCH(9 downto 0);
						end if;
					elsif LSM = "11" then
						vscroll_val := VSRAM( CONV_INTEGER(BGA_POS(8 downto 4) & "0") )(10 downto 0);
					else
						vscroll_val := '0' & VSRAM( CONV_INTEGER(BGA_POS(8 downto 4) & "0") )(9 downto 0);
					end if;
					BGA_Y <= (BG_Y + vscroll_val) and vscroll_mask;
				end if;
				BGAC <= BGAC_CALC_BASE;
				
			when BGAC_CALC_BASE =>
				if LSM = "11" then
					y_cells := BGA_Y(10 downto 4);
				else
					y_cells := BGA_Y(9 downto 3);
				end if;

				if WIN_H = '1' or WIN_V = '1' then
					V_BGA_XBASE := (NTWB & "00000000000") + (BGA_POS(9 downto 3) & "0");
					if H40 = '0' then -- WIN is 32 tiles wide in H32 mode
						V_BGA_BASE := V_BGA_XBASE + (y_cells & "00000" & "0");
					else              -- WIN is 64 tiles wide in H40 mode
						V_BGA_BASE := V_BGA_XBASE + (y_cells & "000000" & "0");
					end if;
			   else
					V_BGA_XBASE := (NTAB & "0000000000000") + (BGA_X(9 downto 3) & "0");
					case HSIZE is
					when "00"|"10" => -- HS 32 cells
						V_BGA_BASE := V_BGA_XBASE + (y_cells & "00000" & "0");
					when "01" => -- HS 64 cells
						V_BGA_BASE := V_BGA_XBASE + (y_cells & "000000" & "0");
					when "11" => -- HS 128 cells
						V_BGA_BASE := V_BGA_XBASE + (y_cells & "0000000" & "0");
					when others => null;
					end case;
				end if;

				BGA_VRAM_ADDR <= V_BGA_BASE(15 downto 1);
				BGA_SEL <= '1';
				BGAC <= BGAC_BASE_RD;
				
			when BGAC_BASE_RD =>
				if early_ack_bga='0' then
-- synthesis translate_off					
					write(L, string'("BGA BASE_RD Y="));
					hwrite(L, "000000" & BGA_Y(9 downto 0));
					write(L, string'(" X="));
					hwrite(L, "000000" & BGA_X(9 downto 0));
					write(L, string'(" POS="));
					hwrite(L, "000000" & BGA_POS(9 downto 0));				
					write(L, string'(" BASE_RD ["));
					hwrite(L, BGA_VRAM_ADDR & '0');					
					write(L, string'("] = ["));
					hwrite(L, BGA_VRAM_DO);
					write(L, string'("]"));
					writeline(F,L);									
-- synthesis translate_on											
					BGA_SEL <= '0';
					T_BGA_PRI <= BGA_VRAM_DO(15);
					T_BGA_PAL <= BGA_VRAM_DO(14 downto 13);
					BGA_HF <= BGA_VRAM_DO(11);
					if LSM = "11" then
						if BGA_VRAM_DO(12) = '1' then	-- VF
							BGA_TILEBASE <= BGA_VRAM_DO(9 downto 0) & not(BGA_Y(3 downto 0)) & "00";
						else
							BGA_TILEBASE <= BGA_VRAM_DO(9 downto 0) & BGA_Y(3 downto 0) & "00";
						end if;
					else
						if BGA_VRAM_DO(12) = '1' then	-- VF
							BGA_TILEBASE <= BGA_VRAM_DO(10 downto 0) & not(BGA_Y(2 downto 0)) & "00";
						else
							BGA_TILEBASE <= BGA_VRAM_DO(10 downto 0) & BGA_Y(2 downto 0) & "00";
						end if;
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
				--	and BGA_POS(3 downto 0) = "0000" and BGA_POS(8 downto 4) = WHP
					and BGA_X(2 downto 0) = "000" and BGA_POS(8 downto 4) = WHP
				then
					WIN_H <= not WIN_H;
					if WIN_V = '0' then
						BGAC <= BGAC_CALC_Y;
					end if;
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
					BGA_X <= (BGA_X + 1) and hscroll_mask;
					if BGA_POS = H_DISP_WIDTH - 1 then
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
-- synthesis translate_off					
					write(L, string'("BGA TILE_RD Y="));
					hwrite(L, "000000" & BGA_Y(9 downto 0));
					write(L, string'(" X="));
					hwrite(L, "000000" & BGA_X(9 downto 0));
					write(L, string'(" POS="));
					hwrite(L, "000000" & BGA_POS(9 downto 0));				
					write(L, string'(" TILE_RD ["));
					hwrite(L, BGA_VRAM_ADDR & '0');					
					write(L, string'("] = ["));
					hwrite(L, BGA_VRAM_DO);
					write(L, string'("]"));
					writeline(F,L);									
-- synthesis translate_on											
					BGAC <= BGAC_LOOP;
				end if;
			
			when others =>	-- BGAC_DONE
				BGA_SEL <= '0';
				BGA_COLINFO_WE_A <= '0';
			end case;
	end if;
end process;


----------------------------------------------------------------
-- SPRITE ENGINE
----------------------------------------------------------------
OBJ_MAX_FRAME <= conv_std_logic_vector(OBJ_MAX_FRAME_H40, 7) when H40 = '1' else
					  conv_std_logic_vector(OBJ_MAX_FRAME_H32, 7);
OBJ_MAX_LINE  <= conv_std_logic_vector(OBJ_MAX_LINE_H40, 7) when H40 = '1' else
					  conv_std_logic_vector(OBJ_MAX_LINE_H32, 7);

-- Write-through cache for Y, Link and size fields
process( RST_N, CLK )
variable cache_addr: std_logic_vector(13 downto 0);
begin
	if RST_N = '0' then
		OBJ_CACHE_Y_L_WE <= '0';
		OBJ_CACHE_Y_H_WE <= '0';
		OBJ_CACHE_Y_ADDR_WR <= (others => '0');

		OBJ_CACHE_SL_L_WE <= '0';
		OBJ_CACHE_SL_H_WE <= '0';
		OBJ_CACHE_SL_ADDR_WR <= (others => '0');
	elsif rising_edge(CLK) then
		OBJ_CACHE_Y_L_WE <= '0';
		OBJ_CACHE_Y_H_WE <= '0';
		OBJ_CACHE_SL_L_WE <= '0';
		OBJ_CACHE_SL_H_WE <= '0';

		cache_addr := DT_VRAM_ADDR(16 downto 3) - (SATB & "000000");
		DT_VRAM_SEL_D <= DT_VRAM_SEL;
		if DT_VRAM_SEL_D = '0' and DT_VRAM_SEL = '1' and DT_VRAM_RNW = '0' and
		   DT_VRAM_ADDR(2) = '0' and cache_addr < OBJ_MAX_FRAME
		then
			if DT_VRAM_ADDR(1) = '0' then
				OBJ_CACHE_Y_L_WE <= not DT_VRAM_LDS_N;
				OBJ_CACHE_Y_H_WE <= not DT_VRAM_UDS_N;
				OBJ_CACHE_Y_ADDR_WR <= cache_addr(6 downto 0);
				OBJ_CACHE_Y_D <= DT_VRAM_DI;
			end if;
			if DT_VRAM_ADDR(1) = '1' then
				OBJ_CACHE_SL_ADDR_WR <= cache_addr(6 downto 0);
				OBJ_CACHE_SL_L_WE <= not DT_VRAM_LDS_N;
				OBJ_CACHE_SL_H_WE <= not DT_VRAM_UDS_N;
				OBJ_CACHE_SL_D <= DT_VRAM_DI;
			end if;
		end if;
	end if;
end process;


OBJ_CACHE_SL_ADDR_RD <= OBJ_CACHE_ADDR_RD_SP1 when SP1C /= SP1C_DONE else OBJ_CACHE_ADDR_RD_SP2;
OBJ_CACHE_Y_ADDR_RD <= OBJ_CACHE_ADDR_RD_SP1 when SP1C /= SP1C_DONE else OBJ_CACHE_ADDR_RD_SP2;

----------------------------------------------------------------
-- SPRITE ENGINE - PART ONE
------------------------------------------------------------------
-- determine the first 16/20 visible sprites
process( RST_N, CLK )
-- synthesis translate_off
file F		: text open write_mode is "sp1_dbg.out";
variable L	: line;
-- synthesis translate_on
variable y_offset: std_logic_vector(9 downto 0);
begin
	if RST_N = '0' then
		SP1C <= SP1C_DONE;
		OBJ_CACHE_ADDR_RD_SP1 <= (others => '0');

		OBJ_VISINFO_ADDR_WR <= (others => '0');

		SP1_SOVR_SET <= '0';
		SP1_STOP <= '0';

	elsif rising_edge(CLK) then

		SP1_SOVR_SET <= '0';

		case SP1C is
			when SP1C_INIT =>
				SP1_Y <= PRE_Y;	-- Latch the current PRE_Y value
				OBJ_TOT <= (others => '0');
				OBJ_NEXT <= (others => '0');
				OBJ_NB <= (others => '0');
				OBJ_VISINFO_WE <= '0';
				SP1_STOP <= '0';
				SP1C <= SP1C_Y_RD;

			when SP1C_Y_RD =>
				if DE='0' then
					SP1_STOP <= '1';
				end if;
				if SP1_EN = '1' then --check one sprite/pixel, this matches the original HW behavior
					OBJ_CACHE_ADDR_RD_SP1 <= OBJ_NEXT;
					SP1C <= SP1C_Y_RD2;
				end if;

			when SP1C_Y_RD2 =>
				SP1C <= SP1C_Y_RD3;

			when SP1C_Y_RD3 =>
				if LSM = "11" then
					y_offset := "0100000000" + SP1_Y - OBJ_CACHE_Y_Q(9 downto 0);
					OBJ_Y_OFS <= y_offset(9 downto 1);
				else
					y_offset := "0010000000" + SP1_Y - ('0' & OBJ_CACHE_Y_Q(8 downto 0));
					OBJ_Y_OFS <= y_offset(8 downto 0);
				end if;
				OBJ_VS1 <= OBJ_CACHE_SL_Q(9 downto 8);
				OBJ_LINK <= OBJ_CACHE_SL_Q(6 downto 0);
				SP1C <= SP1C_Y_TST;

			when SP1C_Y_TST =>
				SP1C <= SP1C_NEXT;
				if (OBJ_VS1 = "00" and OBJ_Y_OFS(8 downto 3) = "000000") or -- 8 pix
				   (OBJ_VS1 = "01" and OBJ_Y_OFS(8 downto 4) = "00000") or  -- 16 pix
				   (OBJ_VS1 = "11" and OBJ_Y_OFS(8 downto 5) = "0000") or   -- 32 pix
				   (OBJ_VS1 = "10" and OBJ_Y_OFS(8 downto 5) = "0000" and OBJ_Y_OFS(4 downto 3) /= "11") --24 pix
				then
					SP1C <= SP1C_SHOW;
				end if;

			when SP1C_SHOW =>
				-- synthesis translate_off
				write(L, string'("OBJ ID="));
				hwrite(L, "0" & OBJ_NEXT);
				write(L, string'(" Y = "));
				hwrite(L, "000000" & OBJ_CACHE_Y_Q(9 downto 0));
				write(L, string'(" VS = "));
				hwrite(L, "000000" & OBJ_VS1);
				write(L, string'(" LINK = "));
				hwrite(L, "0" & OBJ_LINK);
				write(L, string'(" SP1_Y = "));
				hwrite(L, "0000000" & SP1_Y);
				write(L, string'(" HV_VCNT = "));
				hwrite(L, "0000000" & HV_VCNT);
				write(L, string'(" OFS ="));
				hwrite(L, "000000" & OBJ_Y_OFS);
				write(L, string'(" OBJ_NB ="));
				hwrite(L, "000" & OBJ_NB);
				writeline(F,L);
				-- synthesis translate_on
				OBJ_NB <= OBJ_NB + 1;
				OBJ_VISINFO_WE <= '1';
				OBJ_VISINFO_ADDR_WR <= OBJ_NB;
				OBJ_VISINFO_D <= OBJ_NEXT;
				SP1C <= SP1C_NEXT;

			when SP1C_NEXT =>
				OBJ_VISINFO_WE <= '0';
				OBJ_TOT <= OBJ_TOT + 1;
				OBJ_NEXT <= OBJ_LINK;

				-- limit number of sprites per line to 20 / 16
				if OBJ_NB = OBJ_MAX_LINE then
					SP1C <= SP1C_DONE;
					SP1_SOVR_SET <= '1';
				-- check a total of 80 sprites in H40 mode and 64 sprites in H32 mode
				elsif OBJ_TOT = OBJ_MAX_FRAME - 1  or 
					 -- the following checks are inspired by the gens-ii emulator
						OBJ_LINK >= OBJ_MAX_FRAME or
						OBJ_LINK = "0000000" or
						SP1_STOP = '1'
				then
					SP1C <= SP1C_DONE;
				else
					SP1C <= SP1C_Y_RD;
				end if;

			when others => -- SP1C_DONE
				OBJ_VISINFO_WE <= '0';
				OBJ_VISINFO_ADDR_WR <= (others => '0');

				if SP1E_ACTIVATE = '1' then
					SP1C <= SP1C_INIT;
				end if;
		end case;
	end if;
end process;

----------------------------------------------------------------
-- SPRITE ENGINE - PART TWO
----------------------------------------------------------------
--fetch X and size info for visible sprites
process( RST_N, CLK )
variable y_offset: std_logic_vector(9 downto 0);
begin
	if RST_N = '0' then
		SP2_SEL <= '0';
		SP2C <= SP2C_DONE;
		OBJ_CACHE_ADDR_RD_SP2 <= (others => '0');
		OBJ_SPINFO_ADDR_WR <= (others => '0');
		OBJ_SPINFO_WE <= '0';

	elsif rising_edge(CLK) then

		case SP2C is
			when SP2C_INIT =>
				SP2_Y <= PRE_Y;	-- Latch the current PRE_Y value

				-- Treat VISINFO as a shift register, so start reading
				-- from the first unused location.
				-- This way visible sprites processed late.
				if OBJ_NB = OBJ_MAX_LINE
				then
					OBJ_IDX <= (others => '0');
					OBJ_VISINFO_ADDR_RD <= (others => '0');
				else
					OBJ_IDX <= OBJ_NB;
					OBJ_VISINFO_ADDR_RD <= OBJ_NB;
				end if;

				SP2C <= SP2C_Y_RD;

			when SP2C_Y_RD =>
				if SP2_EN = '1' then
					if OBJ_IDX < OBJ_NB then
						SP2C <= SP2C_Y_RD2;
					else
						SP2C <= SP2C_NEXT;
					end if;
				end if;

			when SP2C_Y_RD2 =>
				OBJ_CACHE_ADDR_RD_SP2 <= OBJ_VISINFO_Q(6 downto 0);
				SP2C <= SP2C_Y_RD3;
			when SP2C_Y_RD3 =>
				SP2C <= SP2C_Y_RD4;
			when SP2C_Y_RD4 =>
				if LSM = "11" then
					y_offset := "0100000000" + SP2_Y - OBJ_CACHE_Y_Q(9 downto 0);
				else
					y_offset := "0010000000" + SP2_Y - ('0' & OBJ_CACHE_Y_Q(8 downto 0));
				end if;
				--save only the last 5(6 in doubleres) bits of the offset for part 3
				--Titan 2 textured cube (ab)uses this
				OBJ_SPINFO_D(5 downto 0) <= y_offset(5 downto 0); --Y offset
				OBJ_SPINFO_D(7 downto 6) <= OBJ_CACHE_SL_Q(9 downto 8); --VS
				OBJ_SPINFO_D(9 downto 8) <= OBJ_CACHE_SL_Q(11 downto 10); --HS
				SP2_VRAM_ADDR <= (SATB(6 downto 0) & "00000000") + (OBJ_VISINFO_Q(6 downto 0) & "11");
				SP2_SEL <= '1';
				SP2C <= SP2C_X_RD;

			when SP2C_X_RD =>
				if early_ack_sp2='0' then
					SP2_SEL <= '0';
					OBJ_SPINFO_D(18 downto 10) <= SP2_VRAM_DO(8 downto 0); --X
					SP2C <= SP2C_X_TST;
				end if;

			when SP2C_X_TST =>
				SP2_VRAM_ADDR <= (SATB(6 downto 0) & "00000000") + (OBJ_VISINFO_Q(6 downto 0) & "10");
				SP2_SEL <= '1';
				SP2C <= SP2C_TDEF_RD;

			when SP2C_TDEF_RD =>
				if early_ack_sp2='0' then
					SP2_SEL <= '0';
					OBJ_SPINFO_D(34) <= SP2_VRAM_DO(15); --PRI
					OBJ_SPINFO_D(33 downto 32) <= SP2_VRAM_DO(14 downto 13); --PAL
					OBJ_SPINFO_D(31) <= SP2_VRAM_DO(12); --VF
					OBJ_SPINFO_D(30) <= SP2_VRAM_DO(11); --HF
					OBJ_SPINFO_D(29 downto 19) <= SP2_VRAM_DO(10 downto 0); --PAT
					OBJ_SPINFO_ADDR_WR <= OBJ_IDX;
					OBJ_SPINFO_WE <= '1';
					SP2C <= SP2C_NEXT;
				end if;

			when SP2C_NEXT =>
				OBJ_SPINFO_WE <= '0';
				SP2C <= SP2C_Y_RD;
				if OBJ_IDX = OBJ_MAX_LINE - 1
				then
					if OBJ_NB = 0 or OBJ_NB = OBJ_MAX_LINE
					then
						OBJ_IDX <= OBJ_NB;
						SP2C <= SP2C_DONE;
					else
						OBJ_IDX <= (others => '0');
						OBJ_VISINFO_ADDR_RD <= (others => '0');
					end if;
				else
					if OBJ_NB = OBJ_IDX + 1 then
						OBJ_IDX <= OBJ_NB;
						SP2C <= SP2C_DONE;
					else
						OBJ_IDX <= OBJ_IDX + 1;
						OBJ_VISINFO_ADDR_RD <= OBJ_IDX + 1;
					end if;
				end if;

			when others => -- SP2C_DONE
				SP2_SEL <= '0';

				if SP2E_ACTIVATE = '1' then
					SP2C <= SP2C_INIT;
				end if;
		end case;
	end if;
end process;

----------------------------------------------------------------
-- SPRITE ENGINE - PART THREE
----------------------------------------------------------------
process( RST_N, CLK )
variable obj_vs_var	: std_logic_vector(1 downto 0);
variable obj_hs_var : std_logic_vector(1 downto 0);
variable obj_hf_var	: std_logic;
variable obj_vf_var	: std_logic;
variable obj_x_var	: std_logic_vector(8 downto 0);
variable obj_y_ofs_var: std_logic_vector(5 downto 0);
variable obj_pat_var	: std_logic_vector(10 downto 0);
variable obj_color	: std_logic_vector(3 downto 0);

-- synthesis translate_off
file F		: text open write_mode is "sp3_dbg.out";
variable L	: line;
-- synthesis translate_on
begin
	if RST_N = '0' then
		SP3_SEL <= '0';
		SP3C <= SP3C_DONE;

		OBJ_DOT_OVERFLOW <= '0';

		SCOL_SET <= '0';
		SP3_SOVR_SET <= '0';

	elsif rising_edge(CLK) then

		SCOL_SET <= '0';
		SP3_SOVR_SET <= '0';

		case SP3C is
			when SP3C_INIT =>
				OBJ_NO <= (others => '0');
				OBJ_SPINFO_ADDR_RD <= (others => '0');
				OBJ_PIX <= (others => '0');
				OBJ_MASKED <= '0';
				OBJ_VALID_X <= OBJ_DOT_OVERFLOW;
				OBJ_DOT_OVERFLOW <= '0';
				SP3C <= SP3C_NEXT;

			when SP3C_NEXT =>

				OBJ_COLINFO_WE_SP3 <= '0';

				SP3C <= SP3C_LOOP;
				if OBJ_NO = OBJ_IDX	then
					SP3C <= SP3C_DONE;
				end if;

				obj_vs_var := OBJ_SPINFO_Q(7 downto 6);
				OBJ_VS <= obj_vs_var;
				obj_hs_var := OBJ_SPINFO_Q(9 downto 8);
				OBJ_HS <= obj_hs_var;
				obj_x_var := OBJ_SPINFO_Q(18 downto 10);
				if LSM = "11" then
					obj_pat_var := OBJ_SPINFO_Q(28 downto 19) & '0';
					obj_y_ofs_var := OBJ_SPINFO_Q(5 downto 0);
				else
					obj_pat_var := OBJ_SPINFO_Q(29 downto 19);
					obj_y_ofs_var := '0' & OBJ_SPINFO_Q(4 downto 0);
				end if;
				obj_hf_var := OBJ_SPINFO_Q(30);
				OBJ_HF <= obj_hf_var;
				obj_vf_var := OBJ_SPINFO_Q(31);
				OBJ_PAL <= OBJ_SPINFO_Q(33 downto 32);
				OBJ_PRI <= OBJ_SPINFO_Q(34);

				OBJ_SPINFO_ADDR_RD <= OBJ_NO + 1;
				OBJ_NO <= OBJ_NO + 1;

				-- sprite masking algorithm as implemented by gens-ii
				if obj_x_var = "000000000" and OBJ_VALID_X = '1' then
					OBJ_MASKED <= '1';
				end if;

				if obj_x_var /= "000000000" then
					OBJ_VALID_X <= '1';
				end if;

				OBJ_X_OFS <= "00000";
				if obj_hf_var = '1' then
					case obj_hs_var is
					when "00" =>	-- 8 pixels
						OBJ_X_OFS <= "00111";
					when "01" =>	-- 16 pixels
						OBJ_X_OFS <= "01111";
					when "11" =>	-- 32 pixels
						OBJ_X_OFS <= "11111";
					when others =>	-- 24 pixels
						OBJ_X_OFS <= "10111";
					end case;
				end if;

				if LSM = "11" and obj_vf_var = '1' then
					case obj_vs_var is
					when "00" =>	-- 2*8 pixels
						obj_y_ofs_var := "00" & not(obj_y_ofs_var(3 downto 0));
					when "01" =>	-- 2*16 pixels
						obj_y_ofs_var := "0" & not(obj_y_ofs_var(4 downto 0));
					when "11" =>	-- 2*32 pixels
						obj_y_ofs_var := not(obj_y_ofs_var(5 downto 0));
					when others =>	-- 2*24 pixels
						obj_y_ofs_var := "101111" - obj_y_ofs_var; -- 47-obj_y_ofs
					end case;
				end if;

				if LSM /= "11" and obj_vf_var = '1' then
					case obj_vs_var is
					when "00" =>	-- 8 pixels
						obj_y_ofs_var := "000" & not(obj_y_ofs_var(2 downto 0));
					when "01" =>	-- 16 pixels
						obj_y_ofs_var := "00" & not(obj_y_ofs_var(3 downto 0));
					when "11" =>	-- 32 pixels
						obj_y_ofs_var := "0" & not(obj_y_ofs_var(4 downto 0));
					when others =>	-- 24 pixels
						obj_y_ofs_var := "010111" - obj_y_ofs_var(4 downto 0);
					end case;
				end if;

				OBJ_POS <= obj_x_var - "010000000";
				OBJ_TILEBASE <= (obj_pat_var & "0000") + ("000" & obj_y_ofs_var & "0");

			-- loop over all tiles of the sprite
			when SP3C_LOOP =>
				OBJ_COLINFO_WE_SP3 <= '0';
				OBJ_COLINFO_ADDR_RD_SP3 <= OBJ_POS;

				if LSM = "11" then
					case OBJ_VS is
					when "00" =>	-- 2*8 pixels
						SP3_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "0000" & OBJ_X_OFS(2));
					when "01" =>	-- 2*16 pixels
						SP3_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "00000" & OBJ_X_OFS(2));
					when "11" =>	-- 2*32 pixels
						SP3_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "000000" & OBJ_X_OFS(2));
					when others =>	-- 2*24 pixels
						case OBJ_X_OFS(4 downto 3) is
						when "00" =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + OBJ_X_OFS(2);
						when "01" =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + ("00110000" & OBJ_X_OFS(2));
						when "11" =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + ("10010000" & OBJ_X_OFS(2));
						when others =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + ("01100000" & OBJ_X_OFS(2));
						end case;
					end case;
				else
					case OBJ_VS is
					when "00" =>	-- 8 pixels
						SP3_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "000" & OBJ_X_OFS(2));
					when "01" =>	-- 16 pixels
						SP3_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "0000" & OBJ_X_OFS(2));
					when "11" =>	-- 32 pixels
						SP3_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "00000" & OBJ_X_OFS(2));
					when others =>	-- 24 pixels
						case OBJ_X_OFS(4 downto 3) is
						when "00" =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + OBJ_X_OFS(2);
						when "01" =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + ("0011000" & OBJ_X_OFS(2));
						when "11" =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + ("1001000" & OBJ_X_OFS(2));
						when others =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + ("0110000" & OBJ_X_OFS(2));
						end case;
					end case;
				end if;

				SP3_SEL <= '1';
				SP3C <= SP3C_TILE_RD;

			-- loop over all sprite pixels on the current line
			when SP3C_PLOT =>
			  if ((OBJ_X_OFS(2 downto 0) = "011" and OBJ_HF = '0') or
				  (OBJ_X_OFS(2 downto 0) = "100" and OBJ_HF = '1')) and early_ack_sp3 /= '0'
			  then
				null; --wait for the pre-fetched value
			  else
				-- pre-fetch the 2nd word of the tile
				if (OBJ_X_OFS(2 downto 0) = "000" and OBJ_HF = '0') then
					SP3_VRAM_ADDR <= SP3_VRAM_ADDR + 1;
					SP3_SEL <= '1';
				elsif (OBJ_X_OFS(2 downto 0) = "111" and OBJ_HF = '1') then
					SP3_VRAM_ADDR <= SP3_VRAM_ADDR - 1;
					SP3_SEL <= '1';
				end if;

				-- prepare to use the pre-fetched value for the next 4 pixels
				if (OBJ_X_OFS(2 downto 0) = "011" and OBJ_HF = '0') or
				   (OBJ_X_OFS(2 downto 0) = "100" and OBJ_HF = '1') then
					SP3_SEL <= '0';
					SP3_VRAM_DO_SAVE <= SP3_VRAM_DO;
				end if;

				case OBJ_X_OFS(1 downto 0) is
				when "00" =>
					obj_color := SP3_VRAM_DO_SAVE(15 downto 12);
				when "01" =>
					obj_color := SP3_VRAM_DO_SAVE(11 downto 8);
				when "10" =>
					obj_color := SP3_VRAM_DO_SAVE(7 downto 4);
				when others =>
					obj_color := SP3_VRAM_DO_SAVE(3 downto 0);
				end case;

				OBJ_COLINFO_WE_SP3 <= '0';
				if OBJ_POS < 320 then
					if OBJ_COLINFO_Q_A(3 downto 0) = "0000" then
						if OBJ_MASKED = '0' then
							OBJ_COLINFO_WE_SP3 <= '1';
							OBJ_COLINFO_ADDR_WR_SP3 <= OBJ_POS;
							OBJ_COLINFO_D_SP3 <= OBJ_PRI & OBJ_PAL & obj_color;
						end if;
					else
						if obj_color /= "0000" then
							SCOL_SET <= '1';
						end if;
					end if;
				end if;

				OBJ_POS <= OBJ_POS + 1;
				OBJ_PIX <= OBJ_PIX + 1;
				OBJ_COLINFO_ADDR_RD_SP3 <= OBJ_POS + 1;
				if OBJ_HF = '1' then
					if OBJ_X_OFS = "00000" then
						SP3C <= SP3C_NEXT;
					else
						OBJ_X_OFS <= OBJ_X_OFS - 1;
						if OBJ_X_OFS(2 downto 0) = "000" then
							SP3C <= SP3C_LOOP; -- fetch the next tile
						else
							SP3C <= SP3C_PLOT;
						end if;
					end if;
				else
					if (OBJ_X_OFS = "00111" and OBJ_HS = "00")
					or (OBJ_X_OFS = "01111" and OBJ_HS = "01")
					or (OBJ_X_OFS = "11111" and OBJ_HS = "11")
					or (OBJ_X_OFS = "10111" and OBJ_HS = "10")
					then
						SP3C <= SP3C_NEXT;
					else
						OBJ_X_OFS <= OBJ_X_OFS + 1;
						if OBJ_X_OFS(2 downto 0) = "111" then
							SP3C <= SP3C_LOOP; -- fetch the next tile
						else
							SP3C <= SP3C_PLOT;
						end if;
					end if;
				end if;

				-- limit total sprite pixels per line
				if OBJ_PIX = H_DISP_WIDTH then
					OBJ_DOT_OVERFLOW <= '1';
					SP3C <= SP3C_DONE;
					SP3_SOVR_SET <= '1';
				end if;
			  end if;

			when SP3C_TILE_RD =>
				if early_ack_sp3='0' then
					SP3_SEL <= '0';
					SP3C <= SP3C_PLOT;
					SP3_VRAM_DO_SAVE <= SP3_VRAM_DO;
				end if;

			when others => -- SP3C_DONE
				SP3_SEL <= '0';

				OBJ_COLINFO_WE_SP3 <= '0';
				OBJ_COLINFO_ADDR_WR_SP3 <= (others => '0');
				OBJ_COLINFO_ADDR_RD_SP3 <= (others => '0');

				OBJ_SPINFO_ADDR_RD <= (others => '0');

				if SP3E_ACTIVATE = '1' then
					SP3C <= SP3C_INIT;
				end if;
		end case;
	end if;
end process;


----------------------------------------------------------------
-- VIDEO COUNTING
----------------------------------------------------------------
H_DISP_START    <= conv_std_logic_vector(H_DISP_START_H40, 9) when H40='1'
              else conv_std_logic_vector(H_DISP_START_H32, 9);
H_DISP_WIDTH    <= conv_std_logic_vector(H_DISP_WIDTH_H40, 9) when H40='1'
              else conv_std_logic_vector(H_DISP_WIDTH_H32, 9);
H_TOTAL_WIDTH   <= conv_std_logic_vector(H_TOTAL_WIDTH_H40, 9) when H40='1'
              else conv_std_logic_vector(H_TOTAL_WIDTH_H32, 9);
H_INT_POS       <= conv_std_logic_vector(H_INT_H40, 9) when H40='1'
              else conv_std_logic_vector(H_INT_H32, 9);
HSYNC_START     <= conv_std_logic_vector(HSYNC_START_H40, 9) when H40='1'
              else conv_std_logic_vector(HSYNC_START_H32, 9);
HSYNC_END       <= conv_std_logic_vector(HSYNC_END_H40, 9) when H40='1'
              else conv_std_logic_vector(HSYNC_END_H32, 9);
HBLANK_START    <= conv_std_logic_vector(HBLANK_START_H40, 9) when H40='1'
              else conv_std_logic_vector(HBLANK_START_H32, 9);
HBLANK_END      <= conv_std_logic_vector(HBLANK_END_H40, 9) when H40='1'
              else conv_std_logic_vector(HBLANK_END_H32, 9);
HSCROLL_READ    <= conv_std_logic_vector(HSCROLL_READ_H40, 9) when H40='1'
              else conv_std_logic_vector(HSCROLL_READ_H32, 9);
VSYNC_HSTART    <= conv_std_logic_vector(VSYNC_HSTART_H40, 9) when H40='1'
              else conv_std_logic_vector(VSYNC_HSTART_H32, 9);
VSYNC_START     <= conv_std_logic_vector(VSYNC_START_PAL_V30, 9) when V30='1' and PAL='1'
              else conv_std_logic_vector(VSYNC_START_PAL_V28, 9) when V30='0' and PAL='1'
              else conv_std_logic_vector(VSYNC_START_NTSC_V30, 9) when V30='1' and PAL='0'
              else conv_std_logic_vector(VSYNC_START_NTSC_V28, 9);
V_DISP_START    <= conv_std_logic_vector(V_DISP_START_V30, 9) when V30='1'
              else conv_std_logic_vector(V_DISP_START_PAL_V28, 9) when PAL='1'
			  else conv_std_logic_vector(V_DISP_START_NTSC_V28, 9);
V_DISP_HEIGHT   <= conv_std_logic_vector(V_DISP_HEIGHT_V30, 9) when V30='1'
              else conv_std_logic_vector(V_DISP_HEIGHT_V28, 9);
V_TOTAL_HEIGHT  <= conv_std_logic_vector(PAL_LINES, 9) when PAL='1'
              else conv_std_logic_vector(NTSC_LINES, 9);
V_INT_POS       <= conv_std_logic_vector(V_INT_V30, 9) when V30='1'
              else conv_std_logic_vector(V_INT_V28, 9);

-- COUNTERS AND INTERRUPTS

Y <= HV_VCNT(7 downto 0);
BG_Y <= Y & FIELD when LSM = "11" else '0' & Y;
PRE_Y <= (Y + 1) & FIELD when LSM = "11" else '0' & (Y + 1);

HV_VCNT_EXT <= Y & FIELD_LATCH when LSM = "11" else '0' & Y;
HV8 <= HV_VCNT_EXT(8) when LSM = "11" else HV_VCNT_EXT(0);

-- refresh slots during disabled display - H40 - 6 slots, H32 - 5 slots
-- still not sure: usable slots at line -1, border and blanking area
REFRESH_SLOT <=
	'0' when
	(H40 = '1' and HV_HCNT /= 500 and HV_HCNT /= 52 and HV_HCNT /= 118 and HV_HCNT /= 180 and HV_HCNT /= 244 and HV_HCNT /= 308) or
	(H40 = '0' and HV_HCNT /= 486 and HV_HCNT /= 38 and HV_HCNT /= 102 and HV_HCNT /= 166 and HV_HCNT /= 230) else
	'1';

process( RST_N, CLK )
begin
	if RST_N = '0' then
		FIELD <= '0';

		HV_PIXDIV <= (others => '0');
		HV_HCNT <= (others => '0');
		HV_VCNT <= (others => '0');

		HINT_EN <= '0';
		HINT_PENDING_SET <= '0';
		VINT_TG68_PENDING_SET <= '0';
		VINT_T80_SET <= '0';
		VINT_T80_CLR <= '0';

		IN_HBL <= '0';
		IN_VBL <= '1';

		FIFO_EN <= '0';

		SP1_EN <= '0';
		SP2_EN <= '0';

	elsif rising_edge(CLK) then

		if M3='0' then
			HV <= HV_VCNT_EXT(7 downto 1) & HV8 & HV_HCNT(8 downto 1);
		end if;

		HINT_PENDING_SET <= '0';
		VINT_TG68_PENDING_SET <= '0';
		VINT_T80_SET <= '0';
		VINT_T80_CLR <= '0';
		FIFO_EN <= '0';

		SP1_EN <= '0';
		SP2_EN <= '0';

		HV_PIXDIV <= HV_PIXDIV + 1;
		if (RS0 = '1' and H40 = '1' and 
			((HV_PIXDIV = 8-1 and (HV_HCNT >= H_INT_POS + 30 or HV_HCNT < H_INT_POS)) or
			(HV_PIXDIV = 10-1 and HV_HCNT >= H_INT_POS and HV_HCNT < H_INT_POS + 30))) or --normal H40 - 30*10+390*8=3420 cycles
		   (RS0 = '0' and H40 = '1' and HV_PIXDIV = 8-1) or --fast H40
		   (RS0 = '0' and H40 = '0' and HV_PIXDIV = 10-1) or --normal H32
		   (RS0 = '1' and H40 = '0' and HV_PIXDIV = 8-1) then --fast H32
			HV_PIXDIV <= (others => '0');
			if HV_HCNT = H_DISP_START + H_TOTAL_WIDTH - 1 then
				-- we're just after HSYNC
				HV_HCNT <= H_DISP_START;
			else
				HV_HCNT <= HV_HCNT + 1;
			end if;

			if HV_HCNT = H_INT_POS then
				if HV_VCNT = V_DISP_START + V_TOTAL_HEIGHT - 1 then --VDISP_START is negative
					--just after VSYNC
					HV_VCNT <= V_DISP_START;
				else
					HV_VCNT <= HV_VCNT + 1;
				end if;
				BGB_VSRAM1_LATCH <= VSRAM(1);
				BGA_VSRAM0_LATCH <= VSRAM(0);

				if HV_VCNT = "1"&x"FF" then
					-- FIELD changes at VINT, but the HV_COUNTER reflects the current field from line 0-0
					FIELD_LATCH <= FIELD;
				end if;

				-- HINT_EN effect is delayed by one line
				if HV_VCNT = "1"&x"FE" then
					HINT_EN <= '1';
				elsif HV_VCNT = V_DISP_HEIGHT - 1 then
					HINT_EN <= '0';
				end if;

				if HINT_EN = '0'
					then HINT_COUNT <= HIT;
				else
					if HINT_COUNT = 0 then
						HINT_PENDING_SET <= '1';
						HINT_COUNT <= HIT;
					else
						HINT_COUNT <= HINT_COUNT - 1;
					end if;
				end if;

			end if;

			if HV_HCNT = H_INT_POS + 4 then
				if HV_VCNT = "1"&x"FF" then
					IN_VBL <= '0';
				elsif HV_VCNT = V_DISP_HEIGHT then
					IN_VBL <= '1';
				end if;
			end if;

			if HV_HCNT = HBLANK_END then --active display
				IN_HBL <= '0';
			end if;

			if HV_HCNT = HBLANK_START then -- blanking
				IN_HBL <= '1';
			end if;

			if HV_HCNT = 0 then
				if HV_VCNT = V_INT_POS
				then
					FIELD <= not FIELD;
					VINT_TG68_PENDING_SET <= '1';
					VINT_T80_SET <= '1';
				elsif HV_VCNT = V_INT_POS + 1
				then
					VINT_T80_CLR <= '1';
				end if;
			end if;

			if IN_VBL = '1' or DE = '0'
			then
				if REFRESH_SLOT = '0' -- skip refresh slots
				then
					FIFO_EN <= not HV_HCNT(0);
				end if;
			else
				if (HV_HCNT(3 downto 0) = "0100" and HV_HCNT(5 downto 4) /= "11" and HV_HCNT < H_DISP_WIDTH) or
					(H40 = '1' and (HV_HCNT = 322 or HV_HCNT = 324 or HV_HCNT = 464)) or
					(H40 = '0' and (HV_HCNT = 290 or HV_HCNT = 486 or HV_HCNT = 258 or HV_HCNT = 260))
				then
					FIFO_EN <= '1';
				end if;
			end if;

			SP1_EN <= '1'; --SP1 Engine checks one sprite/pixel
			if HV_HCNT(3 downto 0) = "0000" then
				SP2_EN <= '1'; --Sprite mapping slots in every two cells
			end if;

		end if;
	end if;
end process;

process( CLK )
begin
	if rising_edge(CLK) then
		CE_PIX <= '0';
		if HV_PIXDIV = 0 then
			CE_PIX <= '1';
			if HV_HCNT = HBLANK_END + H_DISP_WIDTH + 1 then 
				HBL <= '1';
			end if;
			if HV_HCNT = HBLANK_END + 1 then 
				HBL <= '0';
			end if;

			if HV_VCNT < V_DISP_HEIGHT	then
				VBL <= '0';
			else
				VBL <= '1';
			end if;
		end if;
	end if;
end process;


-- TIMING MANAGEMENT
PRE_V_ACTIVE <= '1' when HV_VCNT = "1"&x"FF" or HV_VCNT < V_DISP_HEIGHT - 1 else '0';
V_ACTIVE <= '1' when HV_VCNT < V_DISP_HEIGHT else '0';
DISP_ACTIVE <= '1' when V_ACTIVE = '1' and HV_HCNT > HBLANK_END and HV_HCNT <= HBLANK_END + H_DISP_WIDTH else '0';
-- pixel output does not start immediately when DISP_ACTIVE becomes '1'. Thus
-- the last pixel column needs some extra time after DISP_ACTIVE becomes '0' to display
DISP_ACTIVE_LAST_COLUMN	<= '1' when HV_HCNT = HBLANK_END + H_DISP_WIDTH + 1 else '0';
-- Background generation runs during active display.
-- It starts with reading the horizontal scroll values from the VRAM
BGEN_ACTIVATE <= '1' when V_ACTIVE = '1' and HV_HCNT = HSCROLL_READ else '0';

-- Stage 1 - runs after the vcounter incremented
-- Carefully choosing the starting position avoids the
-- "Your emulator suxx" in Titan I demo
SP1E_ACTIVATE <= '1' when PRE_V_ACTIVE = '1' and HV_HCNT = H_INT_POS + 1 else '0';
-- Stage 2 - runs in the active area
SP2E_ACTIVATE <= '1' when PRE_V_ACTIVE = '1' and HV_HCNT = HBLANK_END else '0';
-- Stage 3 runs during HBLANK, just after the active display
SP3E_ACTIVATE <= '1' when V_ACTIVE = '1' and HV_HCNT = HBLANK_END + H_DISP_WIDTH + 2 else '0';
DT_ACTIVE <= '1';

-- PIXEL COUNTER AND OUTPUT
-- ALSO CLEARS THE SPRITE COLINFO BUFFER RIGHT AFTER RENDERING
process( RST_N, CLK )
	variable col : std_logic_vector(5 downto 0);
	variable cold: std_logic_vector(5 downto 0);
begin
	OBJ_COLINFO_D_REND <= (others => '0');
	if RST_N = '0' then
		X <= (others => '0');
		PIXDIV <= (others => '0');
		PIXOUT <= '0';
		
	elsif rising_edge(CLK) then
		if DISP_ACTIVE = '0' and DISP_ACTIVE_LAST_COLUMN = '0' then
			X <= (others => '0');
			PIXDIV <= (others => '0');
			PIXOUT <= '0';
			
			FF_R <= (others => '0');
			FF_G <= (others => '0');
			FF_B <= (others => '0');

			BGB_COLINFO_ADDR_B <= (others => '0');
			BGA_COLINFO_ADDR_B <= (others => '0');
			OBJ_COLINFO_WE_REND <= '0';
		else
			PIXDIV <= PIXDIV + 1;

			case PIXDIV is
			when "0000" =>
				BGB_COLINFO_ADDR_B <= X;
				BGA_COLINFO_ADDR_B <= X;
				OBJ_COLINFO_ADDR_RD_REND <= X;
				OBJ_COLINFO_ADDR_WR_REND <= X;
				OBJ_COLINFO_WE_REND <= '0';

			when "0010" =>
				if SHI = '1' and BGA_COLINFO_Q_B(6) = '0' and BGB_COLINFO_Q_B(6) = '0' then
					--if all layers are normal priority, then shadowed
					PIX_MODE <= PIX_SHADOW;
				else
					PIX_MODE <= PIX_NORMAL;
				end if;

			when "0011" =>
				if SHI = '1' and (OBJ_COLINFO_Q_A(6) = '1' or
					((BGA_COLINFO_Q_B(6) = '0' or BGA_COLINFO_Q_B(3 downto 0) = "0000") and
					 (BGB_COLINFO_Q_B(6) = '0' or BGB_COLINFO_Q_B(3 downto 0) = "0000"))) then
					--sprite is visible
					if OBJ_COLINFO_Q_A(5 downto 0) = "111110" then
						--if sprite is palette 3/color 14 increase intensity
						if PIX_MODE = PIX_SHADOW then 
							PIX_MODE <= PIX_NORMAL;
						else
							PIX_MODE <= PIX_HIGHLIGHT;
						end if;
					elsif OBJ_COLINFO_Q_A(5 downto 0) = "111111" then
						-- if sprite is visible and palette 3/color 15, decrease intensity
						PIX_MODE <= PIX_SHADOW;
					elsif (OBJ_COLINFO_Q_A(6) = '1' and OBJ_COLINFO_Q_A(3 downto 0) /= "0000") or 
					       OBJ_COLINFO_Q_A(3 downto 0) = "1110" then
						--sprite color 14 or high prio always shows up normal
						PIX_MODE <= PIX_NORMAL;
					end if;
				end if;

				if DE='0' then
					col := BGCOL;
				elsif OBJ_COLINFO_Q_A(3 downto 0) /= "0000" and OBJ_COLINFO_Q_A(6) = '1' and
					(SHI='0' or OBJ_COLINFO_Q_A(5 downto 1) /= "11111") then
					col := OBJ_COLINFO_Q_A(5 downto 0);
				elsif BGA_COLINFO_Q_B(3 downto 0) /= "0000" and BGA_COLINFO_Q_B(6) = '1' then
					col := BGA_COLINFO_Q_B(5 downto 0);
				elsif BGB_COLINFO_Q_B(3 downto 0) /= "0000" and BGB_COLINFO_Q_B(6) = '1' then
					col := BGB_COLINFO_Q_B(5 downto 0);
				elsif OBJ_COLINFO_Q_A(3 downto 0) /= "0000" and
					(SHI='0' or OBJ_COLINFO_Q_A(5 downto 1) /= "11111") then
					col := OBJ_COLINFO_Q_A(5 downto 0);
				elsif BGA_COLINFO_Q_B(3 downto 0) /= "0000" then
					col := BGA_COLINFO_Q_B(5 downto 0);
				elsif BGB_COLINFO_Q_B(3 downto 0) /= "0000" then
					col := BGB_COLINFO_Q_B(5 downto 0);
				else
					col := BGCOL;
				end if;

				case DBG(8 downto 7) is
					when "00" => cold := BGCOL;
					when "01" => cold := OBJ_COLINFO_Q_A(5 downto 0);
					when "10" => cold := BGA_COLINFO_Q_B(5 downto 0);
					when "11" => cold := BGB_COLINFO_Q_B(5 downto 0);
					when others => null;
				end case;

				if DBG(6) = '1' then
					col := cold;
				elsif DBG(8 downto 7) /= "00" then
					col := col and cold;
				end if;

				CRAM_ADDR_B <= col;

			when "0101" =>
				if DISP_ACTIVE_LAST_COLUMN = '1' then
					FF_R <= (others => '0');
					FF_G <= (others => '0');
					FF_B <= (others => '0');
				else
					case PIX_MODE is
					when PIX_SHADOW =>
						-- half brightness
						FF_B <= '0' & CRAM_Q_B(8 downto 6);
						FF_G <= '0' & CRAM_Q_B(5 downto 3);
						FF_R <= '0' & CRAM_Q_B(2 downto 0);

					when PIX_NORMAL =>
						-- normal brightness
						FF_B <= CRAM_Q_B(8 downto 6) & '0';
						FF_G <= CRAM_Q_B(5 downto 3) & '0';
						FF_R <= CRAM_Q_B(2 downto 0) & '0';
					
					when PIX_HIGHLIGHT =>
						-- increased brightness
						FF_B <= '0' & CRAM_Q_B(8 downto 6) + 7;
						FF_G <= '0' & CRAM_Q_B(5 downto 3) + 7;
						FF_R <= '0' & CRAM_Q_B(2 downto 0) + 7;
					end case;
				end if;
				OBJ_COLINFO_WE_REND <= '1';

			when "0111" =>
				OBJ_COLINFO_WE_REND <= '0';
			
			when others => null;
			end case;

			if (H40 = '1' and PIXDIV = 8-1) or
			   (H40 = '0' and RS0 = '0' and PIXDIV = 10-1) or
			   (H40 = '0' and RS0 = '1' and PIXDIV = 8-1) then
				PIXDIV <= (others => '0');
				X <= X + 1;
				PIXOUT <= '1';
			else
				PIXOUT <= '0';
			end if;
		end if;

	end if;
end process;

----------------------------------------------------------------
-- VIDEO OUTPUT
----------------------------------------------------------------
-- SYNC
process( RST_N, CLK )
begin
	if RST_N = '0' then
		FF_VS <= '1';
		FF_HS <= '1';
	elsif rising_edge(CLK) then
	
		-- horizontal sync
		if HV_HCNT = HSYNC_START then
			FF_HS <= '0';
		elsif HV_HCNT = HSYNC_END then
			FF_HS <= '1';
		end if;

		if HV_HCNT = VSYNC_HSTART then
			if HV_VCNT = VSYNC_START then
				FF_VS <= '0';
				FIELD_OUT <= LSM(1) and LSM(0) and not FIELD_LATCH;
			end if;
			if HV_VCNT = VSYNC_START + VS_LINES - 1 then
				FF_VS <= '1';
			end if;
		end if;
	end if;
end process;

-- VSync extension by half a line for interlace
process( CLK )
  -- 1710 = 1/2 * 3420 clock per line
  variable VS_START_DELAY : integer range 0 to 1710;
  variable VS_END_DELAY : integer range 0 to 1710;
  variable VS_DELAY_ACTIVE: boolean;
begin
  if rising_edge( CLK ) then
    if FF_VS = '1' then
      -- LSM(0) = 1 and FIELD = 0 right before vsync start -> start the delay
      if HV_HCNT = VSYNC_HSTART and HV_VCNT = VSYNC_START and LSM(0) = '1' and FIELD = '0' then
        VS_START_DELAY := 1710;
        VS_DELAY_ACTIVE := true;
      end if;

      -- FF_VS already inactive, but end delay still != 0
      if VS_END_DELAY /= 0 then
        VS_END_DELAY := VS_END_DELAY - 1;
      else
        VS <= '0';
      end if;
      
    else
      -- FF_VS = '0'
      if VS_DELAY_ACTIVE then
        VS_END_DELAY := 1710;
        VS_DELAY_ACTIVE := false;
      end if;

      -- FF_VS active, but start delay still != 0
      if VS_START_DELAY /= 0 then
        VS_START_DELAY := VS_START_DELAY - 1;
      else
        VS <= '1';
      end if;
    end if;
  end if;  
end process;

-- VS <= FF_VS;
HS <= not FF_HS;

R <= FF_R;
G <= FF_G;
B <= FF_B;

----------------------------------------------------------------
-- VIDEO DEBUG
----------------------------------------------------------------
-- synthesis translate_off
process( PIXOUT )
	file F		: text open write_mode is "vdp.out";
	variable L	: line;
	variable R	: std_logic_vector(2 downto 0);
	variable G	: std_logic_vector(2 downto 0);
	variable B	: std_logic_vector(2 downto 0);
begin
	if rising_edge( PIXOUT ) then
		hwrite(L, FF_R & '0' & FF_G & '0' & FF_B & '0');
		writeline(F,L);
	end if;
end process;
-- synthesis translate_on

----------------------------------------------------------------
-- DATA TRANSFER CONTROLLER
----------------------------------------------------------------
VBUS_ADDR <= FF_VBUS_ADDR(23 downto 1);
VBUS_SEL <= FF_VBUS_SEL;
VBUS_BUSY <= DMA_VBUS;

process( RST_N, CLK )
-- synthesis translate_off
file F		: text open write_mode is "vdp_dbg.out";
variable L	: line;
-- synthesis translate_on
begin
	if RST_N = '0' then

		REG <= (others => (others => '0'));
		VSRAM <= (others => (others => '0'));

		ADDR <= (others => '0');
		ADDR_SET_ACK <= '0';
		REG_SET_ACK <= '0';
		
		DT_VRAM_SEL <= '0';
		
		FIFO_RD_POS <= "00";
		FIFO_WR_POS <= "00";
		FIFO_EMPTY <= '1';
		FIFO_FULL <= '0';
		FIFO_SKIP <= '0';

		DT_RD_DTACK_N <= '1';
		DT_FF_DTACK_N <= '1';

		FF_VBUS_ADDR <= (others => '0');
		FF_VBUS_SEL	<= '0';
		DT_VBUS_SEL <= '0';
		
		DMA_FILL <= '0';
		DMAF_SET_REQ <= '0';
		DMA_COPY <= '0';
		DMA_VBUS <= '0';
		DMA_SOURCE <= (others => '0');
		DMA_LENGTH <= (others => '0');
		
		DTC <= DTC_IDLE;
		DMAC <= DMA_IDLE;
		
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
		if DT_FF_SEL = '0' and DT_VBUS_SEL = '0' then
			DT_FF_DTACK_N <= '1';
		end if;
		if ADDR_SET_REQ = '0' then
			ADDR_SET_ACK <= '0';
		end if;
		if REG_SET_REQ = '0' then
			REG_SET_ACK <= '0';
		end if;

		CRAM_WE_A <= '0';

		if DT_FF_SEL = '1' and (FIFO_WR_POS + 1 /= FIFO_RD_POS) and DT_FF_DTACK_N = '1' then
			FIFO_ADDR( CONV_INTEGER( FIFO_WR_POS ) ) <= ADDR;
			FIFO_DATA( CONV_INTEGER( FIFO_WR_POS ) ) <= DT_FF_DATA;
			FIFO_CODE( CONV_INTEGER( FIFO_WR_POS ) ) <= DT_FF_CODE;
			FIFO_WR_POS <= FIFO_WR_POS + 1;
			ADDR <= ADDR + ADDR_STEP;
			DT_FF_DTACK_N <= '0';
		elsif DT_VBUS_SEL = '1' and (FIFO_WR_POS + 1 /= FIFO_RD_POS) and DT_FF_DTACK_N = '1' then
			FIFO_ADDR( CONV_INTEGER( FIFO_WR_POS ) ) <= ADDR;
			FIFO_DATA( CONV_INTEGER( FIFO_WR_POS ) ) <= DT_DMAV_DATA;
			FIFO_CODE( CONV_INTEGER( FIFO_WR_POS ) ) <= CODE(3 downto 0);
			FIFO_WR_POS <= FIFO_WR_POS + 1;
			ADDR <= ADDR + ADDR_STEP;
			DT_FF_DTACK_N <= '0';
		end if;

		-- Register set
		if REG_SET_REQ = '1' and REG_SET_ACK = '0' then
			if (M5 = '1' or REG_LATCH(12 downto 8) <= 10) then
				-- mask registers above 10 in Mode4
				REG( CONV_INTEGER( REG_LATCH(12 downto 8)) ) <= REG_LATCH(7 downto 0);
			end if;
			REG_SET_ACK <= '1';
		end if;

		if DT_ACTIVE = '1' then
			case DTC is
			when DTC_IDLE =>
				if FIFO_EN = '1' then
					FIFO_SKIP <= FIFO_SKIP_PRE;
					FIFO_SKIP_PRE <= '0';
				end if;
				-- Direct color DMA hack (correct, but why?)
				-- Skip the slot after a refresh
				if FIFO_RD_POS /= FIFO_WR_POS and FIFO_CODE( CONV_INTEGER( FIFO_RD_POS ) ) = "0011" and
				   DE = '0' and REFRESH_SLOT = '1' then
					FIFO_SKIP <= '1';
				end if;

				if VRAM_SPEED = '0' or (FIFO_EN = '1' and FIFO_SKIP = '0') then
					if FIFO_RD_POS /= FIFO_WR_POS then
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
					end if;
				end if;
			
			when DTC_FIFO_RD =>
				DT_WR_ADDR <= FIFO_ADDR( CONV_INTEGER( FIFO_RD_POS ) );
				DT_WR_DATA <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) );
				FIFO_RD_POS <= FIFO_RD_POS + 1;
				case FIFO_CODE( CONV_INTEGER( FIFO_RD_POS ) ) is
				when "0011" => -- CRAM Write
					DTC <= DTC_CRAM_WR;
				when "0101" => -- VSRAM Write
					DTC <= DTC_VSRAM_WR;
				when "0001" => -- VRAM Write
					DTC <= DTC_VRAM_WR1;
				when others => --invalid target
					DTC <= DTC_WR_END;
				end case;

			when DTC_VRAM_WR1 =>
				if M128 = '0' then
					--skip next FIFO slot since we write 16 bit now instead of the original 8
					FIFO_SKIP_PRE <= '1';
				end if;
-- synthesis translate_off
				write(L, string'("   VRAM WR ["));
				hwrite(L, x"00" & DT_WR_ADDR(15 downto 1) & '0');
				write(L, string'("] = ["));
				if DT_WR_ADDR(0) = '0' then 
					hwrite(L, DT_WR_DATA);
				else
					hwrite(L, DT_WR_DATA(7 downto 0) & DT_WR_DATA(15 downto 8));
				end if;
				write(L, string'("]"));
				writeline(F,L);									
-- synthesis translate_on								
				DT_VRAM_SEL <= '1';
				DT_VRAM_RNW <= '0';
				DT_VRAM_ADDR <= DT_WR_ADDR(16 downto 1);
				DT_VRAM_UDS_N <= '0';
				DT_VRAM_LDS_N <= '0';
				if DT_WR_ADDR(0) = '0' or M128 = '1' then
					DT_VRAM_DI <= DT_WR_DATA;
				else
					DT_VRAM_DI <= DT_WR_DATA(7 downto 0) & DT_WR_DATA(15 downto 8);
				end if;

				DTC <= DTC_VRAM_WR2;

			when DTC_VRAM_WR2 =>
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';	
					DTC <= DTC_WR_END;
				end if;

			when DTC_CRAM_WR =>
-- synthesis translate_off					
				write(L, string'("   CRAM WR ["));
				hwrite(L, x"00" & DT_WR_ADDR(15 downto 1) & '0');
				write(L, string'("] = ["));
				hwrite(L, DT_WR_DATA);
				write(L, string'("]"));
				writeline(F,L);									
-- synthesis translate_on
				CRAM_WE_A <= '1';
				CRAM_ADDR_A <= DT_WR_ADDR(6 downto 1);
				CRAM_D_A <= DT_WR_DATA(11 downto 9) & DT_WR_DATA(7 downto 5) & DT_WR_DATA(3 downto 1);
				DTC <= DTC_WR_END;

			when DTC_VSRAM_WR =>
-- synthesis translate_off					
				write(L, string'("  VSRAM WR ["));
				hwrite(L, x"00" & DT_WR_ADDR(15 downto 1) & '0');
				write(L, string'("] = ["));
				hwrite(L, DT_WR_DATA);
				write(L, string'("]"));
				writeline(F,L);									
-- synthesis translate_on
				if DT_WR_ADDR(6 downto 1) < 40 then
					VSRAM( CONV_INTEGER(DT_WR_ADDR(6 downto 1)) ) <= DT_WR_DATA(10 downto 0);
				end if;
				DTC <= DTC_WR_END;

			when DTC_WR_END =>
				if DMA_FILL = '1' then
					DMAF_SET_REQ <= '1';
				end if;
				DTC <= DTC_IDLE;

			when DTC_VRAM_RD1 =>
				DT_VRAM_SEL <= '1';
				DT_VRAM_ADDR <= '0'&ADDR(15 downto 1);
				DT_VRAM_RNW <= '1';
				DT_VRAM_UDS_N <= '0';
				DT_VRAM_LDS_N <= '0';
				DTC <= DTC_VRAM_RD2;
			
			when DTC_VRAM_RD2 =>
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';
					if DT_RD_CODE = "1100" then
						-- VRAM 8 bit read - unused bits come from the next FIFO entry
						if ADDR(0) = '0' then
							DT_RD_DATA <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) )(15 downto 8) & DT_VRAM_DO(7 downto 0);
						else
							DT_RD_DATA <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) )(15 downto 8) & DT_VRAM_DO(15 downto 8);
						end if;
					else
						DT_RD_DATA <= DT_VRAM_DO;
					end if;
					DT_RD_DTACK_N <= '0';
					ADDR <= ADDR + ADDR_STEP;
					DTC <= DTC_IDLE;
				end if;

			when DTC_CRAM_RD =>
				CRAM_ADDR_A <= ADDR(6 downto 1);
				DTC <= DTC_CRAM_RD1;

			when DTC_CRAM_RD1 =>
				-- cram address is set up
				DTC <= DTC_CRAM_RD2;

			when DTC_CRAM_RD2 =>
				DT_RD_DATA(11 downto 9) <= CRAM_Q_A(8 downto 6);
				DT_RD_DATA(7 downto 5) <= CRAM_Q_A(5 downto 3);
				DT_RD_DATA(3 downto 1) <= CRAM_Q_A(2 downto 0);
				--unused bits come from the next FIFO entry
				DT_RD_DATA(15 downto 12) <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) )(15 downto 12);
				DT_RD_DATA(8) <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) )(8);
				DT_RD_DATA(4) <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) )(4);
				DT_RD_DATA(0) <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) )(0);
				DT_RD_DTACK_N <= '0';
				ADDR <= ADDR + ADDR_STEP;	
				DTC <= DTC_IDLE;
				
			when DTC_VSRAM_RD =>
				if ADDR(6 downto 1) < 40 then
					DT_RD_DATA <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) )(15 downto 11) & VSRAM( CONV_INTEGER(ADDR(6 downto 1)) );
				elsif ADDR(1) = '0' then
					DT_RD_DATA <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) )(15 downto 11) & BGA_VSRAM0_LATCH;
				else
					DT_RD_DATA <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) )(15 downto 11) & BGB_VSRAM1_LATCH;
				end if;
				DT_RD_DTACK_N <= '0';
				ADDR <= ADDR + ADDR_STEP;	
				DTC <= DTC_IDLE;

			when others => null;
			end case;

----------------------------------------------------------------
-- DMA ENGINE
----------------------------------------------------------------
			if ADDR_SET_REQ = '1' and ADDR_SET_ACK = '0' then
				ADDR <= ADDR_LATCH;
				if CODE(5) = '1' and PENDING = '1' then
					if REG(23)(7) = '0' then
						DMA_VBUS <= '1';
					else
						if REG(23)(6) = '0' then
							DMA_FILL <= '1';
						else
							DMA_COPY <= '1';
						end if;
					end if;
				end if;
				ADDR_SET_ACK <= '1';
			end if;

			if FIFO_RD_POS = FIFO_WR_POS and DMA_FILL = '1' and DMAF_SET_REQ = '1' then
				if CODE(3 downto 0) = "0011" or CODE(3 downto 0) = "0101" then
					-- CRAM, VSRAM fill gets its data from the next FIFO write position
					DT_DMAF_DATA <= FIFO_DATA( CONV_INTEGER( FIFO_WR_POS ) );
				else -- VRAM Write
					DT_DMAF_DATA <= DT_WR_DATA;
				end if;
				DMAF_SET_REQ <= '0';
			end if;

			case DMAC is
			when DMA_IDLE =>
				if DMA_VBUS = '1' then
					DMAC <= DMA_VBUS_INIT;
				elsif DMA_FILL = '1' and DMAF_SET_REQ = '1' then
					DMAC <= DMA_FILL_INIT;
				elsif DMA_COPY = '1' then
					DMAC <= DMA_COPY_INIT;
				end if;
----------------------------------------------------------------
-- DMA FILL
----------------------------------------------------------------

			when DMA_FILL_INIT =>
-- synthesis translate_off
				write(L, string'("VDP DMA FILL SRC=["));
				hwrite(L, x"00" & ADDR);
				write(L, string'("] LEN=["));
				hwrite(L, x"00" & REG(20) & REG(19));
				write(L, string'("] VALUE=["));
				hwrite(L, DT_DMAF_DATA(7 downto 0));
				write(L, string'("]"));
				writeline(F,L);
-- synthesis translate_on
				DMA_SOURCE <= REG(22) & REG(21);
				DMA_LENGTH <= REG(20) & REG(19);
				DMAC <= DMA_FILL_START;

			when DMA_FILL_START =>
				if FIFO_RD_POS = FIFO_WR_POS and DTC = DTC_IDLE and DMAF_SET_REQ = '0' then
					-- suspend FILL if the FIFO is not empty
					case CODE(3 downto 0) is
					when "0011" => -- CRAM Write
						DMAC <= DMA_FILL_CRAM;
					when "0101" => -- VSRAM Write
						DMAC <= DMA_FILL_VSRAM;
					when "0001" => -- VRAM Write
						DMAC <= DMA_FILL_WR;
					when others => -- invalid target
						DMAC <= DMA_FILL_NEXT;
					end case;
				end if;

			when DMA_FILL_CRAM =>
				if VRAM_SPEED = '0' or FIFO_EN = '1' then
					CRAM_WE_A <= '1';
					CRAM_ADDR_A <= ADDR(6 downto 1);
					CRAM_D_A <= DT_DMAF_DATA(11 downto 9) & DT_DMAF_DATA(7 downto 5) & DT_DMAF_DATA(3 downto 1);
					DMAC <= DMA_FILL_NEXT;
				end if;

			when DMA_FILL_VSRAM =>
				if VRAM_SPEED = '0' or FIFO_EN = '1' then
					if ADDR(6 downto 1) < 40 then
						VSRAM( CONV_INTEGER(ADDR(6 downto 1)) ) <= DT_DMAF_DATA(10 downto 0);
					end if;
					DMAC <= DMA_FILL_NEXT;
				end if;

			when DMA_FILL_WR =>
				if VRAM_SPEED = '0' or FIFO_EN = '1' then
-- synthesis translate_off					
					write(L, string'("   VRAM WR ["));
					hwrite(L, x"00" & ADDR(15 downto 1) & '0');
					write(L, string'("] = ["));
					if ADDR(0) = '0' then
						write(L, string'("  "));
						hwrite(L, DT_DMAF_DATA(7 downto 0));
					else
						hwrite(L, DT_DMAF_DATA(7 downto 0));
						write(L, string'("  "));
					end if;
					write(L, string'("]"));
					writeline(F,L);
-- synthesis translate_on					
					DT_VRAM_SEL <= '1';
					DT_VRAM_ADDR <= '0'&ADDR(15 downto 1);
					DT_VRAM_RNW <= '0';
					DT_VRAM_DI <= DT_DMAF_DATA(15 downto 8) & DT_DMAF_DATA(15 downto 8);
					if ADDR(0) = '0' then
						DT_VRAM_UDS_N <= '1';
						DT_VRAM_LDS_N <= '0';
					else
						DT_VRAM_UDS_N <= '0';
						DT_VRAM_LDS_N <= '1';
					end if;
					DMAC <= DMA_FILL_WR2;
				end if;

			when DMA_FILL_WR2 =>
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';	
					DMAC <= DMA_FILL_NEXT;
				end if;

			when DMA_FILL_NEXT =>
				ADDR <= ADDR + ADDR_STEP;
				DMA_SOURCE <= DMA_SOURCE + ADDR_STEP;
				DMA_LENGTH <= DMA_LENGTH - 1;
				DMAC <= DMA_FILL_LOOP;

			when DMA_FILL_LOOP =>
				REG(20) <= DMA_LENGTH(15 downto 8);
				REG(19) <= DMA_LENGTH(7 downto 0);
				REG(22) <= DMA_SOURCE(15 downto 8);
				REG(21) <= DMA_SOURCE(7 downto 0);
				if DMA_LENGTH = 0 then
					DMA_FILL <= '0';
					DMAC <= DMA_IDLE;
-- synthesis translate_off
					write(L, string'("VDP DMA FILL END"));
					writeline(F,L);
-- synthesis translate_on
				else
					DMAC <= DMA_FILL_START;
				end if;

----------------------------------------------------------------
-- DMA COPY
----------------------------------------------------------------

			when DMA_COPY_INIT =>
-- synthesis translate_off
				write(L, string'("VDP DMA COPY SRC=["));
				hwrite(L, x"00" & REG(22) & REG(21));
				write(L, string'("] DST=["));
				hwrite(L, x"00" & ADDR);				
				write(L, string'("] LEN=["));
				hwrite(L, x"00" & REG(20) & REG(19));
				write(L, string'("]"));
				writeline(F,L);									
-- synthesis translate_on			
				DMA_LENGTH <= REG(20) & REG(19);
				DMA_SOURCE <= REG(22) & REG(21);
				DMAC <= DMA_COPY_RD;
				
			when DMA_COPY_RD =>
				DT_VRAM_SEL <= '1';
				DT_VRAM_ADDR <= '0'&DMA_SOURCE(15 downto 1);
				DT_VRAM_RNW <= '1';
				DT_VRAM_UDS_N <= '0';
				DT_VRAM_LDS_N <= '0';
				DMAC <= DMA_COPY_RD2;

			when DMA_COPY_RD2 =>
				if early_ack_dt='0' then
-- synthesis translate_off					
					write(L, string'("   VRAM RD ["));
					hwrite(L, x"00" & DMA_SOURCE(15 downto 1) & '0');
					write(L, string'("] = ["));
					if DMA_SOURCE(0) = '0' then						
						write(L, string'("  "));
						hwrite(L, DT_VRAM_DO(15 downto 8));
					else
						hwrite(L, DT_VRAM_DO(7 downto 0));
						write(L, string'("  "));
					end if;
					write(L, string'("]"));
					writeline(F,L);									
-- synthesis translate_on									
					DT_VRAM_SEL <= '0';	
					DMAC <= DMA_COPY_WR;
				end if;

			when DMA_COPY_WR =>
-- synthesis translate_off					
					write(L, string'("   VRAM WR ["));
					hwrite(L, x"00" & ADDR(15 downto 1) & '0');
					write(L, string'("] = ["));
					if ADDR(0) = '0' then						
						write(L, string'("  "));
						hwrite(L, DT_VRAM_DI(15 downto 8));						
					else
						hwrite(L, DT_VRAM_DI(7 downto 0));
						write(L, string'("  "));
					end if;
					write(L, string'("]"));
					writeline(F,L);									
-- synthesis translate_on									
				DT_VRAM_SEL <= '1';
				DT_VRAM_ADDR <= '0'&ADDR(15 downto 1);
				DT_VRAM_RNW <= '0';
				if DMA_SOURCE(0) = '0' then
					DT_VRAM_DI <= DT_VRAM_DO(7 downto 0) & DT_VRAM_DO(7 downto 0);
				else
					DT_VRAM_DI <= DT_VRAM_DO(15 downto 8) & DT_VRAM_DO(15 downto 8);
				end if;
				if ADDR(0) = '0' then
					DT_VRAM_UDS_N <= '1';
					DT_VRAM_LDS_N <= '0';
				else
					DT_VRAM_UDS_N <= '0';
					DT_VRAM_LDS_N <= '1';									
				end if;					
				DMAC <= DMA_COPY_WR2;

			when DMA_COPY_WR2 =>
				if early_ack_dt='0' then
					DT_VRAM_SEL <= '0';	
					ADDR <= ADDR + ADDR_STEP;
					DMA_LENGTH <= DMA_LENGTH - 1;
					DMA_SOURCE <= DMA_SOURCE + 1;
					DMAC <= DMA_COPY_LOOP;
				end if;
			
			when DMA_COPY_LOOP =>
				REG(20) <= DMA_LENGTH(15 downto 8);
				REG(19) <= DMA_LENGTH(7 downto 0);
				REG(22) <= DMA_SOURCE(15 downto 8);
				REG(21) <= DMA_SOURCE(7 downto 0);
				if DMA_LENGTH = 0 then
					DMA_COPY <= '0';
					DMAC <= DMA_IDLE;
-- synthesis translate_off										
					write(L, string'("VDP DMA COPY END"));					
					writeline(F,L);									
-- synthesis translate_on															
				else
					DMAC <= DMA_COPY_RD;
				end if;

----------------------------------------------------------------
-- DMA VBUS
----------------------------------------------------------------
				
			when DMA_VBUS_INIT =>
-- synthesis translate_off
				write(L, string'("VDP DMA VBUS SRC=["));
				hwrite(L, REG(23)(6 downto 0) & REG(22) & REG(21) & '0');
				write(L, string'("] DST=["));
				hwrite(L, x"00" & ADDR);				
				write(L, string'("] LEN=["));
				hwrite(L, x"00" & REG(20) & REG(19));
				write(L, string'("]"));
				writeline(F,L);									
-- synthesis translate_on						
				DMA_LENGTH <= REG(20) & REG(19);
				DMA_SOURCE <= REG(22) & REG(21);
				DMAC <= DMA_VBUS_RD;
				
			when DMA_VBUS_RD =>
				FF_VBUS_SEL <= '1';
				FF_VBUS_ADDR <= REG(23)(6 downto 0) & DMA_SOURCE & '0';
				DMAC <= DMA_VBUS_RD2;

			when DMA_VBUS_RD2 =>
				if VBUS_DTACK_N = '0' then
					FF_VBUS_SEL <= '0';
					DT_DMAV_DATA <= VBUS_DATA;
					DMAC <= DMA_VBUS_SEL;
-- synthesis translate_off					
					write(L, string'("   VBUS RD ["));
					hwrite(L, REG(23)(6 downto 0) & DMA_SOURCE & '0');
					write(L, string'("] = ["));
					hwrite(L, VBUS_DATA);
					write(L, string'("]"));
					writeline(F,L);									
-- synthesis translate_on					
				end if;
	
			when DMA_VBUS_SEL =>
				if DT_FF_DTACK_N = '1' then
					DT_VBUS_SEL <= '1';
					DMA_LENGTH <= DMA_LENGTH - 1;
					DMA_SOURCE <= DMA_SOURCE + 1;
					DMAC <= DMA_VBUS_LOOP;
				end if;

			when DMA_VBUS_LOOP =>
				if DT_FF_DTACK_N = '0' then
					DT_VBUS_SEL <= '0';
					REG(20) <= DMA_LENGTH(15 downto 8);
					REG(19) <= DMA_LENGTH(7 downto 0);
					REG(22) <= DMA_SOURCE(15 downto 8);
					REG(21) <= DMA_SOURCE(7 downto 0);
					if DMA_LENGTH = 0 then
						DMA_VBUS <= '0';
						DMAC <= DMA_IDLE;
-- synthesis translate_off										
						write(L, string'("VDP DMA VBUS END"));
						writeline(F,L);
-- synthesis translate_on										
					else
						DMAC <= DMA_VBUS_RD;
					end if;
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
		VINT_TG68_PENDING <= '0';
	elsif rising_edge( CLK) then
		INTACK_D <= INTACK;
		--acknowledge interrupts serially
		if INTACK_D = '0' and INTACK = '1' then
			if VINT_TG68_FF = '1' then
				VINT_TG68_PENDING <= '0';
			elsif HINT_FF = '1' then
				HINT_PENDING <= '0';
			end if;
		end if;
		if HINT_PENDING_SET = '1' then
			HINT_PENDING <= '1';
		end if;
		if VINT_TG68_PENDING_SET = '1' then
			VINT_TG68_PENDING <= '1';
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
		elsif VINT_T80_CLR = '1' then
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
		if SP1_SOVR_SET = '1' or SP3_SOVR_SET = '1' then
			SOVR <= '1';
		elsif SOVR_CLR = '1' then
			SOVR <= '0';
		end if;
	end if;	
end process;

end rtl;

