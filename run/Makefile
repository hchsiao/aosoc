# Project paths
PROJECT_DIR := $(shell pwd)/..
TEST_DIR = $(PROJECT_DIR)/run
CACHE_DIR = $(TEST_DIR)/cache
ZERO_BUGGY_DIR = $(PROJECT_DIR)/zero-buggy
ZERO_RISCY_DIR = $(PROJECT_DIR)/zero-riscy
JTAG_DPI_DIR = $(PROJECT_DIR)/openocd_jtag_dpi
AXI_DIR = $(PROJECT_DIR)/axi
SW_DIR = $(PROJECT_DIR)/sw

# Toolchain
CC = /opt/riscv/bin/riscv32-unknown-elf-gcc
DBG = /opt/riscv/bin/riscv32-unknown-elf-gdb
OCD = $(PROJECT_DIR)/riscv-openocd/build/bin/openocd
SPIKE = $(PROJECT_DIR)/riscv-isa-sim/build/bin/spike
MAKE = make

# Environment paths
INC_DIR = /opt/Cadence/INCISIV/cur/tools/include

C_SRC = $(JTAG_DPI_DIR)/jtag_dpi.c
SV_SRC = "\
          $(ZERO_BUGGY_DIR)/jtag_tap.sv \
          $(ZERO_BUGGY_DIR)/debug_transfer_module.sv \
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
				 	$(ZERO_RISCY_DIR)/mem_mux.sv \
          $(PROJECT_DIR)/src/cluster_clock_gating.sv \
          $(PROJECT_DIR)/src/top.sv \
          $(PROJECT_DIR)/src/test.sv \
					$(AXI_DIR)/axi.sv \
					$(AXI_DIR)/axi_node/axi_address_decoder_AR.sv \
					$(AXI_DIR)/axi_node/axi_address_decoder_AR.sv \
					$(AXI_DIR)/axi_node/axi_address_decoder_AW.sv \
					$(AXI_DIR)/axi_node/axi_address_decoder_BR.sv \
					$(AXI_DIR)/axi_node/axi_address_decoder_BW.sv \
					$(AXI_DIR)/axi_node/axi_address_decoder_DW.sv \
					$(AXI_DIR)/axi_node/axi_AR_allocator.sv \
					$(AXI_DIR)/axi_node/axi_AW_allocator.sv \
					$(AXI_DIR)/axi_node/axi_BR_allocator.sv \
					$(AXI_DIR)/axi_node/axi_BW_allocator.sv \
					$(AXI_DIR)/axi_node/axi_DW_allocator.sv \
					$(AXI_DIR)/axi_node/axi_ArbitrationTree.sv \
					$(AXI_DIR)/axi_node/axi_FanInPrimitive_Req.sv \
					$(AXI_DIR)/axi_node/axi_multiplexer.sv \
					$(AXI_DIR)/axi_node/axi_node.sv \
					$(AXI_DIR)/axi_node/axi_node_intf_wrap.sv \
					$(AXI_DIR)/axi_node/axi_request_block.sv \
					$(AXI_DIR)/axi_node/axi_response_block.sv \
					$(AXI_DIR)/axi_node/axi_RR_Flag_Req.sv \
					$(AXI_DIR)/axi_node/defines.v \
					$(AXI_DIR)/axi_node/generic_fifo.sv \
					$(AXI_DIR)/core2axi/core2axi.sv \
					$(AXI_DIR)/core2axi/core2axi_wrap.sv \
					$(AXI_DIR)/core2axi/axi_slice_wrap.sv \
					$(AXI_DIR)/core2axi/axi_ar_buffer.sv \
					$(AXI_DIR)/core2axi/axi_aw_buffer.sv \
					$(AXI_DIR)/core2axi/axi_b_buffer.sv \
					$(AXI_DIR)/core2axi/axi_buffer.sv \
					$(AXI_DIR)/core2axi/axi_r_buffer.sv \
					$(AXI_DIR)/core2axi/axi_w_buffer.sv \
					$(AXI_DIR)/core2axi/axi_slice.sv \
					$(AXI_DIR)/ram/sp_ram.sv \
					$(AXI_DIR)/ram/sp_ram_wrap.sv \
					$(AXI_DIR)/ram/axi_mem_if_SP_wrap.sv \
					$(AXI_DIR)/ram/axi_mem_if_SP.sv \
					$(AXI_DIR)/ram/axi_read_only_ctrl.sv \
					$(AXI_DIR)/ram/instr_ram_wrap.sv \
					$(AXI_DIR)/ram/boot_rom_wrap.sv \
					$(AXI_DIR)/ram/boot_code.sv \
					$(AXI_DIR)/ram/ram_mux.sv \
					$(AXI_DIR)/includes/axi_bus.sv \
					$(AXI_DIR)/includes/config.sv \
