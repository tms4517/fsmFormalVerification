lint:
	verilator --lint-only -Wall tb/fsmTb.sv -Ihdl/ -Itb/

formal:
	jg jg/jg.tcl &

clean:
	rm -rf jgproject
