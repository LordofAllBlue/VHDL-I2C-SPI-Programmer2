library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;




library machxo2;
use machxo2.all;

entity Main is
  port (	TX 		: out  std_logic;
			RX 		: in  std_logic;
			CS : out  std_logic :='1';
			SCL: out  std_logic :='1';
			SDA: out  std_logic :='1';
			i2cSDA: inout  std_logic :='1';
			i2cSCL: out  std_logic :='1';			
			SDO: in  std_logic;
			nReset	: in std_logic
	);
end entity;

architecture RTL of Main is

component Int_Osc is
  port (	StdBy	: in  std_logic;
			Clk   	: out std_logic
	);
end component;

component write8bit is
  port (	iCS : in  std_logic;
			cs : out  std_logic :='1';
			Clk : in  std_logic;
			Done : out std_logic:='0';
			nReset 		:	in std_logic;
			bit8SCL : out  std_logic:='1';
			bit8SDA : out  std_logic:='1';
			SDA_data : in  std_logic_vector(7 downto 0)
	);
end component;

component UART_TX is
	port (	TXData		: in  std_logic_vector(7 downto 0);
			Clk			: in  std_logic;
			SendTX		: in  std_logic;
			TXDone		: out std_logic;
			nReset 		:	in std_logic;			
			TXOut		: out std_logic;
			TXActive	: out std_logic
	);
end component;

component UART_RX is
	port (	Clk			: in  	std_logic;			
			RXIn		: in 	std_logic;
			Ack			: in 	std_logic;
			nReset 		:	in std_logic;
			RXData		: out  	std_logic_vector(7 downto 0);
			RXDataReady	: out 	std_logic;
			RXActive	: out 	std_logic
    );
end component;
 
component writePage is
  port (	iCS : in  std_logic;
			Rdy	: out std_logic :='1';
			cs : out  std_logic :='1';
			RW : in std_logic;
			Clk : in  std_logic;
			from_SDO : in  std_logic;
			Done : out std_logic:='0';
			nReset 		:	in std_logic;
			toSCL : out  std_logic:='1';
			toSDA : out  std_logic:='1';
			MISO_DR : out std_logic:='0';
			next8bits : in  std_logic_vector(7 downto 0);
			read8bits : out  std_logic_vector(7 downto 0);
			RW_length	:	in integer range 1 to 16777215 ;
			RH_length	:	in integer range 1 to 255 
	);
end component;
 
component I2C is
  port (	DataIn 		:	in std_logic_vector(7 downto 0);
			DataOut 	:	out std_logic_vector(7 downto 0);
			RW_length	:	in integer range 1 to 65535 ;
			RH_length	:	in integer range 1 to 255;-- Header of read packet length in bytes
			Clk 		:	in std_logic;
			nReset 		:	in std_logic;
			Go 			:	in std_logic;
			Send_i2c	:	in std_logic;
			RW			:	in std_logic;
			rSDA 		: 	inout  std_logic ;
			rSCL   		:	out std_logic;
			dataready   :	out std_logic:='0';
			atstop  	:	out std_logic:='0';
			Done   		:	out std_logic 
			);
end component; 



signal Clk : std_logic;
signal SendTX : std_logic := '0';

signal DataToSend : std_logic_vector(7 downto 0):="01000010";
signal DataFromRx : std_logic_vector(7 downto 0):="01000010";

signal TXisActive : std_logic:='0';
signal TXisDone : std_logic:='0';
signal RXAck : std_logic:='0';
signal RXDR : std_logic:='0';
signal RXA : std_logic:='0';
signal iTX : std_logic:='0';
Signal count	:	integer range 0 to 52 :=0;

signal bit8SCLw : std_logic:='0';
signal bit8SDAw: std_logic:='0';

signal bit8SCLp : std_logic:='0';
signal bit8SDAp: std_logic:='0';

signal SDA_data : std_logic_vector(7 downto 0) := "01010101";
signal SDA_datap : std_logic_vector(7 downto 0) := "01010101";
signal SDO_datap : std_logic_vector(7 downto 0) := "01010101";

Signal DoneW : std_logic :='0';
Signal DoneP : std_logic :='0';

Signal csw : std_logic :='1';
Signal csp : std_logic :='1';

Signal iCSw : std_logic :='1';
Signal iCSp : std_logic :='1';

Signal SPI_R1W0 : std_logic :='0';

Signal Rdyp : std_logic :='0';
Signal MISO_DR : std_logic :='0';

Signal statedelay : std_logic :='0';

Signal spi_RW_length	: integer range 0 to 16777215  := 167;
Signal spi_RH_length	: integer range 0 to 255 		:= 3;

signal State : std_logic_vector(2 downto 0):="000";
signal StateHolder : std_logic_vector(2 downto 0):="000";

