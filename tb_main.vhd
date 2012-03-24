
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_main IS
END tb_main;
 
ARCHITECTURE behavior OF tb_main IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Main
    PORT(
         SW : IN  std_logic_vector(7 downto 0);
         RESET : IN  std_logic;
         CLK : IN  std_logic;
         LED : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal SW : std_logic_vector(7 downto 0) := (others => '0');
   signal RESET : std_logic := '0';
   signal CLK : std_logic := '0';

 	--Outputs
   signal LED : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Main PORT MAP (
          SW => SW,
          RESET => RESET,
          CLK => CLK,
          LED => LED
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
      wait for 100 ns;
		RESET <= '0';
		wait for 100 ns;
		RESET <= '1';
      wait for CLK_period*1000000;
		
      wait;
   end process;

END;
