
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--
-- Video RAM Controller
--
entity U82720_GMI is
	Port (
      --
      -- GDC internal Interface
      --
      DB    : inout  STD_LOGIC_VECTOR (7 downto 0);
      
      --
      -- Memory Interface
      --
		AD    : inout  STD_LOGIC_VECTOR (15 downto 0);
      
      -- in graphics mode: bit 16, 17 of 18-bit address in memory
      -- in character mode: A_16 is MSB of line counter, A_17 outputs cursor signal
      -- in mixed mode: A_16 is external line counter clear pulse, A_17 signals whether next raster line is bitmap or characters
      -- values may change during first clock cycle of memory cycle or fourth clock cycle of RMW cycle
      A_16  : out    STD_LOGIC;
      A_17  : out    STD_LOGIC);
end U82720_GMI;

architecture RTL of U82720_GMI is
   
begin
   
end RTL;
