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
`include "axi_bus.sv"
`include "dmi_port.svh"
`include "jtag_tap.svh"

`define AXI_ADDR_WIDTH 32
`define AXI_DATA_WIDTH 32
`define AXI_USER_WIDTH 1
`define AXI_ID_MASTER_WIDTH 2
`define AXI_ID_SLAVE_WIDTH 3
`define INSTR_RAM_SIZE 131072
`define DATA_RAM_SIZE 131072

module top(
  input        clk,
  input        rst_n,
  input        fetch_enable_i,
  input        clk_gating_i,
  output logic core_busy_o,
  output logic uart_tx,
  input        uart_rx,
  output logic uart_rts,
  output logic uart_dtr,
  input        uart_cts,
  input        uart_dsr,

  Jtag         tap
);

  AXI_BUS
  #(
    .AXI_ADDR_WIDTH ( `AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH ( `AXI_DATA_WIDTH      ),
    .AXI_ID_WIDTH   ( `AXI_ID_MASTER_WIDTH ),
    .AXI_USER_WIDTH ( `AXI_USER_WIDTH      )
  )
  masters[1:0] ();

  AXI_BUS
  #(
    .AXI_ADDR_WIDTH ( `AXI_ADDR_WIDTH     ),
    .AXI_DATA_WIDTH ( `AXI_DATA_WIDTH     ),
    .AXI_ID_WIDTH   ( `AXI_ID_SLAVE_WIDTH ),
    .AXI_USER_WIDTH ( `AXI_USER_WIDTH     )
  )
  slaves[3:0] ();

  logic [31:0] irq_to_core_int;
  logic [31:0] boot_addr;



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
    .rst           ( ~rst_n              ),
    .test_mode     ( 1'b0                )
  );

///////////////////////////////////////////////////////
//
//  
//
//
//
//
///////////////////////////////////////////////////////  

  assign boot_addr = 32'h1002_0000;

  core_region
  #(
    .AXI_ADDR_WIDTH      ( `AXI_ADDR_WIDTH       ),
    .AXI_DATA_WIDTH      ( `AXI_DATA_WIDTH       ),
    .AXI_USER_WIDTH      ( `AXI_USER_WIDTH       ),
    .AXI_ID_MASTER_WIDTH ( `AXI_ID_MASTER_WIDTH  )
  )
  core
  (
    .clk                 ( clk              ),
    .rst_n               ( rst_n            ),
    .clk_gating_i        ( clk_gating_i     ),
    .testmode_i          ( 1'b0             ),
    .fetch_enable_i      ( fetch_enable_i   ),
    .irq_i               ( irq_to_core_int  ),
    .boot_addr_i         ( boot_addr        ),
    .core_busy_o         ( core_busy_o      ),

    .dbg_slave           ( dm_port          ),
    
    .if_master           ( masters[0]       ),
    .lsu_master          ( masters[1]       )
  );

///////////////////////////////////////////////////////
//
//  
//
//
//
//
///////////////////////////////////////////////////////  

  instr_mem
  #(
    .AXI_ADDR_WIDTH     ( `AXI_ADDR_WIDTH     ),
    .AXI_DATA_WIDTH     ( `AXI_DATA_WIDTH     ),
    .AXI_ID_SLAVE_WIDTH ( `AXI_ID_SLAVE_WIDTH ),
    .AXI_USER_WIDTH     ( `AXI_USER_WIDTH     ),
    .INSTR_RAM_SIZE     ( `INSTR_RAM_SIZE     )
  )
  instr_mem_i
  (
    .clk   ( clk       ),
    .rst_n ( rst_n     ),
    
    .slave ( slaves[0] )
  );
  
///////////////////////////////////////////////////////
//
//  
//
//
//
//
///////////////////////////////////////////////////////  

  data_mem
  #(
    .AXI_ADDR_WIDTH     ( `AXI_ADDR_WIDTH     ),
    .AXI_DATA_WIDTH     ( `AXI_DATA_WIDTH     ),
    .AXI_ID_SLAVE_WIDTH ( `AXI_ID_SLAVE_WIDTH ),
    .AXI_USER_WIDTH     ( `AXI_USER_WIDTH     ),
    .DATA_RAM_SIZE      ( `DATA_RAM_SIZE      )
  )
  data_mem_i
  (
    .clk   ( clk      ),
    .rst_n ( rst_n    ),

    .slave ( slaves[1] )
  );

///////////////////////////////////////////////////////
//
//  
//
//
//
//
/////////////////////////////////////////////////////// 
  aos
  #(
    .AXI_ADDR_WIDTH     (`AXI_ADDR_WIDTH    ),
    .AXI_DATA_WIDTH     (`AXI_DATA_WIDTH    ),
    .AXI_ID_SLAVE_WIDTH (`AXI_ID_SLAVE_WIDTH),
    .AXI_USER_WIDTH     (`AXI_USER_WIDTH    ),
    .AOS_ADDR_WIDTH     (1                  )
  ) 
  aos_i
  (
   .clk   ( clk    ),
   .rst   (~rst_n  ),
   
   .slave (slaves[3])
  );


///////////////////////////////////////////////////////
//
//  
//
//
//
//
///////////////////////////////////////////////////////  
 

  peripherals
  #(
    .AXI_ADDR_WIDTH      ( `AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH      ( `AXI_DATA_WIDTH      ),
    .AXI_SLAVE_ID_WIDTH  ( `AXI_ID_SLAVE_WIDTH  ),
    .AXI_MASTER_ID_WIDTH ( `AXI_ID_MASTER_WIDTH ),
    .AXI_USER_WIDTH      ( `AXI_USER_WIDTH      )
  )
  peripherals_i
  (
    .clk_i           ( clk             ),
    .rst_n           ( rst_n           ),
    .testmode_i      ( 1'b0            ),
    .slave           ( slaves[2]       ),
    .uart_tx         ( uart_tx         ),
    .uart_rx         ( uart_rx         ),
    .uart_rts        ( uart_rts        ),
    .uart_dtr        ( uart_dtr        ),
    .uart_cts        ( uart_cts        ),
    .uart_dsr        ( uart_dsr        ),
    .core_busy_i     ( core_busy_o     ),
    .irq_o           ( irq_to_core_int ),
    .fetch_enable_i  ( fetch_enable_i  ),
    .fetch_enable_o  (                 ),
    .clk_gate_core_o (                 )
  );

///////////////////////////////////////////////////////
//
//  
//
//
//
//
///////////////////////////////////////////////////////  

  axi_node_intf_wrap
  #(
    .NB_MASTER      ( 4                              ),
    .NB_SLAVE       ( 2                              ),
    .AXI_ADDR_WIDTH ( `AXI_ADDR_WIDTH                ),
    .AXI_DATA_WIDTH ( `AXI_DATA_WIDTH                ),
    .AXI_ID_WIDTH   ( `AXI_ID_MASTER_WIDTH           ),
    .AXI_USER_WIDTH ( `AXI_USER_WIDTH                )
  )
  axi_interconnect_i 
  (
    .clk            ( clk                            ),
    .rst_n          ( rst_n                          ),
    .test_en_i      ( 1'b0                           ),
    .master         ( slaves                         ),
    .slave          ( masters                        ),
    .start_addr_i   ( {32'h2200_0000,32'h2100_0000, 32'h1013_0000, 32'h1000_0000} ),
    .end_addr_i     ( {32'h2200_0004,32'h2100_FFFF, 32'h1013_FFFF, 32'h1003_FFFF} )
  );
endmodule
