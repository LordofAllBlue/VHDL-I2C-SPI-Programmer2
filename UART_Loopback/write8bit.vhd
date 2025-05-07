LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library IEEE;
use IEEE.std_logic_1164.all;
library machxo2;
use machxo2.all;
 
entity write8bit is
  port (	iCS : in  std_logic;
			cs	: out std_logic :='1';
			Clk : in  std_logic;
			Done : out std_logic:='0';
			bit8SCL : out  std_logic:='1';
			nReset 		:	in std_logic;
			bit8SDA : out  std_logic:='1';
			SDA_data : in  std_logic_vector(7 downto 0)
	);
end entity;
  
architecture write8bit of write8bit is

type TCState is (Idle, write8, stop);
signal CState : TCState := Idle;
signal hold : std_logic := '0';
signal BitIndex : integer range 0 to 7 := 0;

begin					
  
 
process(Clk) is
begin 



if rising_edge(Clk) then
 
case CState is
	when Idle => 
		
		bit8SCL <= '1';
		bit8SDA <= '1';
		Done <= '1';
		
		if (iCS = '0') then
			CState <= write8;
			cs <= '0';
			Done <= '0';
		end if;
		 
	when write8 =>
		
		if hold = '0' then
		bit8SDA <= SDA_data(7-BitIndex);
		bit8SCL <= '0';
		
		hold <= '1';
		
		else 
		hold <= '0';
		bit8SCL <= '1';
		
		if BitIndex < 7 then
              Bitindex 	<= BitIndex + 1; ---
              CState	<= write8;
            else
              BitIndex 	<= 0;
			  Done <= '1';
			  
              CState 	<= stop;
		end if;
		
		end if;
	
	when stop =>
	cs <= '1';
	CState <= idle;
	
	when others =>
		CState <= Idle;
end case;
	
	if nReset = '0' then 
	CState <= Idle;
	end if;
	
end if;
end process;
 
end architecture;