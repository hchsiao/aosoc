`include "axi_bus.sv"
module aos#(
  parameter AXI_ADDR_WIDTH = 32,
  parameter AXI_DATA_WIDTH = 32,
  parameter AXI_ID_SLAVE_WIDTH = 3,
  parameter AXI_USER_WIDTH =  1,
  parameter AOS_ADDR_WIDTH =  1
)(
  input          clk,
  input          rst,

  AXI_BUS.Slave  slave
);
 
  logic[AOS_ADDR_WIDTH-1 :0] aos_addr;
  logic[AXI_DATA_WIDTH-1 :0] aos_wdata;
  logic[AXI_DATA_WIDTH-1 :0] aos_rdata;
  logic                      aos_valid;
  logic                      aos_ready; // no use

  aos_wrapper aos(
     .axi4_strm_addr_i       (aos_addr  ),
     .axi4_strm_in_wdata_i   (aos_wdata ),
     .axi4_strm_in_valid_i   (aos_valid ),
     .axi4_strm_in_ready_o   (aos_ready ),
     .axi4_strm_in_keep_i    (1'b1      ),
     .axi4_strm_in_last_i    (1'b0      ),
     .axi4_strm_out_rdata_o  (aos_rdata ),
     .clk                    (clk       ),
     .rst                    (rst       )
  );



   axi_mem_if_SP_wrap
    #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH     ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH     ),
        .AXI_ID_WIDTH   ( AXI_ID_SLAVE_WIDTH ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH     ),
        .MEM_ADDR_WIDTH ( AOS_ADDR_WIDTH     )
    )
    aos_axi_if (
        .clk            ( clk              ),
        .rst_n          ( ~rst             ),
        .test_en_i      ( testmode_i       ),
        .mem_req_o      ( aos_valid        ),
        .mem_addr_o     ( aos_addr         ),
        .mem_we_o       (                  ),
        .mem_be_o       (                  ),
        .mem_rdata_i    ( aos_rdata        ),
        .mem_wdata_o    ( aos_wdata        ),
        .slave          ( slave            )
    );   


endmodule
