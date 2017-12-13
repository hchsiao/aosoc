`ifndef CORE_WRAPPER_SVH
`define CORE_WRAPPER_SVH

interface MemPort;
  logic          valid;
  logic          ready;
  logic          write_en;
  logic [31:0]   addr;
  logic [31:0]   rdata;
  logic [31:0]   wdata;
  logic [3:0]    byte_en;

  modport Master (
    output valid,
    input  ready,
    output write_en,
    output addr,
    input  rdata,
    output wdata,
    output byte_en
  );

  modport Slave (
    input  valid,
    output ready,
    input  write_en,
    input  addr,
    output rdata,
    input  wdata,
    input  byte_en
  );
endinterface

`endif
