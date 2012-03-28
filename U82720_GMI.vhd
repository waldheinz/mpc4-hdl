
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
      
      -- external setting of pattern register
      PTRN_LOADL  : in     STD_LOGIC;
      PTRN_LOADH  : in     STD_LOGIC;
      
      -- logical RMW operation select
      RMW_OP      : in     STD_LOGIC_VECTOR(1 downto 0);
      
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
   
   signal rd_data : std_logic_vector(15 downto 0); -- input buffer from RAM
   signal wr_data : std_logic_vector(15 downto 0); -- output of RMW logic for writing to RAM
   
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
         elsif (PTRN_LOADH = '1') then
            ptrn(15 downto 8) <= DB;
         end if;
      end if;
   end process;
   
   -- deternmine effective pattern for RMW logic
   proc_rmw_ptrn : process(ptrn, rmw_cycle_cnt, rmw_graphics)
   begin
      if (rmw_graphics = '1') then
         rmw_ptrn <= (others => ptrn(to_integer(rmw_cycle_cnt)));
      else
         rmw_ptrn <= ptrn;
      end if;
   end process;
   
   -- RMW logic block
   proc_rmw_logic : process(rmw_ptrn, RMW_OP, mask, rd_data)
      variable replace_op, do_replace : std_logic;
   begin
      replace_op := '1' when RMW_OP = "00" else '0';
      
      for n in 0 to 15 loop
         do_replace := mask(n) when replace_op = '1' else mask(n) and rmw_ptrn(n);
         
         if (do_replace = '1') then
            case RMW_OP is
               when "00" => wr_data(n) <= rmw_ptrn(n); -- replace
               when "01" => wr_data(n) <= not rd_data(n); -- complement
               when "10" => wr_data(n) <= '0'; -- reset
               when "11" => wr_data(n) <= '1'; -- set
            end case;
         else
            wr_data(n) <= rd_data(n);
         end if;
         
      end loop;
   end process;
   
end RTL;
