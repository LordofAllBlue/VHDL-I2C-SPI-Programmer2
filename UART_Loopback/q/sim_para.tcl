lappend auto_path "D:/programs/lscc/diamond/3.12/data/script"
package require simulation_generation
set ::bali::simulation::Para(DEVICEFAMILYNAME) {MachXO2}
set ::bali::simulation::Para(PROJECT) {q}
set ::bali::simulation::Para(PROJECTPATH) {C:/Users/Szabo Ferenc/Documents/FPGA Projects/UART_Loopback}
set ::bali::simulation::Para(FILELIST) {"C:/Users/Szabo Ferenc/Documents/FPGA Projects/UART_Loopback/UART_RX.vhd" "C:/Users/Szabo Ferenc/Documents/FPGA Projects/UART_Loopback/UART_TX.vhd" "C:/Users/Szabo Ferenc/Documents/FPGA Projects/UART_Loopback/Int_Osc.vhd" "C:/Users/Szabo Ferenc/Documents/FPGA Projects/UART_Loopback/Main.vhd" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"work" "work" "work" "work" }
set ::bali::simulation::Para(COMPLIST) {"VHDL" "VHDL" "VHDL" "VHDL" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_machxo2}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {Main}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VHDL}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(INSTALLATIONPATH) {D:/programs/lscc/diamond/3.12}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(HDLPARAMETERS) {}
set ::bali::simulation::Para(POJO2LIBREFRESH)    {}
set ::bali::simulation::Para(POJO2MODELSIMLIB)   {}
::bali::simulation::ModelSim_Run
