-- Copyright (c) 2010 Gregory Estrade (greg@torlus.com)
-- Copyright (c) 2018 Till Harbaum
-- Copyright (c) 2018-2019 Alexey Melnikov
-- Copyright (c) 2018-2019 György Szombathelyi
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
		RST_N       : in  std_logic;
		CLK         : in  std_logic;
		
		SEL         : in  std_logic;
		A           : in  std_logic_vector(4 downto 0);
		RNW         : in  std_logic;
		DI          : in  std_logic_vector(15 downto 0);
		DO          : out std_logic_vector(15 downto 0);
		DTACK_N     : out std_logic;

		vram_req    : out std_logic;
		vram_ack    : in  std_logic;
		vram_we     : out std_logic;
		vram_a      : out std_logic_vector(15 downto 1);
		vram_d      : out std_logic_vector(15 downto 0);
		vram_q      : in  std_logic_vector(15 downto 0);
		vram_u_n    : out std_logic;
		vram_l_n    : out std_logic;

		vram32_req  : out std_logic;
		vram32_ack  : in  std_logic;
		vram32_a    : out std_logic_vector(15 downto 1);
		vram32_q    : in  std_logic_vector(31 downto 0);

		EXINT       : out std_logic;
		HL          : in  std_logic;
		HINT        : out std_logic;
		VINT_TG68   : out std_logic;
		VINT_T80    : out std_logic;
		INTACK      : in  std_logic;
		BR_N        : out std_logic;
		BG_N        : in  std_logic;
		BGACK_N     : out std_logic;

		VBUS_ADDR   : out std_logic_vector(23 downto 1);
		VBUS_DATA   : in  std_logic_vector(15 downto 0);
		
		VBUS_SEL    : out std_logic;
		VBUS_DTACK_N: in  std_logic;

		PAL         : in  std_logic := '0';

		CE_PIX      : buffer std_logic;
		FIELD_OUT   : out std_logic;
		INTERLACE   : out std_logic;
		RESOLUTION  : out std_logic_vector(1 downto 0);
		HBL         : out std_logic;
		VBL         : out std_logic;

		R           : out std_logic_vector(3 downto 0);
		G           : out std_logic_vector(3 downto 0);
		B           : out std_logic_vector(3 downto 0);
		HS          : out std_logic;
		VS          : out std_logic;

		SVP_QUIRK   : in  std_logic := '0';
		VRAM_SPEED  : in  std_logic := '1'; -- 0 - full speed, 1 - FIFO throttle emulation
		VSCROLL_BUG : in  std_logic := '1'; -- 0 - use nicer effect, 1 - HW original
		BORDER_EN   : in  std_logic := '1';  -- Enable border
		CRAM_DOTS   : in  std_logic := '0';  -- Enable CRAM dots
		OBJ_LIMIT_HIGH_EN : in std_logic := '0'; -- Enable more sprites and pixels per line

		TRANSP_DETECT : out std_logic;
		
		--debug
		BGA_EN		: in  std_logic;
		BGB_EN		: in  std_logic;
		SPR_EN		: in  std_logic
	);
end vdp;

architecture rtl of vdp is

signal vram_a_reg	: std_logic_vector(16 downto 1);
signal vram32_a_reg : std_logic_vector(15 downto 1);
signal vram32_a_next: std_logic_vector(15 downto 1);

signal vram32_req_reg : std_logic;
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
signal CRAM_DATA	: std_logic_vector(8 downto 0);

signal VSRAM0_ADDR_A    : std_logic_vector( 4 downto 0);
signal VSRAM0_ADDR_B    : std_logic_vector( 4 downto 0);
signal VSRAM0_D_A       : std_logic_vector(10 downto 0);
signal VSRAM0_WE_A      : std_logic;
signal VSRAM0_WE_B      : std_logic;
signal VSRAM0_Q_A       : std_logic_vector(10 downto 0);
signal VSRAM0_Q_B       : std_logic_vector(10 downto 0);

signal VSRAM1_ADDR_A    : std_logic_vector( 4 downto 0);
signal VSRAM1_ADDR_B    : std_logic_vector( 4 downto 0);
signal VSRAM1_D_A       : std_logic_vector(10 downto 0);
signal VSRAM1_WE_A      : std_logic;
signal VSRAM1_WE_B      : std_logic;
signal VSRAM1_Q_A       : std_logic_vector(10 downto 0);
signal VSRAM1_Q_B       : std_logic_vector(10 downto 0);

----------------------------------------------------------------
-- CPU INTERFACE
----------------------------------------------------------------
signal FF_DTACK_N	: std_logic;
signal FF_DO		: std_logic_vector(15 downto 0);

type reg_t is array(0 to 31) of std_logic_vector(7 downto 0);
signal REG			: reg_t;
signal PENDING		: std_logic;
signal CODE			: std_logic_vector(5 downto 0);

type fifo_addr_t is array(0 to 3) of std_logic_vector(16 downto 0);
signal FIFO_ADDR	: fifo_addr_t;
type fifo_data_t is array(0 to 3) of std_logic_vector(15 downto 0);
signal FIFO_DATA	: fifo_data_t;
type fifo_code_t is array(0 to 3) of std_logic_vector(3 downto 0);
signal FIFO_CODE	: fifo_code_t;
type fifo_delay_t is array(0 to 3) of std_logic_vector(1 downto 0);
signal FIFO_DELAY   : fifo_delay_t;
signal FIFO_WR_POS	: std_logic_vector(1 downto 0);
signal FIFO_RD_POS	: std_logic_vector(1 downto 0);
signal FIFO_QUEUE	: std_logic_vector(2 downto 0);
signal FIFO_EMPTY	: std_logic;
signal FIFO_FULL	: std_logic;
signal REFRESH_SLOT	: std_logic;
signal REFRESH_FLAG : std_logic;
signal REFRESH_EN   : std_logic;
signal FIFO_EN		: std_logic;
signal FIFO_PARTIAL	: std_logic;
signal SLOT_EN      : std_logic;

signal IN_DMA		: std_logic;
signal IN_HBL		: std_logic;
signal M_HBL		: std_logic;
signal IN_VBL		: std_logic; -- VBL flag to the CPU
signal VBL_AREA		: std_logic; -- outside of borders

signal SOVR			: std_logic;
signal SOVR_SET     : std_logic;
signal SOVR_CLR		: std_logic;

signal SCOL			: std_logic;
signal SCOL_SET		: std_logic;
signal SCOL_CLR		: std_logic;

----------------------------------------------------------------
-- INTERRUPTS
----------------------------------------------------------------
signal EXINT_PENDING          : std_logic;
signal EXINT_PENDING_SET		: std_logic;
signal EXINT_FF					: std_logic;

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
signal VINT_T80_WAIT				: unsigned(11 downto 0);

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
signal WHP_LATCH    : std_logic_vector(4 downto 0);
signal WRIGT		: std_logic;
signal WRIGT_LATCH  : std_logic;

signal BGCOL		: std_logic_vector(5 downto 0);

signal HIT			: std_logic_vector(7 downto 0);
signal IE2			: std_logic;
signal IE1			: std_logic;
signal IE0			: std_logic;

signal OLD_HL 		: std_logic;
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
	DTC_VSRAM_RD,
	DTC_VSRAM_RD2,
	DTC_VSRAM_RD3
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
	DMA_VBUS_WAIT,
	DMA_VBUS_RD,
	DMA_VBUS_LOOP,
	DMA_VBUS_END
);
signal DMAC	: dmac_t;

signal DT_VRAM_SEL      : std_logic;
signal DT_VRAM_SEL_D    : std_logic;
signal DT_VRAM_ADDR     : std_logic_vector(16 downto 1);
signal DT_VRAM_DI       : std_logic_vector(15 downto 0);
signal DT_VRAM_DO       : std_logic_vector(15 downto 0);
signal DT_VRAM_RNW      : std_logic;
signal DT_VRAM_UDS_N    : std_logic;
signal DT_VRAM_LDS_N    : std_logic;

signal DT_WR_ADDR       : std_logic_vector(16 downto 0);
signal DT_WR_DATA       : std_logic_vector(15 downto 0);

signal DT_RD_DATA	: std_logic_vector(15 downto 0);
signal DT_RD_CODE	: std_logic_vector(3 downto 0);
signal DT_RD_SEL	: std_logic;
signal DT_RD_DTACK_N	: std_logic;

signal ADDR			: std_logic_vector(16 downto 0);

signal DT_DMAF_DATA	: std_logic_vector(15 downto 0);
signal DT_DMAV_DATA	: std_logic_vector(15 downto 0);
signal DMAF_SET_REQ	: std_logic;

signal FF_VBUS_ADDR		: std_logic_vector(23 downto 1);
signal FF_VBUS_SEL		: std_logic;

signal DMA_VBUS		: std_logic;
signal DMA_FILL		: std_logic;
signal DMA_COPY		: std_logic;

signal DMA_LENGTH	: std_logic_vector(15 downto 0);
signal DMA_SOURCE	: std_logic_vector(15 downto 0);

signal DMA_VBUS_TIMER : std_logic_vector(1 downto 0);
signal BGACK_N_REG  : std_logic;

----------------------------------------------------------------
-- VIDEO COUNTING
----------------------------------------------------------------
signal V_ACTIVE      : std_logic; -- V_ACTIVE right after line change
signal V_ACTIVE_DISP : std_logic; -- V_ACTIVE after HBLANK_START
signal Y			: std_logic_vector(7 downto 0);
signal BG_Y		: std_logic_vector(8 downto 0);

signal PRE_V_ACTIVE	: std_logic;
signal PRE_Y		: std_logic_vector(8 downto 0);

signal FIELD		: std_logic;
signal FIELD_LATCH	: std_logic;

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
signal VBORDER_START   : std_logic_vector(8 downto 0);
signal VBORDER_END     : std_logic_vector(8 downto 0);
signal V_TOTAL_HEIGHT  : std_logic_vector(8 downto 0);
signal V_INT_POS       : std_logic_vector(8 downto 0);

signal V_DISP_HEIGHT_R : std_logic_vector(8 downto 0);
signal V30_R           : std_logic;

----------------------------------------------------------------
-- VRAM CONTROLLER
----------------------------------------------------------------

signal early_ack_dt : std_logic;

type vmc32_t is (
	VMC32_IDLE,
	VMC32_HSC,
	VMC32_BGB,
	VMC32_BGA,
	VMC32_SP2,
	VMC32_SP3
);
signal VMC32	: vmc32_t := VMC32_IDLE;
signal VMC32_NEXT : vmc32_t := VMC32_IDLE;
signal RAM_REQ_PROGRESS : std_logic;

----------------------------------------------------------------
-- HSCROLL READING
----------------------------------------------------------------

signal HSC_VRAM_ADDR    : std_logic_vector(15 downto 1);
signal HSC_VRAM32_DO    : std_logic_vector(31 downto 0);
signal HSC_VRAM32_DO_REG: std_logic_vector(31 downto 0);
signal HSC_VRAM32_ACK   : std_logic;
signal HSC_SEL          : std_logic;

----------------------------------------------------------------
-- BACKGROUND RENDERING
----------------------------------------------------------------

signal BGEN_ACTIVATE	: std_logic;

-- BACKGROUND B
type bgbc_t is (
	BGBC_INIT,
	BGBC_GET_VSCROLL,
	BGBC_GET_VSCROLL2,
	BGBC_GET_VSCROLL3,
	BGBC_CALC_Y,
	BGBC_CALC_BASE,
	BGBC_BASE_RD,
	BGBC_TILE_RD,
	BGBC_LOOP,
	BGBC_DONE
);
signal BGBC		: bgbc_t;

-- signal BGB_COLINFO		: colinfo_t;
signal BGB_COLINFO_ADDR_A	: std_logic_vector(8 downto 0);
signal BGB_COLINFO_ADDR_B	: std_logic_vector(8 downto 0);
signal BGB_COLINFO_D_A		: std_logic_vector(7 downto 0);
signal BGB_COLINFO_WE_A		: std_logic;
signal BGB_COLINFO_WE_B		: std_logic;
signal BGB_COLINFO_Q_B		: std_logic_vector(7 downto 0);


