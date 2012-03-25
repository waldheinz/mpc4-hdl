
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--
-- Microcontroller Interface of U82720 (the bidirectional FIFO)
--

entity U82720_UC is
	Port (
		--
		-- Host Interface
		--
		DB_H 		: inout	STD_LOGIC_VECTOR (7 downto 0); -- data bus to host
		A0 		: in  	STD_LOGIC;
      RDH_n 	: in  	STD_LOGIC;
      WRH_n		: in  	STD_LOGIC;
		
		--
		-- Internal Interface
		--
		DB_I		: inout	STD_LOGIC_VECTOR(7 downto 0); -- internal data bus
		RDI_n		: in		STD_LOGIC;
		WRI_n		: in		STD_LOGIC;
		DB_DIR	: in		STD_LOGIC; -- 0 -> from host to gdc, 1 -> from gdc to host
		LPD		: in		STD_LOGIC; -- light pen detect
		HSYNC		: in		STD_LOGIC;
		VSYNC		: in 		STD_LOGIC;
		DMA_A		: in 		STD_LOGIC; -- DMA active
		PAINT		: in 		STD_LOGIC; -- paint in progress
		EMPTY		: out		STD_LOGIC; -- FIFO empty
		RESET_n	: out		STD_LOGIC);
end U82720_UC;

architecture RTL of U82720_UC is
	-- FIFO
	subtype FIFO_WORD is std_logic_vector(8 downto 0);
	type FIFO_TABLE is array(0 to 15) of FIFO_WORD;
	signal fifo_h : unsigned(3 downto 0); -- fifo position for host interface
	signal fifo_i : unsigned(3 downto 0); -- fifo position for internal interface
	signal fifo : FIFO_TABLE;
	
	-- 7: light pen detect, 6: hblank, vsync, 5: vsnyc, 4: dma exec, 3: drawing in progress, 2: FIFO empty, 1: FIFO full, 0: data ready
	signal status_reg : std_logic_vector (7 downto 0);
	signal data_out 	: std_logic_vector (7 downto 0); -- data output buffer
	signal reset : std_logic; -- if a reset was requested with the last write cycle
	
begin
	DB_H <= data_out when (RDH_n = '0') else (others => 'Z');
	
	status_reg(7) <= LPD;
	status_reg(6) <= HSYNC;
	status_reg(5) <= VSYNC;
	status_reg(4) <= DMA_A;
	status_reg(3) <= PAINT;
	status_reg(2) <= '1' when (fifo_h = fifo_i) else '0'; -- FIFO empty
	status_reg(1) <= '1' when (fifo_h = (fifo_i + 1)) else '0'; -- FIFO full (keep one slot empty)
	RESET_n <= reset;
	
	proc_host: process (DB_H, A0, RDH_n, WRH_n, fifo_h, status_reg)
	begin
		if (rising_edge(WRH_n)) then
			reset <= '1';
			
			if ((A0 = '1') and (DB_H = "00000000")) then
				-- RESET
				reset <= '0';
				fifo_h <= (others => '0');
			else
				-- FIFO write
				fifo(to_integer(fifo_h)) <= A0 & DB_H;
				fifo_h <= fifo_h + 1;
			end if;
		elsif (falling_edge(RDH_n)) then			
			if (A0 = '0') then
				data_out <= status_reg;
			else
				data_out <= fifo(to_integer(fifo_h))(7 downto 0);
				fifo_h <= fifo_h + 1;
			end if;
		end if;
	end process;
	
	proc_int : process(reset)
	begin
		
	end process;
	
end RTL;
