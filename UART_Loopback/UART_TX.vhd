library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity UART_TX is

generic (ClkRatio : integer := 16); --36 for 33.25 osc

	port (	TXData		: in  std_logic_vector(7 downto 0);
			Clk			: in  std_logic;
			SendTX		: in  std_logic;
			TXDone		: out std_logic;
			nReset 		:	in std_logic;			
			TXOut		: out std_logic;
			TXActive	: out std_logic
    );

end UART_TX;


architecture RTL of UART_TX is
 
type UartTxStateVDef is (Idle, StartBit, DataBits, StopBit, FrameEnd);
signal StateV : UartTxStateVDef := Idle;
signal SData   : std_logic_vector(7 downto 0) := (others => '0');
signal TXisDone   : std_logic := '1';
signal ClkCount : integer range 0 to ClkRatio + 1 := 0;
signal BitIndex : integer range 0 to 7 := 0;  

   
begin

TXDone <= TXisDone;

process (Clk) is
begin
	
	if rising_edge(Clk) then
		case StateV is
			when Idle =>

				ClkCount <= 0;
				TXActive <= '0';
				TXOut <= '1';         
				TXisDone   <= '1';
				BitIndex <= 0;
				StateV <= Idle;
 
				if SendTX = '1' then
					TXisDone   <= '0';
					SData <= TXData;
					StateV <= StartBit;
				end if;
				
 			when StartBit =>
				TXOut<= '0';
				ClkCount <= ClkCount + 1;
				StateV   <= StartBit;
				TXActive <= '1';
				
				if ClkCount >= ClkRatio - 1 then
					ClkCount <= 0;
					StateV   <= DataBits;
				end if;
    
			when DataBits =>
				TXOut<= SData(BitIndex);
				ClkCount <= ClkCount + 1;
				StateV   <= DataBits;
				TXActive <= '1';
				
				if ClkCount >= ClkRatio - 1 then
					ClkCount <= 0;
					if BitIndex < 7 then
						BitIndex <= BitIndex + 1;
						StateV   <= DataBits;
					else
						BitIndex <= 0;
						StateV   <= StopBit;
						TXOut<= '1';
					end if;
				end if;

			when StopBit =>
				TXOut<= '1';
				ClkCount <= ClkCount + 1;
				StateV   <= StopBit;
				TXActive <= '1';
				
				if ClkCount >= ClkRatio - 1 then
					TXisDone   <= '0';
					ClkCount <= 0;
					StateV   <= FrameEnd;
				end if;

			when FrameEnd =>
			
				TXActive <= '0';
				TXOut<= '1';
				TXisDone   <= '1';
				StateV   <= Idle;

			when others =>
				StateV <= Idle;
 
		end case;
		
	if nReset = '0' then 
	StateV <= Idle;
	end if;
		
	end if;
end process;
 
   
end RTL;