Signal i2cRW 			: std_logic :='0';
Signal Send_i2c 		: std_logic :='0';
Signal GO_i2c 			: std_logic :='0';
Signal i2c_RW_length	: integer range 0 to 65535 := 167;
Signal i2c_RH_length	: integer range 0 to 255 := 3;
Signal i2c_DataIn 		: std_logic_vector(7 downto 0):= "01010101";
Signal i2c_DataOut 		: std_logic_vector(7 downto 0);
Signal i2c_off 			: std_logic;
signal i2c_DR			: std_logic;
signal i2c_atStop		: std_logic;

Signal settings			: std_logic_vector(55 downto 0):= x"00001904000403"; --00010404004303
signal settingsindex : integer range 0 to 56 := 0;





begin 



U1 : Int_Osc
    port map (	StdBy		=> '0',
				Clk   		=> Clk
				);
U2 : UART_TX
    port map (	Clk 		=> Clk,
				SendTX 		=> SendTX,
				TXData 		=> DataToSend,
				TXOut 		=> TX,
				nReset		=> nReset,
				TXActive 	=> TXisActive,
				TXDone 		=> TXisDone);
				
U3 : UART_RX
    port map (	Clk 		=> Clk,
				RXIn 		=> RX,
				Ack 		=> RXAck,
				nReset		=> nReset,
				RXData 		=> DataFromRx,
				RXDataReady	=> RXDR,
				RXActive 	=> RXA);
				 
U4 : write8bit
	port map(	iCS => ICSw,
				cs 	=> csw, --csw
				Clk => Clk,
				Done => DoneW,
				nReset		=> nReset,
				bit8SCL => bit8SCLw, --bit8SCL,
				bit8SDA => bit8SDAw, --bit8SDA,
				SDA_data => SDA_data
				);
U5 : writePage
	port map(	iCS => 	ICSp,
				cs 	=> 	csp, --csw
				Clk => 	Clk,
				RW 	=>	SPI_R1W0,
				Done => DoneP,
				Rdy => RdyP,
				MISO_DR => MISO_DR,
				from_SDO	=> SDO,
				toSCL => bit8SCLp, --bit8SCL,
				toSDA => bit8SDAp, --bit8SDA,
				next8bits => SDA_datap,
				read8bits => SDO_datap,
				RW_length => spi_RW_length,
				nReset		=> nReset,
				RH_length	=> spi_RH_length
				);
			 	
U6 : I2C
	port map(	DataIn 		=> i2c_DataIn,
				DataOut 	=> i2c_DataOut, 
				Clk 		=> Clk,
				RW_length 	=> i2c_RW_length,
				RH_length	=> i2c_RH_length,
				Go 			=> GO_i2c,
				Send_i2c 	=> Send_i2c,
				RW			=> i2cRW,
				rSDA 		=> i2cSDA, 
				rSCL 		=> i2cSCL, 
				Done		=> i2c_off,
				dataready  	=> i2c_DR,
				nReset		=> nReset,
				atstop		=> i2c_atStop
				);

 With DataFromRX select
	StateHolder <= 	"001" when "01000001",-- (ascii A) SPI configure 		x41 
					"010" when "01000010",-- (ascii B) SPI read			x42
					"011" when "01000011",-- (ascii C) SPI write			x43
					"100" when "01000100",-- (ascii D) Get settings 		x44
					"101" when "01000101",-- (ascii E) I2C read			x45
					"110" when "01000110",-- (ascii F) I2C write			x46
					"000" when others;    -- ()base state					x47
					
 With State select
	SCL <= 	bit8SCLw when "001",
			bit8SCLp when "010",
			bit8SCLp when "011",
			bit8SCLw when others; 
 With State select
	SDA <= 	bit8SDAw when "001",
			bit8SDAp when "010",
			bit8SDAp when "011",
			bit8SDAw when others; 
 With State select
	CS <= 	CSw when "001",
			CSp when "010",
			CSp when "011",
			CSw when others;  			

spi_RW_length <= to_integer(unsigned(settings(55 downto 32)));
spi_RH_length <= to_integer(unsigned(settings(31 downto 24)));
i2c_RW_length <= to_integer(unsigned(settings(23 downto 8)));
i2c_RH_length <= to_integer(unsigned(settings(7 downto 0)));

