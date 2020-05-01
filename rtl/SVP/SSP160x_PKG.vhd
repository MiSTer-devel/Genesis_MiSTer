library IEEE;
use IEEE.Std_Logic_1164.all;
library STD;
use ieee.numeric_std.all;

package SSP160x_PKG is  

	constant REG_0 	: std_logic_vector(3 downto 0) := x"0";
	constant REG_X 	: std_logic_vector(3 downto 0) := x"1";
	constant REG_Y 	: std_logic_vector(3 downto 0) := x"2";
	constant REG_AH 	: std_logic_vector(3 downto 0) := x"3";
	constant REG_ST 	: std_logic_vector(3 downto 0) := x"4";
	constant REG_SP 	: std_logic_vector(3 downto 0) := x"5";
	constant REG_PC 	: std_logic_vector(3 downto 0) := x"6";
	constant REG_P 	: std_logic_vector(3 downto 0) := x"7";
	constant REG_EXT0 : std_logic_vector(3 downto 0) := x"8";
	constant REG_EXT1 : std_logic_vector(3 downto 0) := x"9";
	constant REG_EXT2 : std_logic_vector(3 downto 0) := x"A";
	constant REG_EXT3 : std_logic_vector(3 downto 0) := x"B";
	constant REG_EXT4 : std_logic_vector(3 downto 0) := x"C";
	constant REG_EXT5 : std_logic_vector(3 downto 0) := x"D";
	constant REG_EXT6 : std_logic_vector(3 downto 0) := x"E";
	constant REG_AL 	: std_logic_vector(3 downto 0) := x"F";
	
	type InstrType_t is (
		IT_NON,
		IT_LD,
		IT_ADD,
		IT_SUB,
		IT_AND,
		IT_OR,
		IT_EOR,
		IT_CMP,
		IT_SHL,
		IT_SHR,
		IT_NEG,
		IT_ABS,
		IT_MLD,
		IT_MPYA,
		IT_MPYS,
		IT_BRA,
		IT_CALL,
		IT_SETI
	);
	
	type InstrAddr_t is (
		IA_NON,
		IA_ACC,
		IA_REGX,
		IA_REGY,
		IA_PTR,
		IA_RAM,
		IA_IMM8,
		IA_IMM16,
		IA_INDPTR,
		IA_INDACC,
		IA_PREG
	);

	type Instr_r is record
		IT		: InstrType_t;
		AS		: InstrAddr_t;
		AD		: InstrAddr_t;
		X 		: std_logic_vector(3 downto 0);
		Y 		: std_logic_vector(3 downto 0);
		RAM 	: std_logic_vector(1 downto 0);
	end record;
	
	
	type PointRegs_t is array (0 to 7) of std_logic_vector(7 downto 0);
	type Stack_t is array (0 to 5) of std_logic_vector(15 downto 0);
	

	function ModAdj(data: std_logic_vector(7 downto 0); m: std_logic_vector(2 downto 0); inc: std_logic) return std_logic_vector;

end SSP160x_PKG;

package body SSP160x_PKG is

	function ModAdj(data: std_logic_vector(7 downto 0); m: std_logic_vector(2 downto 0); inc: std_logic) return std_logic_vector is
		variable mask: std_logic_vector(7 downto 0); 
		variable temp: std_logic_vector(7 downto 0); 
		variable res: std_logic_vector(7 downto 0); 
	begin
		case m is
			when "001" => 	mask := "00000001";
			when "010" => 	mask := "00000011";
			when "011" => 	mask := "00000111";
			when "100" => 	mask := "00001111";
			when "101" => 	mask := "00011111";
			when "110" => 	mask := "00111111";
			when "111" => 	mask := "01111111";
			when others => mask := "11111111";
		end case;
		if inc = '1' then
			temp := std_logic_vector(unsigned(data) + 1);
		else
			temp := std_logic_vector(unsigned(data) - 1);
		end if;
		
		res := (data and not mask) or (temp and mask);
		return res;
	end function;

end package body SSP160x_PKG;