signal BGB_X		: std_logic_vector(9 downto 0);
signal BGB_POS		: std_logic_vector(9 downto 0);
signal BGB_COL		: std_logic_vector(6 downto 0);
signal BGB_Y		: std_logic_vector(10 downto 0);
signal T_BGB_PRI	: std_logic;
signal T_BGB_PAL	: std_logic_vector(1 downto 0);
signal T_BGB_COLNO	: std_logic_vector(3 downto 0);
signal BGB_BASE		: std_logic_vector(15 downto 0);
signal BGB_HF		: std_logic;
signal BGB_TRANSP0	: std_logic;
signal BGB_TRANSP1	: std_logic;
signal BGB_TRANSP2	: std_logic;
signal BGB_TRANSP3	: std_logic;

signal BGB_NAMETABLE_ITEMS  : std_logic_vector(31 downto 0);
signal BGB_VRAM_ADDR        : std_logic_vector(15 downto 1);
signal BGB_VRAM32_DO        : std_logic_vector(31 downto 0);
signal BGB_VRAM32_DO_REG    : std_logic_vector(31 downto 0);
signal BGB_VRAM32_ACK       : std_logic;
signal BGB_VRAM32_ACK_REG   : std_logic;
signal BGB_SEL		        : std_logic;
signal BGB_VSRAM1_LATCH     : std_logic_vector(10 downto 0);
signal BGB_VSRAM1_LAST_READ : std_logic_vector(10 downto 0);

signal BGB_MAPPING_EN       : std_logic;
signal BGB_PATTERN_EN       : std_logic;
signal BGB_ENABLE           : std_logic;

-- BACKGROUND A
type bgac_t is (
	BGAC_INIT,
	BGAC_GET_VSCROLL,
	BGAC_GET_VSCROLL2,
	BGAC_GET_VSCROLL3,
	BGAC_CALC_Y,
	BGAC_CALC_BASE,
	BGAC_BASE_RD,
	BGAC_TILE_RD,
	BGAC_LOOP,
	BGAC_DONE
);
signal BGAC		: bgac_t;

-- signal BGA_COLINFO		: colinfo_t;
signal BGA_COLINFO_ADDR_A	: std_logic_vector(8 downto 0);
signal BGA_COLINFO_ADDR_B	: std_logic_vector(8 downto 0);
signal BGA_COLINFO_D_A		: std_logic_vector(7 downto 0);
signal BGA_COLINFO_WE_A		: std_logic;
signal BGA_COLINFO_WE_B		: std_logic;
signal BGA_COLINFO_Q_B		: std_logic_vector(7 downto 0);

signal BGA_X		: std_logic_vector(9 downto 0);
signal BGA_POS		: std_logic_vector(9 downto 0);
signal BGA_COL		: std_logic_vector(6 downto 0);
signal BGA_Y		: std_logic_vector(10 downto 0);
signal T_BGA_PRI	: std_logic;
signal T_BGA_PAL	: std_logic_vector(1 downto 0);
signal T_BGA_COLNO	: std_logic_vector(3 downto 0);
signal BGA_BASE		: std_logic_vector(15 downto 0);
signal BGA_TILEBASE	: std_logic_vector(15 downto 0);
signal BGA_HF		: std_logic;
signal BGA_TRANSP0	: std_logic;
signal BGA_TRANSP1	: std_logic;
signal BGA_TRANSP2	: std_logic;
signal BGA_TRANSP3	: std_logic;

signal BGA_NAMETABLE_ITEMS  : std_logic_vector(31 downto 0);
signal BGA_VRAM_ADDR        : std_logic_vector(15 downto 1);
signal BGA_VRAM32_DO        : std_logic_vector(31 downto 0);
signal BGA_VRAM32_DO_REG    : std_logic_vector(31 downto 0);
signal BGA_VRAM32_ACK       : std_logic;
signal BGA_VRAM32_ACK_REG   : std_logic;
signal BGA_SEL              : std_logic;
signal BGA_VSRAM0_LATCH     : std_logic_vector(10 downto 0);
signal BGA_VSRAM0_LAST_READ : std_logic_vector(10 downto 0);

signal WIN_V		: std_logic;
signal WIN_H		: std_logic;

signal BGA_MAPPING_EN       : std_logic;
signal BGA_PATTERN_EN       : std_logic;
signal BGA_ENABLE           : std_logic;
----------------------------------------------------------------
-- SPRITE ENGINE
----------------------------------------------------------------
signal OBJ_MAX_FRAME			: std_logic_vector(6 downto 0);
signal OBJ_MAX_LINE         : std_logic_vector(5 downto 0);

signal OBJ_CACHE_ADDR_RD    : std_logic_vector(6 downto 0);
signal OBJ_CACHE_ADDR_WR    : std_logic_vector(6 downto 0);
signal OBJ_CACHE_D          : std_logic_vector(31 downto 0);
signal OBJ_CACHE_Q          : std_logic_vector(31 downto 0);
signal OBJ_CACHE_BE         : std_logic_vector(3 downto 0);
signal OBJ_CACHE_WE         : std_logic_vector(1 downto 0);

signal OBJ_VISINFO_ADDR_RD	: std_logic_vector(5 downto 0);
signal OBJ_VISINFO_ADDR_WR	: std_logic_vector(5 downto 0);
signal OBJ_VISINFO_D		: std_logic_vector(6 downto 0);
signal OBJ_VISINFO_WE		: std_logic;
signal OBJ_VISINFO_Q		: std_logic_vector(6 downto 0);

signal OBJ_SPINFO_ADDR_RD	: std_logic_vector(5 downto 0);
signal OBJ_SPINFO_ADDR_WR	: std_logic_vector(5 downto 0);
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

signal OBJ_COLINFO2_ADDR_RD : std_logic_vector(8 downto 0);
signal OBJ_COLINFO2_ADDR_WR : std_logic_vector(8 downto 0);
signal OBJ_COLINFO2_D       : std_logic_vector(6 downto 0);
signal OBJ_COLINFO2_WE      : std_logic;
signal OBJ_COLINFO2_Q       : std_logic_vector(6 downto 0);

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
signal SP1_EN			: std_logic;
signal SP1_STEPS        : std_logic_vector(6 downto 0);

signal OBJ_TOT			: std_logic_vector(6 downto 0);
signal OBJ_NEXT			: std_logic_vector(6 downto 0);
signal OBJ_NB			: std_logic_vector(5 downto 0);
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
	SP2C_RD,
	SP2C_NEXT,
	SP2C_DONE
);
signal SP2C	: SP2C_t;
signal SP2_Y			: std_logic_vector(8 downto 0);
signal SP2_EN			: std_logic;
signal SP2_VRAM_ADDR	: std_logic_vector(15 downto 1);
signal SP2_VRAM32_DO     : std_logic_vector(31 downto 0);
signal SP2_VRAM32_DO_REG : std_logic_vector(31 downto 0);
signal SP2_VRAM32_ACK    : std_logic;
signal SP2_SEL			: std_logic;

signal OBJ_IDX			: std_logic_vector(5 downto 0);

signal OBJ_CACHE_ADDR_RD_SP2	: std_logic_vector(6 downto 0);

-- PART 3
signal SP3E_ACTIVATE	: std_logic;

type sp3c_t is (
	SP3C_INIT,
	SP3C_NEXT,
	SP3C_TILE_RD,
	SP3C_LOOP,
	SP3C_PLOT,
	SP3C_DONE
);
signal SP3C		: SP3C_t;

signal SP3_VRAM_ADDR	: std_logic_vector(15 downto 1);
signal SP3_VRAM32_DO    : std_logic_vector(31 downto 0);
signal SP3_VRAM32_DO_REG: std_logic_vector(31 downto 0);
signal SP3_VRAM32_ACK   : std_logic;
signal SP3_VRAM32_ACK_REG: std_logic;
signal SP3_SEL          : std_logic;

signal OBJ_PIX          : std_logic_vector(8 downto 0);
signal OBJ_NO			: std_logic_vector(5 downto 0);

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

begin

bgb_ci : entity work.DualPortRAM
generic map (
	addrbits => 9,
	databits => 8
)
port map(
	address_a	=> BGB_COLINFO_ADDR_A,
	address_b	=> BGB_COLINFO_ADDR_B,
	clock		=> CLK,
	data_a		=> BGB_COLINFO_D_A,
	data_b		=> (others => '0'),
	wren_a		=> BGB_COLINFO_WE_A,
	wren_b		=> BGB_COLINFO_WE_B,
	q_a			=> open,
	q_b			=> BGB_COLINFO_Q_B
);
BGB_COLINFO_WE_B <= '0';

bga_ci : entity work.DualPortRAM
generic map (
	addrbits => 9,
	databits => 8
)
port map(
	address_a	=> BGA_COLINFO_ADDR_A,
	address_b	=> BGA_COLINFO_ADDR_B,
	clock		=> CLK,
	data_a		=> BGA_COLINFO_D_A,
	data_b		=> (others => '0'),
	wren_a		=> BGA_COLINFO_WE_A,
	wren_b		=> BGA_COLINFO_WE_B,
	q_a			=> open,
	q_b			=> BGA_COLINFO_Q_B
);
BGA_COLINFO_WE_B <= '0';

