# ==================================
# Differential System Clock (200 MHz)
# ==================================
set_property PACKAGE_PIN R3 [get_ports clk_p]
set_property PACKAGE_PIN P3 [get_ports clk_n]
set_property IOSTANDARD LVDS_25 [get_ports clk_p]
set_property IOSTANDARD LVDS_25 [get_ports clk_n]
create_clock -name sys_clk -period 5.000 [get_ports clk_p]

# ==================================
# UART Interface (to CP2103 USB bridge)
# ==================================

# RX from PC to FPGA (UART TX of CP2103 → FPGA RX)
set_property PACKAGE_PIN U19 [get_ports rx_serial]
set_property IOSTANDARD LVCMOS18 [get_ports rx_serial]

# TX from FPGA to PC (UART RX of CP2103 ← FPGA TX)
set_property PACKAGE_PIN T19 [get_ports tx_serial]
set_property IOSTANDARD LVCMOS18 [get_ports tx_serial]

# reset button
set_property PACKAGE_PIN U6 [get_ports rst]
set_property IOSTANDARD SSTL15 [get_ports rst]
