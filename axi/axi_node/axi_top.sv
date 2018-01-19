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
module axi_top
#(
    parameter AXI_ADDRESS_W = 32,
    parameter AXI_DATA_W    = 32,
    parameter AXI_NUMBYTES  = AXI_DATA_W/8,
    parameter AXI_USER_W    = 6, // unknown
    parameter N_MASTER_PORT = 2,
    parameter N_SLAVE_PORT  = 2,
    parameter AXI_ID_IN     = 16,
    parameter AXI_ID_OUT    = AXI_ID_IN + $clog2(N_SLAVE_PORT),
    parameter FIFO_DEPTH_DW = 8,
    parameter N_REGION      = 2  // unknown
)
(
    input                         clk,
    input                         rst,
    input                         test_en_i,
    // slave1 write address bus
    input  [AXI_ID_IN-1:0]        s1_awid_i,
    input  [AXI_ADDRESS_W-1:0]    s1_awaddr_i,
    input  [7:0]                  s1_awlen_i,
    input  [2:0]                  s1_awsize_i,
    input  [1:0]                  s1_awburst_i,
    input                         s1_awlock_i,
    input  [3:0]                  s1_awcache_i,
    input  [2:0]                  s1_awprot_i,
    input  [3:0]                  s1_awregion_i,
    input  [AXI_USER_W-1:0]       s1_awuser_i,
    input  [3:0]                  s1_awqos_i,
    input                         s1_awvalid_i,
    output logic                  s1_awready_o,
    // slave1 write data bus
    input  [AXI_DATA_W-1:0]       s1_wdata_i,
    input  [AXI_NUMBYTES-1:0]     s1_wstrb_i,
    input                         s1_wlast_i,
    input  [AXI_USER_W-1:0]       s1_wuser_i,
    input                         s1_wvalid_i,
    output logic                  s1_wready_o,
    // slave1 write response bus
    output logic [AXI_ID_IN-1:0]  s1_bid_o,
    output logic [1:0]            s1_bresp_o,
    output logic                  s1_bvalid_o,
    output logic [AXI_USER_W-1:0] s1_buser_o,
    input                         s1_bready_i,
    // slave1 read address bus
    input  [AXI_ID_IN-1:0]        s1_arid_i,
    input  [AXI_ADDRESS_W-1:0]    s1_araddr_i,
    input  [7:0]                  s1_arlen_i,
    input  [2:0]                  s1_arsize_i,
    input  [1:0]                  s1_arburst_i,
    input                         s1_arlock_i,
    input  [3:0]                  s1_arcache_i,
    input  [2:0]                  s1_arprot_i,
    input  [3:0]                  s1_arregion_i,
    input  [AXI_USER_W-1:0]       s1_aruser_i,
    input  [3:0]                  s1_arqos_i,
    input                         s1_arvalid_i,
    output logic                  s1_arready_o,
    // slave1 read data bus
    output logic [AXI_ID_IN-1:0]  s1_rid_o,
    output logic [AXI_DATA_W-1:0] s1_rdata_o,
    output logic [1:0]            s1_rresp_o,
    output logic                  s1_rlast_o,
    output logic [AXI_USER_W-1:0] s1_ruser_i,
    output logic                  s1_rvalid_o,
    input                         s1_rready_i,

    // slave2 write address bus
    input  [AXI_ID_IN-1:0]        s2_awid_i,
    input  [AXI_ADDRESS_W-1:0]    s2_awaddr_i,
    input  [7:0]                  s2_awlen_i,
    input  [2:0]                  s2_awsize_i,
    input  [1:0]                  s2_awburst_i,
    input                         s2_awlock_i,
    input  [3:0]                  s2_awcache_i,
    input  [2:0]                  s2_awprot_i,
    input  [3:0]                  s2_awregion_i,
    input  [AXI_USER_W-1:0]       s2_awuser_i,
    input  [3:0]                  s2_awqos_i,
    input                         s2_awvalid_i,
    output logic                  s2_awready_o,
    // slave2 write data bus
    input  [AXI_DATA_W-1:0]       s2_wdata_i,
    input  [AXI_NUMBYTES-1:0]     s2_wstrb_i,
    input                         s2_wlast_i,
    input  [AXI_USER_W-1:0]       s2_wuser_i,
    input                         s2_wvalid_i,
    output logic                  s2_wready_o,
    // slave2 write response bus
    output logic [AXI_ID_IN-1:0]  s2_bid_o,
    output logic [1:0]            s2_bresp_o,
    output logic                  s2_bvalid_o,
    output logic [AXI_USER_W-1:0] s2_buser_o,
    input                         s2_bready_i,
    // slave2 read address bus
    input  [AXI_ID_IN-1:0]        s2_arid_i,
    input  [AXI_ADDRESS_W-1:0]    s2_araddr_i,
    input  [7:0]                  s2_arlen_i,
    input  [2:0]                  s2_arsize_i,
    input  [1:0]                  s2_arburst_i,
    input                         s2_arlock_i,
    input  [3:0]                  s2_arcache_i,
    input  [2:0]                  s2_arprot_i,
    input  [3:0]                  s2_arregion_i,
    input  [AXI_USER_W-1:0]       s2_aruser_i,
    input  [3:0]                  s2_arqos_i,
    input                         s2_arvalid_i,
    output logic                  s2_arready_o,
    // slave2 read data bus
    output logic [AXI_ID_IN-1:0]  s2_rid_o,
    output logic [AXI_DATA_W-1:0] s2_rdata_o,
    output logic [1:0]            s2_rresp_o,
    output logic                  s2_rlast_o,
    output logic [AXI_USER_W-1:0] s2_ruser_i,
    output logic                  s2_rvalid_o,
    input                         s2_rready_i,

    // master1 write address bus
    output logic [AXI_ID_OUT-1:0]    m1_awid_o,
    output logic [AXI_ADDRESS_W-1:0] m1_awaddr_o,
    output logic [7:0]               m1_awlen_o,
    output logic [2:0]               m1_awsize_o,
    output logic [1:0]               m1_awburst_o,
    output logic                     m1_awlock_o,
    output logic [3:0]               m1_awcache_o,
    output logic [2:0]               m1_awprot_o,
    output logic [3:0]               m1_awregion_o,
    output logic [AXI_USER_W-1:0]    m1_awuser_o,
    output logic [3:0]               m1_awqos_o,
    output logic                     m1_awvalid_o,
    input                            m1_awready_i,
    // master1 write data bus
    output logic [AXI_DATA_W-1:0]    m1_wdata_o,
    output logic [AXI_NUMBYTES-1:0]  m1_wstrb_o,
    output logic                     m1_wlast_o,
    output logic [AXI_USER_W-1:0]    m1_wuser_o,
    output logic                     m1_wvalid_o,
    input                            m1_wready_i,
    // master1 backward write response bus
    input  [AXI_ID_OUT-1:0]          m1_bid_i,
    input  [1:0]                     m1_bresp_i,
    input  [AXI_USER_W-1:0]          m1_buser_i,
    input                            m1_bvalid_i,
    output logic                     m1_bready_o,
    // master1 read address bus
    output logic [AXI_ID_OUT-1:0]    m1_arid_o,
    output logic [AXI_ADDRESS_W-1:0] m1_araddr_o,
    output logic [7:0]               m1_arlen_o,
    output logic [2:0]               m1_arsize_o,
    output logic [1:0]               m1_arburst_o,
    output logic                     m1_arlock_o,
    output logic [3:0]               m1_arcache_o,
    output logic [2:0]               m1_arprot_o,
    output logic [3:0]               m1_arregion_o,
    output logic [AXI_USER_W-1:0]    m1_aruser_o,
    output logic [3:0]               m1_arqos_o,
    output logic                     m1_arvalid_o,
    input                            m1_arready_i,
    // master1 read data bus
    input  [AXI_ID_OUT-1:0]          m1_rid_i,
    input  [AXI_DATA_W-1:0]          m1_rdata_i,
    input  [1:0]                     m1_rresp_i,
    input                            m1_rlast_i,
    input  [AXI_USER_W-1:0]          m1_ruser_i,
    input                            m1_rvalid_i,
    output logic                     m1_rready_o,

    // master2 write address bus
    output logic [AXI_ID_OUT-1:0]    m2_awid_o,
    output logic [AXI_ADDRESS_W-1:0] m2_awaddr_o,
    output logic [7:0]               m2_awlen_o,
    output logic [2:0]               m2_awsize_o,
    output logic [1:0]               m2_awburst_o,
    output logic                     m2_awlock_o,
    output logic [3:0]               m2_awcache_o,
    output logic [2:0]               m2_awprot_o,
    output logic [3:0]               m2_awregion_o,
    output logic [AXI_USER_W-1:0]    m2_awuser_o,
    output logic [3:0]               m2_awqos_o,
    output logic                     m2_awvalid_o,
    input                            m2_awready_i,
    // master2 write data bus
    output logic [AXI_DATA_W-1:0]    m2_wdata_o,
    output logic [AXI_NUMBYTES-1:0]  m2_wstrb_o,
    output logic                     m2_wlast_o,
    output logic [AXI_USER_W-1:0]    m2_wuser_o,
    output logic                     m2_wvalid_o,
    input                            m2_wready_i,
    // master2 backward write response2bus
    input  [AXI_ID_OUT-1:0]          m2_bid_i,
    input  [1:0]                     m2_bresp_i,
    input  [AXI_USER_W-1:0]          m2_buser_i,
    input                            m2_bvalid_i,
    output logic                     m2_bready_o,
    // master2 read address bus
    output logic [AXI_ID_OUT-1:0]    m2_arid_o,
    output logic [AXI_ADDRESS_W-1:0] m2_araddr_o,
    output logic [7:0]               m2_arlen_o,
    output logic [2:0]               m2_arsize_o,
    output logic [1:0]               m2_arburst_o,
    output logic                     m2_arlock_o,
    output logic [3:0]               m2_arcache_o,
    output logic [2:0]               m2_arprot_o,
    output logic [2:0]               m2_arregion_o,
    output logic [AXI_USER_W-1:0]    m2_aruser_o,
    output logic [3:0]               m2_arqos_o,
    output logic                     m2_arvalid_o,
    input                            m2_arready_i,
    // master2 read data bus
    input  [AXI_ID_OUT-1:0]          m2_rid_i,
    input  [AXI_DATA_W-1:0]          m2_rdata_i,
    input  [1:0]                     m2_rresp_i,
    input                            m2_rlast_i,
    input  [AXI_USER_W-1:0]          m2_ruser_i,
    input                            m2_rvalid_i,
    output logic                     m2_rready_o,

    // initial memory map
    input [N_REGION-1:0][N_MASTER_PORT-1:0][31:0] cfg_START_ADDR_i,
    input [N_REGION-1:0][N_MASTER_PORT-1:0][31:0] cfg_END_ADDR_i,
    input [N_REGION-1:0][N_MASTER_PORT-1:0]       cfg_valid_rule_i,
    input [N_SLAVE_PORT-1:0][N_MASTER_PORT-1:0]   cfg_connectivity_map_i 
);
    
    logic [N_SLAVE_PORT-1:0][AXI_ID_IN-1:0]      slave_awid;
    logic [N_SLAVE_PORT-1:0][AXI_ADDRESS_W-1:0]  slave_awaddr;
    logic [N_SLAVE_PORT-1:0][ 7:0]               slave_awlen;
    logic [N_SLAVE_PORT-1:0][ 2:0]               slave_awsize;
    logic [N_SLAVE_PORT-1:0][ 1:0]               slave_awburst;
    logic [N_SLAVE_PORT-1:0]                     slave_awlock;
    logic [N_SLAVE_PORT-1:0][ 3:0]               slave_awcache;
    logic [N_SLAVE_PORT-1:0][ 2:0]               slave_awprot;
    logic [N_SLAVE_PORT-1:0][ 3:0]               slave_awregion;
    logic [N_SLAVE_PORT-1:0][ AXI_USER_W-1:0]    slave_awuser;
    logic [N_SLAVE_PORT-1:0][ 3:0]               slave_awqos;
    logic [N_SLAVE_PORT-1:0]                     slave_awvalid;
    logic [N_SLAVE_PORT-1:0]                     slave_awready;
    
    logic [N_SLAVE_PORT-1:0] [AXI_DATA_W-1:0]    slave_wdata;
    logic [N_SLAVE_PORT-1:0] [AXI_NUMBYTES-1:0]  slave_wstrb;
    logic [N_SLAVE_PORT-1:0]                     slave_wlast;
    logic [N_SLAVE_PORT-1:0] [AXI_USER_W-1:0]    slave_wuser;
    logic [N_SLAVE_PORT-1:0]                     slave_wvalid;
    logic [N_SLAVE_PORT-1:0]                     slave_wready;
    
    logic [N_SLAVE_PORT-1:0]  [AXI_ID_IN-1:0]    slave_bid;
    logic [N_SLAVE_PORT-1:0]  [ 1:0]             slave_bresp;
    logic [N_SLAVE_PORT-1:0]                     slave_bvalid;
    logic [N_SLAVE_PORT-1:0]  [AXI_USER_W-1:0]   slave_buser;
    logic [N_SLAVE_PORT-1:0]                     slave_bready;
    
    logic [N_SLAVE_PORT-1:0][AXI_ID_IN-1:0]      slave_arid;
    logic [N_SLAVE_PORT-1:0][AXI_ADDRESS_W-1:0]  slave_araddr;
    logic [N_SLAVE_PORT-1:0][ 7:0]               slave_arlen;
    logic [N_SLAVE_PORT-1:0][ 2:0]               slave_arsize;
    logic [N_SLAVE_PORT-1:0][ 1:0]               slave_arburst;
    logic [N_SLAVE_PORT-1:0]                     slave_arlock;
    logic [N_SLAVE_PORT-1:0][ 3:0]               slave_arcache;
    logic [N_SLAVE_PORT-1:0][ 2:0]               slave_arprot;
    logic [N_SLAVE_PORT-1:0][ 3:0]               slave_arregion;
    logic [N_SLAVE_PORT-1:0][ AXI_USER_W-1:0]    slave_aruser;
    logic [N_SLAVE_PORT-1:0][ 3:0]               slave_arqos;
    logic [N_SLAVE_PORT-1:0]                     slave_arvalid;
    logic [N_SLAVE_PORT-1:0]                     slave_arready;
    
    logic [N_SLAVE_PORT-1:0][AXI_ID_IN-1:0]      slave_rid;
    logic [N_SLAVE_PORT-1:0][AXI_DATA_W-1:0]     slave_rdata;
    logic [N_SLAVE_PORT-1:0][ 1:0]               slave_rresp;
    logic [N_SLAVE_PORT-1:0]                     slave_rlast;
    logic [N_SLAVE_PORT-1:0][AXI_USER_W-1:0]     slave_ruser;
    logic [N_SLAVE_PORT-1:0]                     slave_rvalid;
    logic [N_SLAVE_PORT-1:0]                     slave_rready;
    
    logic [N_MASTER_PORT-1:0][AXI_ID_OUT-1:0]    master_awid;
    logic [N_MASTER_PORT-1:0][AXI_ADDRESS_W-1:0] master_awaddr;
    logic [N_MASTER_PORT-1:0][ 7:0]              master_awlen;
    logic [N_MASTER_PORT-1:0][ 2:0]              master_awsize;
    logic [N_MASTER_PORT-1:0][ 1:0]              master_awburst;
    logic [N_MASTER_PORT-1:0]                    master_awlock;
    logic [N_MASTER_PORT-1:0][ 3:0]              master_awcache;
    logic [N_MASTER_PORT-1:0][ 2:0]              master_awprot;
    logic [N_MASTER_PORT-1:0][ 3:0]              master_awregion;
    logic [N_MASTER_PORT-1:0][ AXI_USER_W-1:0]   master_awuser;
    logic [N_MASTER_PORT-1:0][ 3:0]              master_awqos;
    logic [N_MASTER_PORT-1:0]                    master_awvalid;
    logic [N_MASTER_PORT-1:0]                    master_awready;
    
    logic [N_MASTER_PORT-1:0] [AXI_DATA_W-1:0]   master_wdata;
    logic [N_MASTER_PORT-1:0] [AXI_NUMBYTES-1:0] master_wstrb;
    logic [N_MASTER_PORT-1:0]                    master_wlast;
    logic [N_MASTER_PORT-1:0] [ AXI_USER_W-1:0]  master_wuser;
    logic [N_MASTER_PORT-1:0]                    master_wvalid;
    logic [N_MASTER_PORT-1:0]                    master_wready;
    
    logic [N_MASTER_PORT-1:0] [AXI_ID_OUT-1:0]   master_bid;
    logic [N_MASTER_PORT-1:0] [ 1:0]             master_bresp;
    logic [N_MASTER_PORT-1:0] [ AXI_USER_W-1:0]  master_buser;
    logic [N_MASTER_PORT-1:0]                    master_bvalid;
    logic [N_MASTER_PORT-1:0]                    master_bready;
    
    logic [N_MASTER_PORT-1:0][AXI_ID_OUT-1:0]    master_arid;
    logic [N_MASTER_PORT-1:0][AXI_ADDRESS_W-1:0] master_araddr;
    logic [N_MASTER_PORT-1:0][ 7:0]              master_arlen;
    logic [N_MASTER_PORT-1:0][ 2:0]              master_arsize;
    logic [N_MASTER_PORT-1:0][ 1:0]              master_arburst;
    logic [N_MASTER_PORT-1:0]                    master_arlock;
    logic [N_MASTER_PORT-1:0][ 3:0]              master_arcache;
    logic [N_MASTER_PORT-1:0][ 2:0]              master_arprot;
    logic [N_MASTER_PORT-1:0][ 3:0]              master_arregion;
    logic [N_MASTER_PORT-1:0][ AXI_USER_W-1:0]   master_aruser;
    logic [N_MASTER_PORT-1:0][ 3:0]              master_arqos;
    logic [N_MASTER_PORT-1:0]                    master_arvalid;
    logic [N_MASTER_PORT-1:0]                    master_arready;
    
    logic [N_MASTER_PORT-1:0][AXI_ID_OUT-1:0]    master_rid;
    logic [N_MASTER_PORT-1:0][AXI_DATA_W-1:0]    master_rdata;
    logic [N_MASTER_PORT-1:0][ 1:0]              master_rresp;
    logic [N_MASTER_PORT-1:0]                    master_rlast;
    logic [N_MASTER_PORT-1:0][ AXI_USER_W-1:0]   master_ruser;
    logic [N_MASTER_PORT-1:0]                    master_rvalid;
    logic [N_MASTER_PORT-1:0]                    master_rready;

    assign slave_awaddr[0]   = s1_awaddr_i;
    assign slave_awprot[0]   = s1_awprot_i;
    assign slave_awregion[0] = s1_awregion_i;
    assign slave_awlen[0]    = s1_awlen_i;
    assign slave_awsize[0]   = s1_awsize_i;
    assign slave_awburst[0]  = s1_awburst_i;
    assign slave_awlock[0]   = s1_awlock_i;
    assign slave_awcache[0]  = s1_awcache_i;
    assign slave_awqos[0]    = s1_awqos_i;
    assign slave_awid[0]     = s1_awid_i;
    assign slave_awuser[0]   = s1_awuser_i;
    assign slave_awvalid[0]  = s1_awvalid_i;
    assign s1_awready_o      = slave_awready[0];

    assign slave_araddr[0]   = s1_araddr_i;
    assign slave_arprot[0]   = s1_arprot_i;
    assign slave_arregion[0] = s1_arregion_i;
    assign slave_arlen[0]    = s1_arlen_i;
    assign slave_arsize[0]   = s1_arsize_i;
    assign slave_arburst[0]  = s1_arburst_i;
    assign slave_arlock[0]   = s1_arlock_i;
    assign slave_arcache[0]  = s1_arcache_i;
    assign slave_arqos[0]    = s1_arqos_i;
    assign slave_arid[0]     = s1_arid_i;
    assign slave_aruser[0]   = s1_aruser_i;
    assign slave_arvalid[0]  = s1_arvalid_i;
    assign s1_arready_o      = slave_arready[0];

    assign slave_wvalid[0]   = s1_wvalid_i;
    assign slave_wdata[0]    = s1_wdata_i;
    assign slave_wstrb[0]    = s1_wstrb_i;
    assign slave_wuser[0]    = s1_wuser_i;
    assign slave_wlast[0]    = s1_wlast_i;
    assign s1_wready_o       = slave_wready[0];

    assign s1_bid_o          = slave_bid[0];
    assign s1_bresp_o        = slave_bresp[0];
    assign s1_bvalid_o       = slave_bvalid[0];
    assign s1_buser_o        = slave_buser[0];
    assign slave_bready[0]   = s1_bready_i;

    assign s1_rdata_o        = slave_rdata[0];
    assign s1_rresp_o        = slave_rresp[0];
    assign s1_rlast_o        = slave_rlast[0];
    assign s1_rid_o          = slave_rid[0];
    assign s1_ruser_i        = slave_ruser[0];
    assign s1_rvalid_o       = slave_rvalid[0];
    assign slave_rready[0]   = s1_rready_i;

    assign slave_awaddr[1]   = s2_awaddr_i;
    assign slave_awprot[1]   = s2_awprot_i;
    assign slave_awregion[1] = s2_awregion_i;
    assign slave_awlen[1]    = s2_awlen_i;
    assign slave_awsize[1]   = s2_awsize_i;
    assign slave_awburst[1]  = s2_awburst_i;
    assign slave_awlock[1]   = s2_awlock_i;
    assign slave_awcache[1]  = s2_awcache_i;
    assign slave_awqos[1]    = s2_awqos_i;
    assign slave_awid[1]     = s2_awid_i;
    assign slave_awuser[1]   = s2_awuser_i;
    assign slave_awvalid[1]  = s2_awvalid_i;
    assign s2_awready_o      = slave_awready[1];

    assign slave_araddr[1]   = s2_araddr_i;
    assign slave_arprot[1]   = s2_arprot_i;
    assign slave_arregion[1] = s2_arregion_i;
    assign slave_arlen[1]    = s2_arlen_i;
    assign slave_arsize[1]   = s2_arsize_i;
    assign slave_arburst[1]  = s2_arburst_i;
    assign slave_arlock[1]   = s2_arlock_i;
    assign slave_arcache[1]  = s2_arcache_i;
    assign slave_arqos[1]    = s2_arqos_i;
    assign slave_arid[1]     = s2_arid_i;
    assign slave_aruser[1]   = s2_aruser_i;
    assign slave_arvalid[1]  = s2_arvalid_i;
    assign s2_arready_o      = slave_arready[1];

    assign slave_wvalid[1]   = s2_wvalid_i;
    assign slave_wdata[1]    = s2_wdata_i;
    assign slave_wstrb[1]    = s2_wstrb_i;
    assign slave_wuser[1]    = s2_wuser_i;
    assign slave_wlast[1]    = s2_wlast_i;
    assign s2_wready_o       = slave_wready[1];

    assign s2_bid_o          = slave_bid[1];
    assign s2_bresp_o        = slave_bresp[1];
    assign s2_bvalid_o       = slave_bvalid[1];
    assign s2_buser_o        = slave_buser[1];
    assign slave_bready[1]   = s2_bready_i;

    assign s2_rdata_o        = slave_rdata[1];
    assign s2_rresp_o        = slave_rresp[1];
    assign s2_rlast_o        = slave_rlast[1];
    assign s2_rid_o          = slave_rid[1];
    assign s2_ruser_i        = slave_ruser[1];
    assign s2_rvalid_o       = slave_rvalid[1];
    assign slave_rready[1]   = s2_rready_i;

    assign m1_awaddr_o       = master_awaddr[0];
    assign m1_awprot_o       = master_awprot[0];
    assign m1_awregion_o     = master_awregion[0];
    assign m1_awlen_o        = master_awlen[0];
    assign m1_awsize_o       = master_awsize[0];
    assign m1_awburst_o      = master_awburst[0];
    assign m1_awlock_o       = master_awlock[0];
    assign m1_awcache_o      = master_awcache[0];
    assign m1_awqos_o        = master_awqos[0];
    assign m1_awid_o         = master_awid[0];
    assign m1_awuser_o       = master_awuser[0];
    assign m1_awvalid_o      = master_awvalid[0];
    assign master_awready[0] = m1_awready_i;

    assign m1_araddr_o       = master_araddr[0];
    assign m1_arprot_o       = master_arprot[0];
    assign m1_arregion_o     = master_arregion[0];
    assign m1_arlen_o        = master_arlen[0];
    assign m1_arsize_o       = master_arsize[0];
    assign m1_arburst_o      = master_arburst[0];
    assign m1_arlock_o       = master_arlock[0];
    assign m1_arcache_o      = master_arcache[0];
    assign m1_arqos_o        = master_arqos[0];
    assign m1_arid_o         = master_arid[0];
    assign m1_aruser_o       = master_aruser[0];
    assign m1_arvalid_o      = master_arvalid[0];
    assign master_arready[0] = m1_arready_i;

    assign m1_wvalid_o       = master_wvalid[0];
    assign m1_wdata_o        = master_wdata[0];
    assign m1_wstrb_o        = master_wstrb[0];
    assign m1_wuser_o        = master_wuser[0];
    assign m1_wlast_o        = master_wlast[0];
    assign master_wready[0]  = m1_wready_i;

    assign master_bid[0]     = m1_bid_i;
    assign master_bresp[0]   = m1_bresp_i;
    assign master_bvalid[0]  = m1_bvalid_i;
    assign master_buser[0]   = m1_buser_i;
    assign m1_bready_o       = master_bready[0];

    assign master_rdata[0]   = m1_rdata_i;
    assign master_rresp[0]   = m1_rresp_i;
    assign master_rlast[0]   = m1_rlast_i;
    assign master_rid[0]     = m1_rid_i;
    assign master_ruser[0]   = m1_ruser_i;
    assign master_rvalid[0]  = m1_rvalid_i;
    assign m1_rready_o       = master_rready[0];

    assign m2_awaddr_o       = master_awaddr[1];
    assign m2_awprot_o       = master_awprot[1];
    assign m2_awregion_o     = master_awregion[1];
    assign m2_awlen_o        = master_awlen[1];
    assign m2_awsize_o       = master_awsize[1];
    assign m2_awburst_o      = master_awburst[1];
    assign m2_awlock_o       = master_awlock[1];
    assign m2_awcache_o      = master_awcache[1];
    assign m2_awqos_o        = master_awqos[1];
    assign m2_awid_o         = master_awid[1];
    assign m2_awuser_o       = master_awuser[1];
    assign m2_awvalid_o      = master_awvalid[1];
    assign master_awready[1] = m2_awready_i;

    assign m2_araddr_o       = master_araddr[0];
    assign m2_arprot_o       = master_arprot[1];
    assign m2_arregion_o     = master_arregion[1];
    assign m2_arlen_o        = master_arlen[1];
    assign m2_arsize_o       = master_arsize[1];
    assign m2_arburst_o      = master_arburst[1];
    assign m2_arlock_o       = master_arlock[1];
    assign m2_arcache_o      = master_arcache[1];
    assign m2_arqos_o        = master_arqos[1];
    assign m2_arid_o         = master_arid[1];
    assign m2_aruser_o       = master_aruser[1];
    assign m2_arvalid_o      = master_arvalid[1];
    assign master_arready[1] = m2_arready_i;

    assign m2_wvalid_o       = master_wvalid[1];
    assign m2_wdata_o        = master_wdata[1];
    assign m2_wstrb_o        = master_wstrb[1];
    assign m2_wuser_o        = master_wuser[1];
    assign m2_wlast_o        = master_wlast[1];
    assign master_wready[1]  = m2_wready_i;

    assign master_bid[1]     = m2_bid_i;
    assign master_bresp[1]   = m2_bresp_i;
    assign master_bvalid[1]  = m2_bvalid_i;
    assign master_buser[1]   = m2_buser_i;
    assign m2_bready_o       = master_bready[1];

    assign master_rdata[1]   = m2_rdata_i;
    assign master_rresp[1]   = m2_rresp_i;
    assign master_rlast[1]   = m2_rlast_i;
    assign master_rid[1]     = m2_rid_i;
    assign master_ruser[1]   = m2_ruser_i;
    assign master_rvalid[1]  = m2_rvalid_i;
    assign m2_rready_o       = master_rready[1];

    axi_node
    #(
        .AXI_ADDRESS_W ( AXI_ADDRESS_W ),
        .AXI_DATA_W    ( AXI_DATA_W    ),
        .AXI_ID_IN     ( AXI_ID_IN     ),
        .AXI_USER_W    ( AXI_USER_W    ),
        .N_MASTER_PORT ( N_MASTER_PORT ),
        .N_SLAVE_PORT  ( N_SLAVE_PORT  ),
        .N_REGION      ( N_REGION      )
    )
    AXI4_NODE (
        .clk ( clk ),
        .rst_n ( ~rst ),
        .test_en_i ( test_en_i ),
          
        .slave_awid_i    (  slave_awid     ),
        .slave_awaddr_i  (  slave_awaddr   ),
        .slave_awlen_i   (  slave_awlen    ),
        .slave_awsize_i  (  slave_awsize   ),
        .slave_awburst_i (  slave_awburst  ),
        .slave_awlock_i  (  slave_awlock   ),
        .slave_awcache_i (  slave_awcache  ),
        .slave_awprot_i  (  slave_awprot   ),
        .slave_awregion_i(  slave_awregion ),
        .slave_awqos_i   (  slave_awqos    ),
        .slave_awuser_i  (  slave_awuser   ),
        .slave_awvalid_i (  slave_awvalid  ),
        .slave_awready_o (  slave_awready  ),

        .slave_wdata_i   (  slave_wdata    ),
        .slave_wstrb_i   (  slave_wstrb    ),
        .slave_wlast_i   (  slave_wlast    ),
        .slave_wuser_i   (  slave_wuser    ),
        .slave_wvalid_i  (  slave_wvalid   ),
        .slave_wready_o  (  slave_wready   ),
        
        .slave_bid_o     (  slave_bid     ),
        .slave_bresp_o   (  slave_bresp   ),
        .slave_buser_o   (  slave_buser   ),
        .slave_bvalid_o  (  slave_bvalid  ),
        .slave_bready_i  (  slave_bready  ),
                
        .slave_arid_i    (  slave_arid     ),
        .slave_araddr_i  (  slave_araddr   ),
        .slave_arlen_i   (  slave_arlen    ),   //burst length - 1 to 16
        .slave_arsize_i  (  slave_arsize   ),  //size of each transfer in burst
        .slave_arburst_i (  slave_arburst  ), //for bursts>1(), accept only incr burst=01
        .slave_arlock_i  (  slave_arlock   ),  //only normal access supported axs_awlock=00
        .slave_arcache_i (  slave_arcache  ),
        .slave_arprot_i  (  slave_arprot   ),
        .slave_arregion_i(  slave_arregion ),
        .slave_aruser_i  (  slave_aruser   ),
        .slave_arqos_i   (  slave_arqos    ),
        .slave_arvalid_i (  slave_arvalid  ), //master addr valid
        .slave_arready_o (  slave_arready  ), //slave ready to accept
                                                                                                     
        .slave_rid_o     (  slave_rid      ),
        .slave_rdata_o   (  slave_rdata    ),
        .slave_rresp_o   (  slave_rresp    ),
        .slave_rlast_o   (  slave_rlast    ),   //last transfer in burst
        .slave_ruser_o   (  slave_ruser    ),
        .slave_rvalid_o  (  slave_rvalid   ),  //slave data valid
        .slave_rready_i  (  slave_rready   ),   //master ready to accept
                                                                                                     
        .master_awid_o    (  master_awid     ),         //
        .master_awaddr_o  (  master_awaddr   ),         //
        .master_awlen_o   (  master_awlen    ),         //burst length is 1 + (0 - 15)
        .master_awsize_o  (  master_awsize   ),         //size of each transfer in burst
        .master_awburst_o (  master_awburst  ),         //for bursts>1(), accept only incr burst=01
        .master_awlock_o  (  master_awlock   ),         //only normal access supported axs_awlock=00
        .master_awcache_o (  master_awcache  ),         //
        .master_awprot_o  (  master_awprot   ),         //
        .master_awregion_o(  master_awregion ),         //
        .master_awuser_o  (  master_awuser   ),         //
        .master_awqos_o   (  master_awqos    ),         //
        .master_awvalid_o (  master_awvalid  ),         //master addr valid
        .master_awready_i (  master_awready  ),         //slave ready to accept
                                                                                                     
        .master_wdata_o   (  master_wdata    ),
        .master_wstrb_o   (  master_wstrb    ),   //1 strobe per byte
        .master_wlast_o   (  master_wlast    ),   //last transfer in burst
        .master_wuser_o   (  master_wuser    ),  //master data valid
        .master_wvalid_o  (  master_wvalid   ),  //master data valid
        .master_wready_i  (  master_wready   ),  //slave ready to accept
                                                                                                     
        .master_bid_i     (  master_bid      ),
        .master_bresp_i   (  master_bresp    ),
        .master_buser_i   (  master_buser    ),
        .master_bvalid_i  (  master_bvalid   ),
        .master_bready_o  (  master_bready   ),
                                                                                                     
        .master_arid_o    (  master_arid     ),
        .master_araddr_o  (  master_araddr   ),
        .master_arlen_o   (  master_arlen    ),   //burst length - 1 to 16
        .master_arsize_o  (  master_arsize   ),  //size of each transfer in burst
        .master_arburst_o (  master_arburst  ), //for bursts>1(), accept only incr burst=01
        .master_arlock_o  (  master_arlock   ),  //only normal access supported axs_awlock=00
        .master_arcache_o (  master_arcache  ),
        .master_arprot_o  (  master_arprot   ),
        .master_arregion_o(  master_arregion ),
        .master_aruser_o  (  master_aruser   ),
        .master_arqos_o   (  master_arqos    ),
        .master_arvalid_o (  master_arvalid  ), //master addr valid
        .master_arready_i (  master_arready  ), //slave ready to accept
                                                                                                     
        .master_rid_i     (  master_rid      ),
        .master_rdata_i   (  master_rdata    ),
        .master_rresp_i   (  master_rresp    ),
        .master_rlast_i   (  master_rlast    ),   //last transfer in burst
        .master_ruser_i   (  master_ruser    ),   //last transfer in burst
        .master_rvalid_i  (  master_rvalid   ),  //slave data valid
        .master_rready_o  (  master_rready   ),   //master ready to accept

        .cfg_START_ADDR_i ( cfg_START_ADDR_i ),
        .cfg_END_ADDR_i   ( cfg_END_ADDR_i   ),
        .cfg_valid_rule_i ( cfg_valid_rule_i ),
        .cfg_connectivity_map_i ( cfg_connectivity_map_i )
    );
endmodule
