module aos_wrapper (
  MemPort.Slave bus_interface,

  input logic clk,
  input logic rst
);

  aos_axis #(
  )AOS_AXIS(
    .frame_width(9'd128),
    .axi4_strm_in_data(axi4_strm_in_data_delay),
    .axi4_strm_in_valid(axi4_strm_in_valid_delay),
    .axi4_strm_in_ready(axi4_strm_in_ready),
    .axi4_strm_in_keep(axi4_strm_in_keep_delay),
    .axi4_strm_in_last(axi4_strm_in_last_delay),
    .axi4_strm_out_data(axi4_strm_out_data),
    .axi4_strm_out_valid(axi4_strm_out_valid),
    .axi4_strm_out_ready(axi4_strm_out_ready_delay),
    .axi4_strm_out_keep(axi4_strm_out_keep),
    .axi4_strm_out_last(axi4_strm_out_last),
    .clk(clk),
    .reset(reset)
  );

endmodule
