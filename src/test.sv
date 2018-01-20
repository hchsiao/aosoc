`include "jtag_tap.svh"

module test;

logic	clk;
logic	rst;
logic tx;
logic rx;

Jtag  tap();

logic initialized = 0;

initial begin
  //$dumpfile("jtag_dpi.vcd");
  //$dumpvars(0);
  $fsdbDumpfile("jtag_dpi.fsdb");
  $fsdbDumpvars();
end

always
	#5 clk <= ~clk;

initial begin
  clk = 'b0; rst = 1'b1;
	#7 rst <= 1;
	#23 rst <= 0;
  initialized <= 1;
  if(!$test$plusargs("jtag_vpi_enable"))
    #10000 $finish();
end

jtag_dpi 
#(
  .DEBUG_INFO ( 0 )
)
JTAG_HOST
(
	.tms       ( tap.TMS     ),
  .tck       ( tap.TCK     ),
	.tdi       ( tap.TDI     ),
	.tdo       ( tap.TDO     ),

	.init_done ( initialized )
);

uartdpi
#(
  .BAUD ( 100000   ),
  .FREQ ( 10000000 )
)
UART_HOST
(
  .clk ( clk ),
  .rst ( rst ),
  .tx  ( rx  ),
  .rx  ( tx  )
);

top TOP (
  .tap            ( tap  ),

  .clk            ( clk  ),
  .rst_n          ( ~rst ),
  .fetch_enable_i ( 1'b1 ),
  .clk_gating_i   ( 1'b1 ),
  .core_busy_o    (      ),
  .uart_tx        ( tx   ),
  .uart_rx        ( rx   ),
  .uart_rts       (      ),
  .uart_dtr       (      ),
  .uart_cts       (      ),
  .uart_dsr       (      )
);

endmodule
