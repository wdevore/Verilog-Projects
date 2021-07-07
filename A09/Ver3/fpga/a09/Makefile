TOP_FILE = a09_cpu.v

SUB_MODULES_FILES = \
	../../modules/sequence_control/constants.v \
	../../components/cpu/cpu.v \
	../../modules/program_counter/pc.v \
	../../modules/mux/mux.v \
	../../modules/memory/memory.v \
	../../modules/register/register.v \
	../../modules/register_file/register_file.v \
	../../modules/sequence_control/sequence_control.v \
	../../modules/alu/alu

MODULES_FILES = ${SUB_MODULES_FILES} ${TOP_FILE}

BUILD_OUT = /media/RAMDisk

ICE40_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-ice40
YOSYS_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-yosys
YOSYS_COMMAND = "synth_ice40 -json ${BUILD_OUT}/hardware.json -top top"
SIM_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-iverilog
NETLIST_OUTPUT_PATH = /media/RAMDisk

TARGET_PORT = /dev/ttyACM0

PINS_CONSTRAINTS = pins.pcf

.PHONY: all

all: build route upload
# touch ${MODULES_FILES}

build: ${MODULES_FILES} ${PINS_CONSTRAINTS}
	@echo "##### Running yosys..."
	${YOSYS_TOOLCHAIN}/bin/yosys -p ${YOSYS_COMMAND} \
	-l ${BUILD_OUT}/yo.log \
	-q \
	-defer \
	${TOP_FILE}

route: ${BUILD_OUT}/hardware.json
	@echo "##### Running PnR..."
	${ICE40_TOOLCHAIN}/bin/nextpnr-ice40 --lp8k \
	-q \
	--package cm81 \
	--pcf ${PINS_CONSTRAINTS} \
	-l ${BUILD_OUT}/next.log \
	--json ${BUILD_OUT}/hardware.json \
	--asc ${BUILD_OUT}/hardware.asc

upload: ${BUILD_OUT}/hardware.asc
	@echo "##### Packing..."
	${ICE40_TOOLCHAIN}/bin/icepack ${BUILD_OUT}/hardware.asc ${BUILD_OUT}/hardware.bin
	@echo "##### Uploading..."
	tinyfpgab -c ${TARGET_PORT} --program ${BUILD_OUT}/hardware.bin

clean:
	$(RM) \
	${BUILD_OUT}/hardware.asc \
	${BUILD_OUT}/hardware.json \
	${BUILD_OUT}/hardware.bin \
	${BUILD_OUT}/*.log
