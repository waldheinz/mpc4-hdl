
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity U82720_CTRL is
	Port (
		CLK		   : in  STD_LOGIC;								-- clock
		RESET		   : in  STD_LOGIC; 								-- async reset
		DB			   : in  STD_LOGIC_VECTOR (7 downto 0);	-- GDC internal data bus
		D_CMD		   : in  STD_LOGIC;								-- command bit (is the byte on DB a command or data?)
		D_READY	   : in  STD_LOGIC;								-- ready from FIFO
		FIFO_E	   : in  STD_LOGIC;								-- FIFO empty
		RD_REQ	   : out STD_LOGIC;								-- read request to FIFO
		DB_DIR	   : out STD_LOGIC;								-- direction of data transfer (0 -> to GDC, 1 -> to host)
      SYNC_CTRL   : out STD_LOGIC_VECTOR(3 downto 0);    -- controls the video sync unit
      V_ENABLED   : out STD_LOGIC;                       -- video gen. enabled
      GMI_MASK_L  : out STD_LOGIC;
      GMI_MASK_H  : out STD_LOGIC);
end U82720_CTRL;

architecture RTL of U82720_CTRL is

	--
	-- Microcode ROM (the original is 128x14, let's see if we can match this)
	--
	type UC_OP is record
		op_done	: std_logic;
		foo		: std_logic;
	end record;
	
	type UC_ROM_TABLE is array(0 to 1) of UC_OP;
	constant UC_ROM: UC_ROM_TABLE := UC_ROM_TABLE'(
		('0', '1'),
		('1', '0')
	);
	
	-- RESET : 8
	-- SYNC	: 8
	-- VSYNC	: 0
	-- CCHAR	: 3
	-- START : 0
	-- BCTRL : 0	
	-- ZOOM	: 1
	--	CURS	: 2 o. 3 (im Grafik - Modus)
	-- PRAM	: 1 - 16
	-- PITCH	: 1
	-- WDAT	: 2
	-- MASK	: 2
	-- FIGS	: 11
	-- FIGD	: 0
	-- GCHRD	: 0
	-- RDAT	: 0
	-- CURD	: 5
	-- LPRD	: 3
	-- DMAR	: 0
	-- DMAW	: 0
	
	--
	-- Internal State
	--
	type CTRL_CMD is (WAIT_CMD, CMD_RESET);
	type CMD_STATE is (WAIT_DATA, READ_DATA);
	signal command			: CTRL_CMD; -- currently executed command
	signal state			: CMD_STATE;
	signal data				: std_logic_vector(7 downto 0);
	
	signal param_num		: unsigned(4 downto 0); -- counts the parameter bytes
	
	-- display mode
	type DISPLAY_MODE_TYPE is (DM_MIXED, DM_GRAPH, DM_ChARA);
	signal display_mode	: DISPLAY_MODE_TYPE;
	signal display_mode_reg : std_logic_vector(1 downto 0);
	
	-- video properties (1 -> interlace on/off, 0 -> "zeilensprung-wiederholfeld"?, "01" is invalid)
	signal video_props_reg : std_logic_vector(1 downto 0);
	
	-- DRAM refresh enable
	signal dram_refresh_enabled : std_logic;
	
	-- drawing during display time enabled
	signal display_draw_enabled : std_logic;
	
begin
	
	state_logic : process(RESET, CLK, state)
	begin
		if (reset = '0') then
			state <= WAIT_DATA;
			command <= CMD_RESET;
			db_dir <= '0';
			param_num <= (others => '0');
		elsif (rising_edge(CLK)) then
			case state is
				when WAIT_DATA =>
					if (D_READY = '1') then
						state <= READ_DATA;
						data <= DB;
					end if;
					
				when READ_DATA =>
					state <= WAIT_DATA;
					param_num <= param_num + 1;
			end case;
		end if;
	end process;
	
	rd_req_logic : process(CLK, state, FIFO_E)
	begin
		if (reset = '0') then
			RD_REQ <= '0';
		elsif (rising_edge(CLK)) then
			if ((state = WAIT_DATA) and FIFO_E = '0') then
				RD_REQ <= '1';
			else
				RD_REQ <= '0';
			end if;
		end if;
	end process;
	
	p_cmd_reset : process(CLK, command, state, DB)
	begin
		if (reset = '1' and rising_edge(CLK)) then
			if ((command = CMD_RESET) and (state = READ_DATA)) then
				case to_integer(param_num) is
					when 0 =>
						-- mode bits
						display_mode_reg <= DB(5) & DB(1);
						video_props_reg <= DB(3) & DB(0);
						dram_refresh_enabled <= DB(2);
						display_draw_enabled <= DB(4);
					when others => null;
				end case;
			end if;
		end if;
	end process;
	
	display_mode <= DM_MIXED when display_mode_reg = "00" else
						 DM_GRAPH when display_mode_reg = "01" else
						 DM_CHARA;
	
end RTL;
