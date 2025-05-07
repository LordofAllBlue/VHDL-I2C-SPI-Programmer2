LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library IEEE;
use IEEE.std_logic_1164.all;
library machxo2;
use machxo2.all;
 
entity readPage is
  port (	iCS : in std_logic;
			Rdy	: out std_logic :='1';
			cs	: out std_logic :='1';
			Clk : in  std_logic;
			Done : out std_logic:='0';
			toSCL : out  std_logic:='1';
			toSDA : out  std_logic:='1';
			fromSDO : in  std_logic;
			read8bits : out  std_logic_vector(7 downto 0);
			next8bits : in  std_logic_vector(7 downto 0)
	);
end entity;
  
architecture readPage of readPage is

type TCState is (Idle, write8, stop, read8);
signal CState : TCState := Idle;
signal hold : std_logic := '0';
signal BitIndex : integer range 0 to 7 := 0;
signal ByteIndex : integer range 0 to 260 := 0;
signal current8bits : std_logic_vector(7 downto 0) := "00000000";

begin					
  
 
process(Clk) is
begin 
 
if rising_edge(Clk) then
 
case CState is
	when Idle => 
		Bitindex 	<= 0;
		toSCL <= '1';
		toSDA <= '1';
		Done <= '1';
		Rdy <= '0';
		
		if (iCS = '0') then
			CState <= write8;
			cs <= '0';
			Done <= '0';
			current8bits <= next8bits;
		end if;
		 
	when write8 =>
	
		Rdy <= '0';
		if hold = '0' then
		toSDA <= current8bits(7-BitIndex);
		toSCL <= '0';
		
		hold <= '1';
		
		else 
		hold <= '0';
		toSCL <= '1';
		
		if BitIndex < 7 then
              Bitindex 	<= BitIndex + 1;
              CState	<= write8;
            else
              BitIndex 	<= 0;			                                                    		  
              CState 	<= stop;
		end if;
		
		end if;
	
		when read8 =>
	
		Rdy <= '0';
		if hold = '0' then
		toSCL <= '0';
		
		hold <= '1';
		
		else 
		hold <= '0';
		read8bits(7-BitIndex) <= fromSDO;
		toSCL <= '1';
		
		if BitIndex < 7 then
              Bitindex 	<= BitIndex + 1;
              CState	<= write8;
            else
              BitIndex 	<= 0;			                                                    		  
              CState 	<= stop;
		end if;
		
		end if;
	
	when stop =>
		Bitindex 	<= 0;
		CState <= stop;
		cs <= '0';
	
	if iCS = '0' then
		current8bits <= next8bits;
		
		ByteIndex <= ByteIndex + 1;
		CState <= write8;
		
		if ByteIndex > 3 then
			CState <= read8;
		end if;
		
	end if;
	
	if ByteIndex = 258 then	
		cs <= '1';
		CState <= idle;
		ByteIndex <= 0;
		Rdy <= '1';
	end if;
	
	when others =>
		CState <= Idle;
end case;
end if;
end process;
 
end architecture;