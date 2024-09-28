# URBANA BOARD CONSTRAINTS V2I1 1/3/2023 

# clk input is from the 100 MHz oscillator on Urbana board
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports i_top_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_top_clk]
set_property PACKAGE_PIN N15 [get_ports i_top_clk]

# Set Bank 0 voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.Config.SPI_buswidth 4 [current_design]

# On-board LEDs
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports {o_top_cam_done}]

# On-board Buttons
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS25} [get_ports {i_top_rst}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS25} [get_ports {i_top_cam_start}]

#HDMI Signals
set_property -dict { PACKAGE_PIN V17   IOSTANDARD TMDS_33 } [get_ports {hdmi_tmds_clk_n}]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD TMDS_33 } [get_ports {hdmi_tmds_clk_p}]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD TMDS_33  } [get_ports {hdmi_tmds_data_n[0]}]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD TMDS_33  } [get_ports {hdmi_tmds_data_n[1]}]
set_property -dict { PACKAGE_PIN T14   IOSTANDARD TMDS_33  } [get_ports {hdmi_tmds_data_n[2]}]                              
set_property -dict { PACKAGE_PIN U17   IOSTANDARD TMDS_33  } [get_ports {hdmi_tmds_data_p[0]}]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD TMDS_33  } [get_ports {hdmi_tmds_data_p[1]}]
set_property -dict { PACKAGE_PIN R14   IOSTANDARD TMDS_33  } [get_ports {hdmi_tmds_data_p[2]}]

# PMOD A Signals  
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {i_top_pix_vsync}]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports {i_top_pclk}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {i_top_pclk_IBUF}]
set_property -dict {PACKAGE_PIN H13 IOSTANDARD LVCMOS33} [get_ports {o_top_pwdn}]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports {o_top_reset}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {o_top_sioc}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {o_top_siod}]
set_property -dict {PACKAGE_PIN E14 IOSTANDARD LVCMOS33} [get_ports {o_top_xclk}]
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {i_top_pix_href}]

# PMOD B Signals  
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS33} [get_ports {i_top_pix_byte[3]}]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {i_top_pix_byte[2]}]
set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports {i_top_pix_byte[1]}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {i_top_pix_byte[0]}]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports {i_top_pix_byte[7]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {i_top_pix_byte[6]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {i_top_pix_byte[5]}]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports {i_top_pix_byte[4]}]