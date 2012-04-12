
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--
-- DMA Controller
--
entity UA858D is
   Port (
      D           : inout  STD_LOGIC_VECTOR (7 downto 0);
      
      WR_n        : in     STD_LOGIC;
      RD_n        : in     STD_LOGIC;
      IORQ_n      : in     STD_LOGIC;
      MREQ_n      : in     STD_LOGIC;
      BUSRQ_n     : in     STD_LOGIC;
      
      C           : in     STD_LOGIC;
      M1_n        : in     STD_LOGIC;
      CS_WAIT_n   : in     STD_LOGIC;
      IEI         : in     STD_LOGIC;
      BAI_n       : in     STD_LOGIC;
      RDY         : in     STD_LOGIC;
      
      A           : out    STD_LOGIC_VECTOR (15 downto 0);
      IEO         : out    STD_LOGIC;
      BAO_n       : out    STD_LOGIC;
      INT_n       : out    STD_LOGIC);
end UA858D;

architecture RTL of UA858D is
   
begin
   D <= (others => 'Z');
   A <= (others => 'Z');
end RTL;