"                             

# Parameters
VJTAG_PORT = 22221
GDB_PORT = 3331

# Set V=1 when calling make to enable verbose output
# mainly for debugging purposes.
ifeq ($(V), 1)
Q=
QUIET=
OPENOCD_FLAG="-d3"
else
Q ?=@
QUIET=-quiet
OPENOCD_FLAG="-d2"
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
	$(Q)cd $(CACHE_DIR); gcc -fPIC -shared -o jtag_dpi.so $(C_SRC) -I$(INC_DIR)

build: jtag_dpi.so
	mkdir -p $(CACHE_DIR)
	cp $(SW_DIR)/hello.s $(CACHE_DIR)
	cp $(SW_DIR)/dummy.s $(CACHE_DIR)
	cp $(SW_DIR)/link.ld $(CACHE_DIR)
	$(Q)cd $(CACHE_DIR); $(CC) -g -nostdlib -nostartfiles -Tlink.ld -o hello.elf hello.s
	$(Q)cd $(CACHE_DIR); $(CC) -g -nostdlib -nostartfiles -Tlink.ld -o dummy.elf dummy.s

# TODO: should not run alone
inner-ncsim: build
	@echo '##### Start the simulation ######'
	mkdir -p $(CACHE_DIR)
	$(Q)cd $(CACHE_DIR); \
		ncverilog +nc64bit +sv +sv_lib=jtag_dpi.so \
		+incdir+$(ZERO_BUGGY_DIR) \
		+incdir+$(ZERO_RISCY_DIR)/include \
		+incdir+$(PROJECT_DIR)/src \
		+incdir+$(AXI_DIR)/includes \
		+incdir+$(AXI_DIR)/axi_node \
		+define+JTAG_DPI_PORT=$(VJTAG_PORT) \
		+access+r -mccodegen $(JTAG_FLAG) +fsdb+struct=on $(SV_SRC) &

sim:
	bash -c "trap 'trap - SIGINT SIGTERM ERR; \
		$(MAKE) on-err; \
		exit 1' SIGINT SIGTERM ERR; $(MAKE) inner-sim"

inner-sim: inner-ncsim
	@echo '##### Waiting for the server ######'
	$(Q)while ! fuser $(VJTAG_PORT)/tcp; do sleep 1; done;
	@echo '##### Running the test client ######'
	-$(Q)cd $(CACHE_DIR); VJTAG_PORT=$(VJTAG_PORT) GDB_PORT=$(GDB_PORT) $(OCD) $(OPENOCD_FLAG) -f $(PROJECT_DIR)/src/jtag_dpi.cfg
	# to prevent hanging simulations
	killall ncsim

# dont run alone. TODO: handle it properly
inner-spike: build
	@echo '##### Start the simulation ######'
	mkdir -p $(CACHE_DIR)
	$(Q)cd $(CACHE_DIR); \
		$(SPIKE) --isa=rv32imc --progsize=16 --rbb-port=$(VJTAG_PORT) -m0x10000000:0x20000 dummy.elf &

run:
	bash -c "trap 'trap - SIGINT SIGTERM ERR; \
		$(MAKE) on-err; \
		exit 1' SIGINT SIGTERM ERR; $(MAKE) inner-run"

inner-run: inner-spike
	@echo '##### Waiting for the server ######'
	$(Q)while ! fuser $(VJTAG_PORT)/tcp; do sleep 1; done;
	$(Q)cd $(CACHE_DIR); \
    VJTAG_PORT=$(VJTAG_PORT) $(DBG) -ex "target remote | \
    $(OCD) $(OPENOCD_FLAG) --pipe -f $(SW_DIR)/spike.cfg \
    " -ex "load"  hello.elf
	killall -9 spike

#ocd:
#	bash -c "trap 'trap - SIGINT SIGTERM ERR; \
#		$(MAKE) on-err; \
#		exit 1' SIGINT SIGTERM ERR; $(MAKE) inner-ocd"
#
#inner-ocd: spike
#	@echo '##### Waiting for the server ######'
#	$(Q)while ! fuser $(VJTAG_PORT)/tcp; do sleep 1; done;
#	$(OCD) $(OPENOCD_FLAG) -f spike.cfg
#	killall -9 spike

on-err:
	@echo '##### Clean up ######'
	-killall -9 spike
	-killall -9 ncsim

clean:
	@rm -rf $(CACHE_DIR)

gdb:
	riscv32-unknown-elf-gdb -ex "set remotetimeout 60" -ex "target remote localhost:$(GDB_PORT)" -ex "load" cache/hello.elf
