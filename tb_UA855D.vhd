
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_UA855D IS
END tb_UA855D;
 
ARCHITECTURE behavior OF tb_UA855D IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT UA855D
    PORT(
         CLK : IN  std_logic;
         D : INOUT  std_logic_vector(7 downto 0);
         B_A_SEL : IN  std_logic;
         C_D_SEL : IN  std_logic;
         CS_n : IN  std_logic;
         M1_n : IN  std_logic;
         IORQ_n : IN  std_logic;
         RD_n : IN  std_logic;
         IEI : IN  std_logic;
         IEO : OUT  std_logic;
         INT_n : OUT  std_logic;
         A : INOUT  std_logic_vector(7 downto 0);
         ARDY : OUT  std_logic;
         ASTB_n : IN  std_logic;
         B : INOUT  std_logic_vector(7 downto 0);
         BRDY : OUT  std_logic;
         BSTB_n : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal C : std_logic := '0';
   signal B_A_SEL : std_logic := '0';
   signal C_D_SEL : std_logic := '0';
   signal CS_n : std_logic := '0';
   signal M1_n : std_logic := '0';
   signal IORQ_n : std_logic := '0';
   signal RD_n : std_logic := '0';
   signal IEI : std_logic := '0';
   signal ASTB_n : std_logic := '0';
   signal BSTB_n : std_logic := '0';

	--BiDirs
   signal D : std_logic_vector(7 downto 0);
   signal A : std_logic_vector(7 downto 0);
   signal B : std_logic_vector(7 downto 0);

 	--Outputs
   signal IEO : std_logic;
   signal INT_n : std_logic;
   signal ARDY : std_logic;
   signal BRDY : std_logic;
   
   constant C_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: UA855D PORT MAP (
          CLK => C,
          D => D,
          B_A_SEL => B_A_SEL,
          C_D_SEL => C_D_SEL,
          CS_n => CS_n,
          M1_n => M1_n,
          IORQ_n => IORQ_n,
          RD_n => RD_n,
          IEI => IEI,
          IEO => IEO,
          INT_n => INT_n,
          A => A,
          ARDY => ARDY,
          ASTB_n => ASTB_n,
          B => B,
          BRDY => BRDY,
          BSTB_n => BSTB_n
        );

   -- Clock process definitions
   C_process :process
   begin
		C <= '0';
		wait for C_period/2;
		C <= '1';
		wait for C_period/2;
   end process;
   
   stim_proc: process
   begin
      -- reset
      RD_n <= '1';
      IORQ_n <= '1';
      wait for C_period*10;

      -- set port A ctrl mode
      CS_n <= '1';
      M1_n <= '1';
      C_D_SEL <= '1';
      D <= "11001111";
      wait for 20 ns;
      
      CS_n <= '0';
      
      wait for 20 ns;
      
      -- set port A pins i/o mode
      CS_n <= '1';
      D <= "10000000";
      wait for 20 ns;
      
      CS_n <= '0';
      
      wait;
   end process;

END;
