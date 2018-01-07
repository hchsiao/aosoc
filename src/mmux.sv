`include "core_wrapper.svh"

module mmux (
  MemPort.Slave from_lsu,
  MemPort.Master to_mem,
  MemPort.Master to_uart
);

  // from_lsu.addr already have offset of 'h10000000, base address of uart is 'h40000000
  wire uart_sel = (from_lsu.addr >= 'h30000000) && (from_lsu.addr < 'h30001000);

  assign from_lsu.ready = uart_sel ? to_uart.ready : to_mem.ready;
  assign from_lsu.rdata = to_mem.rvalid ? to_mem.rdata : to_uart.rdata;
  assign from_lsu.rvalid = to_mem.rvalid ? to_mem.rvalid : to_uart.rvalid;

  assign to_uart.valid = from_lsu.valid && uart_sel;
  assign to_uart.write_en = from_lsu.write_en;
  assign to_uart.byte_en = from_lsu.byte_en;
  assign to_uart.addr = from_lsu.addr - 'h30000000;
  assign to_uart.wdata = from_lsu.wdata;

  assign to_mem.valid = from_lsu.valid && !uart_sel;
  assign to_mem.write_en = from_lsu.write_en;
  assign to_mem.byte_en = from_lsu.byte_en;
  assign to_mem.addr = from_lsu.addr;
  assign to_mem.wdata = from_lsu.wdata;

endmodule
