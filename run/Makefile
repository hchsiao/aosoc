# Project paths
PROJECT_DIR := $(shell pwd)/..
TEST_DIR = $(PROJECT_DIR)/run
CACHE_DIR = $(TEST_DIR)/cache
ZERO_BUGGY_DIR = $(PROJECT_DIR)/zero-buggy
JTAG_DPI_DIR = $(PROJECT_DIR)/openocd_jtag_dpi

# Environment paths
INC_DIR = /opt/Cadence/INCISIV/cur/tools/include

# Toolchain
CC = gcc
OCD = $(PROJECT_DIR)/riscv-openocd/build/bin/openocd

C_SRC = $(JTAG_DPI_DIR)/jtag_dpi.c
SV_SRC = "\
				  $(ZERO_BUGGY_DIR)/jtag_tap.sv \
				  $(ZERO_BUGGY_DIR)/debug_transfer_module.sv \
				  $(ZERO_BUGGY_DIR)/debug_module.sv \
          $(JTAG_DPI_DIR)/jtag_dpi.sv \
				  $(TEST_DIR)/src/test.sv \
"

# Parameters (TODO: this does not affect jtag_dpi setting)
JTAG_DPI_PORT = 22222

# Set V=1 when calling make to enable verbose output
# mainly for debugging purposes.
ifeq ($(V), 1)
Q=
QUIET=
OPENOCD_FLAG="-d3"
else
Q ?=@
QUIET=-quiet
OPENOCD_FLAG=
endif

all: build

jtag_dpi.so:
	@echo '##### Building DPI object ######'
	mkdir -p $(CACHE_DIR)
	$(Q)cd $(CACHE_DIR); $(CC) -fPIC -shared -o jtag_dpi.so $(C_SRC) -I$(INC_DIR)

build: jtag_dpi.so
	#$(Q)iverilog-vpi $(IVERILOG_VPI_SRC) > /dev/null
	#$(Q)iverilog -I$(INCLUDE_DIR) -ojtag_vpi_tb.vvp $(IVERILOG_SRC)

# TODO: should not run alone
ncsim: build
	@echo '##### Start the simulation ######'
	mkdir -p $(CACHE_DIR)
	$(Q)cd $(CACHE_DIR); ncverilog +nc64bit +sv +sv_lib=jtag_dpi.so +incdir+$(ZERO_BUGGY_DIR) +access+r -mccodegen +jtag_vpi_enable +fsdb+struct=on $(SV_SRC) &

run: ncsim
	@echo '##### Waiting for the server ######'
	$(Q)while ! fuser $(JTAG_DPI_PORT)/tcp; do sleep 1; done;
	@echo '##### Running the test client ######'
	-$(Q)cd $(CACHE_DIR); $(OCD) $(OPENOCD_FLAG) -f $(TEST_DIR)/src/jtag_dpi.cfg
	# to prevent hanging simulations
	killall ncsim

clean:
	@rm -rf $(CACHE_DIR)
