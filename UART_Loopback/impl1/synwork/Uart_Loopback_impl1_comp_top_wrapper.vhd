--
-- Synopsys
-- Vhdl wrapper for top level design, written on Tue May  6 10:40:21 2025
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wrapper_for_Main is
   port (
      TX : out std_logic;
      RX : in std_logic;
      CS : out std_logic;
      SCL : out std_logic;
      SDA : out std_logic;
      i2cSDA : in std_logic;
      i2cSCL : out std_logic;
      SDO : in std_logic;
      nReset : in std_logic
   );
end wrapper_for_Main;

architecture rtl of wrapper_for_Main is

component Main
 port (
   TX : out std_logic;
   RX : in std_logic;
   CS : out std_logic;
   SCL : out std_logic;
   SDA : out std_logic;
   i2cSDA : inout std_logic;
   i2cSCL : out std_logic;
   SDO : in std_logic;
   nReset : in std_logic
 );
end component;

signal tmp_TX : std_logic;
signal tmp_RX : std_logic;
signal tmp_CS : std_logic;
signal tmp_SCL : std_logic;
signal tmp_SDA : std_logic;
signal tmp_i2cSDA : std_logic;
signal tmp_i2cSCL : std_logic;
signal tmp_SDO : std_logic;
signal tmp_nReset : std_logic;

begin

TX <= tmp_TX;

tmp_RX <= RX;

CS <= tmp_CS;

SCL <= tmp_SCL;

SDA <= tmp_SDA;

tmp_i2cSDA <= i2cSDA;

i2cSCL <= tmp_i2cSCL;

tmp_SDO <= SDO;

tmp_nReset <= nReset;



u1:   Main port map (
		TX => tmp_TX,
		RX => tmp_RX,
		CS => tmp_CS,
		SCL => tmp_SCL,
		SDA => tmp_SDA,
		i2cSDA => tmp_i2cSDA,
		i2cSCL => tmp_i2cSCL,
		SDO => tmp_SDO,
		nReset => tmp_nReset
       );
end rtl;
