
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Main is
	Port(
		SW 	: in  STD_LOGIC_VECTOR(7 downto 0);
		LED 	: out STD_LOGIC_VECTOR(7 downto 0)
	);
end Main;

architecture Behave of Main is

	signal addr_bus 		: std_logic_vector(16 downto 1);
	signal chip_select	: std_logic_vector(8 downto 1);
	signal dc_8_1_out		: std_logic_vector(7 downto 0);
	signal dack_n			: std_logic;
	
	COMPONENT DS8205D
	PORT(
		A : IN std_logic_vector(2 downto 0);
		E1_n : IN std_logic;
		E2_n : IN std_logic;
		E3 : IN std_logic;          
		O : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
begin
	LED <= SW;
	
	DC_8_1: DS8205D PORT MAP(
		A => addr_bus(3 downto 1),
		E1_n => chip_select(8),
		E2_n => chip_select(8),
		E3 => '1',
		O => dc_8_1_out
	);
	
	dack_n <= dc_8_1_out(5);
	
end Behave;
