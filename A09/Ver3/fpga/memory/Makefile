TOP_FILE = top.v

SUB_MODULES_FILES = \
	../../../Modules/memory.v

MODULES_FILES = ${SUB_MODULES_FILES} ${TOP_FILE}

BUILD_BIN = /media/RAMDisk

ICE40_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-ice40
YOSYS_TOOLCHAIN = ${HOME}/.apio/packages/toolchain-yosys
YOSYS_COMMAND = "synth_ice40 -json ${BUILD_BIN}/hardware.json -top top"

# The Tiny shows up as generally ACM0 or ACM1 depending on what other
# devices you have connected. Be sure to run "dmesg -w" and see what
# the device name is.
TARGET_PORT = /dev/ttyACM0

PINS_CONSTRAINTS = pins.pcf

.PHONY: all

all: build route upload

build: ${MODULES_FILES} ${PINS_CONSTRAINTS}
	@echo "##### Building..."
	${YOSYS_TOOLCHAIN}/bin/yosys -p ${YOSYS_COMMAND} \
	-l ${BUILD_BIN}/yo.log \
	-q \
	-defer \
	${MODULES_FILES}

route: ${BUILD_BIN}/hardware.json
	@echo "##### Routing..."
	${ICE40_TOOLCHAIN}/bin/nextpnr-ice40 --lp8k \
	-q \
	--package cm81 \
	--pcf ${PINS_CONSTRAINTS} \
	-l ${BUILD_BIN}/next.log \
	--json ${BUILD_BIN}/hardware.json \
	--asc ${BUILD_BIN}/hardware.asc

upload: ${BUILD_BIN}/hardware.asc
	@echo "##### Packing..."
	${ICE40_TOOLCHAIN}/bin/icepack ${BUILD_BIN}/hardware.asc ${BUILD_BIN}/hardware.bin
	@echo "##### Uploading..."
	tinyfpgab -c ${TARGET_PORT} --program ${BUILD_BIN}/hardware.bin

