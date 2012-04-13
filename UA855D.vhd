
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity UA855D is
   Port (
      -- Clock
      C        : in     STD_LOGIC;
      
      -- CPU Data Bus
      D        : inout  STD_LOGIC_VECTOR (7 downto 0);
      
      -- PIO Control
      B_A_SEL  : in     STD_LOGIC;
      C_D_SEL  : in     STD_LOGIC;
      CS_n     : in     STD_LOGIC;
      M1_n     : in     STD_LOGIC;
      IORQ_n   : in     STD_LOGIC;
      RD_n     : in     STD_LOGIC;
      
      -- Interrupt Control
      IEI      : in     STD_LOGIC;
      IEO      : out    STD_LOGIC;
      INT_n    : out    STD_LOGIC;
      
      -- Port A I/O
      A        : inout  STD_LOGIC_VECTOR (7 downto 0);
      ARDY     : out    STD_LOGIC;
      ASTB_n   : in     STD_LOGIC;
      
      -- Port B I/O
      B        : inout  STD_LOGIC_VECTOR (7 downto 0);
      BRDY     : out    STD_LOGIC;
      BSTB_n   : in     STD_LOGIC);
end UA855D;

architecture RTL of UA855D is
   signal reset_n : std_logic;
begin
   
   reset_n <= '0' when (M1_n = '0' and RD_n = '1' and IORQ_n = '1') else '1';
   
end RTL;
