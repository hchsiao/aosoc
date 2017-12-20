`include "jtag_tap.svh"
`include "riscv_debug.svh"
`include "dmi_port.svh"
`include "core_wrapper.svh"


module top (
  Jtag tap,

  input logic clk,
  input logic rst,
  input logic test_mode
);

// interface between TAP & DTM
DTMCS dtmcs_scan_in;
DMI dmi_scan_in;
DTMCS dtmcs_scan_out;
DMI dmi_scan_out;
logic dtmcs_scan_in_valid;
logic dmi_scan_in_valid;

// interface between DTM & DM
DMIPort dm_port();

// TAP
jtag_tap JTAG_TARGET (
  .tap(tap),
  .dtmcs_valid_o(dtmcs_scan_in_valid),
  .dtmcs_i(dtmcs_scan_out),
  .dtmcs_o(dtmcs_scan_in),
  .dmi_valid_o(dmi_scan_in_valid),
  .dmi_i(dmi_scan_out),
  .dmi_o(dmi_scan_in),

  .clk(clk),
  .test_mode(1'b0)
);

// DTM
debug_transfer_module DTM (
  .dtmcs_valid_i(dtmcs_scan_in_valid),
  .dtmcs_i(dtmcs_scan_in),
  .dtmcs_o(dtmcs_scan_out),
  .dmi_valid_i(dmi_scan_in_valid),
  .dmi_i(dmi_scan_in),
  .dmi_o(dmi_scan_out),

  .dm(dm_port),

  .clk(clk),
  .rst(rst),
  .test_mode(1'b0)
);

// core
MemPort instr_mem();
MemPort data_mem();

core_wrapper CORE(
  .instr_mem(instr_mem),
  .data_mem(data_mem),

  .dm(dm_port),

  .clk(clk),
  .rst(rst),
  .test_mode(1'b0)
);

mem MEM(
  .instr_mem(instr_mem),
  .data_mem(data_mem),

  .clk(clk),
  .rst(rst),
  .test_mode(1'b0)
);

endmodule
