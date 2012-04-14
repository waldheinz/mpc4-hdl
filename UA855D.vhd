
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UA855D is
   Port (
      -- Clock
      CLK      : in     STD_LOGIC;
      
      -- CPU Data Bus
      D        : inout  STD_LOGIC_VECTOR (7 downto 0);
      
      -- PIO Control
      B_A_SEL  : in     STD_LOGIC;
      C_D_SEL  : in     STD_LOGIC;
      CS_n     : in     STD_LOGIC;
      M1_n     : in     STD_LOGIC;
      IORQ_n   : in     STD_LOGIC;
      RD_n     : in     STD_LOGIC;
      
      -- Interrupt Control
      IEI      : in     STD_LOGIC;
      IEO      : out    STD_LOGIC;
      INT_n    : out    STD_LOGIC;
      
      -- Port A I/O
      A        : inout  STD_LOGIC_VECTOR (7 downto 0);
      ARDY     : out    STD_LOGIC;
      ASTB_n   : in     STD_LOGIC;
      
      -- Port B I/O
      B        : inout  STD_LOGIC_VECTOR (7 downto 0);
      BRDY     : out    STD_LOGIC;
      BSTB_n   : in     STD_LOGIC);
end UA855D;

architecture RTL of UA855D is
   
   type PORT_REG_TABLE is array(1 downto 0) of std_logic_vector(7 downto 0);
   
   type PORT_CTRL_STATE_TYPE is (CS_WAIT_CMD, CS_WAIT_IOSEL);
   type PORT_CTRL_STATE_TBL is array(1 downto 0) of PORT_CTRL_STATE_TYPE;
   signal port_ctrl_state : PORT_CTRL_STATE_TBL;
   
   -- Port Modes
   type PORT_MODE_TYPE is (M_OUTP, M_INPU, M_BIDI, M_CTRL);
   type PORT_MODE_TABLE is array(1 downto 0) of PORT_MODE_TYPE;
   signal port_mode : PORT_MODE_TABLE;
   
   -- Port specific Registers
   signal port_out      : PORT_REG_TABLE; -- Port Output Registers
   signal port_io_sel   : PORT_REG_TABLE; -- Port I/O Select
   
   signal reset_n : std_logic; -- internal async reset signal
   signal port_select : integer range 0 to 1; -- 0 is port A, 1 is B
   
begin
   D <= (others => 'Z');
   
   reset_n <= '0' when (M1_n = '0' and RD_n = '1' and IORQ_n = '1' and CS_n = '0') else '1';
   port_select <= 0 when B_A_SEL = '0' else 1;
   
   proc_ctrl : process (B_A_SEL, C_D_SEL, CLK, D, RD_n, port_select)
   begin
      if (reset_n = '0') then
         for i in 0 to 1 loop
            port_ctrl_state(i) <= CS_WAIT_CMD;
         end loop;
      elsif (rising_edge(CLK) and CS_n = '0' and RD_n = '1' and C_D_SEL = '1') then
         case port_ctrl_state(port_select) is
            when CS_WAIT_CMD =>
               case D(3 downto 0) is
                  when "1111" => -- set mode
                     case D(7 downto 6) is
                        when "00"   => port_mode(port_select) <= M_OUTP;
                        when "01"   => port_mode(port_select) <= M_INPU;
                        when "10"   => port_mode(port_select) <= M_BIDI;
                        when others =>
                           port_mode(port_select) <= M_CTRL;
                           port_ctrl_state(port_select) <= CS_WAIT_IOSEL;
                     end case;
               
                  when others => null;
               end case;
             
            when CS_WAIT_IOSEL =>
               port_io_sel(port_select) <= D;
               port_ctrl_state(port_select) <= CS_WAIT_CMD;
               
            when others => null;
         end case;
      end if;
   end process;
   
end RTL;
