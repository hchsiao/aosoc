`include "core_wrapper.svh"
`include "dmi_port.svh"

module core_wrapper (
  MemPort.Master instr_mem,
  MemPort.Master data_mem,

  DMIPort.Slave dm,

  input logic clk,
  input logic rst,
  input logic test_mode
);

wire clock_gating_i = 1;
wire [31:0] boot_addr_i = 'h10000000;

// signals from/to core
wire core_instr_req;
wire [31:0] core_instr_addr;
assign  instr_mem.valid = core_instr_req;
wire         core_instr_gnt = instr_mem.ready;
reg         core_instr_rvalid;
assign  instr_mem.addr = core_instr_addr;
wire [31:0]  core_instr_rdata = instr_mem.rdata;

wire core_lsu_req;
wire [31:0] core_lsu_addr;
wire core_lsu_we;
wire [3:0] core_lsu_be;
wire [31:0] core_lsu_wdata;
assign  data_mem.valid = core_lsu_req;
wire         core_lsu_gnt = data_mem.ready;
reg         core_lsu_rvalid;
assign  data_mem.addr = core_lsu_addr;
assign  data_mem.write_en = core_lsu_we;
assign  data_mem.byte_en = core_lsu_be;
wire [31:0]  core_lsu_rdata = data_mem.rdata;
assign  data_mem.wdata = core_lsu_wdata;

wire [31:0] irq_i = 0;
wire [4:0] irq_id = 0;
wire fetch_enable_i = 1;

always_ff @ (posedge clk) begin
  if(rst) begin
    core_instr_rvalid <= 0;
    core_lsu_rvalid <= 0;
  end
  else begin
    core_instr_rvalid <= core_instr_gnt;
    core_lsu_rvalid <= core_lsu_gnt;
  end
end

zeroriscy_core
      #(
        .N_EXT_PERF_COUNTERS (     0      ),
        .RV32E               ( 0 ),
        .RV32M               ( 1 )
      )
      RISCV_CORE
      (
        .clk_i           ( clk               ),
        .rst_ni          ( ~rst              ),

        .clock_en_i      ( clock_gating_i    ),
        .test_en_i       ( test_mode        ),

        .boot_addr_i     ( boot_addr_i       ),
        .core_id_i       ( 4'h0              ),
        .cluster_id_i    ( 6'h0              ),

        .instr_addr_o    ( core_instr_addr   ),
        .instr_req_o     ( core_instr_req    ),
        .instr_rdata_i   ( core_instr_rdata  ),
        .instr_gnt_i     ( core_instr_gnt    ),
        .instr_rvalid_i  ( core_instr_rvalid ),

        .data_addr_o     ( core_lsu_addr     ),
        .data_wdata_o    ( core_lsu_wdata    ),
        .data_we_o       ( core_lsu_we       ),
        .data_req_o      ( core_lsu_req      ),
        .data_be_o       ( core_lsu_be       ),
        .data_rdata_i    ( core_lsu_rdata    ),
        .data_gnt_i      ( core_lsu_gnt      ),
        .data_rvalid_i   ( core_lsu_rvalid   ),
        .data_err_i      ( 1'b0              ),

        .irq_i           ( (|irq_i)          ),
        .irq_id_i        ( irq_id            ),
        .irq_ack_o       (                   ),
        .irq_id_o        (                   ),

        .debug_req_i     ( dm.valid          ),
        .debug_gnt_o     (                   ),
        .debug_rvalid_o  ( dm.ready          ),
        .debug_addr_i    ( dm.addr           ),
        .debug_we_i      ( dm.write_en       ),
        .debug_wdata_i   ( dm.wdata          ),
        .debug_rdata_o   ( dm.rdata          ),
        .debug_halted_o  (                   ),
        .debug_halt_i    ( 1'b0              ),
        .debug_resume_i  ( 1'b0              ),

        .fetch_enable_i  ( fetch_enable_i    ),
        .core_busy_o     ( ),
        .ext_perf_counters_i (               )
);

//wire instr_main_sel = instr_mem.addr >= 'h10000000;
//wire data_main_sel = data_mem.addr >= 'h10000000;
//wire instr_main_valid = instr_main_sel & instr_mem.valid;
//wire data_main_valid = data_main_sel & data_mem.valid;
//wire instr_dbg_sel = instr_mem.addr >= 'h20000000;
//wire data_dbg_sel = data_mem.addr >= 'h20000000;
//wire instr_dbg_valid = instr_dbg_sel & instr_mem.valid;
//wire data_dbg_valid = data_dbg_sel & data_mem.valid;
//
//assign instr_dbg_mem.valid = instr_dbg_valid;
//assign instr_mem.ready = instr_main_sel ? instr_mem.valid :
//                         instr_dbg_sel  ? instr_dbg_mem.ready :
//                         0;
//assign instr_dbg_mem.addr = instr_mem.addr - 'h20000000;
//assign instr_mem.rdata = instr_main_sel ? instr_rdata :
//                         instr_dbg_sel  ? instr_dbg_mem.rdata :
//                         0;
//
//assign data_dbg_mem.valid = data_dbg_valid;
//assign data_mem.ready = data_main_sel ? data_mem.valid :
//                        data_dbg_sel  ? data_dbg_mem.ready :
//                        0;
//assign data_dbg_mem.addr = data_mem.addr - 'h20000000;
//assign data_mem.rdata = data_main_sel ? data_rdata :
//                        data_dbg_sel  ? data_dbg_mem.rdata :
//                        0;
//assign data_dbg_mem.write_en = data_mem.write_en;
//assign data_dbg_mem.byte_en = data_mem.byte_en;
//assign data_dbg_mem.wdata = data_mem.wdata;
endmodule
