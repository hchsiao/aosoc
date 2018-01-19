/* 
    * File Name : 
    *
    * Purpose :
    *           
    * Creation Date : 
    *
    * Last Modified : 
    *
    * Create By : Jyun-Neng Ji
    *
*/
module uart
#(
    parameter        BAUD       = 100000,
    parameter        FREQ       = 10000000,
    parameter        ADDR_WIDTH = 12,
    parameter string NAME       = "uart0"
)
(
    input                         clk,
    input                         rst,
    input        [ADDR_WIDTH-1:0] addr_i,
    input        [31:0]           wdata_i,
    input                         write_i,
    input                         sel_i,
    input                         enable_i,
    output logic [31:0]           rdata_o,
    output logic                  ready_o
);

    logic rx, tx;
    
    apb_uart_sv
    #(
        .APB_ADDR_WIDTH ( ADDR_WIDTH )
    ) 
    uart_i (
        .clk     ( clk      ),
        .rstn    ( ~rst     ),
        .addr    ( addr_i   ),
        .wdata   ( wdata_i  ),
        .write   ( write_i  ),
        .sel     ( sel_i    ),
        .enable  ( enable_i ),
        .rdata   ( rdata_o  ),
        .ready   ( ready_o  ),
        .rx_i    ( rx       ),
        .tx_o    ( tx       ),
        .event_o (          )
    );

    uartdpi
    #(
        .BAUD ( BAUD ),
        .FREQ ( FREQ ),
        .NAME ( NAME )
    )
    uartdpi_i (
        .clk ( clk ),
        .rst ( rst ),
        .tx  ( rx  ),
        .rx  ( tx  )
    );
endmodule
