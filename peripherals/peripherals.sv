// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "axi_bus.sv"
`include "apb_bus.sv"
`include "config.sv"

module peripherals
  #(
    parameter AXI_ADDR_WIDTH       = 32,
    parameter AXI_DATA_WIDTH       = 64,
    parameter AXI_USER_WIDTH       = 6,
    parameter AXI_SLAVE_ID_WIDTH   = 6,
    parameter AXI_MASTER_ID_WIDTH  = 6,
    parameter ROM_START_ADDR       = 32'h8000
  )
  (
    // Clock and Reset
    input logic         clk_i,
    input logic         rst_n,

    input  logic        testmode_i,

    AXI_BUS.Slave       slave,

    output logic        uart_tx,
    input  logic        uart_rx,
    output logic        uart_rts,
    output logic        uart_dtr,
    input  logic        uart_cts,
    input  logic        uart_dsr,

    input  logic        core_busy_i,
    output logic [31:0] irq_o,
    input  logic        fetch_enable_i,
    output logic        fetch_enable_o,
    output logic        clk_gate_core_o
  );

  localparam APB_ADDR_WIDTH  = 32;
  localparam APB_NUM_SLAVES  = 3;

  APB_BUS s_apb_bus();
  APB_BUS s_uart_bus();
  APB_BUS s_timer_bus();
  APB_BUS s_event_unit_bus();

  logic [1:0]   s_spim_event;
  logic [3:0]   timer_irq;
  logic [31:0]  clk_int;
  logic         s_uart_event;

  //////////////////////////////////////////////////////////////////
  ///                                                            ///
  /// Peripheral Clock Gating                                    ///
  ///                                                            ///
  //////////////////////////////////////////////////////////////////

  generate
     genvar i;
       for (i = 0; i < APB_NUM_SLAVES; i = i + 1) begin
        cluster_clock_gating core_clock_gate
        (
          .clk_o     ( clk_int[i]                    ),
          .en_i      ( 1'b1                          ),
          .test_en_i ( testmode_i                    ),
          .clk_i     ( clk_i                         )
        );
      end
   endgenerate

  //////////////////////////////////////////////////////////////////
  ///                                                            ///
  /// AXI2APB Bridge                                             ///
  ///                                                            ///
  //////////////////////////////////////////////////////////////////

  axi2apb_wrap
  #(
      .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH     ),
      .AXI_DATA_WIDTH ( AXI_DATA_WIDTH     ),
      .AXI_USER_WIDTH ( AXI_USER_WIDTH     ),
      .AXI_ID_WIDTH   ( AXI_SLAVE_ID_WIDTH ),
      .APB_ADDR_WIDTH ( APB_ADDR_WIDTH     )
  )
  axi2apb_i
  (
    .clk_i     ( clk_i      ),
    .rst_ni    ( rst_n      ),
    .test_en_i ( testmode_i ),

    .axi_slave ( slave      ),

    .apb_master( s_apb_bus  )
  );

  //////////////////////////////////////////////////////////////////
  ///                                                            ///
  /// APB Bus                                                    ///
  ///                                                            ///
  //////////////////////////////////////////////////////////////////

  periph_bus_wrap
  #(
     .APB_ADDR_WIDTH( APB_ADDR_WIDTH ),
     .APB_DATA_WIDTH( 32             )
  )
  periph_bus_i
  (
     .clk_i             ( clk_i            ),
     .rst_ni            ( rst_n            ),

     .apb_slave         ( s_apb_bus        ),

     .uart_master       ( s_uart_bus       ),
     .timer_master      ( s_timer_bus      ),
     .event_unit_master ( s_event_unit_bus )
  );

  //////////////////////////////////////////////////////////////////
  ///                                                            ///
  /// APB Slave 0: APB UART interface                            ///
  ///                                                            ///
  //////////////////////////////////////////////////////////////////

  apb_uart_sv
    #(
       .APB_ADDR_WIDTH( 3 )
    )
    apb_uart_i
    (
      .clk     ( clk_int[0]            ),
      .rstn    ( rst_n                 ),

      .sel     ( s_uart_bus.psel       ),
      .enable  ( s_uart_bus.penable    ),
      .write   ( s_uart_bus.pwrite     ),
      .addr    ( s_uart_bus.paddr[4:2] ),
      .wdata   ( s_uart_bus.pwdata     ),
      .rdata   ( s_uart_bus.prdata     ),
      .ready   ( s_uart_bus.pready     ),
      .slverr  ( s_uart_bus.pslverr    ),

      .rx_i    ( uart_rx               ),
      .tx_o    ( uart_tx               ),
      .event_o ( s_uart_event          )
    );

  //////////////////////////////////////////////////////////////////
  ///                                                            ///
  /// APB Slave 3: Timer Unit                                    ///
  ///                                                            ///
  //////////////////////////////////////////////////////////////////

  apb_timer
  apb_timer_i
  (
    .HCLK       ( clk_int[1]   ),
    .HRESETn    ( rst_n        ),

    .PADDR      ( s_timer_bus.paddr[11:0]),
    .PWDATA     ( s_timer_bus.pwdata     ),
    .PWRITE     ( s_timer_bus.pwrite     ),
    .PSEL       ( s_timer_bus.psel       ),
    .PENABLE    ( s_timer_bus.penable    ),
    .PRDATA     ( s_timer_bus.prdata     ),
    .PREADY     ( s_timer_bus.pready     ),
    .PSLVERR    ( s_timer_bus.pslverr    ),

    .irq_o      ( timer_irq    )
  );
  //////////////////////////////////////////////////////////////////
  ///                                                            ///
  /// APB Slave 4: Event Unit                                    ///
  ///                                                            ///
  //////////////////////////////////////////////////////////////////

  apb_event_unit
  apb_event_unit_i
  (
    .clk_i            ( clk_i        ),
    .HCLK             ( clk_int[2]   ),
    .HRESETn          ( rst_n        ),

    .PADDR            ( s_event_unit_bus.paddr[11:0]),
    .PWDATA           ( s_event_unit_bus.pwdata     ),
    .PWRITE           ( s_event_unit_bus.pwrite     ),
    .PSEL             ( s_event_unit_bus.psel       ),
    .PENABLE          ( s_event_unit_bus.penable    ),
    .PRDATA           ( s_event_unit_bus.prdata     ),
    .PREADY           ( s_event_unit_bus.pready     ),
    .PSLVERR          ( s_event_unit_bus.pslverr    ),

    .irq_i            ( {timer_irq, s_uart_event, 27'b0} ),
    .event_i          ( {timer_irq, s_uart_event, 27'b0} ),
    .irq_o            ( irq_o              ),

    .fetch_enable_i   ( fetch_enable_i     ),
    .fetch_enable_o   ( fetch_enable_o     ),
    .clk_gate_core_o  ( clk_gate_core_o    ),
    .core_busy_i      ( core_busy_i        )
  );

endmodule
