
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_U82720_UC IS
END tb_U82720_UC;
 
ARCHITECTURE behavior OF tb_U82720_UC IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT U82720_UC
    PORT(
         DB : INOUT  std_logic_vector(7 downto 0);
         A0 : IN  std_logic;
         RD_n : IN  std_logic;
         WR_n : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal A0 : std_logic := '0';
   signal RD_n : std_logic := '1';
   signal WR_n : std_logic := '1';

	--BiDirs
   signal DB : std_logic_vector(7 downto 0);

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: U82720_UC PORT MAP (
          DB => DB,
          A0 => A0,
          RD_n => RD_n,
          WR_n => WR_n
        );

   -- Stimulus process
   stim_proc: process
   begin
      wait for 20 ns;	
		
		-- reset
		
		wr_n <= '0';
		wait for 5 ns;
		a0 <= '1';
		db <= "00000000";
		wait for 5 ns;
		wr_n <= '1';
		wait for 5 ns;
		
		-- write fifo
		
		wr_n <= '0';
		a0 <= '0';
		db <= "10101010";
		wait for 5 ns;
		wr_n <= '1';
		wait for 5 ns;
		db <= (others => 'Z');
		wait for 5 ns;
		
		-- read fifo
		
		rd_n <= '0';
		a0 <= '1';
		db <= "ZZZZZZZZ";
		wait for 5 ns;
		rd_n <= '1';
		wait for 5 ns;
		
      wait;
   end process;

END;
