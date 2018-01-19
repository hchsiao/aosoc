`include "jtag_tap.svh"
`include "riscv_debug.svh"
`include "dmi_port.svh"


module top (
  Jtag tap,

  input logic clk,
  input logic rst,
  input logic test_mode
);

parameter AXI_ADDR_WIDTH      = 32;
parameter AXI_DATA_WIDTH      = 32;
parameter AXI_USER_WIDTH      = 1;
parameter AXI_ID_MASTER_WIDTH = 2;
parameter AXI_ID_SLAVE_WIDTH  = 3; // slave id width should be master id width + log(master id width)
parameter DATA_RAM_SIZE       = 32768;
parameter INSTR_RAM_SIZE      = 32768;
parameter DATA_ADDR_WIDTH     = $clog2(DATA_RAM_SIZE);
parameter INSTR_ADDR_WIDTH    = $clog2(INSTR_RAM_SIZE);
parameter UART_ADDR_WIDTH     = 12;
parameter UART_DATA_WIDTH     = 32;


logic [31: 0] boot_addr_i;
logic         clock_gating_i;

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

logic                        data_mem_en;
logic [DATA_ADDR_WIDTH-1:0]  data_mem_addr;
logic                        data_mem_we;
logic [AXI_DATA_WIDTH/8-1:0] data_mem_be;
logic [AXI_DATA_WIDTH-1:0]   data_mem_rdata;
logic [AXI_DATA_WIDTH-1:0]   data_mem_wdata;

logic                        instr_mem_en;
logic [DATA_ADDR_WIDTH-1:0]  instr_mem_addr;
logic                        instr_mem_we;
logic [AXI_DATA_WIDTH/8-1:0] instr_mem_be;
logic [AXI_DATA_WIDTH-1:0]   instr_mem_rdata;
logic [AXI_DATA_WIDTH-1:0]   instr_mem_wdata;

logic [UART_ADDR_WIDTH-1:0]  uart_addr;
logic [UART_DATA_WIDTH-1:0]  uart_rdata;
logic [UART_DATA_WIDTH-1:0]  uart_wdata;
logic                        uart_enable;
logic                        uart_write;


// interface between TAP & DTM
DTMCS   dtmcs_scan_in;
DMI     dmi_scan_in;
DTMCS   dtmcs_scan_out;
DMI     dmi_scan_out;
logic   dtmcs_scan_in_valid;
logic   dmi_scan_in_valid;

// interface between DTM & DM
DMIPort dm_port();

// TAP
jtag_tap JTAG_TARGET (
  .tap           ( tap                 ),
  .dtmcs_valid_o ( dtmcs_scan_in_valid ),
  .dtmcs_i       ( dtmcs_scan_out      ),
  .dtmcs_o       ( dtmcs_scan_in       ),
  .dmi_valid_o   ( dmi_scan_in_valid   ),
  .dmi_i         ( dmi_scan_out        ),
  .dmi_o         ( dmi_scan_in         ),

  .clk           ( clk                 ),
  .test_mode     ( 1'b0                )
);

// DTM
debug_transfer_module DTM (
  .dtmcs_valid_i ( dtmcs_scan_in_valid ),
  .dtmcs_i       ( dtmcs_scan_in       ),
  .dtmcs_o       ( dtmcs_scan_out      ),
  .dmi_valid_i   ( dmi_scan_in_valid   ),
  .dmi_i         ( dmi_scan_in         ),
  .dmi_o         ( dmi_scan_out        ),

  .dm            ( dm_port             ),

  .clk           ( clk                 ),
  .rst           ( rst                 ),
  .test_mode     ( 1'b0                )
);

assign clock_gating_i = 1'b1;
assign boot_addr_i = 32'h1000_0000;

// core
zeroriscy_core
#(
  .N_EXT_PERF_COUNTERS ( 0    ),
  .RV32E               ( 0    ),
  .RV32M               ( 1    )
)
RISCV_CORE
(
  .clk_i               ( clk               ),
  .rst_ni              ( ~rst              ),

  .clock_en_i          ( clock_gating_i    ),
  .test_en_i           ( 1'b0              ),

  .boot_addr_i         ( boot_addr_i       ),
  .core_id_i           ( 4'h0              ),
  .cluster_id_i        ( 6'h0              ),

  .instr_addr_o        ( core_instr_addr   ),
  .instr_req_o         ( core_instr_req    ),
  .instr_rdata_i       ( core_instr_rdata  ),
  .instr_gnt_i         ( core_instr_gnt    ),
  .instr_rvalid_i      ( core_instr_rvalid ),

  .data_addr_o         ( core_lsu_addr     ),
  .data_wdata_o        ( core_lsu_wdata    ),
  .data_we_o           ( core_lsu_we       ),
  .data_req_o          ( core_lsu_req      ),
  .data_be_o           ( core_lsu_be       ),
  .data_rdata_i        ( core_lsu_rdata    ),
  .data_gnt_i          ( core_lsu_gnt      ),
  .data_rvalid_i       ( core_lsu_rvalid   ),
  .data_err_i          ( 1'b0              ),

  .irq_i               ( 1'b0              ),
  .irq_id_i            ( 4'd0              ),
  .irq_ack_o           (                   ),
  .irq_id_o            (                   ),

  .debug_req_i         ( dm_port.valid     ),
  .debug_gnt_o         (                   ),
  .debug_rvalid_o      ( dm_port.ready     ),
  .debug_addr_i        ( dm_port.addr      ),
  .debug_we_i          ( dm_port.write_en  ),
  .debug_wdata_i       ( dm_port.wdata     ),
  .debug_rdata_o       ( dm_port.rdata     ),
  .debug_halted_o      (                   ),
  .debug_halt_i        ( 1'b0              ),
  .debug_resume_i      ( 1'b0              ),

  .fetch_enable_i      ( 1'b1              ),
  .core_busy_o         (                   ),
  .ext_perf_counters_i (                   )
);

/*sp_ram_wrap
#(
    .RAM_SIZE    ( INSTR_RAM_SIZE  ),
    .DATA_WIDTH  ( AXI_DATA_WIDTH  )
)
instr_mem (
    .clk         ( clk             ),
    .rstn_i      ( ~rst            ),
    .en_i        ( instr_mem_req   ),
    .addr_i      ( instr_mem_addr  ),
    .wdata_i     ( instr_mem_wdata ),
    .rdata_o     ( instr_mem_rdata ),
    .we_i        ( instr_mem_we    ),
    .be_i        ( instr_mem_be    ),
    .bypass_en_i ( 1'b0            )
);
*/

instr_ram_wrap
#(
  .RAM_SIZE    ( INSTR_RAM_SIZE  ),
  .DATA_WIDTH  ( AXI_DATA_WIDTH  )
)
instr_mem (
  .clk         ( clk             ),
  .en_i        ( instr_mem_req   ),
  .addr_i      ( instr_mem_addr  ),
  .wdata_i     ( instr_mem_wdata ),
  .rdata_o     ( instr_mem_rdata ),
  .we_i        ( instr_mem_we    ),
  .be_i        ( instr_mem_be    ),
  .bypass_en_i ( 1'b0            )
);

sp_ram_wrap
#(
    .RAM_SIZE    ( DATA_RAM_SIZE  ),
    .DATA_WIDTH  ( AXI_DATA_WIDTH )
)
data_mem (
    .clk         ( clk            ),
    .rstn_i      ( ~rst           ),
    .en_i        ( data_mem_req   ),
    .addr_i      ( data_mem_addr  ),
    .wdata_i     ( data_mem_wdata ),
    .rdata_o     ( data_mem_rdata ),
    .we_i        ( data_mem_we    ),
    .be_i        ( data_mem_be    ),
    .bypass_en_i ( 1'b0           )
);

uart uart(
     .clk      (clk            ),
     .rst      (rst            ),
     .addr_i   (uart_addr      ),
     .wdata_i  (uart_wdata     ),
     .write_i  (uart_write     ),
     .sel_i    (1'b1  ),
     .enable_i (uart_enable    ),
     .rdata_o  (uart_rdata     ),
     .ready_o  (               )
);


axi AXI (
  .clk                 ( clk               ),
  .rst                 ( rst               ),
  .testmode_i          ( 1'b0              ),
                       
  .core_instr_req_i    ( core_instr_req    ),
  .core_instr_gnt_o    ( core_instr_gnt    ),
  .core_instr_rvalid_o ( core_instr_rvalid ),
  .core_instr_addr_i   ( core_instr_addr   ),
  .core_instr_rdata_o  ( core_instr_rdata  ),
                     
  .core_lsu_req_i      ( core_lsu_req      ),
  .core_lsu_gnt_o      ( core_lsu_gnt      ),
  .core_lsu_rvalid_o   ( core_lsu_rvalid   ),
  .core_lsu_we_i       ( core_lsu_we       ),
  .core_lsu_be_i       ( core_lsu_be       ),
  .core_lsu_addr_i     ( core_lsu_addr     ),
  .core_lsu_wdata_i    ( core_lsu_wdata    ),
  .core_lsu_rdata_o    ( core_lsu_rdata    ),
                      
  .instr_mem_req_o     ( instr_mem_req     ),
  .instr_mem_addr_o    ( instr_mem_addr    ),
  .instr_mem_we_o      ( instr_mem_we      ),
  .instr_mem_be_o      ( instr_mem_be      ),
  .instr_mem_rdata_i   ( instr_mem_rdata   ),
  .instr_mem_wdata_o   ( instr_mem_wdata   ),
                       
  .data_mem_req_o      ( data_mem_req      ),
  .data_mem_addr_o     ( data_mem_addr     ),
  .data_mem_we_o       ( data_mem_we       ),
  .data_mem_be_o       ( data_mem_be       ),
  .data_mem_rdata_i    ( data_mem_rdata    ),
  .data_mem_wdata_o    ( data_mem_wdata    ),

  .uart_addr_o         (uart_addr          ),
  .uart_wdata_o        (uart_wdata         ),
  .uart_write_o        (uart_write         ),
  .uart_enable_o       (uart_enable        ),
  .uart_rdata_i        (uart_rdata         )
);

endmodule
