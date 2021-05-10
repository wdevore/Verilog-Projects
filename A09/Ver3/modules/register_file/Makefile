TEST_BENCH = register_file_tb

VERILOG_FILES = ${TEST_BENCH}.v

SUB_MODULES_FILES = register_file.v

DEPENDENCY_FILES =

MODULES_FILES = ${VERILOG_FILES} ${SUB_MODULES_FILES}

YOSYS_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-yosys
SIM_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-iverilog

OUTPUT_PATH = /media/RAMDisk

.PHONY: all

sim:
	@echo "##### Simulating via iverilog..."
	touch ${MODULES_FILES} ${DEPENDENCY_FILES}
	${SIM_TOOLCHAIN}/bin/iverilog -B "${SIM_TOOLCHAIN}/lib/ivl" -o ${OUTPUT_PATH}/netlist.out -DSIMULATE=1 \
	${YOSYS_TOOLCHAIN}/share/yosys/ice40/cells_sim.v ${MODULES_FILES}
	${SIM_TOOLCHAIN}/bin/vvp -M "${SIM_TOOLCHAIN}/lib/ivl" ${OUTPUT_PATH}/netlist.out
	gtkwave ${OUTPUT_PATH}/${TEST_BENCH}.vcd ${TEST_BENCH}.gtkw
