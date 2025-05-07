library IEEE;
use IEEE.std_logic_1164.all;
library machxo2;
use machxo2.all;

entity Int_Osc is
  port (StdBy 	: 	in  std_logic;		
        Clk   	:	out std_logic
		);
end entity;

architecture Int_Osc_arch of Int_Osc is

component OSCH
-- synthesis translate_off
  generic  (NOM_FREQ: string := "9.17"); --33.25
-- synthesis translate_on
  port (STDBY    : in std_logic;
        OSC      : out std_logic;
        SEDSTDBY : out std_logic);
end component;

attribute NOM_FREQ : string;
attribute NOM_FREQ of OSCinst0 : label is "9.17";

   
begin

  OSCInst0: OSCH
-- synthesis translate_off
    generic map( NOM_FREQ  => "9.17" )
-- synthesis translate_on
    port map (STDBY => StdBy, 
	          OSC   => Clk);

end architecture;