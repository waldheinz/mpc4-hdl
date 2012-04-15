
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity U82720 is
    Port ( DB 			: inout  STD_LOGIC_VECTOR (7 downto 0);
           RD_n 		: in  	STD_LOGIC;
           WR_n 		: in  	STD_LOGIC;
           A0 			: in  	STD_LOGIC;
           TWOxWCLK 	: in  	STD_LOGIC;
           LPEN 		: in  	STD_LOGIC;
           DACK_n 	: in  	STD_LOGIC;
           AD 			: inout 	STD_LOGIC_VECTOR (15 downto 0);
           A16 		: out  	STD_LOGIC;
           A17 		: out  	STD_LOGIC;
           HSYNC 		: out  	STD_LOGIC;
           VSYNC 		: inout  STD_LOGIC;
           BLANK 		: out  	STD_LOGIC;
           DRQ_n 		: out  	STD_LOGIC;
           ALE 		: out  	STD_LOGIC;
           DBIN_n 	: out  	STD_LOGIC);
end U82720;

architecture RTL of U82720 is
   
   COMPONENT U82720_CTRL
	PORT(
		CLK : IN std_logic;
		RESET : IN std_logic;
		DB : IN std_logic_vector(7 downto 0);
		D_CMD : IN std_logic;
		D_READY : IN std_logic;
		FIFO_E : IN std_logic;          
		RD_REQ : OUT std_logic;
		DB_DIR : OUT std_logic;
		SYNC_CTRL : OUT std_logic_vector(3 downto 0);
		V_ENABLED : OUT std_logic;
      GMI_MASK_L  : out STD_LOGIC;
      GMI_MASK_H  : out STD_LOGIC
		);
	END COMPONENT;
   
   COMPONENT U82720_UC
	PORT(
		A0 : IN std_logic;
		RDH_n : IN std_logic;
		WRH_n : IN std_logic;
		RDI_n : IN std_logic;
		WRI_n : IN std_logic;
		DB_DIR : IN std_logic;
		LPD : IN std_logic;
		HSYNC : IN std_logic;
		VSYNC : IN std_logic;
		DMA_A : IN std_logic;
		PAINT : IN std_logic;    
		DB_H : INOUT std_logic_vector(7 downto 0);
		DB_I : INOUT std_logic_vector(7 downto 0);      
		EMPTY : OUT std_logic;
		RESET_n : OUT std_logic
		);
	END COMPONENT;
   
   COMPONENT U82720_GMI
	PORT(
		CLK : IN std_logic;
		MASK_LOADL : IN std_logic;
		MASK_LOADH : IN std_logic;
		MASK_SHL : IN std_logic;
		MASK_SHR : IN std_logic;
		PTRN_LOADL : IN std_logic;
		PTRN_LOADH : IN std_logic;
		RMW_CYCLE : IN std_logic;
		RMW_OP : IN std_logic_vector(1 downto 0);    
		DB : INOUT std_logic_vector(7 downto 0);
		AD : INOUT std_logic_vector(15 downto 0);      
		MASK_MSB : OUT std_logic;
		MASK_LSB : OUT std_logic;
		A_16 : OUT std_logic;
		A_17 : OUT std_logic
		);
	END COMPONENT;
   
   COMPONENT U82720_SYNC
	PORT(
		CLK : IN std_logic;
		DB : IN std_logic_vector(7 downto 0);
		ENABLE : IN std_logic;
		SET : IN std_logic_vector(3 downto 0);    
		VSYNC : INOUT std_logic;      
		HSYNC : OUT std_logic;
		HBLANK : OUT std_logic;
		VBLANK : OUT std_logic;
		BLANK : OUT std_logic
		);
	END COMPONENT;
   
   signal db_int : std_logic_vector(7 downto 0); -- internal data bus
   signal db_dir : std_logic;
	
   signal h_blank : std_logic;
   signal h_sync : std_logic;
   signal v_blank : std_logic;
   signal v_sync : std_logic;
   signal video_enable : std_logic;
   
   signal sync_ctrl : std_logic_vector(3 downto 0); -- controls video sync gen.
   signal reset_n : std_logic; -- async reset from host interface
   signal d_cmd : std_logic; -- if db_int holds a command byte (from host interface)
   signal fifo_empty : std_logic;
   signal fifo_read : std_logic; -- internal read request to fifo
   
   -- signals the GMI to read it's mask register from the bus
   signal gmi_mask_l : std_logic;
   signal gmi_mask_h : std_logic;
begin
   
   CTRL : U82720_CTRL PORT MAP(
		CLK => TWOxWCLK,
		RESET => reset_n,
		DB => db_int,
		D_CMD => d_cmd,
		D_READY => '0',
		FIFO_E => fifo_empty,
		RD_REQ => fifo_read,
		DB_DIR => db_dir,
		SYNC_CTRL => sync_ctrl,
		V_ENABLED => video_enable,
      GMI_MASK_L => gmi_mask_l,
      GMI_MASK_H => gmi_mask_h
	);
   
   UC : U82720_UC PORT MAP(
		DB_H => DB,
		A0 => A0,
		RDH_n => RD_n,
		WRH_n => WR_n,
		DB_I => db_int,
		RDI_n => fifo_read,
		WRI_n => '1', -- TODO : implement host read
		DB_DIR => db_dir,
		LPD => '0',
		HSYNC => h_sync,
		VSYNC => v_sync,
		DMA_A => '0',
		PAINT => '0',
		EMPTY => fifo_empty,
		RESET_n => reset_n
	);
   
   GMI: U82720_GMI PORT MAP(
		DB => db_int,
		CLK => TWOxWCLK,
		MASK_LOADL => gmi_mask_l,
		MASK_LOADH => gmi_mask_h,
		MASK_SHL => '0',
		MASK_SHR => '0',
--		MASK_MSB => ,
--		MASK_LSB => ,
		PTRN_LOADL => '0',
		PTRN_LOADH => '0',
		RMW_CYCLE => '0',
		RMW_OP => "00",
		AD => AD,
		A_16 => A16,
		A_17 => A17
	);
   
   SYNC : U82720_SYNC PORT MAP(
		CLK => TWOxWCLK,
		DB => db_int,
		ENABLE => video_enable,
		SET => sync_ctrl,
		HSYNC => h_sync,
		VSYNC => v_sync,
		HBLANK => h_blank,
		VBLANK => v_blank,
		BLANK => BLANK
	);
   
   HSYNC <= h_sync;
   VSYNC <= v_sync;
   
end RTL;

