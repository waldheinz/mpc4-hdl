
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_U82720_GMI IS
END tb_U82720_GMI;
 
ARCHITECTURE behavior OF tb_U82720_GMI IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT U82720_GMI
    PORT(
         DB : INOUT  std_logic_vector(7 downto 0);
         CLK : IN  std_logic;
         MASK_LOADL : IN  std_logic;
         MASK_LOADH : IN  std_logic;
         MASK_SHL : IN  std_logic;
         MASK_SHR : IN  std_logic;
         MASK_MSB : OUT  std_logic;
         MASK_LSB : OUT  std_logic;
         AD : INOUT  std_logic_vector(15 downto 0);
         A_16 : OUT  std_logic;
         A_17 : OUT  std_logic
        );
    END COMPONENT;
   
   --Inputs
   signal CLK : std_logic := '0';
   signal MASK_LOADL : std_logic := '0';
   signal MASK_LOADH : std_logic := '0';
   signal MASK_SHL : std_logic := '0';
   signal MASK_SHR : std_logic := '0';

	--BiDirs
   signal DB : std_logic_vector(7 downto 0);
   signal AD : std_logic_vector(15 downto 0);

 	--Outputs
   signal MASK_MSB : std_logic;
   signal MASK_LSB : std_logic;
   signal A_16 : std_logic;
   signal A_17 : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: U82720_GMI PORT MAP (
          DB => DB,
          CLK => CLK,
          MASK_LOADL => MASK_LOADL,
          MASK_LOADH => MASK_LOADH,
          MASK_SHL => MASK_SHL,
          MASK_SHR => MASK_SHR,
          MASK_MSB => MASK_MSB,
          MASK_LSB => MASK_LSB,
          AD => AD,
          A_16 => A_16,
          A_17 => A_17
        );
   
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
      wait for 7 ns;
      
      DB <= "10000000";
      MASK_LOADH <= '1';
      
      wait for 10 ns;
      
      DB <= (others => '0');
      MASK_LOADH <= '0';
      MASK_LOADL <= '1';
      
      wait for 10 ns;
      MASK_LOADL <= '0';
      MASK_SHL <= '1';
      
      wait for 10 ns;
      
      MASK_SHL <= '0';
      MASK_SHR <= '1';
      
      wait;
   end process;

END;
