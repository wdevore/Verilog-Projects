TEST_BENCH = cm_7c_tb

SUB_MODULES_FILES = ../../Modules/sequence_control_7c.v \
	../../Modules/memory.v \
	../../Modules/pc.v \
	../../Modules/mux.v \
	../../Modules/register.v

MODULES_FILES = ${TEST_BENCH}.v ${SUB_MODULES_FILES}

YOSYS_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-yosys
SIM_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-iverilog

OUTPUT_PATH = /media/RAMDisk

.PHONY: all

sim:
	@echo "##### Simulating via iverilog..."
	${SIM_TOOLCHAIN}/bin/iverilog -B "${SIM_TOOLCHAIN}/lib/ivl" -o ${OUTPUT_PATH}/netlist.out -DSIMULATE -DUSE_ROM \
	${YOSYS_TOOLCHAIN}/share/yosys/ice40/cells_sim.v ${MODULES_FILES}
	${SIM_TOOLCHAIN}/bin/vvp -M "${SIM_TOOLCHAIN}/lib/ivl" ${OUTPUT_PATH}/netlist.out
	gtkwave ${OUTPUT_PATH}/${TEST_BENCH}.vcd ${TEST_BENCH}.gtkw
