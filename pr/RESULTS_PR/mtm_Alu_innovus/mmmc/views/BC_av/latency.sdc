set_clock_latency -source -early -min -rise  -0.183765 [get_ports {clk}] -clock clk1 
set_clock_latency -source -early -min -fall  -0.189582 [get_ports {clk}] -clock clk1 
set_clock_latency -source -early -max -rise  -0.183765 [get_ports {clk}] -clock clk1 
set_clock_latency -source -early -max -fall  -0.189582 [get_ports {clk}] -clock clk1 
set_clock_latency -source -late -min -rise  -0.183765 [get_ports {clk}] -clock clk1 
set_clock_latency -source -late -min -fall  -0.189582 [get_ports {clk}] -clock clk1 
set_clock_latency -source -late -max -rise  -0.183765 [get_ports {clk}] -clock clk1 
set_clock_latency -source -late -max -fall  -0.189582 [get_ports {clk}] -clock clk1 
