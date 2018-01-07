`include "core_wrapper.svh"

module uart_wrapper (
  input logic clk,
  input logic rst,
  MemPort.Slave from_core
);

logic rvalid;
assign from_core.ready = from_core.valid;
assign from_core.rvalid = rvalid;
uart UART (
  .addr_i(from_core.addr[11:0]),
  .wdata_i(from_core.wdata),
  .write_i(from_core.write_en),
  .sel_i(1'b1),
  .enable_i(from_core.valid),
  .rdata_o(from_core.rdata),
  .ready_o(),
  .clk(clk),
  .rst(rst)
);

always_ff @(posedge clk) begin
  if (rst)
    rvalid <= 0;
  else
    rvalid <= from_core.valid;
end

endmodule
