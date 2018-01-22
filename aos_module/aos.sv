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
  logic                      aos_we;
  logic[3:0]                 aos_be;
  logic[AXI_DATA_WIDTH-1 :0] aos_rdata;
  logic                      aos_valid;
  logic                      aos_ready;

  logic [7:0] aos_out;
  logic       aos_out_en;

  logic [7:0] latch;
  logic       dirty;

  always_ff @(posedge clk)
  begin
    if (rst) begin
      latch <= 0;
      dirty <= 0;
    end
    else begin
      if (aos_out_en) begin
        latch <= aos_out;
        dirty <= 1;
      end
      else if (aos_valid && !aos_we) // read access
        dirty <= 0;
    end
  end

  assign aos_rdata = {aos_ready, dirty, 22'b0, latch};

  aos_axis #(
  )AOS_AXIS(
    .frame_width(9'd128),
    .axi4_strm_in_data(aos_wdata[7:0]      ),
    .axi4_strm_in_valid(aos_we && aos_be[0] && aos_valid    ),
    .axi4_strm_in_ready(aos_ready    ),
    .axi4_strm_in_keep(-1      ),
    .axi4_strm_in_last(1'b0      ),
    .axi4_strm_out_data(aos_out    ),
    .axi4_strm_out_valid(aos_out_en  ),
    .axi4_strm_out_ready(1'b1  ),
    .axi4_strm_out_keep(),
    .axi4_strm_out_last(),
    .clk(clk),
    .reset(rst)
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
        .test_en_i      ( 1'b0             ),
        .mem_req_o      ( aos_valid        ),
        .mem_addr_o     ( aos_addr         ),
        .mem_we_o       ( aos_we           ),
        .mem_be_o       ( aos_be           ),
        .mem_rdata_i    ( aos_rdata        ),
        .mem_wdata_o    ( aos_wdata        ),
        .slave          ( slave            )
    );   


endmodule
