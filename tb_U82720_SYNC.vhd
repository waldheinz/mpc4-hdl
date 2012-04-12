
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY tb_U82720_SYNC IS
END tb_U82720_SYNC;
 
ARCHITECTURE behavior OF tb_U82720_SYNC IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
   
    COMPONENT U82720_SYNC
    PORT(
         CLK : IN  std_logic;
         DB : IN  std_logic_vector(7 downto 0);
         ENABLE : IN  std_logic;
         SET : IN  std_logic_vector(3 downto 0);
         HSYNC : OUT  std_logic;
         VSYNC : INOUT  std_logic;
         BLANK : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal DB : std_logic_vector(7 downto 0) := (others => '0');
   signal ENABLE : std_logic := '0';
   signal SET : std_logic_vector(3 downto 0) := (others => '0');

	--BiDirs
   signal VSYNC : std_logic;

 	--Outputs
   signal HSYNC : std_logic;
   signal BLANK : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: U82720_SYNC PORT MAP (
          CLK => CLK,
          DB => DB,
          ENABLE => ENABLE,
          SET => SET,
          HSYNC => HSYNC,
          VSYNC => VSYNC,
          BLANK => BLANK
        );
   
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
   
   stim_proc: process
   begin
      
      DB <= std_logic_vector(to_unsigned(320, 8));
      SET <= std_logic_vector(to_unsigned(2, 4));
      wait for CLK_period;
      
      DB <= "10100101";
      SET <= std_logic_vector(to_unsigned(3, 4));
      wait for CLK_period;
      
      DB <= "00101011";
      SET <= std_logic_vector(to_unsigned(4, 4));
      wait for CLK_period;
      
      DB <= "00000011";
      SET <= std_logic_vector(to_unsigned(5, 4));
      wait for CLK_period;
      
      DB <= "00001011";
      SET <= std_logic_vector(to_unsigned(6, 4));
      wait for CLK_period;
      
      DB <= std_logic_vector(to_unsigned(200, 8));
      SET <= std_logic_vector(to_unsigned(7, 4));
      wait for CLK_period;
      
      DB <= "00010000";
      SET <= std_logic_vector(to_unsigned(8, 4));
      wait for CLK_period;
      
      ENABLE <= '1';
      
      wait;
   end process;

END;
