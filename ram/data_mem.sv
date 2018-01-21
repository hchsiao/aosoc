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

module data_mem
#(
  parameter AXI_ADDR_WIDTH     = 32,
  parameter AXI_DATA_WIDTH     = 32,
  parameter AXI_ID_SLAVE_WIDTH = 6,
  parameter AXI_USER_WIDTH     = 1,
  parameter DATA_RAM_SIZE      = 65536,
  parameter DATA_ADDR_WIDTH    = $clog2(DATA_RAM_SIZE)
)
(
  input clk,
  input rst_n,

  output logic [7:0] led,

  AXI_BUS.Slave slave
);

  logic                        data_mem_req;
  logic [DATA_ADDR_WIDTH-1:0]  data_mem_addr;
  logic                        data_mem_we;
  logic [AXI_DATA_WIDTH/8-1:0] data_mem_be;
  logic [AXI_DATA_WIDTH-1:0]   data_mem_rdata;
  logic [AXI_DATA_WIDTH-1:0]   data_mem_wdata;

  always_ff @(posedge clk)
  begin
    if (!rst_n)
      led <= 7'b0;
    else
      if (data_mem_req && data_mem_we && data_mem_be[0] && data_mem_addr == 'h10130000)
        led <= data_mem_wdata[7:0];
  end

  axi_mem_if_SP_wrap
  #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH     ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH     ),
    .AXI_ID_WIDTH   ( AXI_ID_SLAVE_WIDTH ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH     ),
    .MEM_ADDR_WIDTH ( DATA_ADDR_WIDTH    )
  )
  data_mem_axi_if (
    .clk            ( clk            ),
    .rst_n          ( rst_n          ),
    .test_en_i      ( 1'b0           ),
    .mem_req_o      ( data_mem_req   ),
    .mem_addr_o     ( data_mem_addr  ),
    .mem_we_o       ( data_mem_we    ),
    .mem_be_o       ( data_mem_be    ),
    .mem_rdata_i    ( data_mem_rdata ),
    .mem_wdata_o    ( data_mem_wdata ),
    .slave          ( slave          )
  );

  sp_ram_wrap
  #(
      .RAM_SIZE    ( DATA_RAM_SIZE  )
  )
  data_mem (
      .clk         ( clk            ),
      .rstn_i      ( rst_n          ),
      .en_i        ( data_mem_req   ),
      .addr_i      ( data_mem_addr  ),
      .wdata_i     ( data_mem_wdata ),
      .rdata_o     ( data_mem_rdata ),
      .we_i        ( data_mem_we    ),
      .be_i        ( data_mem_be    ),
      .bypass_en_i ( 1'b0           )
  );
  
endmodule