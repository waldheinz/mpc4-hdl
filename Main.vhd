
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
		SW 	: in STD_LOGIC_VECTOR(7 downto 0);
		RESET : in STD_LOGIC;
		CLK	: in STD_LOGIC; -- 100 MHz clock from board
		LED 	: out STD_LOGIC_VECTOR(7 downto 0)
	);
end Main;

architecture Behave of Main is

	signal addr_bus 		: std_logic_vector(17 downto 1);
	signal data_bus		: std_logic_vector(8 downto 1);
	signal chip_select	: std_logic_vector(8 downto 1);
	signal dc_8_1_out		: std_logic_vector(7 downto 0);
	signal dc_8_4_out		: std_logic_vector(7 downto 0);
	signal nand_1_2		: std_logic;
	signal dack_n			: std_logic;
	signal reset_n			: std_logic;
	signal clock_n			: std_logic;
	signal wait_n			: std_logic;
	signal int_n			: std_logic;
	signal nmi_n			: std_logic;
	signal busrq_n			: std_logic;
	signal mreq_n			: std_logic;
	signal iorq_n			: std_logic;
	signal rfsh_n			: std_logic;
	signal m1				: std_logic;
	signal rd				: std_logic;
	signal wr				: std_logic;
	signal cup16_m1_out 	: std_logic;
   signal cpu16_bus_ack : std_logic;
	signal aus_n			: std_logic;
	signal clock_locked	: std_logic; -- locked output of the 4MHz DCG
   
	signal dma16_int_n   : std_logic;
   signal dma16_ieo     : std_logic;
   signal bus_ack       : std_logic;
   signal drq_n         : std_logic;
   
	COMPONENT CLOCK_GEN
	PORT(
		CLK_IN1 : IN std_logic;
		RESET : IN std_logic;          
		CLK_OUT1 : OUT std_logic;
		LOCKED : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT UA880D
	PORT(
		WAIT_n : IN std_logic;
		INT_n : IN std_logic;
		NMI_n : IN std_logic;
		RESET_n : IN std_logic;
		BUSRQ_n : IN std_logic;
		C_n : IN std_logic;    
		D : INOUT std_logic_vector(7 downto 0);      
		A : OUT std_logic_vector(15 downto 0);
		M1_n : OUT std_logic;
		MREQ_n : OUT std_logic;
		IORQ_n : OUT std_logic;
		RD_n : OUT std_logic;
		WR_n : OUT std_logic;
		RFSH_n : OUT std_logic;
		HALT_n : OUT std_logic;
		BUSAK_n : OUT std_logic
		);
	END COMPONENT;
	
   COMPONENT UA858D
	PORT(
		WR_n : IN std_logic;
		RD_n : IN std_logic;
		IORQ_n : IN std_logic;
		MREQ_n : IN std_logic;
		BUSRQ_n : IN std_logic;
		C : IN std_logic;
		M1_n : IN std_logic;
		CS_WAIT_n : IN std_logic;
		IEI : IN std_logic;
		BAI_n : IN std_logic;
		RDY : IN std_logic;    
		D : INOUT std_logic_vector(7 downto 0);      
		A : OUT std_logic_vector(15 downto 0);
		IEO : OUT std_logic;
		BAO_n : OUT std_logic;
		INT_n : OUT std_logic
		);
	END COMPONENT;
   
	COMPONENT RESET_LOGIC
	PORT(
		a : IN std_logic_vector(17 downto 1);
		reset_n : IN std_logic;
		clock_n : IN std_logic;
		mreq_n : IN std_logic;
		iorq_n : IN std_logic;
		wr_n : IN std_logic;
		m1_n : IN std_logic;          
		aus_n : OUT std_logic;
		wait_n : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT U2732
	PORT(
		A : IN std_logic_vector(11 downto 0);
		CE_n : IN std_logic;
		OE_n : IN std_logic;          
		D : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
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
	process (SW, aus_n, reset_n)
	begin
		if (reset_n = '0') then
			LED <= (others => '1');
		else
			LED(6 downto 0) <= (others => '0');
			LED(7) <= not aus_n;
		end if;
	end process;
	
	CLK_GEN: CLOCK_GEN PORT MAP(
		CLK_IN1 => CLK,
		CLK_OUT1 => clock_n,
		RESET => '0',
		LOCKED => clock_locked
	);
	
	reset_n <= (RESET and clock_locked);
	
	CPU_16: UA880D PORT MAP(
		D => data_bus,
		WAIT_n => wait_n,
		INT_n => int_n,
		NMI_n => nmi_n,
		RESET_n => reset_n,
		BUSRQ_n => busrq_n,
		C_n => clock_n,
		A => addr_bus(16 downto 1),
		M1_n => cup16_m1_out,
		MREQ_n => mreq_n,
		IORQ_n => iorq_n,
		RD_n => rd,
		WR_n => wr,
		RFSH_n => rfsh_n,
--		HALT_n => ,
		BUSAK_n => cpu16_bus_ack
	);
	
   DMA_17 : UA858D PORT MAP(
		D => data_bus,
      WR_n => wr,
		RD_n => rd,
		IORQ_n => iorq_n,
		MREQ_n => mreq_n,
		BUSRQ_n => busrq_n,
		C => clock_n,
		M1_n => m1,
		CS_WAIT_n => dc_8_1_out(7),
		IEI => '1',
		BAI_n => cpu16_bus_ack,
		RDY => drq_n,
		A => addr_bus(16 downto 1),
		IEO => dma16_ieo,
		BAO_n => bus_ack,
		INT_n => dma16_int_n
	);
   
	int_n <= dma16_int_n;
	nmi_n <= '1';
	busrq_n <= '1';
	
	RST_LOGIC: RESET_LOGIC PORT MAP(
		a => addr_bus,
		reset_n => reset_n,
		clock_n => clock_n,
		mreq_n => mreq_n,
		iorq_n => iorq_n,
		wr_n => wr,
		m1_n => m1,
		aus_n => aus_n,
		wait_n => wait_n
	);
	
	EPROM_20: U2732 PORT MAP(
		A => addr_bus(12 downto 1),
		CE_n => aus_n,
		OE_n => rd,
		D => data_bus
	);
	
	and_3 : process(cup16_m1_out, reset_n)
	begin
		m1 <= cup16_m1_out and reset_n;
	end process;
	
	DC_8_1: DS8205D PORT MAP(
		A => addr_bus(3 downto 1),
		E1_n => chip_select(8),
		E2_n => chip_select(8),
		E3 => '1',
		O => dc_8_1_out
	);
	
	dack_n <= dc_8_1_out(5);
	addr_bus(17) <= dc_8_1_out(6);
	
	nand_1_2 <= '0' when (addr_bus(8 downto 6) = "111") else '1';
	
	DC_8_4: DS8205D PORT MAP(
		A => addr_bus(5 downto 3),
		E1_n => nand_1_2,
		E2_n => iorq_n,
		E3 => m1,
		O => dc_8_4_out
	);
	
	chip_select(4 downto 1) <= dc_8_4_out(3 downto 0);
	chip_select(8 downto 6) <= dc_8_4_out(7 downto 5);
end Behave;
