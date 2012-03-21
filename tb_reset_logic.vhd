
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_reset_logic IS
END tb_reset_logic;
 
ARCHITECTURE behavior OF tb_reset_logic IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RESET_LOGIC
    PORT(
         a : IN  std_logic_vector(17 downto 1);
         reset_n : IN  std_logic;
         iorq_n : IN  std_logic;
         aus_n : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal a : std_logic_vector(17 downto 1) := (others => '0');
   signal reset_n : std_logic := '1';
   signal iorq_n : std_logic := '1';

 	--Outputs
   signal aus_n : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
--   constant <clock>_period : time := 10 ns;
 
BEGIN
	
	-- Instantiate the Unit Under Test (UUT)
   uut: RESET_LOGIC PORT MAP (
          a => a,
          reset_n => reset_n,
          iorq_n => iorq_n,
          aus_n => aus_n
        );

   -- Clock process definitions
 --  <clock>_process :process
--   begin
	--	<clock> <= '0';
--		wait for <clock>_period/2;
	--	<clock> <= '1';
	--	wait for <clock>_period/2;
 --  end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		reset_n <= '0';
		
--      wait for <clock>_period*10;
		wait for 100 ns;	
		reset_n <= '1';
		
		wait for 100 ns;
		iorq_n <= '0';
		
		wait for 100 ns;
		iorq_n <= '1';
		
		wait for 100 ns;
		a <= "01100000000000000";
		wait for 10 ns;
		iorq_n <= '0';
		
      -- insert stimulus here 

      wait;
   end process;

END;
