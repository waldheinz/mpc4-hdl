
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

--
-- Graphics - Display - Controller 1
--
entity GDC1 is
   Port (
      DB       : inout  STD_LOGIC_VECTOR (7 downto 0);
      IRD      : in     STD_LOGIC;
      IWR      : in     STD_LOGIC;
      AB       : in     STD_LOGIC_VECTOR (7 downto 0);
      IODI_n   : in     STD_LOGIC;
      IORQ_n   : in     STD_LOGIC;
      M1_n     : in     STD_LOGIC;
      HSYNC    : out    STD_LOGIC;
      VSYNC    : out    STD_LOGIC;
      BA       : out    STD_LOGIC);
end GDC1;

architecture RTL of GDC1 is

   COMPONENT DS8205D
	PORT(
		A : IN std_logic_vector(2 downto 0);
		E1_n : IN std_logic;
		E2_n : IN std_logic;
		E3 : IN std_logic;          
		O : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
   
   signal ds_1_out : std_logic_vector(7 downto 0);
   signal ds_2_out : std_logic_vector(7 downto 0);
   
begin
   DB <= (others => 'Z');
   
   DS_1: DS8205D PORT MAP(
		A => ab(7 downto 5),
		E1_n => IORQ_n,
		E2_n => '0',
		E3 => M1_n,
		O => ds_1_out
	);
   
   DS_2: DS8205D PORT MAP(
		A => ab(4 downto 2),
		E1_n => ab(1),
		E2_n => ds_1_out(3), -- there happens a reset / initalization, makes sense
		E3 => IODI_n,
		O => ds_2_out
	);
   
end RTL;
