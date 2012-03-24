
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity U82720 is
    Port ( DB 			: inout  STD_LOGIC_VECTOR (7 downto 0);
           RD_n 		: in  	STD_LOGIC;
           WR_n 		: in  	STD_LOGIC;
           A0 			: in  	STD_LOGIC;
           TWOxWCLK 	: in  	STD_LOGIC;
           LPEN 		: in  	STD_LOGIC;
           DACK_n 	: in  	STD_LOGIC;
           AD 			: inout 	STD_LOGIC_VECTOR (15 downto 0);
           A16 		: out  	STD_LOGIC;
           A17 		: out  	STD_LOGIC;
           HSYNC 		: out  	STD_LOGIC;
           VSYNC 		: out  	STD_LOGIC;
           BLANK 		: out  	STD_LOGIC;
           DRQ_n 		: out  	STD_LOGIC;
           ALE 		: out  	STD_LOGIC;
           DBIN_n 	: out  	STD_LOGIC);
end U82720;

architecture RTL of U82720 is

begin


end RTL;

