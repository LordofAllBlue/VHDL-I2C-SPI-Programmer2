library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity UART_RX is

generic (	ClkRatio	: integer := 16;
			CRHalf		: integer := 8
	);


	port (	Clk			: in  	std_logic;			
			RXIn		: in 	std_logic;
			Ack			: in 	std_logic;
			RXData		: out  	std_logic_vector(7 downto 0);
			RXDataReady	: out 	std_logic:= '0';
			nReset 		:	in std_logic;
			RXActive	: out 	std_logic:= '0' 
    );

end UART_RX;


architecture RTL of UART_RX is
 
type UartRxStateVDef is (Idle, StartBit, DataBits, StopBit);
signal StateV : UartRxStateVDef := Idle;
signal SData   : std_logic_vector(7 downto 0) := (others => '0');
signal ClkCount : integer range 0 to ClkRatio:= 0;
signal BitIndex : integer range 0 to 8 := 0;  

   
begin

process (Clk) is
begin


	
	if rising_edge(Clk) then
		case StateV is
			when Idle =>
			
				RXDataReady <= '0';
				BitIndex <= 0;
				StateV <= Idle;
				ClkCount <= 0;
				
				if RXIn = '0' then
					StateV <= StartBit;
				end if;
				
 			when StartBit =>
			
				ClkCount <= ClkCount+1;
				
				if ClkCount >= ClkRatio-1 then			
					StateV   <= DataBits;
					ClkCount <= 0;					
				end if;

			when DataBits =>
			
				ClkCount <= ClkCount+1;
				
				if ClkCount = CRHalf-1 then
						SData(BitIndex) <= RXIn;
				end if;		
				
				if ClkCount >= ClkRatio-1 then	

					if BitIndex >= 7 then			
						ClkCount <= 0;	
						StateV   <= stopBit;					
					end if;

					ClkCount <= 0;
					BitIndex <= BitIndex +1;
					
				end if;
				
			when StopBit =>

				RXDataReady <= '1';
				RXData <= SData;
				
				if Ack = '1' then
					StateV   <= Idle;
					RXDataReady <= '0';
					RXData <= "00000000";
				end if;

			when others =>
			
				RXDataReady <= '0';
				StateV <= Idle;
 
		end case;
		
	if nReset = '0' then 
	StateV <= Idle;
	end if;
		
	end if;
end process;
 
   
end RTL;