process(Clk) is
begin



	if rising_edge(clk) then

	

	case State is  

			when "000" =>	--base state
				State <= "000";
				SendTX <= '0';
				ICSw <= '1';
				ICSp <= '1';
				count <= 0;
				RXAck <= '0';				
				
				if RXDR = '1' and DoneW = '1' then
					DataToSend <= DataFromRx;
					SendTX <= '1';
					state <= StateHolder;
					RXAck <= '1'; 
				end if;
					

			when "001" =>
			
				State <= "001";
				SendTX <= '0';
				ICSw <= '1';				
				RXAck <= '0';
				count <= count + 1;
				
				
				if count >= 50 then					
					if RXDR = '1' then
						SDA_data <= DataFromRx;
						RXAck <= '1';
						ICSw <= '0';
						statedelay <= '1';
					end if;	
					count <= count;
				end if;
				
				if statedelay = '1' then
					state <= "000";
						RXAck <= '0';
						ICSw <= '1';
						count <= 0 ;
						statedelay <= '0';
				end if;


			when "010" =>
			
			SPI_R1W0 <= '1';
			SendTX <= '0';			
			RXAck <= '0';
			ICSp <= '1';
			statedelay <= '0';
			count <= count + 1;
			
			if count >= 50 then	
				
				if TXisDone = '1' and MISO_DR = '1' then
					DataToSend <= SDO_datap;
					SendTX <= '1';
					ICSp <= '0';
				end if;
				
				if RXDR = '1' and statedelay = '0' and MISO_DR = '0' then
					SDA_datap <= DataFromRx;
					ICSp <= '0';
					RXAck <= '1';
					statedelay <= '1';
				end if;
			
				if Rdyp = '1' then
					SPI_R1W0 <= '0';
					state <= "000";
					ICSp <= '1';
				end if;
			count <= count;
			end if;	
			
			when "100" =>
			
				State <= "100";
				SendTX <= '0';				
				RXAck <= '0';
				count <= count + 1;
				
				
				if count >= 50 then
					count <= count;
					
					if RXDR = '1' then
						settings((55-settingsindex) downto (48-(settingsindex))) <= DataFromRx;
						RXAck <= '1';
						count <= 0 ;
						settingsindex <= settingsindex + 8;
					end if;	 
					
				end if;
				
				if settingsindex = 56 then
					 statedelay <= '1';
					 RXAck <= '0';
					 count <= 0 ;
				end if;
				
				if statedelay = '1' then
					state <= "000";
						RXAck <= '0';
						ICSw <= '1';
						count <= 0 ;
						statedelay <= '0';
						settingsindex <= 0;
				end if;
			
			when "011" =>
			
			SPI_R1W0 <= '0';
			SendTX <= '0';			
			RXAck <= '0';
			ICSp <= '1';
			statedelay <= '0';
			count <= count + 1;
			
			if count >= 50 then	
			
				if RXDR = '1' and statedelay = '0' then
					SDA_datap <= DataFromRx;
					ICSp <= '0';
					RXAck <= '1';
					statedelay <= '1';
				end if;
			
				if Rdyp = '1' then
					state <= "000";
					ICSp <= '1';
				end if;
			count <= count;
			end if;	
			
			when "101" =>
			
			GO_i2c <= '0';
			i2cRW <= '1';
			Send_i2c <= '0';
			SendTX <= '0';			
			RXAck <= '0';
			statedelay <= '0';
			count <= count + 1;
			
			if count >= 50 then	
				
				if i2c_off = '0' and i2c_DR = '1' and TXisDone = '1' then
					DataToSend <= i2c_DataOut;
					SendTX <= '1';
					GO_i2c <= '1';
				end if;
				
				if RXDR = '1' and statedelay = '0' and i2c_DR = '0' and TXisDone = '1' then
					i2c_DataIn <= DataFromRx;
					Send_i2c <= '1';
					GO_i2c <= '1';
					RXAck <= '1';
					statedelay <= '1';
				end if;
			
				if i2c_atStop = '1' then
					i2cRW <= '0';
					state <= "000";
					GO_i2c <= '0';
				end if;
				
			count <= count;
			
			end if;	
			
			when "110" =>
			
			GO_i2c <= '0';
			i2cRW <= '0';
			Send_i2c <= '0';
			SendTX <= '0';			
			RXAck <= '0';
			statedelay <= '0';
			count <= count + 1;
			
			if count >= 50 then	
			
				if RXDR = '1' and statedelay = '0' and i2c_DR = '0' and TXisDone = '1' then
					i2c_DataIn <= DataFromRx;
					Send_i2c <= '1';
					GO_i2c <= '1';
					RXAck <= '1';
					statedelay <= '1';
				end if;
			
				if i2c_atStop = '1' then
					i2cRW <= '0';
					state <= "000";
					GO_i2c <= '0';
				end if;
				
			count <= count;
			
			end if;	

			when others =>
				State <= "000";
		 
	end case;
	
	if nReset = '0' then 
	state <= "000";
	settings <= x"00000504000403";
	end if;	 
	
	end if;


end process;

end architecture;