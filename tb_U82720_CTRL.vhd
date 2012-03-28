
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_U82720_CTRL IS
END tb_U82720_CTRL;
 
ARCHITECTURE behavior OF tb_U82720_CTRL IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT U82720_CTRL
    PORT(
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         DB : IN  std_logic_vector(7 downto 0);
         D_CMD : IN  std_logic;
         D_READY : IN  std_logic;
         FIFO_E : IN  std_logic;
         RD_REQ : OUT  std_logic;
         DB_DIR : OUT  std_logic
        );
    END COMPONENT;
    
   --Inputs
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '1';
   signal DB : std_logic_vector(7 downto 0) := (others => '0');
   signal D_CMD : std_logic := '0';
   signal D_READY : std_logic := '0';
   signal FIFO_E : std_logic := '1';

 	--Outputs
   signal RD_REQ : std_logic;
   signal DB_DIR : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: U82720_CTRL PORT MAP (
          CLK => CLK,
          RESET => RESET,
          DB => DB,
          D_CMD => D_CMD,
          D_READY => D_READY,
          FIFO_E => FIFO_E,
          RD_REQ => RD_REQ,
          DB_DIR => DB_DIR
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
      -- hold reset state for 100 ns.
      wait for 10 ns;
		reset <= '0';
		wait for 10 ns;
		reset <= '1';
		
		fifo_e <= '0';
		
		wait until rd_req = '1';
		
		DB <= "00011011";
		wait for 3 ns;
		d_ready <= '1';
		
      wait until rd_req = '0';
		wait for 3 ns;
		d_ready <= '0';
		wait until rd_req = '1';
		
		DB <= "10101010";
		wait for 3 ns;
		d_ready <= '1';
		
      wait;
   end process;

END;
