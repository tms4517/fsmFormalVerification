clear -all

# Load and analyze the RTL & TB.
analyze -sv hdl/fsmWithBugs.sv tb/fsmAssertions.sv tb/fsmTb.sv
# Synthesize the RTL and read the netlist.
elaborate -top fsmTb

clock clk
reset !rst_n

# Prove all properties.
prove -all
