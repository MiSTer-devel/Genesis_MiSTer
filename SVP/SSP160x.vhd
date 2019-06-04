library STD;
use STD.TEXTIO.ALL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
library work;
use work.SSP160x_PKG.all; 

entity SSP160x is
	port(
		CLK			: in std_logic;
		RST_N			: in std_logic;
		ENABLE		: in std_logic;
		
		PA				: out std_logic_vector(15 downto 0);		
		PDI			: in std_logic_vector(15 downto 0);
		
		SS				: in std_logic;
		
		EA				: out std_logic_vector(2 downto 0);
		EXTI			: in std_logic_vector(15 downto 0);
		EXTO 			: out std_logic_vector(15 downto 0); 
		ESB			: out std_logic;
		R_NW			: out std_logic;
		
		USR01			: in std_logic_vector(1 downto 0);
		ST56			: out std_logic_vector(1 downto 0);
		
		BLIND_RD		: out std_logic;
		BLIND_WR		: out std_logic;

		INST_NON		: out std_logic
	);
end SSP160x;

architecture rtl of SSP160x is

	signal EN				: std_logic;
	
	--Registers
	signal PC 				: std_logic_vector(15 downto 0);
	signal P 				: std_logic_vector(31 downto 0);
	signal A 				: std_logic_vector(31 downto 0);
	signal X 				: std_logic_vector(15 downto 0);
	signal Y 				: std_logic_vector(15 downto 0);
	signal SP 				: std_logic_vector(15 downto 0);
	signal RPL 				: std_logic_vector(2 downto 0);
	signal RB 				: std_logic_vector(1 downto 0);
	signal ST5 				: std_logic;
	signal ST6 				: std_logic;
	signal IE 				: std_logic;
	signal OP 				: std_logic;
	signal MACS				: std_logic;
	signal GPI0				: std_logic;
	signal GPI1				: std_logic;
	signal FLAG_L 			: std_logic;
	signal FLAG_Z 			: std_logic;
	signal FLAG_OV			: std_logic;
	signal FLAG_N 			: std_logic;
	signal ST 				: std_logic_vector(15 downto 0);
	signal STACK 			: Stack_t;
	signal PREG 			: PointRegs_t;
	
	signal IR 				: std_logic_vector(15 downto 0);
	signal IR_SAVED 		: std_logic_vector(15 downto 0);
	signal INST 			: Instr_r;
	signal IND_EXT_CYCLE : std_logic;
	signal IMM16_EXT_CYCLE: std_logic;
	signal ALU_R 			: std_logic_vector(31 downto 0);
	signal COND 			: std_logic; 
	signal LAST_CYCLE 	: std_logic;
	signal STACK_POS 		: unsigned(2 downto 0);
	signal SRC_REG_DATA 	: std_logic_vector(15 downto 0);
	signal SRC_DATA 		: std_logic_vector(15 downto 0);
	signal RAMA_PTR_DATA	: std_logic_vector(15 downto 0);
	signal RAMB_PTR_DATA : std_logic_vector(15 downto 0);
	signal RAMA_PTR 		: std_logic_vector(7 downto 0);
	signal RAMB_PTR 		: std_logic_vector(7 downto 0);
	signal IND_ADDR 		: std_logic_vector(15 downto 0);
	
	--Data RAM
	signal RAMA_ADDR		: std_logic_vector(7 downto 0);
	signal RAMB_ADDR		: std_logic_vector(7 downto 0);
	signal RAMA_D 			: std_logic_vector(15 downto 0);
	signal RAMB_D 			: std_logic_vector(15 downto 0);
	signal RAMA_WE 		: std_logic;
	signal RAMB_WE 		: std_logic;
	signal RAMA_Q 			: std_logic_vector(15 downto 0);
	signal RAMB_Q 			: std_logic_vector(15 downto 0);

