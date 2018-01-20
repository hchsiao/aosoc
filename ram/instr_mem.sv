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

module instr_mem
#(
  parameter AXI_ADDR_WIDTH     = 32,
  parameter AXI_DATA_WIDTH     = 32,
  parameter AXI_ID_SLAVE_WIDTH = 6,
  parameter AXI_USER_WIDTH     = 1,
  parameter INSTR_RAM_SIZE     = 65536,
  parameter INSTR_ADDR_WIDTH   = $clog2(INSTR_RAM_SIZE)
)
(
  input clk,
  input rst_n,

  AXI_BUS.Slave slave 
);

  logic                        instr_mem_req;
  logic [INSTR_ADDR_WIDTH-1:0] instr_mem_addr;
  logic                        instr_mem_we;
  logic [AXI_DATA_WIDTH/8-1:0] instr_mem_be;
  logic [AXI_DATA_WIDTH-1:0]   instr_mem_rdata;
  logic [AXI_DATA_WIDTH-1:0]   instr_mem_wdata;

  axi_mem_if_SP_wrap
  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH      ),
    .AXI_ID_WIDTH   ( AXI_ID_SLAVE_WIDTH  ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH      ),
    .MEM_ADDR_WIDTH ( INSTR_ADDR_WIDTH    )
  )
  instr_mem_axi_if (
    .clk            ( clk             ),
    .rst_n          ( rst_n           ),
    .test_en_i      ( 1'b0            ),
    .mem_req_o      ( instr_mem_req   ),
    .mem_addr_o     ( instr_mem_addr  ),
    .mem_we_o       ( instr_mem_we    ),
    .mem_be_o       ( instr_mem_be    ),
    .mem_rdata_i    ( instr_mem_rdata ),
    .mem_wdata_o    ( instr_mem_wdata ),
    .slave          ( slave           )
  );

  instr_ram_wrap
  #(
    .RAM_SIZE    ( INSTR_RAM_SIZE  )
  )
  instr_mem (
    .clk         ( clk             ),
    .rst_n       ( rst_n           ),
    .en_i        ( instr_mem_req   ),
    .addr_i      ( instr_mem_addr  ),
    .wdata_i     ( instr_mem_wdata ),
    .rdata_o     ( instr_mem_rdata ),
    .we_i        ( instr_mem_we    ),
    .be_i        ( instr_mem_be    ),
    .bypass_en_i ( 1'b0            )
  );
endmodule
