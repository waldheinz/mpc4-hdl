
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

--
-- Video RAM Controller
--
entity U82720_GMI is
	Port (
      --
      -- GDC internal Interface
      --
      DB          : inout  STD_LOGIC_VECTOR (7 downto 0);
      CLK         : in     STD_LOGIC;
      
      -- external access to the mask register
      MASK_LOADL  : in     STD_LOGIC;
      MASK_LOADH  : in     STD_LOGIC;
      MASK_SHL    : in     STD_LOGIC;
      MASK_SHR    : in     STD_LOGIC;
      MASK_MSB    : out    STD_LOGIC;
      MASK_LSB    : out    STD_LOGIC;
      
      -- external settign of pattern register
      PTRN_LOADL  : in     STD_LOGIC;
      PTRN_LOADH  : in     STD_LOGIC;
      
      --
      -- Memory Interface
      --
		AD          : inout  STD_LOGIC_VECTOR (15 downto 0);
      
      -- in graphics mode: bit 16, 17 of 18-bit address in memory
      -- in character mode: A_16 is MSB of line counter, A_17 outputs cursor signal
      -- in mixed mode: A_16 is external line counter clear pulse, A_17 signals whether next raster line is bitmap or characters
      -- values may change during first clock cycle of memory cycle or fourth clock cycle of RMW cycle
      A_16  : out    STD_LOGIC;
      A_17  : out    STD_LOGIC);
end U82720_GMI;

architecture RTL of U82720_GMI is
   
   signal mask : std_logic_vector (15 downto 0); -- mask register
   signal ptrn : std_logic_vector (15 downto 0); -- pattern register
   
   signal rmw_cycle_cnt : unsigned(3 downto 0);
   signal rmw_ptrn : std_logic_vector(15 downto 0); -- currently effective pattern for RMW logic
   signal rmw_graphics : std_logic;
   
begin
   DB <= (others => 'Z');
   
   rmw_graphics <= '1';
   
   -- concurrent output of mask LSB and MSB
   MASK_MSB <= mask(15);
   MASK_LSB <= mask(0);
   
   -- mask loading and shifting
   proc_mask : process(CLK, DB, MASK_LOADL, MASK_LOADH, MASK_SHL, MASK_SHR)
      variable tmp : std_logic;
   begin
      if (rising_edge(CLK)) then
         if (MASK_LOADL = '1') then
            mask(7 downto 0) <= DB;
         elsif (MASK_LOADH = '1') then
            mask(15 downto 8) <= DB;
         elsif (MASK_SHL = '1') then
            tmp := mask(15);
            mask(15 downto 1) <= mask(14 downto 0);
            mask(0) <= tmp;
         elsif (MASK_SHR = '1') then
            tmp := mask(0);
            mask(14 downto 0) <= mask(15 downto 1);
            mask(15) <= tmp;
         end if;
      end if;
   end process;
   
   -- pattern loading
   proc_ptrn : process(CLK, DB, PTRN_LOADL, PTRN_LOADH)
   begin
      if (rising_edge(CLK)) then
         if (PTRN_LOADL = '1') then
            ptrn(7 downto 0) <= DB;
         elsif (PRTN_LOADH = '1') then
            ptrn(15 downto 8) <= DB;
         end if;
      end if;
   end process;
   
   -- deternmine effective pattern for RMW logic
   proc_rmw_ptrn : process(ptrn, rmw_cycle_cnt, rmw_graphics)
   begin
      if (rmw_graphics = '1') then
         rmw_ptrn <= (others => ptrn(15 - rmw_cycle_count));
      else
         rmw_ptrn <= ptrn;
      end if;
   end process;
   
end RTL;
