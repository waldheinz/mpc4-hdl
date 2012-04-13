
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DS8205D is
    Port ( A 		: in  STD_LOGIC_VECTOR (2 downto 0);
           E1_n 	: in  STD_LOGIC;
           E2_n 	: in  STD_LOGIC;
           E3 		: in  STD_LOGIC;
           O 		: out STD_LOGIC_VECTOR (7 downto 0));
end DS8205D;

architecture Behave of DS8205D is
	signal E : STD_LOGIC_VECTOR (2 downto 0);
begin
	E <= E1_n & E2_n & E3;
	
	process (E, A)
	begin
		if (E = "001") then
			case A is
				when "000"  => O <= "11111110";
				when "001"  => O <= "11111101";
				when "010"  => O <= "11111011";
				when "011"  => O <= "11110111";
				when "100"  => O <= "11101111";
				when "101"  => O <= "11011111";
				when "110"  => O <= "10111111";
				when others => O <= "01111111";
			end case;
		else
			O <= (others => '1');
		end if;
	end process;
	
end Behave;
