-- -----------------------------------------------------------------------
--
-- Turbo Chameleon
--
-- Multi purpose FPGA expansion for the Commodore 64 computer
--
-- -----------------------------------------------------------------------
-- Copyright 2005-2011 by Peter Wendrich (pwsoft@syntiac.com)
-- All Rights Reserved.
--
-- Your allowed to re-use this file for non-commercial applications
-- developed for the Turbo Chameleon 64 cartridge. Either open or closed
-- source whatever might be required by other licenses.
--
-- http://www.syntiac.com/chameleon.html
-- -----------------------------------------------------------------------
--
-- SDRAM controller
--
-- -----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- -----------------------------------------------------------------------

entity chameleon_sdram is
	generic (
		-- SDRAM cols/rows  8/12 = 8 Mbyte, 9/12 = 16 Mbyte, 9/13 = 32 Mbyte
		colAddrBits : integer := 9;
		rowAddrBits : integer := 12;

		-- Controller settings
		writeBurst : boolean := false;  -- Warning: Set to True if using the cache port!
		initTimeout : integer := 10000;
	-- SDRAM timing
		casLatency : integer := 3;
		t_refresh_ms  : real := 64.0;
		t_ck_ns  : real := 10.0 -- Clock cycle time
	);
	port (
-- System
		clk : in std_logic;

		reserve : in std_logic := '0';
		delay_refresh : in std_logic := '0';

-- SDRAM interface
		sd_data : inout unsigned(15 downto 0);
		sd_addr : out unsigned((rowAddrBits-1) downto 0);
		sd_we_n : out std_logic;
		sd_ras_n : out std_logic;
		sd_cas_n : out std_logic;
		sd_ba_0 : out std_logic;
		sd_ba_1 : out std_logic;
		sd_ldqm : out std_logic;
		sd_udqm : out std_logic;

-- cache port
		cache_req : in std_logic;
		cache_ack : out std_logic;
		cache_we : in std_logic;
		cache_burst : in std_logic;
		cache_a : in unsigned((colAddrBits+rowAddrBits+2) downto 0);
		cache_d : in unsigned(63 downto 0);
		cache_q : out unsigned(63 downto 0);

-- VGA Video read ports
		vid0_req : in std_logic; -- Toggle for request
		vid0_ack : out std_logic; -- Ack follows req when done
		vid0_addr : unsigned((colAddrBits+rowAddrBits+2) downto 3);
		vid0_do : out unsigned(63 downto 0);

		vid1_rdStrobe : in std_logic; -- 1 clock pulse high to signal request
		vid1_busy : out std_logic; -- Port is busy and can't accept requests
		vid1_addr : unsigned((colAddrBits+rowAddrBits+2) downto 3);
		vid1_do : out unsigned(63 downto 0);

-- VIC-II video write port
		vicvid_wrStrobe : in std_logic; -- 1 clock pulse high to clock data in.
		vicvid_busy : out std_logic; -- Port is busy and can't accept requests
		vicvid_addr : unsigned((colAddrBits+rowAddrBits+2) downto 3);
		vicvid_di : in unsigned(63 downto 0);

-- 6510 port (8 bit port)
		cpu6510_ack : out std_logic; -- will follow 'request' after transfer
		cpu6510_request : in std_logic; -- toggle to start memory request
		cpu6510_we : in std_logic; -- 1 write action, 0 read action
		cpu6510_a : in unsigned((colAddrBits+rowAddrBits+2) downto 0);
		cpu6510_d : in unsigned(7 downto 0);
		cpu6510_q : out unsigned(7 downto 0);

-- REU port (8 bit port)
		reuStrobe : in std_logic; -- 1 clock pulse high to clock data in.
		reuBusy : out std_logic; -- Port is busy and can't accept requests
		reuWe : in std_logic; -- 1 write action, 0 read action
		reuA : in unsigned((colAddrBits+rowAddrBits+2) downto 0);
		reuD : in unsigned(7 downto 0);
		reuQ : out unsigned(7 downto 0);

-- 1541 drive cpu port (8 bit port)
		cpu1541_req : in std_logic;  -- Toggle for request
		cpu1541_ack : out std_logic; -- Ack follows req when done
		cpu1541_we : in std_logic; -- 1 write action, 0 read action
		cpu1541_a : in unsigned((colAddrBits+rowAddrBits+2) downto 0);
		cpu1541_d : in unsigned(7 downto 0);
		cpu1541_q : out unsigned(7 downto 0);

-- drive disk port (8 bit port)
--		rawdisk_busy : out std_logic; -- Port is busy and can't accept requests
--		rawdisk_strobe : in std_logic; -- 1 clock pulse high to clock data in.
--		rawdisk_we : in std_logic; -- 1 write action, 0 read action
--		rawdisk_a : in unsigned(23 downto 0);
--		rawdisk_d : in unsigned(7 downto 0);
--		rawdisk_q : out unsigned(7 downto 0);

-- RISC CPU port (64 bit port?)

-- Copper port (64 bit port?)

-- Blitter ports

--GE
		
		romwr_req : in std_logic;
		romwr_ack : out std_logic;
		romwr_we : in std_logic;
		romwr_a : in unsigned((colAddrBits+rowAddrBits+2) downto 1);
		romwr_d : in unsigned(15 downto 0);
		romwr_q : out unsigned(15 downto 0);
		
		romrd_req : in std_logic;
		romrd_ack : out std_logic;
		romrd_a : in unsigned((colAddrBits+rowAddrBits+2) downto 3);
		romrd_q : out unsigned(63 downto 0);

		ram68k_req : in std_logic;
		ram68k_ack : out std_logic;
		ram68k_we : in std_logic;
		ram68k_a : in unsigned((colAddrBits+rowAddrBits+2) downto 1);
		ram68k_d : in unsigned(15 downto 0);
		ram68k_q : out unsigned(15 downto 0);
		ram68k_u_n : in std_logic;
		ram68k_l_n : in std_logic;

		vram_req : in std_logic;
		vram_ack : out std_logic;
		vram_we : in std_logic;
		vram_a : in unsigned((colAddrBits+rowAddrBits+2) downto 1);
		vram_d : in unsigned(15 downto 0);
		vram_q : out unsigned(15 downto 0);
		vram_u_n : in std_logic;
		vram_l_n : in std_logic;
		
--GE Temporary
		initDone : out std_logic;
		
-- Debug ports
		debugIdle : out std_logic;  -- '1' memory is idle
		debugRefresh : out std_logic -- '1' memory is being refreshed
	);
