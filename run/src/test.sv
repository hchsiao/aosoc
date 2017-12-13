`include "jtag_tap.svh"
`include "riscv_debug.svh"
`include "dmi_port.svh"

module test;

logic		clk = 0;
logic		rst = 0;

Jtag    tap();

logic   initialized = 0;

initial begin
  //$dumpfile("jtag_dpi.vcd");
  //$dumpvars(0);
  $fsdbDumpfile("jtag_dpi.fsdb");
  $fsdbDumpvars();
end

always
	#1 clk <= ~clk;

initial begin
	#10 rst <= 1;
	#20 rst <= 0;
  initialized <= 1;
end

jtag_dpi #(
  .DEBUG_INFO(0)
)JTAG_HOST(
	.tms(tap.TMS),
  .tck(tap.TCK),
	.tdi(tap.TDI),
	.tdo(tap.TDO),

	.init_done(initialized)
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

// DM
debug_module DM (
  .dm(dm_port),

  .clk(clk),
  .rst(rst),
  .test_mode(1'b0)
);

endmodule
