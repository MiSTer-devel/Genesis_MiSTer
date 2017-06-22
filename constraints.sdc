
#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3


#**************************************************************
# Create Clock
#**************************************************************

#create_clock -name fm_clk3 -period 388.9 -waveform { 0 129.64 } [get_nets {emu|fpgagen|fm|u_clksync|u_clkgen|cnt3[0]}]

create_generated_clock -name VCLK -source [get_pins -compatibility_mode {*|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -divide_by 7 -duty_cycle 57.1 [get_nets {emu|fpgagen|VCLK}]
create_generated_clock -name ZCLK -source [get_pins -compatibility_mode {*|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -divide_by 14 -duty_cycle 50 [get_nets {emu|fpgagen|ZCLK}]

create_generated_clock -name romrd_req -source [get_pins -compatibility_mode {*|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -divide_by 7  [get_nets {*|romrd_req}] 

create_generated_clock -name fm_clk6 -source [get_nets {emu|fpgagen|VCLK}] -divide_by 6 -duty_cycle 50 -phase 0 [get_nets {emu:emu|Virtual_Toplevel:fpgagen|jt12:fm|jt12_clksync:u_clksync|jt12_clk:u_clkgen|clk_n6}]
create_generated_clock -name psg_clk -source [get_nets {emu|fpgagen|ZCLK}] -divide_by 32 [get_nets  {emu|fpgagen|u_psg|clk_divide[4]}]
#create_generated_clock -name psg_noise -source [get_nets {virtualtoplevel|u_psg|clk_divide[4]}] -divide_by 2 [get_nets {virtualtoplevel|u_psg|t3|v}]


#**************************************************************
# Set False Path
#**************************************************************

# JT12 internal clock uses synchronizers:
#set_false_path  -from  [get_nets {emu|fpgagen|VCLK}]  -to  [get_clocks {fm_clk6}]
