
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM_256 is
   Port (
      RD_n     : in     STD_LOGIC;
      BANK_n   : in     STD_LOGIC_VECTOR (7 downto 0);
      COM_n    : in     STD_LOGIC;
      A        : in     STD_LOGIC_VECTOR (15 downto 0);
      RFSH_n   : in     STD_LOGIC;
      AUS_n    : in     STD_LOGIC;
      TAKT     : in     STD_LOGIC;
      MREQ_n   : in     STD_LOGIC;
      D        : inout  STD_LOGIC_VECTOR (7 downto 0));
end RAM_256;

architecture RTL of RAM_256 is
   
begin
   D <= (others => 'Z');
end RTL;