obj_ci : entity work.DualPortRAM
generic map (
	addrbits        => 9,
	databits        => 7
)
port map(
	address_a	=> OBJ_COLINFO_ADDR_A,
	address_b	=> OBJ_COLINFO_ADDR_B,
	clock		=> OBJ_COLINFO_CLK,
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

obj_ci2 : entity work.DualPortRAM
generic map (
	addrbits    => 9,
	databits    => 7
)
port map(
	address_a   => OBJ_COLINFO2_ADDR_RD,
	address_b   => OBJ_COLINFO2_ADDR_WR,
	clock       => CLK,
	data_a      => (others => '0'),
	data_b      => OBJ_COLINFO2_D,
	wren_a      => '0',
	wren_b      => OBJ_COLINFO2_WE,
	q_a         => OBJ_COLINFO2_Q,
	q_b         => open
);

obj_cache : entity work.obj_cache
port map(
	clock       => CLK,
	rdaddress   => OBJ_CACHE_ADDR_RD,
	q           => OBJ_CACHE_Q,
	wraddress   => OBJ_CACHE_ADDR_WR,
	data        => OBJ_CACHE_D,
	wren        => OBJ_CACHE_WE(1),
	byteena_a   => OBJ_CACHE_BE
);

OBJ_CACHE_ADDR_RD <= OBJ_CACHE_ADDR_RD_SP1 when SP1C /= SP1C_DONE else OBJ_CACHE_ADDR_RD_SP2;

obj_visinfo : entity work.DualPortRAM
generic map (
	addrbits	=> 6,
	databits	=> 7
)
port map(
	clock		=> CLK,
	data_a		=> (others => '0'),
	data_b		=> OBJ_VISINFO_D,
	address_a	=> OBJ_VISINFO_ADDR_RD,
	address_b	=> OBJ_VISINFO_ADDR_WR,
	wren_a		=> '0',
	wren_b		=> OBJ_VISINFO_WE,
	q_a			=> OBJ_VISINFO_Q,
	q_b			=> open
 );

obj_spinfo : entity work.DualPortRAM
generic map (
	addrbits	=> 6,
	databits	=> 35
)
port map(
	clock		=> CLK,
	data_a		=> (others => '0'),
	data_b		=> OBJ_SPINFO_D,
	address_a	=> OBJ_SPINFO_ADDR_RD,
	address_b	=> OBJ_SPINFO_ADDR_WR,
	wren_a		=> '0',
	wren_b		=> OBJ_SPINFO_WE,
	q_a			=> OBJ_SPINFO_Q,
	q_b			=> open
 );

cram : entity work.DualPortRAM
generic map (
	addrbits => 6,
	databits => 9
)
port map(
	address_a	=> CRAM_ADDR_A,
	address_b	=> CRAM_ADDR_B,
	clock		=> CLK,
	data_a		=> CRAM_D_A,
	data_b		=> (others => '0'),
	wren_a		=> CRAM_WE_A,
	wren_b		=> CRAM_WE_B,
	q_a			=> CRAM_Q_A,
	q_b			=> CRAM_Q_B
);
CRAM_WE_B <= '0';
CRAM_DATA <= CRAM_D_A when CRAM_WE_A = '1' and CRAM_DOTS = '1' else CRAM_Q_B;

vsram0 : entity work.DualPortRAM
generic map (
	addrbits => 5,
	databits => 11
)
port map(
	address_a   => VSRAM0_ADDR_A,
	address_b   => VSRAM0_ADDR_B,
	clock       => CLK,
	data_a      => VSRAM0_D_A,
	data_b      => (others => '0'),
	wren_a      => VSRAM0_WE_A,
	wren_b      => VSRAM0_WE_B,
	q_a         => VSRAM0_Q_A,
	q_b         => VSRAM0_Q_B
);
VSRAM0_WE_B <= '0';

vsram1 : entity work.DualPortRAM
generic map (
	addrbits => 5,
	databits => 11
)
port map(
	address_a   => VSRAM1_ADDR_A,
	address_b   => VSRAM1_ADDR_B,
	clock       => CLK,
	data_a      => VSRAM1_D_A,
	data_b      => (others => '0'),
	wren_a      => VSRAM1_WE_A,
	wren_b      => VSRAM1_WE_B,
	q_a         => VSRAM1_Q_A,
	q_b         => VSRAM1_Q_B
);
VSRAM1_WE_B <= '0';

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
IE2 <= REG(11)(3);
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

----------------------------------------------------------------
-- CPU INTERFACE
----------------------------------------------------------------

BGACK_N <= BGACK_N_REG;

----------------------------------------------------------------
-- VRAM CONTROLLER
----------------------------------------------------------------
vram32_req <= not vram32_req_reg when VMC32_NEXT /= VMC32_IDLE and RAM_REQ_PROGRESS = '0' and vram32_req_reg = vram32_ack else vram32_req_reg;
vram32_a <= vram32_a_next when VMC32_NEXT /= VMC32_IDLE and RAM_REQ_PROGRESS = '0' and vram32_req_reg = vram32_ack else vram32_a_reg;

-- Get the ack and data one cycle earlier
SP2_VRAM32_DO <= vram32_q when VMC32 = VMC32_SP2 else SP2_VRAM32_DO_REG;
SP3_VRAM32_DO <= vram32_q when VMC32 = VMC32_SP3 else SP3_VRAM32_DO_REG;
HSC_VRAM32_DO <= vram32_q when VMC32 = VMC32_HSC else HSC_VRAM32_DO_REG;
BGB_VRAM32_DO <= vram32_q when VMC32 = VMC32_BGB else BGB_VRAM32_DO_REG;
BGA_VRAM32_DO <= vram32_q when VMC32 = VMC32_BGA else BGA_VRAM32_DO_REG;

SP2_VRAM32_ACK <= '1' when VMC32 = VMC32_SP2 and vram32_req_reg = vram32_ack and RAM_REQ_PROGRESS = '1' else '0';
SP3_VRAM32_ACK <= '1' when VMC32 = VMC32_SP3 and vram32_req_reg = vram32_ack and RAM_REQ_PROGRESS = '1' else SP3_VRAM32_ACK_REG;
HSC_VRAM32_ACK <= '1' when VMC32 = VMC32_HSC and vram32_req_reg = vram32_ack and RAM_REQ_PROGRESS = '1' else '0';
BGB_VRAM32_ACK <= '1' when VMC32 = VMC32_BGB and vram32_req_reg = vram32_ack and RAM_REQ_PROGRESS = '1' else BGB_VRAM32_ACK_REG;
BGA_VRAM32_ACK <= '1' when VMC32 = VMC32_BGA and vram32_req_reg = vram32_ack and RAM_REQ_PROGRESS = '1' else BGA_VRAM32_ACK_REG;

VMC32_NEXT <= VMC32_SP3 when SP3_SEL = '1' and SP3_VRAM32_ACK_REG = '0' else
              VMC32_SP2 when SP2_SEL = '1' else
              VMC32_HSC when HSC_SEL = '1' else
              VMC32_BGA when BGA_SEL = '1' and BGA_VRAM32_ACK_REG = '0' else
              VMC32_BGB when BGB_SEL = '1' and BGB_VRAM32_ACK_REG = '0' else
              VMC32_IDLE;

process( RST_N, CLK, 
	vram32_req_reg, vram32_ack, RAM_REQ_PROGRESS, VMC32_NEXT,
	SP2_VRAM_ADDR, SP3_VRAM_ADDR, HSC_VRAM_ADDR, BGB_VRAM_ADDR, BGA_VRAM_ADDR)
begin

	vram32_a_next <= (others => '0');
	if vram32_req_reg = vram32_ack and RAM_REQ_PROGRESS = '0' then
		case VMC32_NEXT is
		when VMC32_IDLE =>
			null;
		when VMC32_SP2 =>
			vram32_a_next <= SP2_VRAM_ADDR;
		when VMC32_SP3 =>
			vram32_a_next <= SP3_VRAM_ADDR;
		when VMC32_HSC =>
			vram32_a_next <= HSC_VRAM_ADDR;
		when VMC32_BGB =>
			vram32_a_next <= BGB_VRAM_ADDR;
		when VMC32_BGA =>
			vram32_a_next <= BGA_VRAM_ADDR;
		end case;
	end if;

	if RST_N = '0' then

		vram32_req_reg <= '0';

		VMC32 <= VMC32_IDLE;
		RAM_REQ_PROGRESS <= '0';
		SP3_VRAM32_ACK_REG <= '0';
		BGA_VRAM32_ACK_REG <= '0';
		BGB_VRAM32_ACK_REG <= '0';

	elsif rising_edge(CLK) then
		if SP3_SEL = '0' then
			SP3_VRAM32_ACK_REG <= '0';
		end if;
		if BGA_SEL = '0' then
			BGA_VRAM32_ACK_REG <= '0';
		end if;
		if BGB_SEL = '0' then
			BGB_VRAM32_ACK_REG <= '0';
		end if;

		if vram32_req_reg = vram32_ack then
			if RAM_REQ_PROGRESS = '0' then
				VMC32 <= VMC32_NEXT;
				if VMC32_NEXT /= VMC32_IDLE then
					vram32_a_reg <= vram32_a_next;
					vram32_req_reg <= not vram32_req_reg;
					RAM_REQ_PROGRESS <= '1';
				end if;
			else
				case VMC32 is
				when VMC32_IDLE =>
					null;
				when VMC32_SP2 =>
					SP2_VRAM32_DO_REG <= vram32_q;
				when VMC32_SP3 =>
					SP3_VRAM32_DO_REG <= vram32_q;
					SP3_VRAM32_ACK_REG <= '1';
				when VMC32_HSC =>
					HSC_VRAM32_DO_REG <= vram32_q;
				when VMC32_BGB =>
					BGB_VRAM32_DO_REG <= vram32_q;
					BGB_VRAM32_ACK_REG <= '1';
				when VMC32_BGA =>
					BGA_VRAM32_DO_REG <= vram32_q;
					BGA_VRAM32_ACK_REG <= '1';
				end case;
				RAM_REQ_PROGRESS <= '0';
			end if;
		end if;
	end if;
end process;

-- 16 bit interface for data transfer

vram_req <= DT_VRAM_SEL;
vram_d <= DT_VRAM_DI when M128 = '0' else DT_VRAM_DI(7 downto 0) & DT_VRAM_DI(7 downto 0);
vram_we <= not DT_VRAM_RNW;
vram_u_n <= (DT_VRAM_UDS_N or M128) and (not vram_a_reg(1) or not M128);
vram_l_n <= (DT_VRAM_LDS_N or M128) and (vram_a_reg(1) or not M128);
vram_a <= vram_a_reg(15 downto 1) when M128 = '0' else vram_a_reg(16 downto 11) & vram_a_reg(9 downto 2) & vram_a_reg(10);
vram_a_reg <= DT_VRAM_ADDR;
early_ack_dt <= '0' when DT_VRAM_SEL=vram_ack else '1';
DT_VRAM_DO <= vram_q;

----------------------------------------------------------------
-- HSCROLL READ
----------------------------------------------------------------
process (RST_N, CLK) begin
	if RST_N = '0' then
		HSC_SEL <= '0';
	elsif rising_edge(CLK) then
		if V_ACTIVE = '1' and HV_HCNT = HSCROLL_READ and HV_PIXDIV = 0 then

			case HSCR is -- Horizontal scroll mode
				when "00" =>
					HSC_VRAM_ADDR <= HSCB & "000000000";
				when "01" =>
					HSC_VRAM_ADDR <= HSCB & "00000" & Y(2 downto 0) & '0';
				when "10" =>
					HSC_VRAM_ADDR <= HSCB & Y(7 downto 3) & "0000";
				when "11" =>
					HSC_VRAM_ADDR <= HSCB & Y & '0';
				when others => null;
			end case;
			HSC_SEL <= '1';
		elsif HSC_VRAM32_ACK = '1' then
			HSC_SEL <= '0';
		end if;
	end if;
end process;

----------------------------------------------------------------
-- BACKGROUND B RENDERING
----------------------------------------------------------------
BGB_TRANSP0 <= '1' when (BGB_VRAM32_DO( 3 downto  0) or BGB_VRAM32_DO(11 downto  8)) = "0000" else '0';
BGB_TRANSP1 <= '1' when (BGB_VRAM32_DO( 7 downto  4) or BGB_VRAM32_DO(15 downto 12)) = "0000" else '0';
BGB_TRANSP2 <= '1' when (BGB_VRAM32_DO(19 downto 16) or BGB_VRAM32_DO(27 downto 24)) = "0000" else '0';
BGB_TRANSP3 <= '1' when (BGB_VRAM32_DO(23 downto 20) or BGB_VRAM32_DO(31 downto 28)) = "0000" else '0';

process( RST_N, CLK )
variable V_BGB_XSTART	: std_logic_vector(9 downto 0);
variable V_BGB_BASE		: std_logic_vector(15 downto 0);
variable bgb_nametable_item : std_logic_vector(15 downto 0);
variable vscroll_mask	: std_logic_vector(10 downto 0);
variable hscroll_mask	: std_logic_vector(9 downto 0);
variable vscroll_val	: std_logic_vector(10 downto 0);
variable vscroll_index  : std_logic_vector(4 downto 0);
variable y_cells	: std_logic_vector(6 downto 0);

-- synthesis translate_off
file F		: text open write_mode is "bgb_dbg.out";
variable L	: line;
-- synthesis translate_on
begin
	if RST_N = '0' then
		BGB_SEL <= '0';
		BGB_ENABLE <= '1';
		BGBC <= BGBC_DONE;
	elsif rising_edge(CLK) then
			case BGBC is
			when BGBC_DONE =>
				VSRAM1_ADDR_B <= (others => '0');
				if HV_HCNT = H_INT_POS and HV_PIXDIV = 0 and VSCR = '0' then
					BGB_VSRAM1_LATCH <= VSRAM1_Q_B;
					BGB_VSRAM1_LAST_READ <= VSRAM1_Q_B;
				end if;
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

				V_BGB_XSTART := "0000000000" - HSC_VRAM32_DO(25 downto 16);
				if V_BGB_XSTART(3 downto 0) = "0000" then
					V_BGB_XSTART := V_BGB_XSTART - 16;
					BGB_POS <= "1111110000";
				else
					BGB_POS <= "0000000000" - ( "000000" & V_BGB_XSTART(3 downto 0) );
				end if;
				BGB_X <= ( V_BGB_XSTART(9 downto 4) & "0000" ) and hscroll_mask;
				BGB_COL <= "1111110"; -- -2
				BGBC <= BGBC_GET_VSCROLL;

			when BGBC_GET_VSCROLL =>
				BGB_COLINFO_WE_A <= '0';
				if BGB_COL(5 downto 1) <= 19 then
					VSRAM1_ADDR_B <= BGB_COL(5 downto 1);
				else
					VSRAM1_ADDR_B <= (others => '0');
				end if;
				BGBC <= BGBC_GET_VSCROLL2;

			when BGBC_GET_VSCROLL2 =>
				BGBC <= BGBC_GET_VSCROLL3;

			when BGBC_GET_VSCROLL3 =>
				if VSCR = '1' then
					if BGB_COL(5 downto 1) <= 19 then
						BGB_VSRAM1_LATCH <= VSRAM1_Q_B;
						BGB_VSRAM1_LAST_READ <= VSRAM1_Q_B;
					elsif H40 = '0' then
						BGB_VSRAM1_LATCH <= (others => '0');
					elsif VSCROLL_BUG = '1' then
						-- partial column gets the last read values AND'ed in H40 ("left column scroll bug")
						BGB_VSRAM1_LATCH <= BGB_VSRAM1_LAST_READ and BGA_VSRAM0_LAST_READ;
					else
						-- using VSRAM(1) sometimes looks better (Gynoug)
						BGB_VSRAM1_LATCH <= VSRAM1_Q_B;
					end if;
				end if;
				BGBC <= BGBC_CALC_Y;

			when BGBC_CALC_Y =>
-- synthesis translate_off
				write(L, string'("BGB COL = "));
				hwrite(L, "0" & BGB_COL);
				write(L, string'(" BGB X = "));
				hwrite(L, "000000" & BGB_X(9 downto 0));
				write(L, string'(" POS="));
				hwrite(L, "000000" & BGB_POS(9 downto 0));
				writeline(F,L);
-- synthesis translate_on
				if LSM = "11" then
					vscroll_val := BGB_VSRAM1_LATCH(10 downto 0);
				else
					vscroll_val := '0' & BGB_VSRAM1_LATCH(9 downto 0);
				end if;
				BGB_Y <= (BG_Y + vscroll_val) and vscroll_mask;
				BGBC <= BGBC_CALC_BASE;

			when BGBC_CALC_BASE =>
				if BGB_MAPPING_EN = '1' then
					-- BGB mapping slot
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
					BGB_ENABLE <= DE;
					if DE = '1' then
						BGB_SEL <= '1';
						BGBC <= BGBC_BASE_RD;
					else
						BGBC <= BGBC_LOOP;
					end if;
				end if;

			when BGBC_BASE_RD =>
				if BGB_VRAM32_ACK = '1' then
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
					hwrite(L, BGB_VRAM32_DO);
					write(L, string'("]"));
					writeline(F,L);									
-- synthesis translate_on
					BGB_SEL <= '0';
					BGB_NAMETABLE_ITEMS <= BGB_VRAM32_DO;
					BGBC <= BGBC_TILE_RD;
				end if;

			when BGBC_TILE_RD =>
				-- BGB pattern slot
				BGB_COLINFO_WE_A <= '0';

				if BGB_X(3) = '0' then
					bgb_nametable_item := BGB_NAMETABLE_ITEMS(15 downto 0);
				else
					bgb_nametable_item := BGB_NAMETABLE_ITEMS(31 downto 16);
				end if;
				T_BGB_PRI <= bgb_nametable_item(15);
				T_BGB_PAL <= bgb_nametable_item(14 downto 13);
				BGB_HF <= bgb_nametable_item(11);
				if LSM = "11" then
					if bgb_nametable_item(12) = '1' then	-- VF
						BGB_VRAM_ADDR <= bgb_nametable_item(9 downto 0) & not(BGB_Y(3 downto 0)) & "0";
					else
						BGB_VRAM_ADDR <= bgb_nametable_item(9 downto 0) & BGB_Y(3 downto 0) & "0";
					end if;
				else
					if bgb_nametable_item(12) = '1' then	-- VF
						BGB_VRAM_ADDR <= bgb_nametable_item(10 downto 0) & not(BGB_Y(2 downto 0)) & "0";
					else
						BGB_VRAM_ADDR <= bgb_nametable_item(10 downto 0) & BGB_Y(2 downto 0) & "0";
					end if;
				end if;

				if BGB_ENABLE = '1' then
					BGB_SEL <= '1';
				end if;
				BGBC <= BGBC_LOOP;

			when BGBC_LOOP =>
				if BGB_VRAM32_ACK = '1' or BGB_SEL = '0' or BGB_ENABLE = '0' then
					BGB_SEL <= '0';

					BGB_COLINFO_ADDR_A <= BGB_POS(8 downto 0);
					BGB_COLINFO_WE_A <= '1';
					case BGB_X(2 downto 0) is
					when "100" =>
						if BGB_HF = '1' then
							BGB_COLINFO_D_A <= (BGB_TRANSP0 xor BGB_TRANSP1) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO( 3 downto  0);
						else
							BGB_COLINFO_D_A <= (BGB_TRANSP2 xor BGB_TRANSP3) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO(31 downto 28);
						end if;
					when "101" =>
						if BGB_HF = '1' then
							BGB_COLINFO_D_A <= (BGB_TRANSP0 xor BGB_TRANSP1) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO( 7 downto  4);
						else
							BGB_COLINFO_D_A <= (BGB_TRANSP2 xor BGB_TRANSP3) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO(27 downto 24);
						end if;
					when "110" =>
						if BGB_HF = '1' then
							BGB_COLINFO_D_A <= (BGB_TRANSP0 xor BGB_TRANSP1) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO(11 downto  8);
						else
							BGB_COLINFO_D_A <= (BGB_TRANSP2 xor BGB_TRANSP3) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO(23 downto 20);
						end if;
					when "111" =>
						if BGB_HF = '1' then
							BGB_COLINFO_D_A <= (BGB_TRANSP0 xor BGB_TRANSP1) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO(15 downto 12);
						else
							BGB_COLINFO_D_A <= (BGB_TRANSP2 xor BGB_TRANSP3) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO(19 downto 16);
						end if;
					when "000" =>
						if BGB_HF = '1' then
							BGB_COLINFO_D_A <= (BGB_TRANSP2 xor BGB_TRANSP3) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO(19 downto 16);
						else
							BGB_COLINFO_D_A <= (BGB_TRANSP0 xor BGB_TRANSP1) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO(15 downto 12);
						end if;
					when "001" =>
						if BGB_HF = '1' then
							BGB_COLINFO_D_A <= (BGB_TRANSP2 xor BGB_TRANSP3) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO(23 downto 20);
						else
							BGB_COLINFO_D_A <= (BGB_TRANSP0 xor BGB_TRANSP1) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO(11 downto  8);
						end if;
					when "010" =>
						if BGB_HF = '1' then
							BGB_COLINFO_D_A <= (BGB_TRANSP2 xor BGB_TRANSP3) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO(27 downto 24);
						else
							BGB_COLINFO_D_A <= (BGB_TRANSP0 xor BGB_TRANSP1) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO( 7 downto  4);
						end if;
					when "011" =>
						if BGB_HF = '1' then
							BGB_COLINFO_D_A <= (BGB_TRANSP2 xor BGB_TRANSP3) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO(31 downto 28);
						else
							BGB_COLINFO_D_A <= (BGB_TRANSP0 xor BGB_TRANSP1) & T_BGB_PRI & T_BGB_PAL & BGB_VRAM32_DO( 3 downto  0);
						end if;
					when others => null;
					end case;

					if BGB_ENABLE = '0' or DE = '0' then
						BGB_COLINFO_D_A <= "00" & BGCOL;
					end if;

					BGB_X <= (BGB_X + 1) and hscroll_mask;
					BGB_POS <= BGB_POS + 1;
					if BGB_X(2 downto 0) = "111" then
						BGB_COL <= BGB_COL + 1;
						if (H40 = '0' and BGB_COL = 31) or (H40 = '1' and BGB_COL = 39) then
							BGBC <= BGBC_DONE;
						elsif BGB_X(3) = '0' then
							BGBC <= BGBC_TILE_RD;
						else
							BGBC <= BGBC_GET_VSCROLL;
						end if;
					else
						BGBC <= BGBC_LOOP;
					end if;
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
BGA_TRANSP0 <= '1' when (BGA_VRAM32_DO( 3 downto  0) or BGA_VRAM32_DO(11 downto  8)) = "0000" else '0';
BGA_TRANSP1 <= '1' when (BGA_VRAM32_DO( 7 downto  4) or BGA_VRAM32_DO(15 downto 12)) = "0000" else '0';
BGA_TRANSP2 <= '1' when (BGA_VRAM32_DO(19 downto 16) or BGA_VRAM32_DO(27 downto 24)) = "0000" else '0';
BGA_TRANSP3 <= '1' when (BGA_VRAM32_DO(23 downto 20) or BGA_VRAM32_DO(31 downto 28)) = "0000" else '0';

process( RST_N, CLK )
variable V_BGA_XSTART	: std_logic_vector(9 downto 0);
variable V_BGA_XBASE		: std_logic_vector(15 downto 0);
variable V_BGA_BASE		: std_logic_vector(15 downto 0);
variable bga_pos_next   : std_logic_vector(9 downto 0);
variable bga_nametable_item : std_logic_vector(15 downto 0);
variable tile_pos       : std_logic_vector(3 downto 0);
variable vscroll_mask	: std_logic_vector(10 downto 0);
variable hscroll_mask	: std_logic_vector(9 downto 0);
variable vscroll_val    : std_logic_vector(10 downto 0);
variable vscroll_index  : std_logic_vector(4 downto 0);
variable y_cells    : std_logic_vector(6 downto 0);
-- synthesis translate_off
file F		: text open write_mode is "bga_dbg.out";
variable L	: line;
-- synthesis translate_on
begin
	if RST_N = '0' then
		BGA_SEL <= '0';
		BGAC <= BGAC_DONE;
		BGA_ENABLE <= '1';
	elsif rising_edge(CLK) then
			case BGAC is
			when BGAC_DONE =>
				VSRAM0_ADDR_B <= (others => '0');
				if HV_HCNT = H_INT_POS and HV_PIXDIV = 0 then
					if VSCR = '0' then
						BGA_VSRAM0_LATCH <= VSRAM0_Q_B;
						BGA_VSRAM0_LAST_READ <= VSRAM0_Q_B;
					end if;
					WRIGT_LATCH <= WRIGT;
					WHP_LATCH <= WHP;
				end if;
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

				if Y(7 downto 3) < WVP then
					WIN_V <= not WDOWN;
				else
					WIN_V <= WDOWN;
				end if;

				if WHP_LATCH = "00000" then
					WIN_H <= WRIGT_LATCH;
				else
					WIN_H <= not WRIGT_LATCH;
				end if;

				V_BGA_XSTART := "0000000000" - HSC_VRAM32_DO(9 downto 0);
				if V_BGA_XSTART(3 downto 0) = "0000" then
					V_BGA_XSTART := V_BGA_XSTART - 16;
					BGA_POS <= "1111110000";
				else
					BGA_POS <= "0000000000" - ( "000000" & V_BGA_XSTART(3 downto 0) );
				end if;

				BGA_X <= ( V_BGA_XSTART(9 downto 4) & "0000" ) and hscroll_mask;
				BGA_COL <= "1111110"; -- -2
				BGAC <= BGAC_GET_VSCROLL;

			when BGAC_GET_VSCROLL =>
				BGA_COLINFO_WE_A <= '0';

				if BGA_COL(5 downto 1) <= 19 then
					VSRAM0_ADDR_B <= BGA_COL(5 downto 1);
				else
					VSRAM0_ADDR_B <= (others => '0');
				end if;
				BGAC <= BGAC_GET_VSCROLL2;

			when BGAC_GET_VSCROLL2 =>
				BGAC <= BGAC_GET_VSCROLL3;

			when BGAC_GET_VSCROLL3 =>
				if VSCR = '1' then
					if BGA_COL(5 downto 1) <= 19 then
						BGA_VSRAM0_LATCH <= VSRAM0_Q_B;
						BGA_VSRAM0_LAST_READ <= VSRAM0_Q_B;
					elsif H40 = '0' then
						BGA_VSRAM0_LATCH <= (others => '0');
					elsif VSCROLL_BUG = '1' then
						-- partial column gets the last read values AND'ed in H40 ("left column scroll bug")
						BGA_VSRAM0_LATCH <= BGA_VSRAM0_LAST_READ and BGB_VSRAM1_LAST_READ;
					else
						-- using VSRAM(0) sometimes looks better (Gynoug)
						BGA_VSRAM0_LATCH <= VSRAM0_Q_B;
					end if;
				end if;
				BGAC <= BGAC_CALC_Y;

			when BGAC_CALC_Y =>
				if WIN_H = '1' or WIN_V = '1' then
					BGA_Y <= "00" & BG_Y;
				else
					if LSM = "11" then
						vscroll_val := BGA_VSRAM0_LATCH(10 downto 0);
					else
						vscroll_val := '0' & BGA_VSRAM0_LATCH(9 downto 0);
					end if;
					BGA_Y <= (BG_Y + vscroll_val) and vscroll_mask;
				end if;
				BGAC <= BGAC_CALC_BASE;

			when BGAC_CALC_BASE =>
				if BGA_MAPPING_EN = '1' then
					-- BGA mapping slot
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
					BGA_ENABLE <= DE;
					if DE = '1' then
						BGA_SEL <= '1';
						BGAC <= BGAC_BASE_RD;
					else
						BGAC <= BGAC_LOOP;
					end if;
				end if;

			when BGAC_BASE_RD =>
				if BGA_VRAM32_ACK = '1' then
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
					hwrite(L, BGA_VRAM32_DO);
					write(L, string'("]"));
					writeline(F,L);									
-- synthesis translate_on											
					BGA_SEL <= '0';
					BGA_NAMETABLE_ITEMS <= BGA_VRAM32_DO;
					BGAC <= BGAC_TILE_RD;
				end if;

			when BGAC_TILE_RD =>
				-- BGA pattern slot
				BGA_COLINFO_WE_A <= '0';

				if ((WIN_H = '1' or WIN_V = '1') and BGA_POS(3) = '0') or
				   (WIN_H = '0' and WIN_V = '0' and BGA_X(3) = '0') then
					bga_nametable_item := BGA_NAMETABLE_ITEMS(15 downto 0);
				else
					bga_nametable_item := BGA_NAMETABLE_ITEMS(31 downto 16);
				end if;

				T_BGA_PRI <= bga_nametable_item(15);
				T_BGA_PAL <= bga_nametable_item(14 downto 13);
				BGA_HF <= bga_nametable_item(11);
				if LSM = "11" then
					if bga_nametable_item(12) = '1' then	-- VF
						BGA_VRAM_ADDR <= bga_nametable_item(9 downto 0) & not(BGA_Y(3 downto 0)) & "0";
					else
						BGA_VRAM_ADDR <= bga_nametable_item(9 downto 0) & BGA_Y(3 downto 0) & "0";
					end if;
				else
					if bga_nametable_item(12) = '1' then	-- VF
						BGA_VRAM_ADDR <= bga_nametable_item(10 downto 0) & not(BGA_Y(2 downto 0)) & "0";
					else
						BGA_VRAM_ADDR <= bga_nametable_item(10 downto 0) & BGA_Y(2 downto 0) & "0";
					end if;
				end if;

				if BGA_ENABLE = '1' then
					BGA_SEL <= '1';
				end if;
				BGAC <= BGAC_LOOP;

			when BGAC_LOOP =>
				if BGA_VRAM32_ACK = '1' or BGA_SEL = '0' or BGA_ENABLE = '0' then
					BGA_SEL <= '0';

					if SVP_QUIRK = '0' or BG_Y /= 223 then
						BGA_COLINFO_WE_A <= '1';
					end if;

					BGA_COLINFO_ADDR_A <= BGA_POS(8 downto 0);
					if WIN_H = '1' or WIN_V = '1' then
						tile_pos := BGA_POS(3 downto 0);
					else
						tile_pos := BGA_X(3 downto 0);
					end if;
					case tile_pos(2 downto 0) is
						when "100" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= (BGA_TRANSP0 xor BGA_TRANSP1) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO( 3 downto  0);
							else
								BGA_COLINFO_D_A <= (BGA_TRANSP2 xor BGA_TRANSP3) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO(31 downto 28);
							end if;
						when "101" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= (BGA_TRANSP0 xor BGA_TRANSP1) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO( 7 downto  4);
							else
								BGA_COLINFO_D_A <= (BGA_TRANSP2 xor BGA_TRANSP3) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO(27 downto 24);
							end if;
						when "110" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= (BGA_TRANSP0 xor BGA_TRANSP1) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO(11 downto  8);
							else
								BGA_COLINFO_D_A <= (BGA_TRANSP2 xor BGA_TRANSP3) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO(23 downto 20);
							end if;
						when "111" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= (BGA_TRANSP0 xor BGA_TRANSP1) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO(15 downto 12);
							else
								BGA_COLINFO_D_A <= (BGA_TRANSP2 xor BGA_TRANSP3) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO(19 downto 16);
							end if;
						when "000" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= (BGA_TRANSP2 xor BGA_TRANSP3) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO(19 downto 16);
							else
								BGA_COLINFO_D_A <= (BGA_TRANSP0 xor BGA_TRANSP1) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO(15 downto 12);
							end if;
						when "001" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= (BGA_TRANSP2 xor BGA_TRANSP3) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO(23 downto 20);
							else
								BGA_COLINFO_D_A <= (BGA_TRANSP0 xor BGA_TRANSP1) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO(11 downto  8);
							end if;
						when "010" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= (BGA_TRANSP2 xor BGA_TRANSP3) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO(27 downto 24);
							else
								BGA_COLINFO_D_A <= (BGA_TRANSP0 xor BGA_TRANSP1) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO( 7 downto  4);
							end if;
						when "011" =>
							if BGA_HF = '1' then
								BGA_COLINFO_D_A <= (BGA_TRANSP2 xor BGA_TRANSP3) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO(31 downto 28);
							else
								BGA_COLINFO_D_A <= (BGA_TRANSP0 xor BGA_TRANSP1) & T_BGA_PRI & T_BGA_PAL & BGA_VRAM32_DO( 3 downto  0);
							end if;
						when others => null;
					end case;

					if BGA_ENABLE = '0' or DE = '0' then
						BGA_COLINFO_D_A <= "00" & BGCOL;
					end if;

					BGA_X <= (BGA_X + 1) and hscroll_mask;
					bga_pos_next := BGA_POS + 1;
					BGA_POS <= bga_pos_next;
					if tile_pos(2 downto 0) = "111" then
						if tile_pos(3) = '0' then
							BGAC <= BGAC_TILE_RD;
						else
							BGAC <= BGAC_GET_VSCROLL;
						end if;
					else
						BGAC <= BGAC_LOOP;
					end if;

					if WIN_H = '1' and WRIGT_LATCH = '0' and BGA_POS(3 downto 0) = "1111" and bga_pos_next(8 downto 4) = WHP_LATCH
					then
						-- window on the left side ends, but not neccessarily on a scroll boundary,
						-- when it continues to draw a wrong tile ("left window bug")
						WIN_H <= '0';
						if WIN_V = '0' and BGA_X(3 downto 0) /= "1111" then
							BGAC <= BGAC_LOOP;
						end if;
					elsif WIN_H = '0' and WRIGT_LATCH = '1' and BGA_POS(3 downto 0) = "1111" and bga_pos_next(8 downto 4) = WHP_LATCH
					then
						-- window on the right side starts, cancel rendering the current tile
						WIN_H <= '1';
						BGAC <= BGAC_GET_VSCROLL;
					end if;

					if BGA_X(2 downto 0) = "111" then
						BGA_COL <= BGA_COL + 1;
						if (H40 = '0' and BGA_COL = 31) or (H40 = '1' and BGA_COL = 39) then
							BGAC <= BGAC_DONE;
						end if;
					end if;
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

OBJ_MAX_LINE  <= conv_std_logic_vector(OBJ_MAX_LINE_H40, 6) when H40 = '1' and OBJ_LIMIT_HIGH_EN = '0' else
				 conv_std_logic_vector(OBJ_MAX_LINE_H40_HIGH, 6) when H40 = '1' and OBJ_LIMIT_HIGH_EN = '1' else
				 conv_std_logic_vector(OBJ_MAX_LINE_H32, 6) when H40 = '0' and OBJ_LIMIT_HIGH_EN = '0' else
				 conv_std_logic_vector(OBJ_MAX_LINE_H32_HIGH, 6) when H40 = '0' and OBJ_LIMIT_HIGH_EN = '1';

-- Write-through cache for Y, Link and size fields
process( RST_N, CLK )
variable cache_addr: std_logic_vector(13 downto 0);
begin
	if RST_N = '0' then

		OBJ_CACHE_ADDR_WR <= (others => '0');
		OBJ_CACHE_WE <= "00";

	elsif rising_edge(CLK) then

		OBJ_CACHE_WE <= OBJ_CACHE_WE(0) & '0';

		cache_addr := DT_VRAM_ADDR(16 downto 3) - (SATB & "000000");
		DT_VRAM_SEL_D <= DT_VRAM_SEL;
		if DT_VRAM_SEL_D /= DT_VRAM_SEL and DT_VRAM_RNW = '0' and
		   DT_VRAM_ADDR(2) = '0' and cache_addr < OBJ_MAX_FRAME
		then
			OBJ_CACHE_ADDR_WR <= cache_addr(6 downto 0);
			OBJ_CACHE_D <= DT_VRAM_DI & DT_VRAM_DI;
			OBJ_CACHE_BE(3) <= DT_VRAM_ADDR(1) and not DT_VRAM_UDS_N;
			OBJ_CACHE_BE(2) <= DT_VRAM_ADDR(1) and not DT_VRAM_LDS_N;
			OBJ_CACHE_BE(1) <= not DT_VRAM_ADDR(1) and not DT_VRAM_UDS_N;
			OBJ_CACHE_BE(0) <= not DT_VRAM_ADDR(1) and not DT_VRAM_LDS_N;
			OBJ_CACHE_WE <= "01";
		end if;
	end if;
end process;

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

	elsif rising_edge(CLK) then

		case SP1C is
			when SP1C_INIT =>
				SP1_Y <= PRE_Y;	-- Latch the current PRE_Y value
				OBJ_TOT <= (others => '0');
				OBJ_NEXT <= (others => '0');
				OBJ_NB <= (others => '0');
				OBJ_VISINFO_WE <= '0';
				SP1_STEPS <= (others => '0');
				SP1C <= SP1C_Y_RD;

			when SP1C_Y_RD =>
				if SP1_EN = '1' and DE = '1' then --check one sprite/pixel, this matches the original HW behavior
					OBJ_CACHE_ADDR_RD_SP1 <= OBJ_NEXT;
					SP1C <= SP1C_Y_RD2;
				end if;

				if SP1_EN = '1' then
					SP1_STEPS <= SP1_STEPS + 1;
				end if;
				if SP1_STEPS = OBJ_MAX_FRAME then
					SP1C <= SP1C_DONE;
				end if;

			when SP1C_Y_RD2 =>
				SP1C <= SP1C_Y_RD3;

			when SP1C_Y_RD3 =>
				if LSM = "11" then
					y_offset := "0100000000" + SP1_Y - OBJ_CACHE_Q(9 downto 0);
					OBJ_Y_OFS <= y_offset(9 downto 1);
				else
					y_offset := "0010000000" + SP1_Y - ('0' & OBJ_CACHE_Q(8 downto 0));
					OBJ_Y_OFS <= y_offset(8 downto 0);
				end if;
				OBJ_VS1 <= OBJ_CACHE_Q(25 downto 24);
				OBJ_LINK <= OBJ_CACHE_Q(22 downto 16);
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
				hwrite(L, "000000" & OBJ_CACHE_Q(9 downto 0));
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
				-- check a total of 80 sprites in H40 mode and 64 sprites in H32 mode
				elsif OBJ_TOT = OBJ_MAX_FRAME - 1  or 
					 -- the following checks are inspired by the gens-ii emulator
						OBJ_LINK >= OBJ_MAX_FRAME or
						OBJ_LINK = "0000000"
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
					y_offset := "0100000000" + SP2_Y - OBJ_CACHE_Q(9 downto 0);
				else
					y_offset := "0010000000" + SP2_Y - ('0' & OBJ_CACHE_Q(8 downto 0));
				end if;
				--save only the last 5(6 in doubleres) bits of the offset for part 3
				--Titan 2 textured cube (ab)uses this
				OBJ_SPINFO_D(5 downto 0) <= y_offset(5 downto 0); --Y offset
				OBJ_SPINFO_D(7 downto 6) <= OBJ_CACHE_Q(25 downto 24); --VS
				OBJ_SPINFO_D(9 downto 8) <= OBJ_CACHE_Q(27 downto 26); --HS

				SP2_VRAM_ADDR <= (SATB(6 downto 0) & "00000000") + (OBJ_VISINFO_Q(6 downto 0) & "10");
				SP2_SEL <= '1';

				SP2C <= SP2C_RD;

			when SP2C_RD =>
				if SP2_VRAM32_ACK = '1' then
					SP2_SEL <= '0';
					OBJ_SPINFO_D(34) <= SP2_VRAM32_DO(15); --PRI
					OBJ_SPINFO_D(33 downto 32) <= SP2_VRAM32_DO(14 downto 13); --PAL
					OBJ_SPINFO_D(31) <= SP2_VRAM32_DO(12); --VF
					OBJ_SPINFO_D(30) <= SP2_VRAM32_DO(11); --HF
					OBJ_SPINFO_D(29 downto 19) <= SP2_VRAM32_DO(10 downto 0); --PAT
					OBJ_SPINFO_D(18 downto 10) <= SP2_VRAM32_DO(24 downto 16); --X
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
		SOVR_SET <= '0';

	elsif rising_edge(CLK) then

		SCOL_SET <= '0';
		SOVR_SET <= '0';

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
						SP3_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "00000");
					when "01" =>	-- 2*16 pixels
						SP3_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "000000");
					when "11" =>	-- 2*32 pixels
						SP3_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "0000000");
					when others =>	-- 2*24 pixels
						case OBJ_X_OFS(4 downto 3) is
						when "00" =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE;
						when "01" =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + "001100000";
						when "11" =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + "100100000";
						when others =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + "011000000";
						end case;
					end case;
				else
					case OBJ_VS is
					when "00" =>	-- 8 pixels
						SP3_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "0000");
					when "01" =>	-- 16 pixels
						SP3_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "00000");
					when "11" =>	-- 32 pixels
						SP3_VRAM_ADDR <= OBJ_TILEBASE + (OBJ_X_OFS(4 downto 3) & "000000");
					when others =>	-- 24 pixels
						case OBJ_X_OFS(4 downto 3) is
						when "00" =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE;
						when "01" =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + "00110000";
						when "11" =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + "10010000";
						when others =>
							SP3_VRAM_ADDR <= OBJ_TILEBASE + "01100000";
						end case;
					end case;
				end if;

				SP3_SEL <= '1';
				SP3C <= SP3C_TILE_RD;

			when SP3C_TILE_RD =>
				if SP3_VRAM32_ACK = '1' then
					SP3_SEL <= '0';
					SP3C <= SP3C_PLOT;
				end if;

			-- loop over all sprite pixels on the current line
			when SP3C_PLOT =>
				case OBJ_X_OFS(2 downto 0) is
				when "100" =>
					obj_color := SP3_VRAM32_DO(31 downto 28);
				when "101" =>
					obj_color := SP3_VRAM32_DO(27 downto 24);
				when "110" =>
					obj_color := SP3_VRAM32_DO(23 downto 20);
				when "111" =>
					obj_color := SP3_VRAM32_DO(19 downto 16);
				when "000" =>
					obj_color := SP3_VRAM32_DO(15 downto 12);
				when "001" =>
					obj_color := SP3_VRAM32_DO(11 downto  8);
				when "010" =>
					obj_color := SP3_VRAM32_DO( 7 downto  4);
				when "011" =>
					obj_color := SP3_VRAM32_DO( 3 downto  0);
				when others => null;
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
				if (OBJ_PIX = H_DISP_WIDTH AND OBJ_LIMIT_HIGH_EN = '0') OR (OBJ_PIX = H_TOTAL_WIDTH AND OBJ_LIMIT_HIGH_EN = '1') then
					OBJ_DOT_OVERFLOW <= '1';
					SP3C <= SP3C_DONE;
					SOVR_SET <= '1';
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
VBORDER_START   <= conv_std_logic_vector(VBORDER_START_PAL_V30, 9) when V30='1' and PAL='1'
              else conv_std_logic_vector(VBORDER_START_PAL_V28, 9) when V30='0' and PAL='1'
              else conv_std_logic_vector(VBORDER_START_NTSC_V30, 9) when V30='1' and PAL='0'
              else conv_std_logic_vector(VBORDER_START_NTSC_V28, 9);
VBORDER_END     <= conv_std_logic_vector(VBORDER_END_PAL_V30, 9) when V30='1' and PAL='1'
              else conv_std_logic_vector(VBORDER_END_PAL_V28, 9) when V30='0' and PAL='1'
              else conv_std_logic_vector(VBORDER_END_NTSC_V30, 9) when V30='1' and PAL='0'
              else conv_std_logic_vector(VBORDER_END_NTSC_V28, 9);
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
BG_Y <= Y & FIELD when LSM = "11" else HV_VCNT;
PRE_Y <= (Y + 1) & FIELD when LSM = "11" else HV_VCNT + 1;

HV_VCNT_EXT <= Y & FIELD_LATCH when LSM = "11" else HV_VCNT;
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
		-- Start the VCounter after VSYNC,
		-- thus various latches can be activated in VDPsim for the 1st frame
		HV_VCNT <= "111100101"; -- 485

		PRE_V_ACTIVE <= '0';
		V_ACTIVE <= '0';
		V_ACTIVE_DISP <= '0';

		EXINT_PENDING_SET <= '0';
		HINT_EN <= '0';
		HINT_PENDING_SET <= '0';
		VINT_TG68_PENDING_SET <= '0';
		VINT_T80_SET <= '0';
		VINT_T80_CLR <= '0';

		M_HBL <= '0';
		IN_HBL <= '0';
		IN_VBL <= '1';
		VBL_AREA <= '1';

		FIFO_EN <= '0';
		SLOT_EN <= '0';
		REFRESH_EN <= '0';

		SP1_EN <= '0';
		SP2_EN <= '0';

	elsif rising_edge(CLK) then

		EXINT_PENDING_SET <= '0';
		HINT_PENDING_SET <= '0';
		VINT_TG68_PENDING_SET <= '0';
		VINT_T80_SET <= '0';
		VINT_T80_CLR <= '0';
		FIFO_EN <= '0';
		SLOT_EN <= '0';
		REFRESH_EN <= '0';

		SP1_EN <= '0';
		SP2_EN <= '0';
		BGA_MAPPING_EN <= '0';
		--BGA_PATTERN_EN <= '0';
		BGB_MAPPING_EN <= '0';
		--BGB_PATTERN_EN <= '0';
		
		OLD_HL <= HL;
		if OLD_HL = '1' and HL = '0' then
			HV <= HV_VCNT_EXT(7 downto 1) & HV8 & HV_HCNT(8 downto 1);
			EXINT_PENDING_SET <= '1';
		end if;
		
		if M3 ='0' then	
			HV <= HV_VCNT_EXT(7 downto 1) & HV8 & HV_HCNT(8 downto 1);
		end if;

		-- H40 slow slots: 8aaaaaaa99aaaaaaa8aaaaaaa99aaaaaaa
		-- 8, 10, 10, 10, 10, 10, 10, 10, 9, 9, 10, 10, 10, 10, 10, 10, 10, 8, 10, 10, 10, 10, 10, 10, 10, 9, 9, 10, 10, 10, 10, 10, 10, 10
		-- 460                           468                               477                            485                            493

		HV_PIXDIV <= HV_PIXDIV + 1;
		if (RS0 = '1' and H40 = '1' and 
			((HV_PIXDIV = 8-1 and (HV_HCNT <= 460 or HV_HCNT > 493 or HV_HCNT = 477)) or
			((HV_PIXDIV = 9-1 and (HV_HCNT = 468 or HV_HCNT = 469 or HV_HCNT = 485 or HV_HCNT = 486))) or
			(HV_PIXDIV = 10-1))) or --normal H40 - 28*10+4*9+388*8=3420 cycles
		   (RS0 = '0' and H40 = '1' and HV_PIXDIV = 8-1) or --fast H40
		   (RS0 = '0' and H40 = '0' and HV_PIXDIV = 10-1) or --normal H32
		   (RS0 = '1' and H40 = '0' and HV_PIXDIV = 8-1) then --fast H32
			HV_PIXDIV <= (others => '0');
			if HV_HCNT = H_DISP_START + H_TOTAL_WIDTH - 1 then
				-- counter reset, originally HSYNC begins here
				HV_HCNT <= H_DISP_START;
			else
				HV_HCNT <= HV_HCNT + 1;
			end if;

			if HV_HCNT = H_INT_POS then
				if HV_VCNT = V_DISP_START + V_TOTAL_HEIGHT - 1 and --VDISP_START is negative
				   (V30 = '0' or PAL = '1') then -- NTSC with V30 will not reload the VCounter
					--just after VSYNC
					HV_VCNT <= V_DISP_START;
				else
					HV_VCNT <= HV_VCNT + 1;
				end if;

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

				if HV_VCNT = "1"&x"FE" then
					PRE_V_ACTIVE <= '1';
				elsif HV_VCNT = "1"&x"FF" then
					V_ACTIVE <= '1';
				elsif HV_VCNT = V_DISP_HEIGHT - 2 then
					PRE_V_ACTIVE <= '0';
				elsif HV_VCNT = V_DISP_HEIGHT - 1 then
					V_ACTIVE <= '0';
				end if;
			end if;

			if HV_HCNT = HBLANK_START then
				if HV_VCNT = 0 then
					V_ACTIVE_DISP <= '1';
				elsif HV_VCNT = V_DISP_HEIGHT then
					V_ACTIVE_DISP <= '0';
				end if;

				if HV_VCNT = VBORDER_START then
					VBL_AREA <= '0';
				end if;
				if HV_VCNT = VBORDER_END then
					VBL_AREA <= '1';
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
				M_HBL <= '0';
			end if;

			if HV_HCNT = HBLANK_START then -- blanking
				IN_HBL <= '1';
			end if;

			if HV_HCNT = HBLANK_START-3 then
				M_HBL <= '1';
			end if;

			if HV_HCNT = 0 then
				if HV_VCNT = V_INT_POS
				then
					FIELD <= not FIELD;
					VINT_TG68_PENDING_SET <= '1';
					VINT_T80_SET <= '1';
					VINT_T80_WAIT <= x"975";	--2422 MCLK
				end if;
			end if;

			-- VRAM Access slot enables

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

			case HV_HCNT(3 downto 0) is
				when "0010" => BGA_MAPPING_EN <= '1';
				when "0100" => null; -- external or refresh
				--when "0110" => BGA_PATTERN_EN <= '1';
				--when "1000" => BGA_PATTERN_EN <= '1';
				when "1010" => BGB_MAPPING_EN <= '1';
				when "1100" => SP2_EN <= '1';
				--when "1110" => BGB_PATTERN_EN <= '1';
				when "0000" =>
					--BGB_PATTERN_EN <= '1';
					if OBJ_LIMIT_HIGH_EN = '1' then
						SP2_EN <= '1'; -- Update SP2 twice as often when sprite limit is increased
					end if;
				when others => null;
			end case;

			SLOT_EN <= not HV_HCNT(0);
			if (IN_VBL = '1' or DE = '0') and REFRESH_SLOT = '1' then
				REFRESH_EN <= '1';
			end if;

		end if;
		
		if VINT_T80_WAIT = 0 then
			if VINT_T80_FF = '1' then
				VINT_T80_CLR <= '1';
			end if;
		else
			VINT_T80_WAIT <= VINT_T80_WAIT - 1;
		end if;
	end if;
end process;

-- TIMING MANAGEMENT
-- Background generation runs during active display.
-- It starts with reading the horizontal scroll values from the VRAM
BGEN_ACTIVATE <= '1' when V_ACTIVE = '1' and HV_HCNT = HSCROLL_READ + 8 else '0';

-- Stage 1 - runs after the vcounter incremented
-- Carefully choosing the starting position avoids the
-- "Your emulator suxx" in Titan I demo
SP1E_ACTIVATE <= '1' when PRE_V_ACTIVE = '1' and HV_HCNT = H_INT_POS + 1 else '0';
-- Stage 2 - runs in the active area
SP2E_ACTIVATE <= '1' when PRE_V_ACTIVE = '1' and HV_HCNT = 0 else '0';
-- Stage 3 runs 3 slots after the background rendering ends
SP3E_ACTIVATE <= '1' when PRE_V_ACTIVE = '1' and HV_HCNT = H_DISP_WIDTH + 5 else '0';

process( CLK )
	variable x : std_logic_vector(8 downto 0);
begin
	OBJ_COLINFO_D_REND <= (others => '0');
	if rising_edge(CLK) then

		if VBL_AREA = '0' then
			-- As displaying and sprite rendering (part 3) overlap,
			-- copy and clear the sprite buffer a bit sooner.
			-- also apply DE for the sprite layer here and 
			-- clear the colinfo buffer after rendering
			--
			-- A smaller buffer would be enough for the second copy, but
			-- it still uses only 1 BRAM block, and makes the logic simpler
			--
			case HV_PIXDIV is
			when "0000" =>
				x := HV_HCNT;
				OBJ_COLINFO_ADDR_RD_REND <= x;
				OBJ_COLINFO_ADDR_WR_REND <= x;
				OBJ_COLINFO2_ADDR_WR <= x;
				OBJ_COLINFO_WE_REND <= '0';
			when "0010" =>
				OBJ_COLINFO2_WE <= '1';
				if DE = '1' then
					OBJ_COLINFO2_D <= OBJ_COLINFO_Q_A;
				else
					OBJ_COLINFO2_D <= '0' & BGCOL;
				end if;
				OBJ_COLINFO_WE_REND <= '1';

			when "0011" =>
				OBJ_COLINFO2_WE <= '0';
				OBJ_COLINFO_WE_REND <= '0';
			when others => null;
			end case;
		end if;
	end if;
end process;

-- PIXEL COUNTER AND OUTPUT
process( RST_N, CLK )
	variable col : std_logic_vector(5 downto 0);
	variable cold: std_logic_vector(5 downto 0);
	variable x   : std_logic_vector(8 downto 0);
begin
	if rising_edge(CLK) then

		if IN_HBL = '1' or VBL_AREA = '1' then
				BGB_COLINFO_ADDR_B <= (others => '0');
				BGA_COLINFO_ADDR_B <= (others => '0');
				if HV_PIXDIV = "0101" then
					FF_R <= (others => '0');
					FF_G <= (others => '0');
					FF_B <= (others => '0');
				end if;
		else
			case HV_PIXDIV is
			when "0000" =>
				x := HV_HCNT - HBLANK_END - HBORDER_LEFT;
				BGB_COLINFO_ADDR_B <= x;
				BGA_COLINFO_ADDR_B <= x;
				OBJ_COLINFO2_ADDR_RD <= x;

			when "0010" =>
				if SHI = '1' and BGA_COLINFO_Q_B(6) = '0' and BGB_COLINFO_Q_B(6) = '0' then
					--if all layers are normal priority, then shadowed
					PIX_MODE <= PIX_SHADOW;
				else
					PIX_MODE <= PIX_NORMAL;
				end if;

			when "0011" =>
				if SHI = '1' and (OBJ_COLINFO2_Q(6) = '1' or
					((BGA_COLINFO_Q_B(6) = '0' or BGA_COLINFO_Q_B(3 downto 0) = "0000") and
					 (BGB_COLINFO_Q_B(6) = '0' or BGB_COLINFO_Q_B(3 downto 0) = "0000"))) then
					--sprite is visible
					if OBJ_COLINFO2_Q(5 downto 0) = "111110" then
						--if sprite is palette 3/color 14 increase intensity
						if PIX_MODE = PIX_SHADOW then 
							PIX_MODE <= PIX_NORMAL;
						else
							PIX_MODE <= PIX_HIGHLIGHT;
						end if;
					elsif OBJ_COLINFO2_Q(5 downto 0) = "111111" then
						-- if sprite is visible and palette 3/color 15, decrease intensity
						PIX_MODE <= PIX_SHADOW;
					elsif (OBJ_COLINFO2_Q(6) = '1' and OBJ_COLINFO2_Q(3 downto 0) /= "0000") or 
					       OBJ_COLINFO2_Q(3 downto 0) = "1110" then
						--sprite color 14 or high prio always shows up normal
						PIX_MODE <= PIX_NORMAL;
					end if;
				end if;

				if OBJ_COLINFO2_Q(3 downto 0) /= "0000" and OBJ_COLINFO2_Q(6) = '1' and
					(SHI='0' or OBJ_COLINFO2_Q(5 downto 1) /= "11111") and SPR_EN = '1' then
					col := OBJ_COLINFO2_Q(5 downto 0);
				elsif BGA_COLINFO_Q_B(3 downto 0) /= "0000" and BGA_COLINFO_Q_B(6) = '1' and BGA_EN = '1' then
					col := BGA_COLINFO_Q_B(5 downto 0);
				elsif BGB_COLINFO_Q_B(3 downto 0) /= "0000" and BGB_COLINFO_Q_B(6) = '1' and BGB_EN = '1' then
					col := BGB_COLINFO_Q_B(5 downto 0);
				elsif OBJ_COLINFO2_Q(3 downto 0) /= "0000" and
					(SHI='0' or OBJ_COLINFO2_Q(5 downto 1) /= "11111") and SPR_EN = '1' then
					col := OBJ_COLINFO2_Q(5 downto 0);
				elsif BGA_COLINFO_Q_B(3 downto 0) /= "0000" and BGA_EN = '1' then
					col := BGA_COLINFO_Q_B(5 downto 0);
				elsif BGB_COLINFO_Q_B(3 downto 0) /= "0000" and BGB_EN = '1' then
					col := BGB_COLINFO_Q_B(5 downto 0);
				else
					col := BGCOL;
				end if;

				if OBJ_COLINFO2_Q(3 downto 0) /= "0000" and OBJ_COLINFO2_Q(6) = '1' and (SHI='0' or OBJ_COLINFO2_Q(5 downto 1) /= "11111") then
					TRANSP_DETECT <= '0';
				elsif BGA_COLINFO_Q_B(6) = '1' and BGA_COLINFO_Q_B(7) = '1' then
					TRANSP_DETECT <= '1';
				elsif BGB_COLINFO_Q_B(6) = '1' and BGB_COLINFO_Q_B(7) = '1' then
					TRANSP_DETECT <= '1';
				elsif OBJ_COLINFO2_Q(3 downto 0) /= "0000" and (SHI='0' or OBJ_COLINFO2_Q(5 downto 1) /= "11111") then
					TRANSP_DETECT <= '0';
				else
					TRANSP_DETECT <= BGA_COLINFO_Q_B(7);
				end if;

				case DBG(8 downto 7) is
					when "00" => cold := BGCOL;
					when "01" => cold := OBJ_COLINFO2_Q(5 downto 0);
					when "10" => cold := BGA_COLINFO_Q_B(5 downto 0);
					when "11" => cold := BGB_COLINFO_Q_B(5 downto 0);
					when others => null;
				end case;

				if DBG(6) = '1' then
					col := cold;
				elsif DBG(8 downto 7) /= "00" then
					col := col and cold;
				end if;

				if x >= H_DISP_WIDTH or V_ACTIVE_DISP = '0' then
					-- border area
					col := BGCOL;
					PIX_MODE <= PIX_NORMAL;
				end if;

				CRAM_ADDR_B <= col;

			when "0101" =>
				if (x >= H_DISP_WIDTH or V_ACTIVE_DISP = '0') and (BORDER_EN = '0' or DBG(8 downto 7) /= "00") then
					-- disabled border
					FF_B <= (others => '0');
					FF_G <= (others => '0');
					FF_R <= (others => '0');
				else case PIX_MODE is
					when PIX_SHADOW =>
						-- half brightness
						FF_B <= '0' & CRAM_DATA(8 downto 6);
						FF_G <= '0' & CRAM_DATA(5 downto 3);
						FF_R <= '0' & CRAM_DATA(2 downto 0);

					when PIX_NORMAL =>
						-- normal brightness
						FF_B <= CRAM_DATA(8 downto 6) & '0';
						FF_G <= CRAM_DATA(5 downto 3) & '0';
						FF_R <= CRAM_DATA(2 downto 0) & '0';
					
					when PIX_HIGHLIGHT =>
						-- increased brightness
						FF_B <= '0' & CRAM_DATA(8 downto 6) + 7;
						FF_G <= '0' & CRAM_DATA(5 downto 3) + 7;
						FF_R <= '0' & CRAM_DATA(2 downto 0) + 7;
					end case;
				end if;
			
			when others => null;
			end case;

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
        VS <= '1';
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
        VS <= '0';
      end if;
    end if;
	 HS <= FF_HS;
  end if;  
end process;

R <= FF_R;
G <= FF_G;
B <= FF_B;

INTERLACE <= LSM(1) and LSM(0);
RESOLUTION <= V30&H40;

V_DISP_HEIGHT_R <= conv_std_logic_vector(V_DISP_HEIGHT_V30, 9) when V30_R ='1'
              else conv_std_logic_vector(V_DISP_HEIGHT_V28, 9);

process( CLK )
	variable V30prev : std_logic;
begin
	if rising_edge(CLK) then
		CE_PIX <= '0';
		if HV_PIXDIV = "0101" then

			if HV_HCNT = VSYNC_HSTART and HV_VCNT = VSYNC_START then
				FIELD_OUT <= LSM(1) and LSM(0) and not FIELD_LATCH;
			end if;

			V30prev := V30prev and V30;
			if HV_HCNT = H_INT_POS and HV_VCNT = 0 then
				V30_R <= V30prev;
				V30prev := '1';
			end if;

			CE_PIX <= '1';
			if BORDER_EN = '0' then
				if ((HV_HCNT - HBLANK_END - HBORDER_LEFT) >= H_DISP_WIDTH) then
					HBL <= '1';
				else
					HBL <= '0';
				end if;

				if HV_VCNT < V_DISP_HEIGHT_R then
					VBL <= '0';
				else
					VBL <= '1';
				end if;
			else
				HBL <= M_HBL;
				VBL <= VBL_AREA;
			end if;
		end if;
	end if;
end process;

----------------------------------------------------------------
-- VIDEO DEBUG
----------------------------------------------------------------
-- synthesis translate_off
process( CE_PIX )
	file F		: text open write_mode is "vdp.out";
	variable L	: line;
begin
	if rising_edge( CE_PIX ) then
		hwrite(L, FF_R & '0' & FF_G & '0' & FF_B & '0');
		writeline(F,L);
	end if;
end process;
-- synthesis translate_on

----------------------------------------------------------------
-- CPU INTERFACE & DATA TRANSFER CONTROLLER
----------------------------------------------------------------
DTACK_N <= FF_DTACK_N;
DO <= FF_DO;

VBUS_ADDR <= FF_VBUS_ADDR;
VBUS_SEL <= FF_VBUS_SEL;

FIFO_EMPTY <= '1' when FIFO_QUEUE = 0 and FIFO_PARTIAL = '0' else '0';
FIFO_FULL <= '1' when (FIFO_QUEUE(2) = '1') or (FIFO_QUEUE = 3 and FIFO_PARTIAL = '1') else '0';

process( RST_N, CLK )
-- synthesis translate_off
file F		: text open write_mode is "vdp_dbg.out";
variable L	: line;
-- synthesis translate_on
begin
	if RST_N = '0' then

		FF_DTACK_N <= '1';
		FF_DO <= (others => '1');

		PENDING <= '0';
		CODE <= (others => '0');

		DT_RD_SEL <= '0';
		DT_RD_DTACK_N <= '1';

		SOVR_CLR <= '0';
		SCOL_CLR <= '0';

		DBG <= (others => '0');

		REG <= (others => (others => '0'));

		ADDR <= (others => '0');
		
		DT_VRAM_SEL <= '0';
		
		FIFO_RD_POS <= "00";
		FIFO_WR_POS <= "00";
		FIFO_QUEUE <= "000";
		FIFO_PARTIAL <= '0';

		REFRESH_FLAG <= '0';

		FF_VBUS_ADDR <= (others => '0');
		FF_VBUS_SEL	<= '0';
		
		DMA_FILL <= '0';
		DMAF_SET_REQ <= '0';
		DMA_COPY <= '0';
		DMA_VBUS <= '0';
		DMA_SOURCE <= (others => '0');
		DMA_LENGTH <= (others => '0');
		
		DTC <= DTC_IDLE;
		DMAC <= DMA_IDLE;

		BR_N <= '1';
		BGACK_N_REG <= '1';

	elsif rising_edge(CLK) then

		if DT_RD_SEL = '0' then
			DT_RD_DTACK_N <= '1';
		end if;

		if SLOT_EN = '1' then
			if FIFO_DELAY(0) /= "00" then FIFO_DELAY(0) <= FIFO_DELAY(0) - 1; end if;
			if FIFO_DELAY(1) /= "00" then FIFO_DELAY(1) <= FIFO_DELAY(1) - 1; end if;
			if FIFO_DELAY(2) /= "00" then FIFO_DELAY(2) <= FIFO_DELAY(2) - 1; end if;
			if FIFO_DELAY(3) /= "00" then FIFO_DELAY(3) <= FIFO_DELAY(3) - 1; end if;
		end if;

		-- Extend CRAM write enable for CRAM dots
		if CE_PIX = '1' then
			CRAM_WE_A <= '0';
		end if;

		SOVR_CLR <= '0';
		SCOL_CLR <= '0';

		if SEL = '0' then
			FF_DTACK_N <= '1';
		elsif SEL = '1' and FF_DTACK_N = '1' then
			if RNW = '0' then -- Write
				if A(4 downto 2) = "000" then
					-- Data Port
					PENDING <= '0';

					if FIFO_FULL = '0' and DTC /= DTC_FIFO_RD and FF_DTACK_N = '1' then
						FIFO_ADDR( CONV_INTEGER( FIFO_WR_POS ) ) <= ADDR;
						FIFO_DATA( CONV_INTEGER( FIFO_WR_POS ) ) <= DI;
						FIFO_CODE( CONV_INTEGER( FIFO_WR_POS ) ) <= CODE(3 downto 0);
						FIFO_DELAY( CONV_INTEGER( FIFO_WR_POS ) ) <= "00"; -- should be delayed, too? (no, according to Zsenilla by RSE demo)
						FIFO_WR_POS <= FIFO_WR_POS + 1;
						FIFO_QUEUE <= FIFO_QUEUE + 1;
						ADDR <= ADDR + ADDR_STEP;
						FF_DTACK_N <= '0';
					end if;

				elsif A(4 downto 2) = "001" then
					-- Control Port
					if PENDING = '1' then
						CODE(4 downto 2) <= DI(6 downto 4);
						ADDR <= DI(2 downto 0) & ADDR(13 downto 0);

						if DMA = '1' then
							CODE(5) <= DI(7);
							if DI(7) = '1' then
								if REG(23)(7) = '0' then
									DMA_VBUS <= '1';
									BR_N <= '0';
								else
									if REG(23)(6) = '0' then
										DMA_FILL <= '1';
									else
										DMA_COPY <= '1';
									end if;
								end if;
							end if;
						end if;
						FF_DTACK_N <= '0';
						PENDING <= '0';
					else
						CODE(1 downto 0) <= DI(15 downto 14);
						if DI(15 downto 14) = "10" then
							-- Register Set
							if (M5 = '1' or DI(12 downto 8) <= 10) then
								-- mask registers above 10 in Mode4
								REG( CONV_INTEGER( DI(12 downto 8)) ) <= DI(7 downto 0);
							end if;
							FF_DTACK_N <= '0';
						else
							-- Address Set
							ADDR(13 downto 0) <= DI(13 downto 0);
							FF_DTACK_N <= '0';
							PENDING <= '1';
							CODE(5 downto 4) <= "00"; -- attempt to fix lotus i
						end if;
						-- Note : Genesis Plus does address setting
						-- even in Register Set mode. Normal ?
					end if;
				elsif A(4 downto 2) = "111" then
					DBG <= DI;
					FF_DTACK_N <= '0';
				elsif A(4 downto 3) = "10" then
					-- PSG
					FF_DTACK_N <= '0';
				else
					-- Unused (Lock-up)
					FF_DTACK_N <= '0';
				end if;
			else -- Read
				if A(4 downto 2) = "000" then
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
				elsif A(4 downto 2) = "001" then
					-- Control Port (Read Status Register)
					PENDING <= '0';
					FF_DO <= STATUS;
					SOVR_CLR <= '1';
					SCOL_CLR <= '1';
					FF_DTACK_N <= '0';
				elsif A(4 downto 3) = "01" then
					-- HV Counter
					FF_DO <= HV;
					FF_DTACK_N <= '0';
				elsif A(4) = '1' then
					-- unused, PSG, DBG
					FF_DO <= x"FFFF";
					FF_DTACK_N <= '0';
				end if;
			end if;
		end if;

		if SLOT_EN = '1' then
			if REFRESH_EN = '1' and DMA_VBUS = '1' and CODE(3 downto 0) /= "0001" then
				-- skip the slot after a refresh for DMA (except for VRAM write)
				REFRESH_FLAG <= '1';
			else
				REFRESH_FLAG <= '0';
			end if;
		end if;

		case DTC is
			when DTC_IDLE =>
				if FIFO_EN = '1' then
					FIFO_PARTIAL <= '0';
				end if;

				if VRAM_SPEED = '0' or (FIFO_EN = '1' and FIFO_PARTIAL = '0' and REFRESH_FLAG = '0') then
					if FIFO_EMPTY = '0' and FIFO_DELAY( CONV_INTEGER( FIFO_RD_POS ) ) = 0 then
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
				FIFO_QUEUE <= FIFO_QUEUE - 1;
				case FIFO_CODE( CONV_INTEGER( FIFO_RD_POS ) ) is
				when "0011" => -- CRAM Write
					DTC <= DTC_CRAM_WR;
				when "0101" => -- VSRAM Write
					DTC <= DTC_VSRAM_WR;
				when "0001" => -- VRAM Write
					if M128 = '0' then
						--skip next FIFO slot since we write 16 bit now instead of the original 8
						FIFO_PARTIAL <= '1';
					end if;
					DTC <= DTC_VRAM_WR1;
				when others => --invalid target
					DTC <= DTC_WR_END;
				end case;

			when DTC_VRAM_WR1 =>
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
				DT_VRAM_SEL <= not DT_VRAM_SEL;
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
					if DT_WR_ADDR(1) = '0' then
						VSRAM0_WE_A <= '1';
						VSRAM0_ADDR_A <= DT_WR_ADDR(6 downto 2);
						VSRAM0_D_A <= DT_WR_DATA(10 downto 0);
					else
						VSRAM1_WE_A <= '1';
						VSRAM1_ADDR_A <= DT_WR_ADDR(6 downto 2);
						VSRAM1_D_A <= DT_WR_DATA(10 downto 0);
					end if;
				end if;
				DTC <= DTC_WR_END;

			when DTC_WR_END =>
				VSRAM0_WE_A <= '0';
				VSRAM1_WE_A <= '0';
				if DMA_FILL = '1' then
					DMAF_SET_REQ <= '1';
				end if;
				DTC <= DTC_IDLE;

			when DTC_VRAM_RD1 =>
				DT_VRAM_SEL <= not DT_VRAM_SEL;
				DT_VRAM_ADDR <= '0'&ADDR(15 downto 1);
				DT_VRAM_RNW <= '1';
				DT_VRAM_UDS_N <= '0';
				DT_VRAM_LDS_N <= '0';
				DTC <= DTC_VRAM_RD2;
			
			when DTC_VRAM_RD2 =>
				if early_ack_dt='0' then
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
				VSRAM0_ADDR_A <= ADDR(6 downto 2);
				VSRAM1_ADDR_A <= ADDR(6 downto 2);
				DTC <= DTC_VSRAM_RD2;

			when DTC_VSRAM_RD2 =>
				DTC <= DTC_VSRAM_RD3;

			when DTC_VSRAM_RD3 =>
				if ADDR(6 downto 1) < 40 then
					if ADDR(1) = '0' then
						DT_RD_DATA <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) )(15 downto 11) & VSRAM0_Q_A;
					else
						DT_RD_DATA <= FIFO_DATA( CONV_INTEGER( FIFO_RD_POS ) )(15 downto 11) & VSRAM1_Q_A;
					end if;
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
			if FIFO_EMPTY = '1' and DMA_FILL = '1' and DMAF_SET_REQ = '1' then
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
				if FIFO_EMPTY = '1' and DTC = DTC_IDLE and DMAF_SET_REQ = '0' then
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
						if ADDR(1) = '0' then
							VSRAM0_WE_A <= '1';
							VSRAM0_ADDR_A <= ADDR(6 downto 2);
							VSRAM0_D_A <= DT_DMAF_DATA(10 downto 0);
						else
							VSRAM1_WE_A <= '1';
							VSRAM1_ADDR_A <= ADDR(6 downto 2);
							VSRAM1_D_A <= DT_DMAF_DATA(10 downto 0);
						end if;
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
					DT_VRAM_SEL <= not DT_VRAM_SEL;
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
					DMAC <= DMA_FILL_NEXT;
				end if;

			when DMA_FILL_NEXT =>
				VSRAM0_WE_A <= '0';
				VSRAM1_WE_A <= '0';
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
				DT_VRAM_SEL <= not DT_VRAM_SEL;
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
				DT_VRAM_SEL <= not DT_VRAM_SEL;
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
				DMA_VBUS_TIMER <= "10";
				DMAC <= DMA_VBUS_WAIT;

			when DMA_VBUS_WAIT =>
				if BG_N = '0' then
					BGACK_N_REG <= '0';
					BR_N <= '1';
				end if;
				if SLOT_EN = '1' then
					if DMA_VBUS_TIMER = 0 then
						if BGACK_N_REG = '0' then
							DMAC <= DMA_VBUS_RD;
							FF_VBUS_SEL <= '1';
							FF_VBUS_ADDR <= REG(23)(6 downto 0) & DMA_SOURCE;
						end if;
					else
						DMA_VBUS_TIMER <= DMA_VBUS_TIMER - 1;
					end if;
				end if;

			when DMA_VBUS_RD =>
				if VBUS_DTACK_N = '0' or FF_VBUS_SEL = '0' then
					FF_VBUS_SEL <= '0';
					if FF_VBUS_SEL = '1' then
						DT_DMAV_DATA <= VBUS_DATA;
					end if;
					if FIFO_FULL = '0' and DTC /= DTC_FIFO_RD then
						FIFO_ADDR( CONV_INTEGER( FIFO_WR_POS ) ) <= ADDR;
						if FF_VBUS_SEL = '1' then
							FIFO_DATA( CONV_INTEGER( FIFO_WR_POS ) ) <= VBUS_DATA;
						else
							FIFO_DATA( CONV_INTEGER( FIFO_WR_POS ) ) <= DT_DMAV_DATA;
						end if;
						FIFO_CODE( CONV_INTEGER( FIFO_WR_POS ) ) <= CODE(3 downto 0);
						FIFO_DELAY( CONV_INTEGER( FIFO_WR_POS ) ) <= "10";
						FIFO_WR_POS <= FIFO_WR_POS + 1;
						FIFO_QUEUE <= FIFO_QUEUE + 1;
						ADDR <= ADDR + ADDR_STEP;

						DMA_LENGTH <= DMA_LENGTH - 1;
						DMA_SOURCE <= DMA_SOURCE + 1;
						DMAC <= DMA_VBUS_LOOP;
					end if;
				end if;

			when DMA_VBUS_LOOP =>
				REG(20) <= DMA_LENGTH(15 downto 8);
				REG(19) <= DMA_LENGTH(7 downto 0);
				REG(22) <= DMA_SOURCE(15 downto 8);
				REG(21) <= DMA_SOURCE(7 downto 0);
				if DMA_LENGTH = 0 then
					DMA_VBUS_TIMER <= "01";
					DMAC <= DMA_VBUS_END;
