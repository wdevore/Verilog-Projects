TEST_BENCH = cpu_tb

VERILOG_FILES = ${TEST_BENCH}.v	cpu.v

SUB_MODULES_FILES = \
	../../modules/sequence_control/constants.v \
	../../modules/program_counter/pc.v \
	../../modules/mux/mux.v \
	../../modules/memory/memory.v \
	../../modules/register/register.v \
	../../modules/register_file/register_file.v \
	../../modules/sequence_control/sequence_control.v \
	../../modules/alu/alu

MODULES_FILES = ${VERILOG_FILES} ${SUB_MODULES_FILES}

YOSYS_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-yosys
SIM_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-iverilog

OUTPUT_PATH = /media/RAMDisk

.PHONY: all

all: sim

sim: ${MODULES_FILES}
	@echo "##### Simulating via iverilog..."
	touch ${MODULES_FILES}
	${SIM_TOOLCHAIN}/bin/iverilog -B "${SIM_TOOLCHAIN}/lib/ivl" -o ${OUTPUT_PATH}/netlist.out -DSIMULATE=1 \
	${YOSYS_TOOLCHAIN}/share/yosys/ice40/cells_sim.v ${VERILOG_FILES}
	${SIM_TOOLCHAIN}/bin/vvp -M "${SIM_TOOLCHAIN}/lib/ivl" ${OUTPUT_PATH}/netlist.out
	gtkwave ${OUTPUT_PATH}/${TEST_BENCH}.vcd ${TEST_BENCH}.gtkw

# If your having issues with files not being found then you can use "strace" to
# understand what is going on. However, iverilog doesn't like "~" for the home directory
# use ${HOME} instead.
# strace -e verbose=all -f ... 2> trace.txt

# Macros don't work for some files
# -DVCD_OUTPUT=${OUTPUT_PATH}/${TEST_BENCH}
# -Pcpu_tb.V_OUTPUT=${OUTPUT_PATH}/${TEST_BENCH}.vcd 