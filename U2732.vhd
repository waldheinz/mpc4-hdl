
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity U2732 is
    Port ( A 		: in  STD_LOGIC_VECTOR (11 downto 0);
           CE_n 	: in  STD_LOGIC;
           OE_n	: in  STD_LOGIC;
           D 		: out STD_LOGIC_VECTOR (7 downto 0));
end U2732;

architecture Behave of U2732 is

begin
	process (OE_n)
	begin
		if (OE_n = '0') then
			D <= "00000000";
		else
			D <= "ZZZZZZZZ";
		end if;
	end process;
end Behave;

