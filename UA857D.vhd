
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

--
-- CTC
--
entity UA857D is
   Port (
      D : inout  STD_LOGIC_VECTOR (7 downto 0);
      CS_n : in  STD_LOGIC;
      KS : in  STD_LOGIC_VECTOR (1 downto 0);
      M1_n : in  STD_LOGIC;
      IORQ_n : in  STD_LOGIC;
      RD_n : in  STD_LOGIC;
      IEI : in  STD_LOGIC;
      C_TRG : in  STD_LOGIC_VECTOR (3 downto 0);
      RESET_n : in  STD_LOGIC;
      C : in  STD_LOGIC;
      IEO : out  STD_LOGIC;
      ZC_TO : out  STD_LOGIC_VECTOR (2 downto 0);
      INT_n : out  STD_LOGIC);
end UA857D;

architecture RTL of UA857D is
   
begin
   
end RTL;
