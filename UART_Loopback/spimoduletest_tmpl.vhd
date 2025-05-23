-- VHDL module instantiation generated by SCUBA Diamond (64-bit) 3.12.0.240.2
-- Module  Version: 1.2
-- Fri Apr 18 11:16:48 2025

-- parameterized module component declaration
component spimoduletest
    port (wb_clk_i: in  std_logic; wb_rst_i: in  std_logic; 
        wb_cyc_i: in  std_logic; wb_stb_i: in  std_logic; 
        wb_we_i: in  std_logic; 
        wb_adr_i: in  std_logic_vector(7 downto 0); 
        wb_dat_i: in  std_logic_vector(7 downto 0); 
        wb_dat_o: out  std_logic_vector(7 downto 0); 
        wb_ack_o: out  std_logic; spi_clk: inout  std_logic; 
        spi_miso: inout  std_logic; spi_mosi: inout  std_logic; 
        spi_scsn: in  std_logic; 
        spi_csn: out  std_logic_vector(0 downto 0));
end component;

-- parameterized module component instance
__ : spimoduletest
    port map (wb_clk_i=>__, wb_rst_i=>__, wb_cyc_i=>__, wb_stb_i=>__, 
        wb_we_i=>__, wb_adr_i(7 downto 0)=>__, wb_dat_i(7 downto 0)=>__, 
        wb_dat_o(7 downto 0)=>__, wb_ack_o=>__, spi_clk=>__, spi_miso=>__, 
        spi_mosi=>__, spi_scsn=>__, spi_csn(0 downto 0)=>__);
