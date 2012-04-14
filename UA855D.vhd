
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
   
   -- State Machine for Bus access
   type BUS_STATE_TYPE is (BS_WAIT, BS_READ, BS_WRITE, BS_WAIT_DONE);
   signal bus_state : BUS_STATE_TYPE;
   
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
   signal port_in       : PORT_REG_TABLE; -- Port input Registers (from port to host)
   
   signal reset_n : std_logic; -- internal async reset signal
   signal port_select : integer range 0 to 1; -- 0 is port A, 1 is B
   
begin
   D <= (others => 'Z');
   
   reset_n <= '0' when (M1_n = '0' and RD_n = '1' and IORQ_n = '1' and CS_n = '0') else '1';
   port_select <= 0 when B_A_SEL = '0' else 1;
   
   proc_bus : process (CLK, RD_n, IORQ_n, CS_n)
   begin
      if (reset_n = '0') then
         bus_state <= BS_WAIT;
      elsif (rising_edge(CLK)) then
         case bus_state is
            when BS_WAIT =>
               if (CS_n = '0') then
                  if (RD_n = '1') then
                     bus_state <= BS_WRITE;
                  else
                     bus_state <= BS_READ;
                  end if;
               end if;
               
            when BS_WAIT_DONE =>
               if (CS_n = '1') then
                  bus_state <= BS_WAIT;
               end if;
               
            when others =>
               bus_state <= BS_WAIT_DONE;
         end case;
      end if;
   end process;
   
   proc_busd : process (bus_state, CLK, port_in)
   begin
      if (rising_edge(CLK)) then
         case bus_state is
            when BS_READ => D <= port_in(port_select);
            when others => D <= (others => 'Z');
         end case;
      end if;
   end process;
   
   proc_port_drv : process (port_out, port_io_sel, port_mode)
   begin
      for p in 0 to 1 loop
         case port_mode(p) is
            when M_CTRL =>
               for i in 0 to 7 loop
                  if (p = 0) then
                     if port_io_sel(0)(i) = '1' then
                        A(i) <= 'Z';
                     else
                        A(i) <= port_out(0)(i);
                     end if;
                  else
                     if port_io_sel(1)(i) = '1' then
                        B(i) <= 'Z';
                     else
                        B(i) <= port_out(1)(i);
                     end if;
                  end if;
               end loop;
               
            when others => null;
               --A <= (others => 'Z');
               --B <= (others => 'Z');
         end case;
      end loop;
   end process;
   
   -- host writing data to the ports
   proc_data : process (C_D_SEL, CLK, D, port_select)
   begin
      if (reset_n = '0') then
         for i in 0 to 1 loop
            port_out(i) <= (others => '0');
         end loop;
      elsif (rising_edge(CLK) and C_D_SEL = '0' and bus_state = BS_WRITE) then
         port_out(port_select) <= D;
      end if;
   end process;
   
   -- host writing control bytes to the ports
   proc_ctrl : process (C_D_SEL, CLK, D, port_select)
   begin
      if (reset_n = '0') then
         for i in 0 to 1 loop
            port_ctrl_state(i) <= CS_WAIT_CMD;
         end loop;
      elsif (rising_edge(CLK) and C_D_SEL = '1' and bus_state = BS_WRITE) then
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