end entity;

-- -----------------------------------------------------------------------

architecture rtl of chameleon_sdram is
	constant refresh_interval : integer := integer((t_refresh_ms*1000000.0) / (t_ck_ns * 2.0**rowAddrBits));
-- ram state machine
	type ramStates is (
		RAM_INIT,
		RAM_INIT_PRECHARGE,
		RAM_INITAUTO1,
		RAM_INITAUTO2,
		RAM_SETMODE,
		RAM_IDLE,
		
		RAM_ACTIVE,
		RAM_READ_1,
		RAM_READ_TERMINATEBURST,
		RAM_READ_2,
		RAM_READ_3,
		RAM_READ_4,
		RAM_READ_5,
		RAM_WRITE_1,
		RAM_WRITE_2,
		RAM_WRITE_3,
		RAM_WRITE_4,
		RAM_WRITE_ABORT,
		RAM_WRITE_DLY,
		
		HV_READ_1,
		HV_READ_2,
		HV_READ_3,
		HV_WRITE_1,
		HV_WRITE_2,
		
		RAM_PRECHARGE,
		RAM_PRECHARGE_ALL,
		RAM_AUTOREFRESH
	);
	
	type ramPorts is (
		PORT_NONE,
		PORT_CACHE,
		PORT_VID0,
		PORT_VID1,
		PORT_VICVID,
		PORT_CPU6510,
		PORT_REU,
		PORT_CPU_1541,
		PORT_ROMRD,
		PORT_ROMWR,
		PORT_RAM68K,
		PORT_VRAM
	);
	subtype row_t is unsigned((rowAddrBits-1) downto 0);
	subtype col_t is unsigned((colAddrBits-1) downto 0);
	
	signal ramTimer : integer range 0 to 32767;
	signal ramState : ramStates := RAM_INIT;
	signal ramAlmostDone : std_logic;
	signal ramDone : std_logic;
	
	signal ram_data_reg : unsigned(sd_data'range);

	signal cache_ack_reg : std_logic := '0';

-- Registered sdram signals
	signal sd_data_reg : unsigned(15 downto 0);
	signal sd_data_ena : std_logic := '0';
	signal sd_addr_reg : unsigned((rowAddrBits-1) downto 0);
	signal sd_we_n_reg : std_logic;
	signal sd_ras_n_reg : std_logic;
	signal sd_cas_n_reg : std_logic;
	signal sd_ba_0_reg : std_logic;
	signal sd_ba_1_reg : std_logic;
	signal sd_ldqm_reg : std_logic;
	signal sd_udqm_reg : std_logic;



-- ram busy signals
	signal vid0_ackReg : std_logic := '0';
--	signal vid0BusyReg : std_logic := '0';
	signal vid1BusyReg : std_logic := '0';
	signal cpu1541_ack_reg : std_logic := '0';

-- ram access scheduler
--	signal vid0_pending : std_logic := '0';
	signal vid1_pending : std_logic := '0';
	signal vicvid_pending : std_logic := '0';
	signal cpu6510_ackLoc : std_logic := '0';
	signal reu_pending : std_logic := '0';
--GE
	signal romwr_ackReg : std_logic := '0';
	signal romrd_ackReg : std_logic := '0';
	signal ram68k_ackReg : std_logic := '0';
	signal vram_ackReg : std_logic := '0';
	
--GE
	signal cpu6510_qReg : unsigned(7 downto 0);
	signal romwr_qReg : unsigned(15 downto 0);	
	signal romrd_qReg : unsigned(63 downto 0);
	signal ram68k_qReg : unsigned(15 downto 0);	
	signal vram_qReg : unsigned(15 downto 0);	
	
	signal initDoneReg : std_logic := '0';
	
-- RAM buffers
	signal vicvid_buffer : unsigned(63 downto 0);
	
-- Active rows in SDRAM
	type bankRowDef is array(0 to 3) of row_t;
	signal bankActive : std_logic_vector(0 to 3) := (others => '0');
	signal bankRow : bankRowDef;

-- Memory auto refresh
	constant refreshClocks : integer := 9;
	signal refreshTimer : integer range 0 to 2047 := 0;
	signal refreshActive : std_logic := '0';
	signal refreshSubtract : std_logic := '0';

	signal currentState : ramStates;
	signal currentPort : ramPorts;
	signal currentBank : unsigned(1 downto 0);
	signal currentRow : row_t;
	signal currentCol : col_t;
	signal currentRdData : unsigned(63 downto 0);
	signal currentWrData : unsigned(63 downto 0);
	signal currentLdqm : std_logic;
	signal currentUdqm : std_logic;
	signal currentBurst : std_logic;

	signal nextRamBank : unsigned(1 downto 0);
	signal nextRamRow : row_t;
	signal nextRamCol : col_t;
	signal nextRamPort : ramPorts;
	signal nextRamState : ramStates;
	signal nextLdqm : std_logic;
	signal nextUdqm : std_logic;
	signal nextBurst : std_logic;

	
	signal hv_a : std_logic_vector(13 downto 0);
	signal hv_d	: std_logic_vector(15 downto 0);
	signal hv_q	: std_logic_vector(15 downto 0);
	signal hv_we : std_logic;
	
	signal nextHvState : ramStates;
	signal nextHvAddr : std_logic_vector(13 downto 0);
	

constant useCache : boolean := false;
	
begin


-- hv : entity work.halfvram port map(
	-- address => hv_a,
	-- clock => clk,
	-- data => hv_d,
	-- wren => hv_we,
	-- q => hv_q
-- );

-- -----------------------------------------------------------------------

	ram_data_reg <= sd_data;

-- -----------------------------------------------------------------------
-- Refresh timer
	process(clk)
	begin
		if rising_edge(clk) then
			if refreshSubtract = '1' then
				refreshTimer <= refreshTimer - refresh_interval;
			else
-- synthesis translate_off
				if refreshTimer < 2047 then --GE
-- synthesis translate_on
					refreshTimer <= refreshTimer + 1;
-- synthesis translate_off
				end if;
-- synthesis translate_on
			end if;
		end if;
	end process;

-- -----------------------------------------------------------------------
-- State machine
	process(clk)
	begin
		--if rising_edge(clk) then
			nextRamState <= RAM_IDLE;
			nextRamPort <= PORT_NONE;
			nextRamBank <= "00";
			nextRamRow <= ( others => '0');
			nextRamCol <= ( others => '0');
			nextLdqm <= '0';
			nextUdqm <= '0';

			nextHvState <= RAM_IDLE;
			nextHvAddr <= (others => '0');
			
			if (romwr_req /= romwr_ackReg) and (currentPort /= PORT_ROMWR) then
				nextRamState <= RAM_READ_1;
				if romwr_we = '1' then
					nextRamState <= RAM_WRITE_1;
				end if;
				nextBurst <= '0';
				nextRamPort <= PORT_ROMWR;
				nextRamBank <= romwr_a((colAddrBits+rowAddrBits+2) downto (colAddrBits+rowAddrBits+1));
				nextRamRow <= romwr_a((colAddrBits+rowAddrBits) downto (colAddrBits+1));
				nextRamCol <= romwr_a(colAddrBits downto 1);

			elsif (vram_req /= vram_ackReg) and (currentPort /= PORT_VRAM) then
				nextRamState <= RAM_READ_1;
				if vram_we = '1' then
					nextRamState <= RAM_WRITE_1;
					nextLdqm <= vram_l_n;
					nextUdqm <= vram_u_n;
				end if;
				nextBurst <= '0';
				nextRamPort <= PORT_VRAM;
				nextRamBank <= vram_a((colAddrBits+rowAddrBits+2) downto (colAddrBits+rowAddrBits+1));
				nextRamRow <= vram_a((colAddrBits+rowAddrBits) downto (colAddrBits+1));
				nextRamCol <= vram_a(colAddrBits downto 1);
				
			elsif (romrd_req /= romrd_ackReg) and (currentPort /= PORT_ROMRD) then
				nextRamState <= RAM_READ_1;
				nextRamPort <= PORT_ROMRD;
				nextBurst <= '1';
				nextRamBank <= romrd_a((colAddrBits+rowAddrBits+2) downto (colAddrBits+rowAddrBits+1));
				nextRamRow <= romrd_a((colAddrBits+rowAddrBits) downto (colAddrBits+1));
				nextRamCol <= romrd_a(colAddrBits downto 3) & "00";

			elsif (ram68k_req /= ram68k_ackReg) and (currentPort /= PORT_RAM68K) then
				nextRamState <= RAM_READ_1;
				if ram68k_we = '1' then
					nextRamState <= RAM_WRITE_1;
					nextLdqm <= ram68k_l_n;
					nextUdqm <= ram68k_u_n;
				end if;
				nextBurst <= '0';
				nextRamPort <= PORT_RAM68K;
				nextRamBank <= ram68k_a((colAddrBits+rowAddrBits+2) downto (colAddrBits+rowAddrBits+1));
				nextRamRow <= ram68k_a((colAddrBits+rowAddrBits) downto (colAddrBits+1));
				nextRamCol <= ram68k_a(colAddrBits downto 1);
				
			elsif (cpu6510_request /= cpu6510_ackLoc) and (currentPort /= PORT_CPU6510) then
				nextRamState <= RAM_READ_1;
				if cpu6510_we = '1' then
					nextRamState <= RAM_WRITE_1;
					nextLdqm <= cpu6510_a(0);
					nextUdqm <= not cpu6510_a(0);
				end if;
				nextBurst <= '0';
				nextRamPort <= PORT_CPU6510;
				nextRamBank <= cpu6510_a((colAddrBits+rowAddrBits+2) downto (colAddrBits+rowAddrBits+1));
				nextRamRow <= cpu6510_a((colAddrBits+rowAddrBits) downto (colAddrBits+1));
				nextRamCol <= cpu6510_a(colAddrBits downto 1);

			elsif (cache_req /= cache_ack_reg) and (currentPort /= PORT_CACHE) then
				nextRamPort <= PORT_CACHE;
				nextRamBank <= cache_a((colAddrBits+rowAddrBits+2) downto (colAddrBits+rowAddrBits+1));
				nextRamRow <= cache_a((colAddrBits+rowAddrBits) downto (colAddrBits+1));
				nextRamCol <= cache_a(colAddrBits downto 1);
				if cache_burst = '1' then
					nextRamCol(1 downto 0) <= "00";
				end if;
				nextBurst <= cache_burst;  -- FIXME - AMR - untested

				nextRamState <= RAM_READ_1;
				if cache_we = '1' then
					nextRamState <= RAM_WRITE_1;
					if cache_burst = '0' then
						nextLdqm <= cache_a(0);
						nextUdqm <= not cache_a(0);
					end if;
				end if;
			elsif reserve = '0' then
				if reu_pending = '1' then
					nextRamState <= RAM_READ_1;
					if reuWe = '1' then
						nextRamState <= RAM_WRITE_1;
						nextLdqm <= reuA(0);
						nextUdqm <= not reuA(0);
					end if;
					nextBurst <= '0';
					nextRamPort <= PORT_REU;
					nextRamBank <= reuA((colAddrBits+rowAddrBits+2) downto (colAddrBits+rowAddrBits+1));
					nextRamRow <= reuA((colAddrBits+rowAddrBits) downto (colAddrBits+1));
					nextRamCol <= reuA(colAddrBits downto 1);
				elsif  (cpu1541_req /= cpu1541_ack_reg) and (currentPort /= PORT_CPU_1541) then
					nextRamState <= RAM_READ_1;
					if cpu1541_we = '1' then
						nextRamState <= RAM_WRITE_1;
						nextLdqm <= cpu1541_a(0);
						nextUdqm <= not cpu1541_a(0);
					end if;
					nextBurst <= '0';
					nextRamPort <= PORT_CPU_1541;
					nextRamBank <= cpu1541_a((colAddrBits+rowAddrBits+2) downto (colAddrBits+rowAddrBits+1));
					nextRamRow <= cpu1541_a((colAddrBits+rowAddrBits) downto (colAddrBits+1));
					nextRamCol <= cpu1541_a(colAddrBits downto 1);			
				elsif vicvid_pending = '1' then
					nextRamState <= RAM_WRITE_1;
					nextRamPort <= PORT_VICVID;
					nextRamBank <= vicvid_addr((colAddrBits+rowAddrBits+2) downto (colAddrBits+rowAddrBits+1));
					nextRamRow <= vicvid_addr((colAddrBits+rowAddrBits) downto (colAddrBits+1));
					nextRamCol <= vicvid_addr(colAddrBits downto 3) & "00";
					nextBurst <= '1'; -- FIXME - AMR - untested
				elsif (vid0_req /= vid0_ackReg) and (currentPort /= PORT_VID0) then
					nextRamState <= RAM_READ_1;
					nextRamPort <= PORT_VID0;
					nextBurst <= '1';
					nextRamBank <= vid0_addr((colAddrBits+rowAddrBits+2) downto (colAddrBits+rowAddrBits+1));
					nextRamRow <= vid0_addr((colAddrBits+rowAddrBits) downto (colAddrBits+1));
					nextRamCol <= vid0_addr(colAddrBits downto 3) & "00";
				elsif vid1_pending = '1' then
					nextRamState <= RAM_READ_1;
					nextRamPort <= PORT_VID1;
					nextBurst <= '1';
					nextRamBank <= vid1_addr((colAddrBits+rowAddrBits+2) downto (colAddrBits+rowAddrBits+1));
					nextRamRow <= vid1_addr((colAddrBits+rowAddrBits) downto (colAddrBits+1));
					nextRamCol <= vid1_addr(colAddrBits downto 3) & "00";
				end if;
			end if;
		--end if;		
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			sd_data <= (others => 'Z');
			if sd_data_ena = '1' then
				sd_data <= sd_data_reg;
			end if;
			sd_addr <= sd_addr_reg;
			sd_ras_n <= sd_ras_n_reg;
			sd_cas_n <= sd_cas_n_reg;
			sd_we_n <= sd_we_n_reg;
			sd_ba_0 <= sd_ba_0_reg;
			sd_ba_1 <= sd_ba_1_reg;
			sd_ldqm <= sd_ldqm_reg;
			sd_udqm <= sd_udqm_reg;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			refreshSubtract <= '0';
			ramAlmostDone <= '0';
			ramDone <= '0';
			sd_data_ena <= '0';
			sd_addr_reg <= (others => '0');
			sd_ras_n_reg <= '1';
			sd_cas_n_reg <= '1';
			sd_we_n_reg <= '1';
			
			sd_ba_0_reg <= '0';
			sd_ba_1_reg <= '0';

			sd_ldqm_reg <= '0';
			sd_udqm_reg <= '0';
			
			hv_we <= '0';

			if ramTimer /= 0 then
				ramTimer <= ramTimer - 1;
			else
				case ramState is
				when RAM_INIT =>
					-- Wait for clock to stabilise and PLL locks
					-- Then follow init steps in datasheet:
					--   precharge all banks
					--   perform a few autorefresh cycles (we do 2 of them)
					--   setmode (burst and CAS latency)
					--   after a few clocks ram is ready for use (we wait 10 just to be sure).
					ramTimer <= 20000;
					ramState <= RAM_INIT_PRECHARGE;
				when RAM_INIT_PRECHARGE =>
					-- Precharge all banks, part of initialisation sequence.
					ramTimer <= 100;
					ramState <= RAM_INITAUTO1;
					sd_ras_n_reg <= '0';
					sd_we_n_reg <= '0';
					sd_addr_reg(10) <= '1'; -- precharge all banks
				when RAM_INITAUTO1 =>
					-- refresh cycle to init ram (1st)
					ramTimer <= 10;
					ramState <= RAM_INITAUTO2;
					sd_we_n_reg <= '0';
					sd_ras_n_reg <= '0';
					sd_cas_n_reg <= '0';				
				when RAM_INITAUTO2 =>
					-- refresh cycle to init ram (2nd)
					ramTimer <= 10;
					ramState <= RAM_SETMODE;
					sd_we_n_reg <= '0';
					sd_ras_n_reg <= '0';
					sd_cas_n_reg <= '0';
				when RAM_SETMODE =>
					-- Set mode bits of RAM.
					ramTimer <= 10;
					ramState <= RAM_IDLE; -- ram is ready for commands after set-mode
					if writeBurst=true then
						sd_addr_reg <= resize("000000100010", sd_addr'length); -- CAS2, Burstlength 4 (8 bytes, 64 bits)
					else
						sd_addr_reg <= resize("001000100010", sd_addr'length); -- CAS2, Burstlength 4 (8 bytes, 64 bits), no burst on writes
					end if;

					if casLatency = 3 then
						sd_addr_reg(6 downto 4) <= "011";
					end if;
					sd_we_n_reg <= '0';
					sd_ras_n_reg <= '0';
					sd_cas_n_reg <= '0';
				when RAM_IDLE =>
					initDoneReg <= '1'; --GE
					refreshActive <= '0';
					currentPort <= PORT_NONE;
					if nextRamState /= RAM_IDLE then
						currentState <= nextRamState;
						currentPort <= nextRamPort;
						currentBank <= nextRamBank;
						currentRow <= nextRamRow;
						currentCol <= nextRamCol;
						currentLdqm <= nextLdqm;
						currentUdqm <= nextUdqm;
						currentBurst <= nextBurst;
						
						case nextRamPort is
						when PORT_CACHE =>
							currentWrData <= cache_d;
						when PORT_CPU6510 =>
							currentWrData(15 downto 0) <= cpu6510_d & cpu6510_d;
						when PORT_REU =>
							currentWrData(15 downto 0) <= reuD & reuD;
						when PORT_VICVID =>
							currentWrData <= vicvid_buffer;
						when PORT_CPU_1541 =>
							currentWrData(15 downto 0) <= cpu1541_d & cpu1541_d;
						when PORT_ROMWR =>
							currentWrData(15 downto 0) <= romwr_d;
						when PORT_RAM68K =>
							currentWrData(15 downto 0) <= ram68k_d;						
						when PORT_VRAM =>
							currentWrData(15 downto 0) <= vram_d;													
						when others =>
							null;
						end case;

						ramState <= nextRamState;
						if bankActive(to_integer(nextRamBank)) = '0' then
							-- Current bank not active. Activate a row first
							ramState <= RAM_ACTIVE;
						elsif bankRow(to_integer(nextRamBank)) /= nextRamRow then
							-- Wrong row active in bank, do precharge then activate a row.
							ramState <= RAM_PRECHARGE;
						end if;
					elsif (delay_refresh = '0') and (reserve = '0') and (refreshTimer > refresh_interval) then
						-- Refresh timeout, perform auto-refresh cycle
						refreshActive <= '1';
						refreshSubtract <= '1';
						if bankActive /= "0000" then
							-- There are still rows active, so we precharge them first							
							ramState <= RAM_PRECHARGE_ALL;
						else
							ramState <= RAM_AUTOREFRESH;
						end if;
					-- elsif nextHvState /= RAM_IDLE then
						-- currentState <= nextHvState;
						-- currentPort <= nextRamPort;
						-- ramState <= nextHvState;
						-- hv_a <= nextHvAddr;
						-- case nextRamPort is
						-- when PORT_VDCCPU => --GE
							-- hv_d <= std_logic_vector(vdccpu_d);
						-- when PORT_VDCDMA => --GE
							-- hv_d <= std_logic_vector(vdcdma_d);
						-- when others =>
							-- null;
						-- end case;
					end if;
				when RAM_ACTIVE =>
					ramTimer <= 2;
					ramState <= currentState;
					sd_addr_reg <= currentRow;
					sd_ras_n_reg <= '0';
					sd_ba_0_reg <= currentBank(0);
					sd_ba_1_reg <= currentBank(1);
					bankRow(to_integer(currentBank)) <= currentRow;
					bankActive(to_integer(currentBank)) <= '1';
				when RAM_READ_1 =>
					if currentBurst='1' then
						ramTimer <= casLatency + 1;
						ramState <= RAM_READ_2;
					else
						ramState <= RAM_READ_TERMINATEBURST;
					end if;
					sd_addr_reg <= resize(currentCol, sd_addr'length);
					--GE sd_addr_reg <= resize(currentCol, sd_addr'length) or resize("10000000000", sd_addr'length); --GE Auto precharge
					sd_cas_n_reg <= '0';
					sd_ba_0_reg <= currentBank(0);
					sd_ba_1_reg <= currentBank(1);
				when RAM_READ_TERMINATEBURST =>
					ramTimer <= casLatency;
					ramState <= RAM_READ_2;
					sd_we_n_reg <= '0';	-- Terminate Burst
					sd_ba_0_reg <= currentBank(0);
					sd_ba_1_reg <= currentBank(1);
				when RAM_READ_2 =>
					if currentBurst='1' then
						ramState <= RAM_READ_3;
					else
						ramDone <='1';
						ramState <= RAM_IDLE;
					end if;
					currentRdData(15 downto 0) <= ram_data_reg;
					case currentPort is
					when PORT_CPU6510 =>
						cpu6510_qReg <= ram_data_reg(7 downto 0); --GE
						if cpu6510_a(0) = '1' then
							cpu6510_qReg <= ram_data_reg(15 downto 8); --GE
						end if;
					when PORT_REU =>
						reuQ <= ram_data_reg(7 downto 0);
						if reuA(0) = '1' then
							reuQ <= ram_data_reg(15 downto 8);
						end if;
					when PORT_CPU_1541 =>
						cpu1541_q <= ram_data_reg(7 downto 0);
						if cpu1541_a(0) = '1' then
							cpu1541_q <= ram_data_reg(15 downto 8);
						end if;
					when PORT_ROMWR => --GE
						romwr_qReg <= ram_data_reg;
					when PORT_RAM68K => --GE
						ram68k_qReg <= ram_data_reg;
					when PORT_VRAM => --GE
						vram_qReg <= ram_data_reg;
					when others =>
						null;
					end case;
				when RAM_READ_3 =>
					ramState <= RAM_READ_4;
					currentRdData(31 downto 16) <= ram_data_reg;
				when RAM_READ_4 =>
					ramState <= RAM_READ_5;
					currentRdData(47 downto 32) <= ram_data_reg;
					ramAlmostDone <= '1';
				when RAM_READ_5 =>
					currentRdData(63 downto 48) <= ram_data_reg;
					ramState <= RAM_IDLE;
-- /!\
					case currentPort is
					when PORT_CPU6510 | PORT_REU | PORT_CPU_1541 
						| PORT_ROMWR | PORT_RAM68K | PORT_VRAM => --GE
						null;
					when others =>
						ramDone <= '1';
					end case;
-- /!\
				when RAM_WRITE_1 =>
					ramState <= RAM_WRITE_2;
					sd_data_ena <= '1';
					sd_we_n_reg <= '0';
					sd_cas_n_reg <= '0';
					sd_ba_0_reg <= currentBank(0);
					sd_ba_1_reg <= currentBank(1);

					sd_addr_reg <= resize(currentCol, sd_addr'length);
					--GE sd_addr_reg <= resize(currentCol, sd_addr'length) or resize("10000000000", sd_addr'length); --GE Auto precharge

					sd_data_reg <= currentWrData(15 downto 0);
					sd_ldqm_reg <= currentLdqm;
					sd_udqm_reg <= currentUdqm;
-- /!\
					if writeBurst=false then	-- Are we writing in single word mode?
						ramState<=RAM_IDLE;
						ramDone<='1';
					else
						if currentLdqm = '1'
						or currentUdqm = '1' 
						or currentPort = PORT_ROMWR --GE
						or currentPort = PORT_RAM68K --GE
						or currentPort = PORT_VRAM --GE					
						then
							-- This is a partial write, abort burst.
							ramState <= RAM_WRITE_ABORT;
						end if;
					end if;
				when RAM_WRITE_2 =>
					ramState <= RAM_WRITE_3;
					sd_data_ena <= '1';
					sd_data_reg <= currentWrData(31 downto 16);
				when RAM_WRITE_3 =>
					ramState <= RAM_WRITE_4;
					sd_data_ena <= '1';
					sd_data_reg <= currentWrData(47 downto 32);
				when RAM_WRITE_4 =>
					ramState <= RAM_WRITE_DLY;
					sd_data_ena <= '1';
					sd_data_reg <= currentWrData(63 downto 48);
				when RAM_WRITE_ABORT =>
					ramState <= RAM_WRITE_DLY;
					sd_we_n_reg <= '0';
				when RAM_WRITE_DLY =>
					ramState <= RAM_IDLE;
					ramAlmostDone <= '1';
					ramDone <= '1';
				when RAM_PRECHARGE =>
					ramTimer <= 2;
					ramState <= RAM_ACTIVE;
					sd_we_n_reg <= '0';
					sd_ras_n_reg <= '0';				
					sd_ba_0_reg <= currentBank(0);
					sd_ba_1_reg <= currentBank(1);
					bankActive(to_integer(currentBank)) <= '0';
				when RAM_PRECHARGE_ALL =>
					ramTimer <= 2;
					ramState <= RAM_IDLE;
					if refreshActive = '1' then
						ramTimer <= 1;
						ramState <= RAM_AUTOREFRESH;
					end if;
					sd_addr_reg(10) <= '1'; -- All banks
					sd_we_n_reg <= '0';
					sd_ras_n_reg <= '0';				
					bankActive <= "0000";
				when RAM_AUTOREFRESH =>
					ramTimer <= refreshClocks;
					ramState <= RAM_IDLE;
					sd_we_n_reg <= '1';
					sd_ras_n_reg <= '0';
					sd_cas_n_reg <= '0';

				-- when HV_WRITE_1 =>
					-- hv_we <= '1';
					-- ramState <= HV_WRITE_2;
				-- when HV_WRITE_2 =>
					-- ramDone <= '1';
					-- ramState <= RAM_IDLE;
				
				-- when HV_READ_1 =>
					-- ramState <= HV_READ_2;
				-- when HV_READ_2 =>
					-- ramState <= HV_READ_3;
				-- when HV_READ_3 =>
					-- -- ramDone <= '1';
					-- ramState <= RAM_IDLE;
					-- case currentPort is
					-- when PORT_VDCCPU => --GE
						-- vdccpu_qReg <= unsigned(hv_q);
						-- ramDone <= '1';
					-- when PORT_VDCDMA => --GE
						-- vdcdma_qReg <= unsigned(hv_q);
						-- ramDone <= '1';					
					-- when PORT_VDCSP => --GE
						-- vdcsp_qReg <= unsigned(hv_q);
						-- ramDone <= '1';					
					-- when PORT_VDCBG => --GE
						-- vdcbg_qReg <= unsigned(hv_q);
						-- ramDone <= '1';					
					-- when PORT_VDCDMAS => --GE
						-- vdcdmas_qReg <= unsigned(hv_q);
						-- ramDone <= '1';					
					-- when others =>
						-- null;
					-- end case;
				when others => null;
					
				end case;
			end if;
		end if;
	end process;

-- -----------------------------------------------------------------------
-- Debug and measurement signals
	debugIdle <= '1' when ((refreshActive = '0') and (ramState = RAM_IDLE)) else '0';
	debugRefresh <= refreshActive;

-- -----------------------------------------------------------------------
-- cache port
	process(clk)
	begin
		if rising_edge(clk) then
			if currentPort = PORT_CACHE
			and ramDone = '1' then
				cache_ack_reg <= cache_req;
				cache_q <= currentRdData;
			end if;
		end if;
	end process;
	cache_ack <= cache_ack_reg;

-- -----------------------------------------------------------------------
-- vid0 port
	process(clk)
	begin
		if rising_edge(clk) then
			if currentPort = PORT_VID0
			and ramDone = '1' then
				vid0_ackReg <= not vid0_ackReg;
				vid0_do <= currentRdData;
			end if;
		end if;
	end process;
	vid0_ack <= vid0_ackReg;

-- -----------------------------------------------------------------------
-- vid1 port
	process(clk)
	begin
		if rising_edge(clk) then
			if currentPort = PORT_VID1
			and ramAlmostDone = '1' then
				vid1_pending <= '0';
			end if;
			if currentPort = PORT_VID1
			and ramDone = '1' then
				vid1_do <= currentRdData;
				vid1BusyReg <= '0';
			end if;
			if vid1_rdStrobe = '1' then
				vid1_pending <= '1';
				vid1BusyReg <= '1';
			end if;
		end if;
	end process;
	vid1_busy <= vid1BusyReg or vid1_rdStrobe;

-- -----------------------------------------------------------------------
-- vicvid port
	process(clk)
	begin
		if rising_edge(clk) then
			if vicvid_wrStrobe = '1' then
				vicvid_buffer <= vicvid_di;
				vicvid_pending <= '1';
			end if;
			if currentPort = PORT_VICVID
			and ramDone = '1' then
				vicvid_pending <= '0';
			end if;
		end if;
	end process;
	vicvid_busy <= vicvid_pending or vicvid_wrStrobe;

-- -----------------------------------------------------------------------
-- cpu0 port
	process(clk)
	begin
		if rising_edge(clk) then
			if currentPort = PORT_CPU6510
			and ramDone = '1' then
				cpu6510_ackLoc <= not cpu6510_ackLoc;
			end if;
		end if;
	end process;
	cpu6510_ack <= cpu6510_ackLoc;
	cpu6510_q <= cpu6510_qReg; --GE
	
-- -----------------------------------------------------------------------
-- REU port
	process(clk)
	begin
		if rising_edge(clk) then
			if currentPort = PORT_REU
			and ramDone = '1' then
				reu_pending <= '0';
			end if;
			if reuStrobe = '1' then
				reu_pending <= '1';
			end if;
		end if;
	end process;
	reuBusy <= reu_pending or reuStrobe;

-- -----------------------------------------------------------------------
-- 1541 drive cpu port
	process(clk)
	begin
		if rising_edge(clk) then
			if currentPort = PORT_CPU_1541
			and ramDone = '1' then
				cpu1541_ack_reg <= cpu1541_req;
			end if;
		end if;
	end process;
	cpu1541_ack <= cpu1541_ack_reg;

	
--GE -----------------------------------------------------------------------
	
	process(clk)
	begin
		if rising_edge(clk) then
			if currentPort = PORT_ROMWR
			and ramDone = '1' then
				romwr_ackReg <= not romwr_ackReg;
			end if;
		end if;
	end process;
	romwr_ack <= romwr_ackReg;
	romwr_q <= romwr_qReg; --GE

	process(clk)
	begin
		if rising_edge(clk) then
			if currentPort = PORT_ROMRD
			and ramDone = '1' then
				romrd_ackReg <= not romrd_ackReg;
				romrd_qReg <= currentRdData;
			end if;
		end if;
	end process;
	romrd_ack <= romrd_ackReg;
	romrd_q <= romrd_qReg; --GE


	process(clk)
	begin
		if rising_edge(clk) then
			if currentPort = PORT_RAM68K
			and ramDone = '1' then
				ram68k_ackReg <= not ram68k_ackReg;
			end if;
		end if;
	end process;
	ram68k_ack <= ram68k_ackReg;
	ram68k_q <= ram68k_qReg; --GE

	process(clk)
	begin
		if rising_edge(clk) then
			if currentPort = PORT_VRAM
			and ramDone = '1' then
				vram_ackReg <= not vram_ackReg;
			end if;
		end if;
	end process;
	vram_ack <= vram_ackReg;
	vram_q <= vram_qReg; --GE




	
	initDone <= initDoneReg; --Ge
	
end architecture;
