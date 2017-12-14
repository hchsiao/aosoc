`include "jtag_tap.svh"

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

top TOP (
  .tap(tap),

  .clk(clk),
  .rst(rst),
  .test_mode(1'b0)
);

endmodule
