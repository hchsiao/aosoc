/* 
    * File Name : 
    *
    * Purpose :
    *           
    * Creation Date : 
    *
    * Last Modified : 
    *
    * Create By : Jyun-Neng Ji
    *
*/
`include "dmi_port.svh"
`include "axi_bus.sv"

module core_region
#(
  parameter AXI_ADDR_WIDTH      = 32,
  parameter AXI_DATA_WIDTH      = 32,
  parameter AXI_USER_WIDTH      = 1,
  parameter AXI_ID_MASTER_WIDTH = 4
)
(
  input          clk,
  input          rst_n,
  input          clk_gating_i,
  input          testmode_i,
  input          fetch_enable_i,
  input  [31:0]  irq_i,
  input  [31:0]  boot_addr_i,
  output logic   core_busy_o,

  DMIPort.Slave  dbg_slave,

  AXI_BUS.Master if_master,
  AXI_BUS.Master lsu_master
);
  
  AXI_BUS
  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH      ),
    .AXI_ID_WIDTH   ( AXI_ID_MASTER_WIDTH ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH      )
  )
  lsu_master_if ();

  AXI_BUS
  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH      ),
    .AXI_ID_WIDTH   ( AXI_ID_MASTER_WIDTH ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH      )
  )
  if_master_if ();

  logic         core_instr_req;
  logic         core_instr_gnt;
  logic         core_instr_rvalid;
  logic [31: 0] core_instr_addr;
  logic [31: 0] core_instr_rdata;
    
  logic         core_lsu_req;
  logic         core_lsu_gnt;
  logic         core_lsu_rvalid;
  logic         core_lsu_we;
  logic [3:  0] core_lsu_be;
  logic [31: 0] core_lsu_addr;
  logic [31: 0] core_lsu_wdata;
  logic [31: 0] core_lsu_rdata;

  zeroriscy_core core (
    .clk_i               ( clk               ),
    .rst_ni              ( rst_n             ),
    .clock_en_i          ( clk_gating_i      ),
    .test_en_i           ( testmode_i        ),
    .core_id_i           ( 4'h0              ),
    .cluster_id_i        ( 6'h0              ),
    .boot_addr_i         ( boot_addr_i       ),
   
    .instr_req_o         ( core_instr_req    ),
    .instr_gnt_i         ( core_instr_gnt    ),
    .instr_rvalid_i      ( core_instr_rvalid ),
    .instr_addr_o        ( core_instr_addr   ),
    .instr_rdata_i       ( core_instr_rdata  ),
  
    .data_req_o          ( core_lsu_req      ),
    .data_gnt_i          ( core_lsu_gnt      ),
    .data_rvalid_i       ( core_lsu_rvalid   ),
    .data_we_o           ( core_lsu_we       ),
    .data_be_o           ( core_lsu_be       ),
    .data_addr_o         ( core_lsu_addr     ),
    .data_wdata_o        ( core_lsu_wdata    ),
    .data_rdata_i        ( core_lsu_rdata    ),
    .data_err_i          (                   ),
    // not used
    .irq_i               ( (!irq_i)          ),
    .irq_id_i            (                   ),
    .irq_ack_o           (                   ),
    .irq_id_o            (                   ),
    // not used
    .debug_req_i         ( dbg_slave.valid     ),
    .debug_gnt_o         (                   ),
    .debug_rvalid_o      ( dbg_slave.ready     ),
    .debug_addr_i        ( dbg_slave.addr      ),
    .debug_we_i          ( dbg_slave.write_en  ),
    .debug_wdata_i       ( dbg_slave.wdata     ),
    .debug_rdata_o       ( dbg_slave.rdata     ),
    .debug_halted_o      (                   ),
    .debug_halt_i        ( 1'b0              ),
    .debug_resume_i      ( 1'b0              ),
                                                     
    .fetch_enable_i      ( fetch_enable_i    ), // core will not work if disable
    .core_busy_o         ( core_busy_o       ),
    // not used 
    .ext_perf_counters_i ( )
  );

  core2axi_wrap
  #(
    .AXI_ADDR_WIDTH   ( AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH   ( AXI_DATA_WIDTH      ),
    .AXI_ID_WIDTH     ( AXI_ID_MASTER_WIDTH ),
    .AXI_USER_WIDTH   ( AXI_USER_WIDTH      ),
    .REGISTERED_GRANT ( "FALSE"             )
  )
  if2axi_i (
    .clk_i            ( clk               ),
    .rst_ni           ( rst_n             ),
    .data_req_i       ( core_instr_req    ),
    .data_gnt_o       ( core_instr_gnt    ),
    .data_rvalid_o    ( core_instr_rvalid ),
    .data_addr_i      ( core_instr_addr   ),
    .data_we_i        ( 1'b0              ),
    .data_be_i        ( 4'b1111           ),
    .data_rdata_o     ( core_instr_rdata  ),
    .data_wdata_i     ( 'd0               ),
    .master           ( if_master_if      )
  );

  axi_slice_wrap
  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH      ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH      ),
    .AXI_ID_WIDTH   ( AXI_ID_MASTER_WIDTH ),
    .SLICE_DEPTH    ( 2                   )
  )
  axi_slice_if2axi (
    .clk_i          ( clk            ),
    .rst_ni         ( rst_n          ),
    .test_en_i      ( testmode_i     ),
    .axi_slave      ( if_master_if   ),
    .axi_master     ( if_master      )
  );

  
  // access data memory

  core2axi_wrap
  #(
      .AXI_ADDR_WIDTH   ( AXI_ADDR_WIDTH      ),
      .AXI_DATA_WIDTH   ( AXI_DATA_WIDTH      ),
      .AXI_ID_WIDTH     ( AXI_ID_MASTER_WIDTH ),
      .AXI_USER_WIDTH   ( AXI_USER_WIDTH      ),
      .REGISTERED_GRANT ( "FALSE"             )
  )
  lsu2axi_i (
    .clk_i            ( clk             ),
    .rst_ni           ( rst_n           ),
    .data_req_i       ( core_lsu_req    ),
    .data_gnt_o       ( core_lsu_gnt    ),
    .data_rvalid_o    ( core_lsu_rvalid ),
    .data_addr_i      ( core_lsu_addr   ),
    .data_we_i        ( core_lsu_we     ),
    .data_be_i        ( core_lsu_be     ),
    .data_rdata_o     ( core_lsu_rdata  ),
    .data_wdata_i     ( core_lsu_wdata  ),
    .master           ( lsu_master_if   )
  );

  axi_slice_wrap
  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH      ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH      ),
    .AXI_ID_WIDTH   ( AXI_ID_MASTER_WIDTH ),
    .SLICE_DEPTH    ( 2                   )
  )
  axi_slice_lsu2axi (
    .clk_i          ( clk            ),
    .rst_ni         ( rst_n          ),
    .test_en_i      ( testmode_i     ),
    .axi_slave      ( lsu_master_if  ),
    .axi_master     ( lsu_master     )
  );

endmodule
