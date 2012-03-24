
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--
-- Microcontroller Interface of U82720
--

entity U82720_UC is
	Port (
		DB 	: inout	STD_LOGIC_VECTOR (7 downto 0);
		
		-- read:  0 -> status register, 1 -> FIFO
		-- write: 0 -> FIFO parameter,  1 -> FIFO command
		A0 	: in  	STD_LOGIC;
      RD_n 	: in  	STD_LOGIC;
      WR_n	: in  	STD_LOGIC;
		LPD	: in		STD_LOGIC;  -- light pen detect
		HSYNC	: in		STD_LOGIC;
		VSYNC	: in 		STD_LOGIC;
		DMA_A	: in 		STD_LOGIC;  -- DMA active
		PAINT	: in 		STD_LOGIC); -- paint in progress
end U82720_UC;

architecture RTL of U82720_UC is
	-- FIFO
	subtype FIFO_WORD is std_logic_vector(8 downto 0);
	type FIFO_TABLE is array(0 to 15) of FIFO_WORD;
	signal fifo_rd	: unsigned(3 downto 0);
	signal fifo_wr : unsigned(3 downto 0);
	signal fifo : FIFO_TABLE;
	
	-- 7: light pen detect, 6: hblank, vsync, 5: vsnyc, 4: dma exec, 3: drawing in progress, 2: FIFO empty, 1: FIFO full, 0: data ready
	signal status_reg : std_logic_vector (7 downto 0);
	
	signal data_out : std_logic_vector (7 downto 0);
	signal reset : std_logic;
	
begin
	DB <= data_out when (RD_n = '0') else (others => 'Z');
	
	status_reg(7) <= LPD;
	status_reg(6) <= HSYNC;
	status_reg(5) <= VSYNC;
	status_reg(4) <= DMA_A;
	status_reg(3) <= PAINT;
	status_reg(2) <= '1' when (fifo_rd = fifo_wr) else '0'; -- FIFO empty
	status_reg(1) <= '1' when (fifo_rd = (fifo_wr + 1)) else '0'; -- FIFO full (keep one slot empty)
	
	proc_reset: process (A0, WR_n, DB)
	begin
		if ((A0 = '1') and WR_n = '0' and DB="00000000") then
			reset <= '1';
		end if;
	end process;
	
	proc_reset2: process (reset, WR_n)
	begin
		if (falling_edge(WR_n)) then
			if (reset = '1') then
				fifo_wr <= (others => '0');
				fifo_rd <= (others => '0');
				reset <= '0';
			end if;
		end if;
	end process;
	
	proc_write: process (DB, A0, WR_n, fifo_wr)
	begin
		if (rising_edge(WR_n)) then
	--		reset <= '0';
			if (A0 = '1') then
				if (DB = "00000000") then
					-- RESET
					reset <= '1';
				else
					-- write FIFO command
					fifo(to_integer(fifo_wr)) <= '1' & DB;
					fifo_wr <= fifo_wr + 1;
				end if;
			else
				-- write FIFO parameter
				fifo(to_integer(fifo_wr)) <= '0' & DB;
				fifo_wr <= fifo_wr + 1;
			end if;
		end if;
	end process;
	
	proc_read: process (A0, RD_n, fifo_rd, status_reg)
	begin
		if (falling_edge(RD_n)) then
			if (A0 = '0') then
				data_out <= status_reg;
			else
				data_out <= fifo(to_integer(fifo_rd))(7 downto 0);
	--			fifo_rd <= fifo_rd + 1;
			end if;
		end if;
	end process;
	
end RTL;
