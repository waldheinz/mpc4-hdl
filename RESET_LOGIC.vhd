
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RESET_LOGIC is
	Port (
		a			: in  STD_LOGIC_VECTOR(17 downto 1);
		reset_n 	: in  STD_LOGIC;
		clock_n	: in  STD_LOGIC;
		mreq_n	: in  STD_LOGIC;
		iorq_n	: in 	STD_LOGIC;
		wr_n		: in  STD_LOGIC;
		m1_n		: in  STD_LOGIC;
		aus_n 	: out STD_LOGIC;
		wait_n	: out STD_LOGIC
	);
end RESET_LOGIC;

architecture Behave of RESET_LOGIC is

	COMPONENT DS8205D
	PORT(
		A : IN std_logic_vector(2 downto 0);
		E1_n : IN std_logic;
		E2_n : IN std_logic;
		E3 : IN std_logic;          
		O : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	signal t_9_1_1_qn			: std_logic;
	signal t_9_1_2_qn			: std_logic;
	signal nand_4_1_1_out	: std_logic;
	signal dc_8_2_d			: std_logic_vector(7 downto 0);
	
begin
	aus_n <= not (nand_4_1_1_out and t_9_1_2_qn);
	nand_4_1_1_out <= not (dc_8_2_d(3) and t_9_1_1_qn);
	wait_n <= '1';
	
	DC_8_2: DS8205D PORT MAP(
		A => a(15 downto 13),
		E1_n => mreq_n,
		E2_n => '0',
		E3 => a(16),
		O => dc_8_2_d
	);
	
	t_9_1_1 : process(reset_n, iorq_n)
	begin
		if (iorq_n = '0') then
			t_9_1_1_qn <= '1';
		elsif (reset_n = '0') then
			t_9_1_1_qn <= '0';
		end if;
	end process;
	
	t_9_1_2 : process(reset_n, a)
	begin
		if (reset_n = '0') then
			t_9_1_2_qn <= '1';
		elsif (rising_edge(a(17))) then
			-- irgend was mit delay in wr_n
		end if;
	end process;
	
end Behave;