begin

	EN <= ENABLE and SS;
	
	--Instruction decoder
	IR <= PDI when IND_EXT_CYCLE = '0' and IMM16_EXT_CYCLE = '0' else IR_SAVED;
	
	process(IR)
	begin
		INST <= (IT_NON, IA_NON, IA_NON, IR(7 downto 4), IR(3 downto 0), IR(8)&not IR(8));
		case IR(15 downto 13) is
			when "000" => 
				INST.IT <= IT_LD;
			when "001" => 
				case IR(12 downto 8) is
					when "10000" => INST.IT <= IT_NON;
					when "10100" => INST.IT <= IT_NON;
					when "10111" => INST.IT <= IT_MPYS;
					when others =>  INST.IT <= IT_SUB;
				end case; 
			when "010" => 
				case IR(12 downto 8) is
					when "01000" | "01001" => INST.IT <= IT_CALL;
					when "01010" => 			  INST.IT <= IT_LD;
					when "01100" | "01101" => INST.IT <= IT_BRA;
					when others =>  			  INST.IT <= IT_NON;
				end case; 
			when "011" => 
				case IR(12 downto 8) is
					when "10000" => INST.IT <= IT_NON;
					when "10100" => INST.IT <= IT_NON;
					when "10111" => INST.IT <= IT_NON;
					when others =>  INST.IT <= IT_CMP;
				end case; 
			when "100" => 
				case IR(12 downto 8) is
					when "10000" => 
						case IR(3 downto 0) is
							when x"2" => 	INST.IT <= IT_SHR;
							when x"3" => 	INST.IT <= IT_SHL;
							when x"6" => 	INST.IT <= IT_NEG;
							when x"7" => 	INST.IT <= IT_ABS;
							when others => INST.IT <= IT_NON;
						end case; 
					when "10100" =>
						case IR(7 downto 0) is
							when x"05" => 	INST.IT <= IT_SETI;
							when others => INST.IT <= IT_NON;
						end case; 
					when "10111" => INST.IT <= IT_MPYA;
					when others =>  INST.IT <= IT_ADD;
				end case; 
			when "101" => 
				case IR(12 downto 8) is
					when "10000" => INST.IT <= IT_NON;
					when "10100" => INST.IT <= IT_NON;
					when "10111" => INST.IT <= IT_MLD;
					when others =>  INST.IT <= IT_AND;
				end case; 
			when "110" => 
				case IR(12 downto 8) is
					when "10000" => INST.IT <= IT_NON;
					when "10100" => INST.IT <= IT_NON;
					when "10111" => INST.IT <= IT_NON;
					when others =>  INST.IT <= IT_OR;
				end case;
			when "111" => 
				case IR(12 downto 8) is
					when "10000" => INST.IT <= IT_NON;
					when "10100" => INST.IT <= IT_NON;
					when "10111" => INST.IT <= IT_NON;
					when others =>  INST.IT <= IT_EOR;
				end case;
			when others =>
				INST.IT <= IT_NON;
		end case; 
			
		case IR(15 downto 8) is
			when x"00" => 
				INST.AD <= IA_REGX;
				INST.AS <= IA_REGY;
				INST.RAM <= "00";
			when x"20" | x"60" | x"80" | x"A0" | x"C0" | x"E0" =>
				INST.AD <= IA_ACC;
				INST.AS <= IA_REGY;
				INST.RAM <= "00";
			when x"02" | x"03" =>
				INST.AD <= IA_REGX;
				INST.AS <= IA_PTR;
				INST.RAM <= IR(8)&not IR(8);
			when x"22" | x"62" | x"82" | x"A2" | x"C2" | x"E2" |
				  x"23" | x"63" | x"83" | x"A3" | x"C3" | x"E3" =>
				INST.AD <= IA_ACC;
				INST.AS <= IA_PTR;
				INST.RAM <= IR(8)&not IR(8);
			when x"04" | x"05" =>
				INST.AD <= IA_PTR;
				INST.AS <= IA_REGX;
				INST.RAM <= IR(8)&not IR(8);
			when x"06" | x"26" | x"66" | x"86" | x"A6" | x"C6" | x"E6" |
				  x"07" | x"27" | x"67" | x"87" | x"A7" | x"C7" | x"E7" =>
				INST.AD <= IA_ACC;
				INST.AS <= IA_RAM;
				INST.RAM <= IR(8)&not IR(8);
			when x"08" =>
				INST.AD <= IA_REGX;
				INST.AS <= IA_IMM16;
				INST.RAM <= "00";
			when x"28" | x"68" | x"88" | x"A8" | x"C8" | x"E8" =>
				INST.AD <= IA_ACC;
				INST.AS <= IA_IMM16;
				INST.RAM <= "00";
			when x"0A" | x"0B" =>
				INST.AD <= IA_REGX;
				INST.AS <= IA_INDPTR;
				INST.RAM <= IR(8)&not IR(8);
			when x"2A" | x"6A" | x"8A" | x"AA" | x"CA" | x"EA" |
				  x"2B" | x"6B" | x"8B" | x"AB" | x"CB" | x"EB" =>
				INST.AD <= IA_ACC;
				INST.AS <= IA_INDPTR;
				INST.RAM <= IR(8)&not IR(8);
			when x"0C" | x"0D" =>
				INST.AD <= IA_PTR;
				INST.AS <= IA_IMM16;
				INST.RAM <= IR(8)&not IR(8);
			when x"0E" | x"0F" =>
				INST.AD <= IA_RAM;
				INST.AS <= IA_ACC;
				INST.RAM <= IR(8)&not IR(8);
			when x"12" | x"13" =>
				INST.AD <= IA_REGX;
				INST.AS <= IA_PREG;
				INST.RAM <= "00";
			when x"32" | x"72" | x"92" | x"B2" | x"D2" | x"F2" |
				  x"33" | x"73" | x"93" | x"B3" | x"D3" | x"F3" =>
				INST.AD <= IA_ACC;
				INST.AS <= IA_PREG;
				INST.RAM <= "00";
			when x"14" | x"15" =>
				INST.AD <= IA_PREG;
				INST.AS <= IA_REGX;
				INST.RAM <= "00";
			when x"18" | x"19" | x"1A" | x"1C" | x"1D" | x"1E" =>
				INST.AD <= IA_PREG;
				INST.AS <= IA_IMM8;
				INST.RAM <= "00";
			when x"38" | x"78" | x"98" | x"B8" | x"D8" | x"F8" =>
				INST.AD <= IA_ACC;
				INST.AS <= IA_IMM8;
				INST.RAM <= "00";
			when x"37" | x"97" | x"B7" =>
				INST.AD <= IA_ACC;
				INST.AS <= IA_PTR;
				INST.RAM <= "11";
			when x"48" | x"49" | x"4C" | x"4D" =>
				INST.AD <= IA_NON;
				INST.AS <= IA_IMM16;
				INST.RAM <= "00";
			when x"4A" =>
				INST.AD <= IA_REGX;
				INST.AS <= IA_INDACC;
				INST.RAM <= "00";
			when x"90" =>
				INST.AD <= IA_ACC;
				INST.AS <= IA_ACC;
				INST.RAM <= "00";
			when others =>
				INST.AD <= IA_NON;
				INST.AS <= IA_NON;
				INST.RAM <= "00";
		end case; 
	end process;
	
	INST_NON <= '1' when INST.IT = IT_NON else '0';
	
	process(CLK, RST_N)
	begin
		if RST_N = '0' then
			IMM16_EXT_CYCLE <= '0';
			IND_EXT_CYCLE <= '0';
			IR_SAVED <= (others => '0');
		elsif rising_edge(CLK) then
			if EN = '1' then
				if INST.AS = IA_IMM16 and IMM16_EXT_CYCLE = '0' then 
					IMM16_EXT_CYCLE <= '1';
				elsif IMM16_EXT_CYCLE = '1' then 
					IMM16_EXT_CYCLE <= '0';
				end if;
				
				if (INST.AS = IA_INDPTR or INST.AS = IA_INDACC) and IND_EXT_CYCLE = '0' then 
					IND_EXT_CYCLE <= '1';
				elsif IND_EXT_CYCLE = '1' then 
					IND_EXT_CYCLE <= '0';
				end if;
				
				IR_SAVED <= IR;
			end if;
		end if;
	end process;
	
	LAST_CYCLE <= SS when (INST.AS /= IA_IMM16 and INST.AS /= IA_INDPTR and INST.AS /= IA_INDACC) or IMM16_EXT_CYCLE = '1' or IND_EXT_CYCLE = '1' else '0';

	
	process(INST, X, Y, A, ST, SP, PC, P, EXTI)
	variable SRC_REG : std_logic_vector(3 downto 0);
	begin
		if INST.AS = IA_REGY then
			SRC_REG := INST.Y;
		else
			SRC_REG := INST.X;
		end if;
		case SRC_REG is
			when x"0" => SRC_REG_DATA <= (others => '1');
			when x"1" => SRC_REG_DATA <= X;
			when x"2" => SRC_REG_DATA <= Y;
			when x"3" => SRC_REG_DATA <= A(31 downto 16);
			when x"4" => SRC_REG_DATA <= ST;
			when x"5" => SRC_REG_DATA <= SP;
			when x"6" => SRC_REG_DATA <= PC;
			when x"7" => SRC_REG_DATA <= P(31 downto 16);
			when x"8" => SRC_REG_DATA <= EXTI;
			when x"9" => SRC_REG_DATA <= EXTI;
			when x"A" => SRC_REG_DATA <= EXTI;
			when x"B" => SRC_REG_DATA <= EXTI;
			when x"C" => SRC_REG_DATA <= EXTI;
			when x"D" => SRC_REG_DATA <= EXTI;
			when x"E" => SRC_REG_DATA <= EXTI;
			when others => SRC_REG_DATA <= A(15 downto 0);
		end case; 
	end process;
	
	
	process(IR, SRC_REG_DATA, A, PREG, PDI, RAMA_Q, RAMB_Q)
	begin
		case IR(12 downto 8) is
			when "00000" => SRC_DATA <= SRC_REG_DATA;
			when "00010" => SRC_DATA <= RAMA_Q;
			when "00011" => SRC_DATA <= RAMB_Q;
			when "00100" => SRC_DATA <= SRC_REG_DATA;
			when "00101" => SRC_DATA <= SRC_REG_DATA;
			when "00110" => SRC_DATA <= RAMA_Q;
			when "00111" => SRC_DATA <= RAMB_Q;
			when "01000" => SRC_DATA <= PDI;
			when "01010" => SRC_DATA <= PDI;
			when "01011" => SRC_DATA <= PDI;
			when "01100" => SRC_DATA <= PDI;
			when "01101" => SRC_DATA <= PDI;
			when "01110" => SRC_DATA <= A(31 downto 16);
			when "01111" => SRC_DATA <= A(31 downto 16);
			when "10010" => SRC_DATA <= x"00" & PREG(to_integer("0"&unsigned(IR(1 downto 0))));
			when "10011" => SRC_DATA <= x"00" & PREG(to_integer("1"&unsigned(IR(1 downto 0))));
			when "10100" => SRC_DATA <= SRC_REG_DATA;
			when "10101" => SRC_DATA <= SRC_REG_DATA;
			when "11000" => SRC_DATA <= x"00" & IR(7 downto 0);
			when "11001" => SRC_DATA <= x"00" & IR(7 downto 0);
			when "11010" => SRC_DATA <= x"00" & IR(7 downto 0);
			when "11011" => SRC_DATA <= x"00" & IR(7 downto 0);
			when "11100" => SRC_DATA <= x"00" & IR(7 downto 0);
			when "11101" => SRC_DATA <= x"00" & IR(7 downto 0);
			when "11110" => SRC_DATA <= x"00" & IR(7 downto 0);
			when "11111" => SRC_DATA <= x"00" & IR(7 downto 0);
			when others => SRC_DATA <= (others => '0');
		end case; 
	end process;
	
	--ALU
	process(INST, A, P, SRC_DATA)
	variable B : std_logic_vector(31 downto 0);
	begin
		if INST.AS = IA_REGY and INST.Y = REG_P then
			B := P;
		elsif INST.AS = IA_REGY and INST.Y = REG_AH then
			B := A;
		else
			B := SRC_DATA & x"0000";
		end if;
		
		ALU_R <= (others => '0');
		if INST.IT = IT_ADD then
			ALU_R <= std_logic_vector(unsigned(A) + unsigned(B));
		elsif INST.IT = IT_SUB or INST.IT = IT_CMP then
			ALU_R <= std_logic_vector(unsigned(A) - unsigned(B));
		elsif INST.IT = IT_AND then
			ALU_R <= A and B;
		elsif INST.IT = IT_OR then
			ALU_R <= A or B;
		elsif INST.IT = IT_EOR then
			ALU_R <= A xor B;
		elsif INST.IT = IT_SHL then
			ALU_R <= A(30 downto 0)&'0';
		elsif INST.IT = IT_SHR then
			ALU_R <= A(31)&A(31 downto 1);
		elsif INST.IT = IT_NEG then
			ALU_R <= std_logic_vector(0-signed(A));
		elsif INST.IT = IT_ABS then
			if A(31) = '1' then
				ALU_R <= std_logic_vector(0-signed(A));
			else
				ALU_R <= A;
			end if;
		elsif INST.IT = IT_MPYA then
			ALU_R <= std_logic_vector(unsigned(A) + unsigned(P));
		elsif INST.IT = IT_MPYS then
			ALU_R <= std_logic_vector(unsigned(A) - unsigned(P));
		elsif INST.IT = IT_MLD then
			ALU_R <= (others => '0');
		end if;
	end process;
	
	process(CLK, RST_N)
	begin
		if RST_N = '0' then
			FLAG_Z <= '0';
			FLAG_N <= '0';
			FLAG_L <= '0';
			FLAG_OV <= '0';
		elsif rising_edge(CLK) then
			if EN = '1' and LAST_CYCLE = '1' then
				if INST.IT = IT_ADD or INST.IT = IT_SUB or INST.IT = IT_AND or INST.IT = IT_OR or INST.IT = IT_EOR or 
					INST.IT = IT_CMP or INST.IT = IT_MLD or INST.IT = IT_MPYA or INST.IT = IT_MPYS or
					((INST.IT = IT_SHL or INST.IT = IT_SHR or INST.IT = IT_NEG or INST.IT = IT_ABS) and COND = '1') then
					if ALU_R = x"00000000" then
						FLAG_Z <= '1';
					else
						FLAG_Z <= '0';
					end if;
					FLAG_N <= ALU_R(31);
					FLAG_L <= '0';
					FLAG_OV <= '0';
				end if;
			end if;
		end if;
	end process;
	
	process(IR, FLAG_Z, FLAG_N)
	begin
		case IR(6 downto 4) is
			when "000" =>  COND <= '1';
			when "101" =>  COND <= FLAG_Z xor not IR(8);
			when "111" =>  COND <= FLAG_N xor not IR(8);
			when others => COND <= '0';	
		end case; 
	end process;
	
	--ACC 
	process(CLK, RST_N)
	begin
		if RST_N = '0' then
			A <= (others => '0');
		elsif rising_edge(CLK) then
			if EN = '1' and LAST_CYCLE = '1' then
				if INST.IT = IT_ADD or INST.IT = IT_SUB or INST.IT = IT_AND or INST.IT = IT_OR or INST.IT = IT_EOR or 
					INST.IT = IT_MPYA or INST.IT = IT_MPYS or INST.IT = IT_MLD or
					((INST.IT = IT_SHL or INST.IT = IT_SHR or INST.IT = IT_NEG or INST.IT = IT_ABS) and COND = '1') then
					A <= ALU_R;
				elsif INST.IT = IT_LD then
					if INST.AD = IA_ACC or (INST.AD = IA_REGX and INST.X = REG_AH) then
						A(31 downto 16) <= SRC_DATA;
						if INST.AS = IA_REGY and INST.Y = REG_P then
							A(15 downto 0) <= P(15 downto 0);
						end if;
					elsif INST.AD = IA_REGX and INST.X = REG_AL then
						A(15 downto 0) <= SRC_DATA;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	--X, Y registers
	process(CLK, RST_N)
	begin
		if RST_N = '0' then
			X <= (others => '0');
			Y <= (others => '0');
		elsif rising_edge(CLK) then
			if EN = '1' and LAST_CYCLE = '1' then
				if INST.IT = IT_MLD or INST.IT = IT_MPYA or INST.IT = IT_MPYS then
					X <= RAMA_Q;
					Y <= RAMB_Q;
				elsif INST.IT = IT_LD then
					if INST.AD = IA_REGX and INST.X = REG_X then
						X <= SRC_DATA;
					elsif INST.AD = IA_REGX and INST.X = REG_Y then
						Y <= SRC_DATA;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	--PC, STACK
	process(CLK, RST_N, STACK, STACK_POS)
	variable NEXT_STACK_POS, PREV_STACK_POS : unsigned(2 downto 0);
	variable NEXT_PC : std_logic_vector(15 downto 0);
	begin
		if STACK_POS = 0 then
			PREV_STACK_POS := "101";
		else
			PREV_STACK_POS := STACK_POS - 1;
		end if;
		
		if STACK_POS = 5 then
			NEXT_STACK_POS := (others => '0');
		else
			NEXT_STACK_POS := STACK_POS + 1;
		end if;
					
		SP <= STACK(to_integer(PREV_STACK_POS));
		
		if RST_N = '0' then
			PC <= x"0400";
			STACK <= (others => (others => '0'));
			STACK_POS <= (others => '0');
		elsif rising_edge(CLK) then
			if EN = '1' then
				NEXT_PC := std_logic_vector(unsigned(PC) + 1);
				
				if INST.IT = IT_LD and INST.AD = IA_REGX and INST.X = REG_PC and LAST_CYCLE = '1' then
					PC <= SRC_DATA;
				elsif (INST.IT = IT_CALL or INST.IT = IT_BRA) and COND = '1' and LAST_CYCLE = '1' then
					PC <= PDI;
				elsif (INST.AS = IA_INDPTR or INST.AS = IA_INDACC) and LAST_CYCLE = '0' then
					PC <= PC;
				else
					PC <= NEXT_PC;
				end if;
				
				if INST.IT = IT_LD and ((INST.AS = IA_REGX and INST.X = REG_SP) or (INST.AS = IA_REGY and INST.Y = REG_SP)) and LAST_CYCLE = '1' then
					STACK_POS <= PREV_STACK_POS;
				elsif INST.IT = IT_LD and INST.AD = IA_REGX and INST.X = REG_SP and LAST_CYCLE = '1' then
					STACK(to_integer(STACK_POS)) <= SRC_DATA;
					STACK_POS <= NEXT_STACK_POS;
				elsif INST.IT = IT_CALL and COND = '1' and LAST_CYCLE = '1' then
					STACK(to_integer(STACK_POS)) <= NEXT_PC;
					STACK_POS <= NEXT_STACK_POS;
				end if;
			end if;
		end if;
	end process;
	
	--ST
	GPI0 <= USR01(0);
	GPI1 <= USR01(1);
	
	ST <= FLAG_N & FLAG_OV & FLAG_Z & FLAG_L & GPI0 & GPI1 & MACS & OP & IE & ST6 & ST5 & RB & RPL;
	
	process(CLK, RST_N)
	begin
		if RST_N = '0' then
			RPL <= (others => '0');
			RB <= (others => '0');
			ST5 <= '0';
			ST6 <= '0';
			IE <= '0';
			OP <= '0';
			MACS <= '0';
		elsif rising_edge(CLK) then
			if EN = '1' and LAST_CYCLE = '1' then
				if INST.IT = IT_LD and INST.AD = IA_REGX and INST.X = REG_ST then
					RPL <= SRC_DATA(2 downto 0);
					RB <= SRC_DATA(4 downto 3);
					ST5 <= SRC_DATA(5);
					ST6 <= SRC_DATA(6);
					IE <= SRC_DATA(7);
					OP <= SRC_DATA(8);
					MACS <= SRC_DATA(9);
				elsif INST.IT = IT_SETI then
					IE <= '1';
				end if;
			end if;
		end if;
	end process;
	
	P <= std_logic_vector( resize(signed(X) * signed(Y) * 2, P'length) );
	
	--Pointer registers
	process(IR, INST, PREG, CLK, RST_N)
	variable NA, NB : std_logic_vector(3 downto 0);
	begin
		NA := INST.Y;		--ptr_Ay
		case NA is
			when x"0" => RAMA_PTR <= PREG(0);
			when x"1" => RAMA_PTR <= PREG(1);
			when x"2" => RAMA_PTR <= PREG(2);
			when x"3" => RAMA_PTR <= x"00";
			when x"4" => RAMA_PTR <= PREG(0);
			when x"5" => RAMA_PTR <= PREG(1);
			when x"6" => RAMA_PTR <= PREG(2);
			when x"7" => RAMA_PTR <= x"01";
			when x"8" => RAMA_PTR <= PREG(0);
			when x"9" => RAMA_PTR <= PREG(1);
			when x"A" => RAMA_PTR <= PREG(2);
			when x"B" => RAMA_PTR <= x"02";
			when x"C" => RAMA_PTR <= PREG(0);
			when x"D" => RAMA_PTR <= PREG(1);
			when x"E" => RAMA_PTR <= PREG(2);
			when others => RAMA_PTR <= x"03";
		end case; 
		
		if INST.RAM = "11" then 
			NB := INST.X;	--ptr_Bx
		else
			NB := INST.Y;	--ptr_By
		end if;
		case NB is
			when x"0" => RAMB_PTR <= PREG(4);
			when x"1" => RAMB_PTR <= PREG(5);
			when x"2" => RAMB_PTR <= PREG(6);
			when x"3" => RAMB_PTR <= x"00";
			when x"4" => RAMB_PTR <= PREG(4);
			when x"5" => RAMB_PTR <= PREG(5);
			when x"6" => RAMB_PTR <= PREG(6);
			when x"7" => RAMB_PTR <= x"01";
			when x"8" => RAMB_PTR <= PREG(4);
			when x"9" => RAMB_PTR <= PREG(5);
			when x"A" => RAMB_PTR <= PREG(6);
			when x"B" => RAMB_PTR <= x"02";
			when x"C" => RAMB_PTR <= PREG(4);
			when x"D" => RAMB_PTR <= PREG(5);
			when x"E" => RAMB_PTR <= PREG(6);
			when others => RAMB_PTR <= x"03";
		end case;
		
		if RST_N = '0' then
			PREG <= (others => (others => '0'));
		elsif rising_edge(CLK) then
			if EN = '1' and LAST_CYCLE = '1' then
				if INST.AD = IA_PTR or INST.AS = IA_PTR then
					if INST.RAM(0) = '1' then
						case NA is
							when x"0" => PREG(0) <= PREG(0);
							when x"1" => PREG(1) <= PREG(1);
							when x"2" => PREG(2) <= PREG(2);
							when x"3" => null;
							when x"4" => PREG(0) <= ModAdj(PREG(0), "000", '1');
							when x"5" => PREG(1) <= ModAdj(PREG(1), "000", '1');
							when x"6" => PREG(2) <= ModAdj(PREG(2), "000", '1');
							when x"7" => null;
							when x"8" => PREG(0) <= ModAdj(PREG(0), RPL, '0');
							when x"9" => PREG(1) <= ModAdj(PREG(1), RPL, '0');
							when x"A" => PREG(2) <= ModAdj(PREG(2), RPL, '0');
							when x"B" => null;
							when x"C" => PREG(0) <= ModAdj(PREG(0), RPL, '1');
							when x"D" => PREG(1) <= ModAdj(PREG(1), RPL, '1');
							when x"E" => PREG(2) <= ModAdj(PREG(2), RPL, '1');
							when others => null;
						end case; 
					end if;
				
					if INST.RAM(1) = '1' then
						case NB is
							when x"0" => PREG(4) <= PREG(4);
							when x"1" => PREG(5) <= PREG(5);
							when x"2" => PREG(6) <= PREG(6);
							when x"3" => null;
							when x"4" => PREG(4) <= ModAdj(PREG(4), "000", '1');
							when x"5" => PREG(5) <= ModAdj(PREG(5), "000", '1');
							when x"6" => PREG(6) <= ModAdj(PREG(6), "000", '1');
							when x"7" => null;
							when x"8" => PREG(4) <= ModAdj(PREG(4), RPL, '0');
							when x"9" => PREG(5) <= ModAdj(PREG(5), RPL, '0');
							when x"A" => PREG(6) <= ModAdj(PREG(6), RPL, '0');
							when x"B" => null;
							when x"C" => PREG(4) <= ModAdj(PREG(4), RPL, '1');
							when x"D" => PREG(5) <= ModAdj(PREG(5), RPL, '1');
							when x"E" => PREG(6) <= ModAdj(PREG(6), RPL, '1');
							when others => null;
						end case;
					end if;
				elsif INST.IT = IT_LD and INST.AD = IA_PREG then
					if INST.AS = IA_REGX then
						PREG(to_integer(unsigned(IR(8)&IR(1 downto 0)))) <= SRC_REG_DATA(7 downto 0);
					elsif INST.AS = IA_IMM8 then
						PREG(to_integer(unsigned(IR(10 downto 8)))) <= IR(7 downto 0);
					end if;
				end if;
			end if;
		end if;
	end process;
	
	--indirect address
	process(CLK, RST_N)
	begin
		if RST_N = '0' then
			IND_ADDR <= (others => '0');
		elsif rising_edge(CLK) then
			if EN = '1' and LAST_CYCLE = '0' then
				if INST.AS = IA_INDPTR then
					if INST.RAM(0) = '1' then
						IND_ADDR <= RAMA_Q;
					elsif INST.RAM(1) = '1' then
						IND_ADDR <= RAMB_Q;
					end if;
				elsif INST.AS = IA_INDACC then
					IND_ADDR <= A(31 downto 16);
				end if;
			end if;
		end if;
	end process;

	RAMA_ADDR <= IR(7 downto 0) when INST.AS = IA_RAM or INST.AD = IA_RAM else RAMA_PTR;
	RAMA_D <= std_logic_vector(unsigned(RAMA_Q) + 1) when INST.AS = IA_INDPTR else SRC_DATA;
	RAMA_WE <= INST.RAM(0) and LAST_CYCLE and EN when INST.AD = IA_RAM or INST.AD = IA_PTR or INST.AS = IA_INDPTR else '0';
	RAMA : entity work.mlab generic map(8, 16)
	port map(
		clock			=> CLK,
		rdaddress	=> RAMA_ADDR,
		wraddress	=> RAMA_ADDR,
		data			=> RAMA_D,
		wren			=> RAMA_WE,
		q				=> RAMA_Q
	);
	
	RAMB_ADDR <= IR(7 downto 0) when INST.AS = IA_RAM or INST.AD = IA_RAM else RAMB_PTR;
	RAMB_D <= std_logic_vector(unsigned(RAMB_Q) + 1) when INST.AS = IA_INDPTR else SRC_DATA;
	RAMB_WE <= INST.RAM(1) and LAST_CYCLE and EN when INST.AD = IA_RAM or INST.AD = IA_PTR or INST.AS = IA_INDPTR else '0';
	RAMB : entity work.mlab generic map(8, 16)
	port map(
		clock			=> CLK,
		rdaddress	=> RAMB_ADDR,
		wraddress	=> RAMB_ADDR,
		data			=> RAMB_D,
		wren			=> RAMB_WE,
		q				=> RAMB_Q
	);

	
	PA <= IND_ADDR when IND_EXT_CYCLE = '1' else PC;
	
	EA <= INST.Y(2 downto 0) when INST.AS = IA_REGY and INST.Y(3) = '1' else INST.X(2 downto 0);
	EXTO <= SRC_DATA;
	ESB <= LAST_CYCLE when INST.AS = IA_REGY and INST.Y(3) = '1' else
			 LAST_CYCLE when (INST.AD = IA_REGX or INST.AS = IA_REGX) and INST.X(3) = '1' else
			 '0';
	R_NW <= '0' when INST.AD = IA_REGX and INST.X(3) = '1' else '1';
	
	BLIND_RD <= '1' when INST.AD = IA_REGX and INST.X = REG_0 else '0';	--I don't know how SVP defines blind access,
	BLIND_WR <= '1' when (INST.AS = IA_REGX and INST.X = REG_0) or (INST.AS = IA_REGY and INST.Y = REG_0) else '0';	--therefore added extern signals 
	
	ST56 <= ST6 & ST5;
	
end rtl;

