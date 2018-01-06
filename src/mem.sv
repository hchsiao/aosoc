`include "core_wrapper.svh"

module mem (
  MemPort.Slave instr_mem,
  MemPort.Slave data_mem,

  input logic clk,
  input logic rst,
  input logic test_mode
);

logic [31:0] mem[65536];
logic [31:0] instr_rdata;
logic [31:0] data_rdata;

logic instr_rvalid, data_rvalid;

assign instr_mem.ready = instr_mem.valid;
assign instr_mem.rdata = instr_rdata;
assign instr_mem.rvalid = instr_rvalid;

assign data_mem.ready = data_mem.valid;
assign data_mem.rdata = data_rdata;
assign data_mem.rvalid = data_rvalid;

int i;
always @ (posedge clk) begin
  if(rst) begin
    instr_rvalid <= 0;
    data_rvalid <= 0;
    for(i = 0; i < 65536; i=i+1)
      mem[i] <= 'h0;
  end
  else begin
    instr_rvalid <= instr_mem.valid; // alwaya respons in 1 cyc
    data_rvalid <= data_mem.valid; // alwaya respons in 1 cyc
    if(data_mem.valid) begin
      if(data_mem.write_en && (|data_mem.byte_en)) begin
        mem[data_mem.addr/4] <= {
          data_mem.byte_en[3] ? data_mem.wdata[31:24] : mem[data_mem.addr/4][31:24],
          data_mem.byte_en[2] ? data_mem.wdata[23:16] : mem[data_mem.addr/4][23:16],
          data_mem.byte_en[1] ? data_mem.wdata[15: 8] : mem[data_mem.addr/4][15: 8],
          data_mem.byte_en[0] ? data_mem.wdata[ 7: 0] : mem[data_mem.addr/4][ 7: 0]
        };
      end
      // TODO: real SRAM cannot read like this
      data_rdata <= mem[data_mem.addr/4];
    end

    if(instr_mem.valid)
      instr_rdata <= mem[instr_mem.addr/4];
  end
end
endmodule
