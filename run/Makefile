# Project paths
PROJECT_DIR := $(shell pwd)/..
TEST_DIR = $(PROJECT_DIR)/run
CACHE_DIR = $(TEST_DIR)/cache
ZERO_BUGGY_DIR = $(PROJECT_DIR)/zero-buggy
ZERO_RISCY_DIR = $(PROJECT_DIR)/zero-riscy
JTAG_DPI_DIR = $(PROJECT_DIR)/openocd_jtag_dpi

# Environment paths
INC_DIR = /opt/Cadence/INCISIV/cur/tools/include

# Toolchain
CC = gcc
OCD = /opt/riscv/bin/openocd

C_SRC = $(JTAG_DPI_DIR)/jtag_dpi.c
SV_SRC = "\
				  $(ZERO_BUGGY_DIR)/jtag_tap.sv \
				  $(ZERO_BUGGY_DIR)/debug_transfer_module.sv \
				  $(ZERO_BUGGY_DIR)/debug_module.sv \
          $(JTAG_DPI_DIR)/jtag_dpi.sv \
				  $(ZERO_RISCY_DIR)/include/zeroriscy_defines.sv \
				  $(ZERO_RISCY_DIR)/include/zeroriscy_tracer_defines.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_alu.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_compressed_decoder.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_controller.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_cs_registers.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_debug_unit.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_decoder.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_int_controller.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_ex_block.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_id_stage.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_if_stage.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_load_store_unit.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_multdiv_slow.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_multdiv_fast.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_prefetch_buffer.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_fetch_fifo.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_core.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_tracer.sv \
				  $(ZERO_RISCY_DIR)/zeroriscy_register_file.sv \
				  $(PROJECT_DIR)/src/cluster_clock_gating.sv \
				  $(PROJECT_DIR)/src/core_wrapper.sv \
				  $(PROJECT_DIR)/src/mem.sv \
				  $(PROJECT_DIR)/src/top.sv \
				  $(PROJECT_DIR)/src/test.sv \
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

JTAG_ENABLE ?= 1
ifeq ($(JTAG_ENABLE), 1)
JTAG_FLAG = "+jtag_vpi_enable"
else
JTAG_FLAG = ""
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
	$(Q)cd $(CACHE_DIR); \
		ncverilog +nc64bit +sv +sv_lib=jtag_dpi.so \
		+incdir+$(ZERO_BUGGY_DIR) \
		+incdir+$(ZERO_RISCY_DIR)/include \
		+incdir+$(PROJECT_DIR)/src \
		+access+r -mccodegen $(JTAG_FLAG) +fsdb+struct=on $(SV_SRC) &

run: ncsim
	@echo '##### Waiting for the server ######'
	$(Q)while ! fuser $(JTAG_DPI_PORT)/tcp; do sleep 1; done;
	@echo '##### Running the test client ######'
	-$(Q)cd $(CACHE_DIR); $(OCD) $(OPENOCD_FLAG) -f $(PROJECT_DIR)/src/jtag_dpi.cfg
	# to prevent hanging simulations
	killall ncsim

clean:
	@rm -rf $(CACHE_DIR)
