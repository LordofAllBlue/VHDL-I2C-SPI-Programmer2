LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library IEEE;
use IEEE.std_logic_1164.all;
library machxo2;
use machxo2.all;
 
entity writePage is
  port (	iCS : in std_logic;
			RW : in std_logic;
			Rdy	: out std_logic :='1';
			cs	: out std_logic :='1';
			Clk : in  std_logic;
			from_SDO : in  std_logic;
			Done : out std_logic:='0';
			toSCL : out  std_logic:='1';
			nReset 		:	in std_logic;
			toSDA : out  std_logic:='1';
			MISO_DR : out std_logic:='0';
			next8bits : in  std_logic_vector(7 downto 0);
			read8bits : out  std_logic_vector(7 downto 0);
			RW_length	:	in integer range 0 to 16777215 ;
			RH_length	:	in integer range 0 to 255 
	);
end entity;
  
architecture writePage of writePage is

type TCState is (Idle, write8,read8, stop);
signal CState : TCState := Idle;
signal hold : std_logic := '0';
signal RWlatch : std_logic := '0';
signal BitIndex : integer range 0 to 7 := 0;
Signal  ByteIndex : integer range 0 to 16777216 := 0;
signal current8bits : std_logic_vector(7 downto 0) := "00000000";

begin					
  
 
process(Clk) is
begin 


if rising_edge(Clk) then
 
case CState is
	when Idle => 
		Bitindex 	<= 0;
		cs <= '1';
		toSCL <= '1';
		toSDA <= '1';
		Done <= '1';
		Rdy <= '0';
		RWlatch <= RW;
		MISO_DR	<= '0';
		
		if (iCS = '0') then
			CState <= write8;
			cs <= '0';
			Done <= '0';
			current8bits <= next8bits;
		end if;
		 
	when write8 =>
		RWlatch <= RWlatch;
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
              BitIndex 	<= 0;			                                                    --Done;			  
              CState 	<= stop;
		end if;
		
		end if;

	when read8 =>
	
		RWlatch <= RWlatch;
		Rdy <= '0';
		
		if hold = '0' then
		
		toSCL <= '0';
		hold <= '1';
		
		else 

		hold <= '0';
		toSCL <= '1';
		read8bits(7-BitIndex) <= from_SDO;
		
		if BitIndex < 7 then
              Bitindex 	<= BitIndex + 1;
              CState	<= read8;
            else
              BitIndex 	<= 0;			                                                    --Done;			  
              CState 	<= stop;
			  MISO_DR	<= '1';
		end if; 
		
		end if;
	
	when stop =>
		RWlatch <= RWlatch;
		Bitindex 	<= 0;
		CState <= stop;
		cs <= '0';
	
	if iCS = '0' then
		current8bits <= next8bits;
		CState <= write8;
		ByteIndex <= ByteIndex + 1;
		if RWlatch = '1' and (ByteIndex + 2) > RH_length   then
			CState <= read8;
			MISO_DR	<= '0';
		end if;
	
	if (ByteIndex + 1) = RW_length then	
		cs <= '1';
		CState <= idle;
		ByteIndex <= 0;
		Rdy <= '1';
		MISO_DR	<= '0';
	end if;

	end if;
	
--	if (ByteIndex + 1) = RW_length then	
--		cs <= '1';
--		CState <= idle;
--		ByteIndex <= 0;
--		Rdy <= '1';
--		MISO_DR	<= '0';
--	end if;
	
	when others =>
		CState <= Idle;
end case;
	
	if nReset = '0' then 
	CState <= Idle;
	end if;
	
end if;
end process;
 
end architecture;