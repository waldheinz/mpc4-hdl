
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity U82720_SYNC is
   Port (
      CLK      : in     STD_LOGIC;
      DB       : in     STD_LOGIC_VECTOR (7 downto 0);
      ENABLE   : in     STD_LOGIC;
      SET      : in     STD_LOGIC_VECTOR (3 downto 0);
      
      HSYNC    : out    STD_LOGIC;
      VSYNC    : inout  STD_LOGIC;
      HBLANK   : out    STD_LOGIC; -- horizontal blank
      VBLANK   : out    STD_LOGIC; -- veritcal blank
      BLANK    : out    STD_LOGIC);
end U82720_SYNC;

architecture RTL of U82720_SYNC is
   
   --
   -- registers holding operating mode
   --
   signal aw   : unsigned(7 downto 0); -- active display words per line - 2 (always even; bit0=0)
   signal hs   : unsigned(4 downto 0); -- hsync pulse length - 1
   signal vs   : unsigned(4 downto 0); -- vsync pulse length (-1 ?)
   signal hfp  : unsigned(5 downto 0); -- horizontal front porch - 1
   signal hbp  : unsigned(5 downto 0); -- horizontal back porch - 1
   signal vfp  : unsigned(5 downto 0); -- vertical front porch - 1
   signal vbp  : unsigned(5 downto 0); -- vertical back porch - 1
   signal al   : unsigned(9 downto 0); -- active display lines per field
   
   --
   -- internal state
   --
   type V_STATE is (S_VFP, S_VSYNC, S_VBP, S_VACTIVE);
   type H_STATE is (S_HFP, S_HSYNC, S_HBP, S_HACTIVE);
   signal vstate : V_STATE;
   signal hstate : H_STATE;
   signal line_cnt : unsigned(7 downto 0); -- counts the pixels in a line
   signal field_cnt : unsigned(9 downto 0); -- counts the lines in a display field
   signal vstate_end : unsigned(7 downto 0); -- line number when vstate should advance
   signal hstate_end : unsigned(9 downto 0); -- row number when hstate should advance
   signal reset : std_logic;
   signal v_blank : std_logic;
   signal h_blank : std_logic;
   
begin
   
   HBLANK <= h_blank;
   VBLANK <= v_blank;
   BLANK <= h_blank or v_blank;
   
   hstate_end <=
      "0000"  & hfp when (hstate = S_HFP) else
      "00000" & hs  when (hstate = S_HSYNC) else
      "0000"  & hbp when (hstate = S_HBP) else
      al;
   
   vstate_end <=
      "00"  & vfp when (vstate = S_VFP) else
      "000" & vs  when (vstate = S_VSYNC) else
      "00"  & vbp when (vstate = S_VBP) else
      aw;
   
   reset <= '0' when SET = "0000" else '1';
   
 --  proc_pixels : process(CLK, line_cnt, reset)
 --  begin
 --     if (reset = '1') then
 --        line_cnt <= (others => '0');
 --     elsif (rising_edge(CLK)) then
 --        line_cnt <= line_cnt + 1;
 --     end if;
 --  end process;
   
   HSYNC <= '1' when hstate = S_HSYNC else '0';
   h_blank <= '0' when hstate = S_HACTIVE else '1';
   
   proc_hsync : process(CLK, hstate, line_cnt, field_cnt, hstate_end, vstate_end, reset)
   begin
      if (reset = '1') then
         hstate <= s_HFP;
         field_cnt <= (others => '0');
         line_cnt <= (others => '0');
      elsif (rising_edge(CLK)) then
         if (line_cnt = hstate_end) then
            line_cnt <= (others => '0');
            
            case hstate is
               when S_HFP => hstate <= S_HSYNC;
               when S_HSYNC => hstate <= S_HBP;
               when S_HBP => hstate <= S_HACTIVE;
               when others =>
                  hstate <= S_HFP;
                  if (field_cnt = vstate_end) then
                     field_cnt <= (others => '0');
                  else
                     field_cnt <= field_cnt + 1;
                  end if;
            end case;
         else
            line_cnt <= line_cnt + 1;
         end if;
      end if;
   end process;
   
   VSYNC <= '1' when vstate = S_VSYNC else '0';
   v_blank <= '0' when vstate = S_VACTIVE else '1';
   
   proc_vsync : process(CLK, vstate, field_cnt, vstate_end)
   begin
      if (rising_edge(CLK)) then
         if (field_cnt = vstate_end) then
            case vstate is
               when S_VFP => vstate <= S_VSYNC;
               when S_VSYNC => vstate <= S_VBP;
               when S_VBP => vstate <= S_VACTIVE;
               when others => vstate <= S_VFP;
            end case;
         end if;
      end if;
   end process;
   
   -- reads configuration values from DB and stores them in registers
   proc_config : process(CLK, DB, SET)
      -- the index matches the parameter byte numbers for RESET / SYNC commands
      variable idx : integer;
   begin
      if (rising_edge(CLK)) then
         idx := to_integer(unsigned(SET));
         case idx is
            when 2 =>
               aw <= unsigned(DB);
               
            when 3 =>
               vs(2 downto 0) <= unsigned(DB(7 downto 5));
               hs <= unsigned(DB(4 downto 0));
               
            when 4 =>
               hfp <= unsigned(DB(7 downto 2));
               vs(4 downto 3) <= unsigned(DB(1 downto 0));
               
            when 5 =>
               hbp <= unsigned(DB(5 downto 0));
            
            when 6 =>
               vfp <= unsigned(DB(5 downto 0));
               
            when 7 =>
               al(7 downto 0) <= unsigned(DB);
               
            when 8 =>
               vbp <= unsigned(DB(7 downto 2));
               al(9 downto 8) <= unsigned(DB(1 downto 0));
               
            when others =>
               null; -- keep values
         end case;
      end if;
   end process;

end RTL;
