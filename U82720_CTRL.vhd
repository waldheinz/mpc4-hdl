
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity U82720_CTRL is
	Port (
		CLK		: in 		STD_LOGIC;								-- clock
		RESET		: in 		STD_LOGIC; 								-- async reset
		DB			: in  	STD_LOGIC_VECTOR (7 downto 0);	-- GDC internal data bus
		D_CMD		: in 		STD_LOGIC;								-- command bit for DB
		D_READY	: in 		STD_LOGIC;								-- ready from FIFO
		FIFO_E	: in  	STD_LOGIC;								-- FIFO empty
		RD_REQ	: out		STD_LOGIC;								-- read request to FIFO
		DB_DIR	: out		STD_LOGIC);								-- direction of data transfer (0 -> to GDC, 1 -> to host)
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
	
	signal curr_inst		: unsigned(7 downto 0);
	signal param_num		: unsigned(4 downto 0); -- counts the parameter bytes
	
	-- display mode
	type DISPLAY_MODE_TYPE is (DM_MIXED, DM_GRAPHICS, DM_ChARACTER);
	signal display_mode	: DISPLAY_MODE_TYPE;
	
begin
	
	state_logic : process(RESET, CLK, state)
	begin
		if (reset = '0') then
			state <= WAIT_DATA;
			command <= CMD_RESET;
			db_dir <= '0';
			curr_inst <= (others => '0');
			param_num <= (others => '0');
		elsif (rising_edge(CLK)) then
			case state is
				when WAIT_DATA =>
					if (FIFO_E = '0') then
						
					end if;
				when READ_DATA =>
					
			end case;
		end if;
	end process;
	
	rd_req_logic : process(CLK, state, FIFO_E)
	begin
		if (rising_edge(CLK)) then
			RD_REQ <= '0';
			if (state = WAIT_DATA) then
				if (FIFO_E = '0') then
					RD_REQ <= '1';
				end if;
			end if;
		end if;
	end process;
	
	p_cmd_reset : process(CLK, command, state, DB, curr_inst)
	begin
		if (rising_edge(CLK)) then
			if ((command = CMD_RESET) and (state = READ_DATA)) then
				case to_integer(param_num) is
					when 0 =>
						-- mode bits
						
				end case;
			end if;
		end if;
	end process;
	
end RTL;
