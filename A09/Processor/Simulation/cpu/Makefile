# Usage:
# make sim ROM=romX
# where "romX" is the name of the rom, for example, Sub_Halt

TEST_BENCH = cpu_tb

SUB_MODULES_FILES = cpu.v \
	../../Modules/control_matrix.v \
	../../Modules/memory.v \
	../../Modules/pc.v \
	../../Modules/mux.v \
	../../Modules/register.v \
	../../Modules/register_file.v \
	../../Modules/alu.v

MODULES_FILES = ${TEST_BENCH}.v ${SUB_MODULES_FILES}

YOSYS_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-yosys
SIM_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-iverilog

OUTPUT_PATH = /media/RAMDisk

.PHONY: all

sim:
	@echo "##### Simulating via iverilog...with $(ROM)"
	${SIM_TOOLCHAIN}/bin/iverilog -B "${SIM_TOOLCHAIN}/lib/ivl" -o ${OUTPUT_PATH}/netlist.out \
	-DSIMULATE -DUSE_ROM -DMEM_CONTENTS=$(ROM) \
	${YOSYS_TOOLCHAIN}/share/yosys/ice40/cells_sim.v ${MODULES_FILES}
	@echo "##### Running vvp..."
	${SIM_TOOLCHAIN}/bin/vvp -M "${SIM_TOOLCHAIN}/lib/ivl" ${OUTPUT_PATH}/netlist.out
	gtkwave ${OUTPUT_PATH}/${TEST_BENCH}.vcd ${TEST_BENCH}.gtkw
