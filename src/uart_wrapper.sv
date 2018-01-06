`include "core_wrapper.svh"

module uart_wrapper (
  input logic clk,
  input logic rst,
  MemPort.Slave from_core
);

assign from_core.ready = 0;
assign from_core.rdata = 0;
assign from_core.rvalid = 0;

endmodule
