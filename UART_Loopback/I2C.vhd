library IEEE;
use IEEE.std_logic_1164.all;
library machxo2;
use machxo2.all;

entity I2C is
  port (	DataIn 		:	in std_logic_vector(7 downto 0);
			DataOut 	:	out std_logic_vector(7 downto 0):="00000000";
			RW_length	:	in integer range 0 to 65535 ;
			RH_length	:	in integer range 0 to 255 ;	-- Header of read packet length in bytes
			Clk 		:	in std_logic;
			Go 			:	in std_logic;
			Send_i2c	:	in std_logic;
			nReset 		:	in std_logic;
			RW			:	in std_logic;
			rSDA 		: 	inout  std_logic;
			rSCL   		:	out std_logic;
			dataready  	:	out std_logic:='0';
			atstop  	:	out std_logic:='0';
			Done   		:	out std_logic );
end entity; 
  
architecture I2C of I2C is
  
Signal 	count		:	integer range 0 to 15 :=0;
Signal 	Bytecount	:	integer range 0 to 65536 :=0;
Signal 	Bitcount	:	integer range 0 to 7 :=0;
type 	stateM is (off, start, PFHW, wack, rack, final_ack, stop, readB, restart);
signal 	state 	: stateM := off;
signal 	part	: std_logic_vector (1 downto 0) := "00";
signal 	SDAen 	: std_logic :='1';
signal 	SCLen 	: std_logic :='1';
signal 	golatch 	: std_logic :='0';
signal 	RWlatch : std_logic := '0';
--signal test : std_logic_vector(7 downto 0):="01000010";


begin

with count select 
	part <= 	"00" when 0 to 3,
				"01" when 4 to 7,
				"10" when 8 to 11,
				"11" when 12 to 15,
				"00" when others;
				
with state select 
	Done 	<= 	'1' when off,
				'0' when others;
with state select 
	atstop 	<= 	'1' when stop,
				'0' when others;

rSDA	<= 'Z' WHEN SDAen = '1' ELSE '0';
rSCL	<= 'Z' WHEN SCLen = '1' ELSE '0';

process(Clk) is 
		begin
		

		
		if rising_edge(Clk) then	
		
				
		case state is
		
			when off =>
						
						dataready <= '0';					
						Bitcount <= 0;
						Bytecount <= 0;
						count <= 0;
						RWlatch <= RW;
						if Send_i2c = '1' then
							state <= start;	
						end if;
						
						
						SDAen <= '1';
						
						SCLen <= '1';					
				
			when start =>
						if count = 15 then		
							state <= PFHW;
							Bitcount <= 0;
							Bytecount <= 0;
							count <= 0;
						else
							count <= count+1;
						end if;
				
						if part = "00" then SDAen <= '0'; end if;
						
						if part = "10" then SCLen <= '0'; end if;
						



			when PFHW =>		--Paket Frame Header and write
						
									
						SDAen <= DataIn(7-Bitcount);	
											
						if part = "00" then SCLen <= '0'; end if;
						if part = "01" then SCLen <= '1'; end if;
						if part = "11" then SCLen <= '0'; end if;
						
						if count = 15 then
							count <= 0;
							
							if Bitcount = 7 then
								Bitcount <= 0;
								Bytecount <= Bytecount+1;
								state <= wack;
							else 
								Bitcount <= Bitcount+1;
							end if;
							
						else
							count <= count+1;
						end if;

			when wack => 
						
						SDAen <= '1';	

						if part = "00" then SCLen <= '0'; end if;
						if part = "01" then SCLen <= '1'; end if;
						if part = "11" then SCLen <= '0'; end if;	

						if go = '1' then
							golatch <= '1';
						end if;
				
						
						if count = 15 then	
							
							count <= 15;						
							
							if RWlatch <= '0' then
							
								if golatch = '1' then
									state <= PFHW;
									golatch <= '0';
									count <= 0;
								end if;
								
								
								if Bytecount = RW_length then
									state <= stop;
									golatch <= '0';
									count <= 0;
								end if;
							else
								
								if golatch = '1' then
								if Bytecount >= (RH_length) then
									state <= readB;
									golatch <= '0';
									count <= 0;
								else
									state <= PFHW;
									golatch <= '0';
									count <= 0;
								end if;	
								
								if Bytecount + 1 = RH_length then
									state <= restart;
									golatch <= '0';
									SCLen <= '1';
									count <= 0;								
								end if;
								end if;
							end if;
							
							
							else
							
							
								count <= count+1;
							
							
							
						end if;
												
						

						

			when readB =>		
						
						dataready <= '0';			
						SDAen <= '1';	
						
						if count = 8 then
							DataOut(7-Bitcount) <= rSDA;
						end if;
						
						
						if part = "00" then SCLen <= '0'; end if;
						if part = "01" then SCLen <= '1'; end if;
						if part = "11" then SCLen <= '0'; end if;
						
						if count = 15 then
							count <= 0;
							
							if Bitcount = 7 then
								Bitcount <= 0;
								Bytecount <= Bytecount+1;
								state <= rack;
								dataready <= '1';
							else 
								Bitcount <= Bitcount+1;
							end if;
							
						else
							count <= count+1;
						end if;

			when rack => 
						
						if Bytecount = RW_length then
							SDAen <= '1';
						else
							SDAen <= '0';
						end if;	
						
						if go = '1' then
							golatch <= '1';
						end if;
				 
						
						if count = 15 then	
						
							count <= 15;						
							
							if golatch = '1' then
								dataready <= '0';
								state <= readB;
								golatch <= '0';
								count <= 0;																
								if Bytecount = RW_length then
									state <= stop;
									golatch <= '0';
									count <= 0;
								end if;	
							end if;
							
	
						else
							count <= count+1;
						end if;
							

													
						if part = "00" then SCLen <= '0'; end if;
						if part = "01" then SCLen <= '1'; end if;
						if part = "11" then SCLen <= '0'; end if;	

			when restart =>
						if count = 15 then		
							state <= PFHW;
							count <= 0;
						else
							count <= count+1;
						end if;
						
						if part = "00" then SDAen <= '1'; end if;
						if part = "01" then SDAen <= '0'; end if;
						if part = "00" then SCLen <= '1'; end if;
						if part = "10" then SCLen <= '0'; end if;
						
			when stop =>	
					dataready <= '0';
					
--					if RWlatch = '1' then
--						state <= off;
--						count <= 0;
--						bytecount <= 0;
--					else 
					
--						if RWlatch <= '0' then
--							state <= off;
--							count <= 0;
--							bytecount <= 0;
--						end if;
						
						if count = 15 then		
							state <= off;
							count <= 0;
							bytecount <= 0;
							else
														
							count <= count+1;
						
						end if;
						
						if part = "00" then SDAen <= '0'; end if;
						if part = "11" then SDAen <= '1'; end if;						
						
						if part = "00" then SCLen <= '0'; end if;
						if part = "01" then SCLen <= '1'; end if;
						
--						if RWlatch <= '0' then
--							state <= off;
--							count <= 0;
--							bytecount <= 0;
--						end if;
						
--					end if;						
			
			when others => 
			
						state <= off;
						
			end case;
	if nReset = '0' then 
	state <= off;
	end if;
	end if;
	end process;

end architecture;