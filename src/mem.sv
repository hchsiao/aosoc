`include "core_wrapper.svh"

module mem (
  MemPort.Slave instr_mem,
  MemPort.Slave data_mem,
  MemPort.Master instr_dbg_mem,
  MemPort.Master data_dbg_mem,

  input logic clk,
  input logic rst,
  input logic test_mode
);

logic [31:0] mem[65536];
logic [31:0] instr_rdata;
logic [31:0] data_rdata;

wire instr_main_sel = instr_mem.addr >= 'h10000000;
wire data_main_sel = data_mem.addr >= 'h10000000;
wire instr_main_valid = instr_main_sel & instr_mem.valid;
wire data_main_valid = data_main_sel & data_mem.valid;
wire instr_dbg_sel = instr_mem.addr >= 'h20000000;
wire data_dbg_sel = data_mem.addr >= 'h20000000;
wire instr_dbg_valid = instr_dbg_sel & instr_mem.valid;
wire data_dbg_valid = data_dbg_sel & data_mem.valid;

assign instr_dbg_mem.valid = instr_dbg_valid;
assign instr_mem.ready = instr_main_sel ? instr_mem.valid :
                         instr_dbg_sel  ? instr_dbg_mem.ready :
                         0;
assign instr_dbg_mem.addr = instr_mem.addr - 'h20000000;
assign instr_mem.rdata = instr_main_sel ? instr_rdata :
                         instr_dbg_sel  ? instr_dbg_mem.rdata :
                         0;

assign data_dbg_mem.valid = data_dbg_valid;
assign data_mem.ready = data_main_sel ? data_mem.valid :
                        data_dbg_sel  ? data_dbg_mem.ready :
                        0;
assign data_dbg_mem.addr = data_mem.addr - 'h20000000;
assign data_mem.rdata = data_main_sel ? data_rdata :
                        data_dbg_sel  ? data_dbg_mem.rdata :
                        0;
assign data_dbg_mem.write_en = data_mem.write_en;
assign data_dbg_mem.byte_en = data_mem.byte_en;
assign data_dbg_mem.wdata = data_mem.wdata;

int i;
always @ (posedge clk) begin
  if(rst) begin
    for(i = 0; i < 65536; i=i+1)
      mem[i] <= 'h13;
  end
  else begin
    if(data_main_valid) begin
      if(data_mem.write_en && (|data_mem.byte_en)) begin
        mem[data_mem.addr] <= {
          data_mem.byte_en[3] ? data_mem.wdata[31:24] : mem[data_mem.addr][31:24],
          data_mem.byte_en[2] ? data_mem.wdata[23:16] : mem[data_mem.addr][23:16],
          data_mem.byte_en[1] ? data_mem.wdata[15: 8] : mem[data_mem.addr][15: 8],
          data_mem.byte_en[0] ? data_mem.wdata[ 7: 0] : mem[data_mem.addr][ 7: 0]
        };
      end
      // TODO: real SRAM cannot read like this
      data_rdata <= mem[data_mem.addr - 'h10000000];
    end

    if(instr_main_valid)
      instr_rdata <= mem[instr_mem.addr - 'h10000000];
  end
end
endmodule
