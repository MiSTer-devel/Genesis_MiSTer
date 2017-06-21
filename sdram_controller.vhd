library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- -----------------------------------------------------------------------

entity sdram_controller is
	generic (
		colAddrBits : integer := 9;
		rowAddrBits : integer := 13
	);
	port (
		-- System
		clk : in std_logic;

		-- SDRAM interface
		sd_data : inout unsigned(15 downto 0);
		sd_addr : out unsigned(rowAddrBits-1 downto 0);
		sd_we_n : out std_logic;
		sd_ras_n : out std_logic;
		sd_cas_n : out std_logic;
		sd_ba_0 : out std_logic;
		sd_ba_1 : out std_logic;
		sd_ldqm : out std_logic;
		sd_udqm : out std_logic;

		ram68k_req : in std_logic;
		ram68k_ack : out std_logic;
		ram68k_we : in std_logic;
		ram68k_a : in std_logic_vector(15 downto 1);
		ram68k_d : in std_logic_vector(15 downto 0);
		ram68k_q : out std_logic_vector(15 downto 0);
		ram68k_u_n : in std_logic;
		ram68k_l_n : in std_logic;

		vram_req : in std_logic;
		vram_ack : out std_logic;
		vram_we : in std_logic;
		vram_a : in std_logic_vector(15 downto 1);
		vram_d : in std_logic_vector(15 downto 0);
		vram_q : out std_logic_vector(15 downto 0);
		vram_u_n : in std_logic;
		vram_l_n : in std_logic;
		
		romwr_req : in std_logic;
		romwr_ack : out std_logic;
		romwr_a : in std_logic_vector(21 downto 1);
		romwr_d : in std_logic_vector(15 downto 0);
		
		romrd_req : in std_logic;
		romrd_ack : out std_logic;
		romrd_a : in std_logic_vector(21 downto 3);
		romrd_q : out std_logic_vector(63 downto 0);

		
--GE Temporary
		initDone : out std_logic
	);
end entity;

-- -----------------------------------------------------------------------

architecture rtl of sdram_controller is

	constant addrwidth : integer := rowAddrBits+colAddrBits+2;

	signal romrd_a_u : unsigned(addrwidth downto 3);
	signal romrd_q_u : unsigned(63 downto 0);
	
	signal romwr_a_u : unsigned(addrwidth downto 1);
	signal romwr_d_u : unsigned(15 downto 0);

	signal ram68k_a_u : unsigned(addrwidth downto 1);
	signal ram68k_d_u : unsigned(15 downto 0);
	signal ram68k_q_u : unsigned(15 downto 0);

	signal vram_a_u : unsigned(addrwidth downto 1);
	signal vram_d_u : unsigned(15 downto 0);
	signal vram_q_u : unsigned(15 downto 0);

	
begin
	
	romrd_a_u <= unsigned(std_logic_vector(to_unsigned(0, addrwidth - 21)) & romrd_a);
	romrd_q <= std_logic_vector(romrd_q_u);
	
	romwr_a_u <= unsigned(std_logic_vector(to_unsigned(0, addrwidth - 21)) & romwr_a);
	romwr_d_u <= unsigned(romwr_d);

	ram68k_a_u <= unsigned(std_logic_vector(to_unsigned(2#1000000#, addrwidth - 15)) & ram68k_a);
	ram68k_d_u <= unsigned(ram68k_d);
	ram68k_q <= std_logic_vector(ram68k_q_u);

	vram_a_u <= unsigned(std_logic_vector(to_unsigned(2#1100000#, addrwidth - 15)) & vram_a);
	vram_d_u <= unsigned(vram_d);
	vram_q <= std_logic_vector(vram_q_u);
	
-- -----------------------------------------------------------------------
-- SDRAM Controller
-- -----------------------------------------------------------------------
	sdr : entity work.chameleon_sdram
		generic map (
			casLatency => 2,
--			casLatency => 3,
			colAddrBits => colAddrBits,
			rowAddrBits => rowAddrBits,

--			t_ck_ns => 10.0
--			t_ck_ns => 6.7

--			t_ck_ns => 7.9

--			t_ck_ns => 8.4
--			t_ck_ns => 8.0
			t_ck_ns => 9.3

--			t_ck_ns => 12.0
--			t_ck_ns => 12.5

--			t_ck_ns => 23.5
--			t_ck_ns => 8.3	
		)
		port map (
			clk => clk,

			reserve => '0',

			sd_data => sd_data,
			sd_addr => sd_addr,
			sd_we_n => sd_we_n,
			sd_ras_n => sd_ras_n,
			sd_cas_n => sd_cas_n,
			sd_ba_0 => sd_ba_0,
			sd_ba_1 => sd_ba_1,
			sd_ldqm => sd_ldqm,
			sd_udqm => sd_udqm,
			
			cache_req => '0',
			cache_ack => open,
			cache_we => '0',
			cache_burst => '0',
			cache_a => (others => '0'),
			cache_d => (others => '0'),
			cache_q => open,
			
			vid0_req => '0',
			vid0_ack => open,
			vid0_addr => (others => '0'),
			vid0_do => open,

			vid1_rdStrobe => '0',
			vid1_busy => open,
			vid1_addr => (others => '0'),
			vid1_do => open,
			
			vicvid_wrStrobe => '0',
			vicvid_addr => (others => '0'),
			vicvid_di => (others => '0'),
			
			cpu6510_request => '0',
			cpu6510_ack => open,
			cpu6510_we => '0',
			cpu6510_a => (others => '0'),
			cpu6510_d => (others => '0'),
			cpu6510_q => open,

			reuStrobe => '0',
			reuBusy => open,
			reuWe => '0',
			reuA => (others => '0'),
			reuD => (others => '0'),
			reuQ => open,

			cpu1541_req => '0',
			cpu1541_we => '0',
			cpu1541_a => (others => '0'),
			cpu1541_d => (others => '0'),
			
			romwr_req => romwr_req,
			romwr_ack => romwr_ack,
			romwr_we => '1',
			romwr_a => romwr_a_u,
			romwr_d => romwr_d_u,
			romwr_q => open,
			
			romrd_req => romrd_req,
			romrd_ack => romrd_ack,
			romrd_a => romrd_a_u,
			romrd_q => romrd_q_u,
	
			ram68k_req => ram68k_req,
			ram68k_ack => ram68k_ack,
			ram68k_we => ram68k_we,
			ram68k_a => ram68k_a_u,
			ram68k_d => ram68k_d_u,
			ram68k_q => ram68k_q_u,
			ram68k_u_n => ram68k_u_n,
			ram68k_l_n => ram68k_l_n,

			vram_req => vram_req,
			vram_ack => vram_ack,
			vram_we => vram_we,
			vram_a => vram_a_u,
			vram_d => vram_d_u,
			vram_q => vram_q_u,
			vram_u_n => vram_u_n,
			vram_l_n => vram_l_n,
			
			initDone => initDone,
			
			debugIdle => open,
			debugRefresh => open
		);

end architecture;
