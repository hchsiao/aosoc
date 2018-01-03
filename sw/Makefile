# Project paths
PROJECT_DIR := $(shell pwd)/..
SW_DIR = $(PROJECT_DIR)/sw

# Toolchain
CC = /opt/riscv/bin/riscv32-unknown-elf-gcc
DBG = /opt/riscv/bin/riscv32-unknown-elf-gdb
OCD = $(PROJECT_DIR)/riscv-openocd/build/bin/openocd
SPIKE = $(PROJECT_DIR)/riscv-isa-sim/build/bin/spike
MAKE = make

# Parameters (TODO: this does not affect jtag_dpi setting)
DBG_PORT = 22223

# Set V=1 when calling make to enable verbose output
# mainly for debugging purposes.
ifeq ($(V), 1)
Q=
QUIET=
OPENOCD_FLAG=-d3
else
Q ?=@
QUIET=-quiet
OPENOCD_FLAG=-d2
endif

all: build

build:
	$(CC) -g -nostdlib -nostartfiles -Tlink.ld -o hello.elf hello.s
	$(CC) -g -nostdlib -nostartfiles -Tlink.ld -o dummy.elf dummy.s

# dont run alone. TODO: handle it properly
spike:
	$(SPIKE) --isa=rv32imc --progsize=16 --rbb-port=$(DBG_PORT) -m0x10000000:0x20000 dummy.elf &

run:
	bash -c "trap 'trap - SIGINT SIGTERM ERR; \
		$(MAKE) on-err; \
		exit 1' SIGINT SIGTERM ERR; $(MAKE) inner-run"

inner-run: spike
	@echo '##### Waiting for the server ######'
	$(Q)while ! fuser $(DBG_PORT)/tcp; do sleep 1; done;
	$(DBG) -ex "target remote | \
    $(OCD) $(OPENOCD_FLAG) --pipe -f spike.cfg \
    " hello.elf
	killall -9 spike

ocd:
	bash -c "trap 'trap - SIGINT SIGTERM ERR; \
		$(MAKE) on-err; \
		exit 1' SIGINT SIGTERM ERR; $(MAKE) inner-ocd"

inner-ocd: spike
	@echo '##### Waiting for the server ######'
	$(Q)while ! fuser $(DBG_PORT)/tcp; do sleep 1; done;
	$(OCD) $(OPENOCD_FLAG) -f spike.cfg
	killall -9 spike

on-err:
	@echo '##### Clean up ######'
	killall -9 spike

clean:
	@rm -rf hello
