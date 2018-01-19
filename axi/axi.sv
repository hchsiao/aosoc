/*
    * File Name : axi_wrap.sv
    *
    * Purpose : wrap axi bus 
    *           
    * Creation Date : 2018/01/08
    *
    * Last Modified : 2018/01/08
    *
    * Create By : Jyun-Neng Ji
    *
*/
module axi
#(
    parameter AXI_ADDR_WIDTH      = 32,
    parameter AXI_DATA_WIDTH      = 32,
    parameter AXI_USER_WIDTH      = 1,
    parameter AXI_ID_MASTER_WIDTH = 2,
    parameter AXI_ID_SLAVE_WIDTH  = 3, // slave id width should be master id width + log(master id width)
    parameter DATA_RAM_SIZE       = 32768,
    parameter INSTR_RAM_SIZE      = 32768,
    parameter DATA_ADDR_WIDTH     = $clog2(DATA_RAM_SIZE),
    parameter INSTR_ADDR_WIDTH    = $clog2(INSTR_RAM_SIZE)
)
(
    input                               clk,
    input                               rst,
    input                               testmode_i,

    input                               core_instr_req_i,
    output logic                        core_instr_gnt_o,
    output logic                        core_instr_rvalid_o,
    input        [31:0]                 core_instr_addr_i,
    output logic [31:0]                 core_instr_rdata_o,

    input                               core_lsu_req_i,
    output logic                        core_lsu_gnt_o,
    output logic                        core_lsu_rvalid_o,
    input                               core_lsu_we_i,
    input        [3:0]                  core_lsu_be_i,
    input        [31:0]                 core_lsu_addr_i,
    input        [31:0]                 core_lsu_wdata_i,
    output logic [31:0]                 core_lsu_rdata_o,

    output logic                        instr_mem_req_o,
    output logic [INSTR_ADDR_WIDTH-1:0] instr_mem_addr_o,
    output logic                        instr_mem_we_o,
    output logic [AXI_DATA_WIDTH/8-1:0] instr_mem_be_o,
    input        [AXI_DATA_WIDTH-1:0]   instr_mem_rdata_i,
    output logic [AXI_DATA_WIDTH-1:0]   instr_mem_wdata_o,

    output logic                        data_mem_req_o,
    output logic [DATA_ADDR_WIDTH-1:0]  data_mem_addr_o,
    output logic                        data_mem_we_o,
    output logic [AXI_DATA_WIDTH/8-1:0] data_mem_be_o,
    input        [AXI_DATA_WIDTH-1:0]   data_mem_rdata_i,
    output logic [AXI_DATA_WIDTH-1:0]   data_mem_wdata_o
);
    AXI_BUS
    #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH      ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH      ),
        .AXI_ID_WIDTH   ( AXI_ID_MASTER_WIDTH ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH      )
    )
    lsu_master_if ();

    AXI_BUS
    #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH      ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH      ),
        .AXI_ID_WIDTH   ( AXI_ID_MASTER_WIDTH ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH      )
    )
    if_master_if ();

    AXI_BUS
    #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH      ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH      ),
        .AXI_ID_WIDTH   ( AXI_ID_MASTER_WIDTH ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH      )
    )
    masters[1:0] ();

    AXI_BUS
    #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH     ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH     ),
        .AXI_ID_WIDTH   ( AXI_ID_SLAVE_WIDTH ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH     )
    )
    slaves[1:0] ();

    // access instruction memory

    core2axi_wrap
    #(
        .AXI_ADDR_WIDTH   ( AXI_ADDR_WIDTH      ),
        .AXI_DATA_WIDTH   ( AXI_DATA_WIDTH      ),
        .AXI_ID_WIDTH     ( AXI_ID_MASTER_WIDTH ),
        .AXI_USER_WIDTH   ( AXI_USER_WIDTH      ),
        .REGISTERED_GRANT ( "FALSE"             )
    )
    if2axi_i (
        .clk_i            ( clk                 ),
        .rst_ni           ( ~rst                ),
        .data_req_i       ( core_instr_req_i    ),
        .data_gnt_o       ( core_instr_gnt_o    ),
        .data_rvalid_o    ( core_instr_rvalid_o ),
        .data_addr_i      ( core_instr_addr_i   ),
        .data_we_i        ( 1'b0                ),
        .data_be_i        ( 4'b1111             ),
        .data_rdata_o     ( core_instr_rdata_o  ),
        .data_wdata_i     ( 'd0                 ),
        .master           ( if_master_if        )
    );

    axi_slice_wrap
    #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH      ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH      ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH      ),
        .AXI_ID_WIDTH   ( AXI_ID_MASTER_WIDTH ),
        .SLICE_DEPTH    ( 2                   )
    )
    axi_slice_if2axi (
        .clk_i          ( clk            ),
        .rst_ni         ( ~rst           ),
        .test_en_i      ( testmode_i     ),
        .axi_slave      ( if_master_if   ),
        .axi_master     ( masters[0]     )
    );

    
    // access data memory

    core2axi_wrap
    #(
        .AXI_ADDR_WIDTH   ( AXI_ADDR_WIDTH      ),
        .AXI_DATA_WIDTH   ( AXI_DATA_WIDTH      ),
        .AXI_ID_WIDTH     ( AXI_ID_MASTER_WIDTH ),
        .AXI_USER_WIDTH   ( AXI_USER_WIDTH      ),
        .REGISTERED_GRANT ( "FALSE"             )
    )
    lsu2axi_i (
        .clk_i            ( clk               ),
        .rst_ni           ( ~rst              ),
        .data_req_i       ( core_lsu_req_i    ),
        .data_gnt_o       ( core_lsu_gnt_o    ),
        .data_rvalid_o    ( core_lsu_rvalid_o ),
        .data_addr_i      ( core_lsu_addr_i   ),
        .data_we_i        ( core_lsu_we_i     ),
        .data_be_i        ( core_lsu_be_i     ),
        .data_rdata_o     ( core_lsu_rdata_o  ),
        .data_wdata_i     ( core_lsu_wdata_i  ),
        .master           ( lsu_master_if     )
    );

    axi_slice_wrap
    #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH      ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH      ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH      ),
        .AXI_ID_WIDTH   ( AXI_ID_MASTER_WIDTH ),
        .SLICE_DEPTH    ( 2                   )
    )
    axi_slice_lsu2axi (
        .clk_i          ( clk            ),
        .rst_ni         ( ~rst           ),
        .test_en_i      ( testmode_i     ),
        .axi_slave      ( lsu_master_if  ),
        .axi_master     ( masters[1]     )
    );

    // instruction memory wrapper
    
    axi_mem_if_SP_wrap
    #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH     ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH     ),
        .AXI_ID_WIDTH   ( AXI_ID_SLAVE_WIDTH ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH     ),
        .MEM_ADDR_WIDTH ( INSTR_ADDR_WIDTH   )
    )
    instr_mem_axi_if (
        .clk            ( clk               ),
        .rst_n          ( ~rst              ),
        .test_en_i      ( testmode_i        ),
        .mem_req_o      ( instr_mem_req_o   ),
        .mem_addr_o     ( instr_mem_addr_o  ),
        .mem_we_o       ( instr_mem_we_o    ),
        .mem_be_o       ( instr_mem_be_o    ),
        .mem_rdata_i    ( instr_mem_rdata_i ),
        .mem_wdata_o    ( instr_mem_wdata_o ),
        .slave          ( slaves[0]         )
    );

    // data memory wrapper

    axi_mem_if_SP_wrap
    #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH     ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH     ),
        .AXI_ID_WIDTH   ( AXI_ID_SLAVE_WIDTH ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH     ),
        .MEM_ADDR_WIDTH ( DATA_ADDR_WIDTH    )
    )
    data_mem_axi_if (
        .clk            ( clk              ),
        .rst_n          ( ~rst             ),
        .test_en_i      ( testmode_i       ),
        .mem_req_o      ( data_mem_req_o   ),
        .mem_addr_o     ( data_mem_addr_o  ),
        .mem_we_o       ( data_mem_we_o    ),
        .mem_be_o       ( data_mem_be_o    ),
        .mem_rdata_i    ( data_mem_rdata_i ),
        .mem_wdata_o    ( data_mem_wdata_o ),
        .slave          ( slaves[1]        )
    );

    // axi bus

    axi_node_intf_wrap
    #(
        .NB_MASTER      ( 2                              ),
        .NB_SLAVE       ( 2                              ),
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH                 ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH                 ),
        .AXI_ID_WIDTH   ( AXI_ID_MASTER_WIDTH            ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH                 )
    )
    axi_interconnect_i (
        .clk            ( clk                            ),
        .rst_n          ( ~rst                           ),
        .test_en_i      ( testmode_i                     ),
        .master         ( slaves                         ),
        .slave          ( masters                        ),
        .start_addr_i   ( {32'h2000_0000, 32'h0000_0000} ),
        .end_addr_i     ( {32'h2000_ffff, 32'h0000_ffff} )
    );
endmodule
