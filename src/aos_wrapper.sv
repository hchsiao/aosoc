module aos_wrapper#(
  parameter AXI_DATA_WIDTH = 32,
  parameter IN_NBYTE = 1
)
(
  input  logic                      axi4_strm_addr_i,
  input  logic[AXI_DATA_WIDTH-1:0]  axi4_strm_in_wdata_i,
  input  logic                      axi4_strm_in_valid_i,
  output logic                      axi4_strm_in_ready_o,
  input  logic[IN_NBYTE-1:0]        axi4_strm_in_keep_i,
  input  logic                      axi4_strm_in_last_i,
  output logic[AXI_DATA_WIDTH-1:0]  axi4_strm_out_rdata_o,
  input  logic                      clk,
  input  logic                      rst
);
  logic                  axi4_strm_in_valid;
  logic [IN_NBYTE*8-1:0] axi4_strm_in_data;
  logic                  axi4_strm_in_ready;
  logic [IN_NBYTE-1  :0] axi4_strm_in_keep;
  logic                  axi4_strm_in_last;

  logic                  axi4_strm_out_valid;
  logic [IN_NBYTE*8-1:0] axi4_strm_out_data;
  logic                  axi4_strm_out_ready;
  logic [IN_NBYTE-1  :0] axi4_strm_out_keep;
  logic                  axi4_strm_out_last;
  
  logic                  fifo_valid;
  logic [IN_NBYTE*8-1:0] fifo_data;
  logic                  fifo_ready;  

  always_comb begin
   if(axi4_strm_addr_i == 1'b0) axi4_strm_in_valid = axi4_strm_in_valid_i;
   else axi4_strm_in_valid = 1'b0;
   axi4_strm_in_data     = axi4_strm_in_wdata_i[IN_NBYTE*8-1:0];
   axi4_strm_in_ready_o  = axi4_strm_in_ready;
   axi4_strm_in_keep     = axi4_strm_in_keep_i;
   axi4_strm_in_last     = axi4_strm_in_last_i;
  end


  always_comb begin
    if(axi4_strm_addr == 1'b0)begin //in 
      fifo_ready = 1'b0;
    end
    else begin //out
      fifo_ready = 1'b1;
    end 
  end

  always_comb begin
    if(fifo_valid) axi4_strm_out_rdata_o = {{24{1'b0}},fifo_data};
    else           axi4_strm_out_rdata_o = 32'b0;
  end 
  
  fifo out_fifo(
     .clk        (clk                 ),
     .rst        (rst                 ),
     .m_vaild    (axi4_strm_out_valid ),
     .m_data     (axi4_strm_out_data  ),
     .m_ready    (axi4_strm_out_ready ),
     .s_valid    (fifo_valid          ),
     .s_data     (fifo_data           ),
     .s_ready    (fifo_ready          ),
  );

  aos_axis #(
  )AOS_AXIS(
    .frame_width(9'd128),
    .axi4_strm_in_data(axi4_strm_in_data      ),
    .axi4_strm_in_valid(axi4_strm_in_valid    ),
    .axi4_strm_in_ready(axi4_strm_in_ready    ),
    .axi4_strm_in_keep(axi4_strm_in_keep      ),
    .axi4_strm_in_last(axi4_strm_in_last      ),
    .axi4_strm_out_data(axi4_strm_out_data    ),
    .axi4_strm_out_valid(axi4_strm_out_valid  ),
    .axi4_strm_out_ready(axi4_strm_out_ready  ),
    .axi4_strm_out_keep(axi4_strm_out_keep    ),
    .axi4_strm_out_last(axi4_strm_out_last    ),
    .clk(clk),
    .reset(rst)
  );

endmodule
