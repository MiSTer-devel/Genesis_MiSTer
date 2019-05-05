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

package vdp_common is

constant VS_LINES               : integer := 4;

-- Timing values from the Exodus emulator in HV_HCNT and HV_VCNT values

constant H_DISP_START_H32       : integer := 466; -- -46
constant H_DISP_START_H40       : integer := 457; -- -55

constant HBLANK_END_H32         : integer := 9;
constant HBLANK_END_H40         : integer := 9;

constant HBLANK_START_H32       : integer := 293;
constant HBLANK_START_H40       : integer := 357;

constant H_TOTAL_WIDTH_H32      : integer := 342;
constant H_TOTAL_WIDTH_H40      : integer := 420;

constant HSYNC_START_H32        : integer := H_DISP_START_H32 + H_TOTAL_WIDTH_H32 - 512 - 6;
constant HSYNC_START_H40        : integer := H_DISP_START_H40 + H_TOTAL_WIDTH_H40 - 512 - 12;

constant HSYNC_END_H32          : integer := H_DISP_START_H32 + 24 - 6;  --498; -- -14
constant HSYNC_END_H40          : integer := H_DISP_START_H40 + 24 - 12; --492; -- -20

constant VSYNC_HSTART_H32       : integer := HSYNC_START_H32;
constant VSYNC_HSTART_H40       : integer := HSYNC_START_H40;

constant H_DISP_WIDTH_H32       : integer := 256;
constant H_DISP_WIDTH_H40       : integer := 320;

constant H_INT_H32              : integer := HBLANK_END_H32 + H_DISP_WIDTH_H32; -- 265
constant H_INT_H40              : integer := HBLANK_END_H40 + H_DISP_WIDTH_H40; -- 329

constant V_DISP_START_PAL_V28   : integer := 458;
constant V_DISP_START_NTSC_V28  : integer := 485; -- -27;
constant V_DISP_START_V30       : integer := 466; -- -46

constant V_DISP_HEIGHT_V28      : integer := 224;
constant V_DISP_HEIGHT_V30      : integer := 240;

constant V_INT_V28              : integer := 224;
constant V_INT_V30              : integer := 240;

constant VSYNC_START_PAL_V28	: integer := 458;
constant VSYNC_START_PAL_V30	: integer := 466;
constant VSYNC_START_NTSC_V28	: integer := 485;
constant VSYNC_START_NTSC_V30	: integer := 466;

constant NTSC_LINES             : integer := 262;
constant PAL_LINES              : integer := 313;

constant HSCROLL_READ_H32       : integer := 502;
constant HSCROLL_READ_H40       : integer := 502;

constant OBJ_MAX_FRAME_H32      : integer := 64;
constant OBJ_MAX_FRAME_H40      : integer := 80;

constant OBJ_MAX_LINE_H32       : integer := 16;
constant OBJ_MAX_LINE_H40       : integer := 20;

end vdp_common;
