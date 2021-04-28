TOP_FILE = a09_cpu.v
VERILOG_FILES = ${TOP_FILE} \
	../../modules/sequence_control/constants.v \
	../../components/cpu/cpu.v \
	../../modules/program_counter/pc.v \
	../../modules/mux/mux.v \
	../../modules/memory/memory.v \
	../../modules/register/register.v \
	../../modules/register_file/register_file.v \
	../../modules/sequence_control/sequence_control.v \
	../../modules/alu/alu

TOOLCHAIN = ~/.apio/packages/toolchain-ice40/bin
TARGET_DEVICE = /dev/ttyACM1
BUILD_BIN = /media/RAMDisk
YOSYS_COMMAND = "synth_ice40 -json ${BUILD_BIN}/hardware.json -top top"
PINS_CONSTRAINTS = pins.pcf

.PHONY: all build route upload clean

all: build route upload

build: ${VERILOG_FILES} pins.pcf
	touch ${VERILOG_FILES}
	@echo "##### Running yosys..."
	yosys -p ${YOSYS_COMMAND} \
	-l ${BUILD_BIN}/yo.log \
	-q \
	-defer \
	${TOP_FILE}

route: ${BUILD_BIN}/hardware.json
	@echo "##### Running PnR..."
	${TOOLCHAIN}/nextpnr-ice40 --lp8k \
	-q \
	--package cm81 \
	--pcf ${PINS_CONSTRAINTS} \
	-l ${BUILD_BIN}/next.log \
	--json ${BUILD_BIN}/hardware.json \
	--asc ${BUILD_BIN}/hardware.asc

upload: ${BUILD_BIN}/hardware.asc
	@echo "Packing..."
	${TOOLCHAIN}/icepack ${BUILD_BIN}/hardware.asc ${BUILD_BIN}/hardware.bin
	@echo "Uploading..."
	tinyfpgab -c ${TARGET_DEVICE} --program ${BUILD_BIN}/hardware.bin

clean:
	$(RM) \
	${BUILD_BIN}/hardware.asc \
	${BUILD_BIN}/hardware.json \
	${BUILD_BIN}/hardware.bin \
	${BUILD_BIN}/*.log
