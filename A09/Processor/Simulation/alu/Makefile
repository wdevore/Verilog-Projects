# Usage:
# make sim TEST_TARGET=SIMULATE_ADD
# or
# make sim TEST_TARGET=SIMULATE_SUB
TEST_TARGET=SIMULATE_ADD	# Default

TEST_BENCH = alu_tb

# The order listing of the files is important
# Note: We don't include add_op.v or sub_op.v because they
# are controlled by Preprocessor constructs.
SUB_MODULES_FILES = ../../Modules/alu.v

MODULES_FILES = ${TEST_BENCH}.v ${SUB_MODULES_FILES}

YOSYS_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-yosys
SIM_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-iverilog

OUTPUT_PATH = /media/RAMDisk

.PHONY: all

sim: ${MODULES_FILES}
	@echo "##### Simulating via iverilog..."
	${SIM_TOOLCHAIN}/bin/iverilog -B "${SIM_TOOLCHAIN}/lib/ivl" -o ${OUTPUT_PATH}/netlist.out -D$(TEST_TARGET) \
	${YOSYS_TOOLCHAIN}/share/yosys/ice40/cells_sim.v ${MODULES_FILES}
	${SIM_TOOLCHAIN}/bin/vvp -M "${SIM_TOOLCHAIN}/lib/ivl" ${OUTPUT_PATH}/netlist.out
	gtkwave ${OUTPUT_PATH}/${TEST_BENCH}.vcd ${TEST_BENCH}.gtkw