-- synthesis translate_off										
					write(L, string'("VDP DMA VBUS END"));
					writeline(F,L);
-- synthesis translate_on										
				elsif SLOT_EN = '1' then
					FF_VBUS_SEL <= '1';
					FF_VBUS_ADDR <= REG(23)(6 downto 0) & DMA_SOURCE;
					DMAC <= DMA_VBUS_RD;
				end if;

			when DMA_VBUS_END =>
				if SLOT_EN = '1' then
					DMA_VBUS_TIMER <= DMA_VBUS_TIMER - 1;
					if DMA_VBUS_TIMER = 0 then
						DMA_VBUS <= '0';
						BGACK_N_REG <= '1';
						DMAC <= DMA_IDLE;
					end if;
				end if;
			when others => null;
		end case;
	end if;

end process;

----------------------------------------------------------------
-- INTERRUPTS AND VARIOUS LATCHES
----------------------------------------------------------------

-- HINT PENDING
process( RST_N, CLK )
begin
	if RST_N = '0' then
		EXINT_PENDING <= '0';
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
			elsif EXINT_FF = '1' then
				EXINT_PENDING <= '0';
			end if;
		end if;
		if EXINT_PENDING_SET = '1' then
			EXINT_PENDING <= '1';
		end if;
		if HINT_PENDING_SET = '1' then
			HINT_PENDING <= '1';
		end if;
		if VINT_TG68_PENDING_SET = '1' then
			VINT_TG68_PENDING <= '1';
		end if;
	end if;	
end process;

-- EXINT
EXINT <= EXINT_FF;
process( RST_N, CLK )
begin
	if RST_N = '0' then
		EXINT_FF <= '0';
	elsif rising_edge( CLK) then
		if EXINT_PENDING = '1' and IE2 = '1' then
			EXINT_FF <= '1';
		else
			EXINT_FF <= '0';
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
		if SOVR_SET = '1' then
			SOVR <= '1';
		elsif SOVR_CLR = '1' then
			SOVR <= '0';
		end if;
	end if;	
end process;

end rtl;

