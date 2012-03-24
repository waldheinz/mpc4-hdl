
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity U82720_CTRL is
    Port ( D : in  STD_LOGIC_VECTOR (8 downto 0);
           D_RDY : in  STD_LOGIC;
           D_FUL : in  STD_LOGIC;
           RD : out  STD_LOGIC;
           WR : in  STD_LOGIC);
end U82720_CTRL;

architecture RTL of U82720_CTRL is

begin


end RTL;
