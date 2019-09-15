set_clock_latency -source -early -min -rise  -0.295007 [get_ports {clk}] -clock clk1 
set_clock_latency -source -early -min -fall  -0.306402 [get_ports {clk}] -clock clk1 
set_clock_latency -source -early -max -rise  -0.295007 [get_ports {clk}] -clock clk1 
set_clock_latency -source -early -max -fall  -0.306402 [get_ports {clk}] -clock clk1 
set_clock_latency -source -late -min -rise  -0.295007 [get_ports {clk}] -clock clk1 
set_clock_latency -source -late -min -fall  -0.306402 [get_ports {clk}] -clock clk1 
set_clock_latency -source -late -max -rise  -0.295007 [get_ports {clk}] -clock clk1 
set_clock_latency -source -late -max -fall  -0.306402 [get_ports {clk}] -clock clk1 
