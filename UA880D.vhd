
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UA880D is
    Port ( D : inout  STD_LOGIC_VECTOR (7 downto 0);
           WAIT_n : in  STD_LOGIC;
           INT_n : in  STD_LOGIC;
           NMI_n : in  STD_LOGIC;
           RESET_n : in  STD_LOGIC;
			  BUSRQ_n : in STD_LOGIC;
           C_n : in  STD_LOGIC;
           A : out  STD_LOGIC_VECTOR (15 downto 0);
           M1_n : out  STD_LOGIC;
           MREQ_n : out  STD_LOGIC;
           IORQ_n : out  STD_LOGIC;
           RD_n : out  STD_LOGIC;
           WR_n : out  STD_LOGIC;
           RFSH_n : out  STD_LOGIC;
           HALT_n : out  STD_LOGIC;
           BUSAK_n : out  STD_LOGIC);
end UA880D;

architecture Behave of UA880D is

	COMPONENT T80a
	PORT(
		RESET_n : IN std_logic;
		CLK_n : IN std_logic;
		WAIT_n : IN std_logic;
		INT_n : IN std_logic;
		NMI_n : IN std_logic;
		BUSRQ_n : IN std_logic;    
		D : INOUT std_logic_vector(7 downto 0);      
		M1_n : OUT std_logic;
		MREQ_n : OUT std_logic;
		IORQ_n : OUT std_logic;
		RD_n : OUT std_logic;
		WR_n : OUT std_logic;
		RFSH_n : OUT std_logic;
		HALT_n : OUT std_logic;
		BUSAK_n : OUT std_logic;
		A : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
begin

Inst_T80a: T80a PORT MAP(
		RESET_n => RESET_n,
		CLK_n => C_n,
		WAIT_n => WAIT_n,
		INT_n => INT_n,
		NMI_n => NMI_n,
		BUSRQ_n => BUSRQ_n,
		M1_n => M1_n,
		MREQ_n => MREQ_n,
		IORQ_n => IORQ_n,
		RD_n => RD_n,
		WR_n => WR_n,
		RFSH_n => RFSH_n,
		HALT_n => HALT_n,
		BUSAK_n => BUSAK_n,
		A => A,
		D => D
	);

end Behave;
