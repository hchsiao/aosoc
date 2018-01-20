module fifo #(
  DATA_WIDTH = 8,
  SIZE = 16,
  ADDR_WIDTH = 4

)
(
  input clk,
  input reset,
  
  // in-port (master)
  input m_valid,
  input [DATA_WIDTH-1:0] m_data,
  output m_ready,
  
  // out-port (slave)
  output s_valid,
  output [DATA_WIDTH-1:0] s_data,
  input s_ready
);

  reg [ADDR_WIDTH-1:0] read_ptr, write_ptr, counter;
  reg [DATA_WIDTH-1:0] data_buf[0:SIZE-1];

  wire empty = (counter == 0);
  wire full = (counter == SIZE-1);

  reg [DATA_WIDTH-1:0] mem [0:SIZE-1];  

  wire read = s_ready && s_valid;
  wire write = m_ready && m_valid;
  wire [DATA_WIDTH-1:0] rdata = mem[read_ptr];
  wire [DATA_WIDTH-1:0] wdata = m_data;
  assign s_valid = ~empty;
  assign s_data = rdata;
  assign m_ready = ~full;

  always @(posedge clk)
  begin
    if (write)
      mem[write_ptr] <= wdata;	
  end

  always @(posedge clk) begin
    if(reset) begin
      read_ptr <= 0;
      write_ptr <= 0;
      counter <= 0;
    end
    else begin
      case({read,write})
        2'b01: begin
          counter <= counter + 1;
          write_ptr <= (write_ptr == SIZE-1) ? 0 : write_ptr + 1;
        end
        2'b10: begin
          counter <= counter - 1;
          read_ptr <= (read_ptr == SIZE-1) ? 0 : read_ptr + 1;
        end
        2'b11: begin
          write_ptr <= (write_ptr == SIZE-1) ? 0 : write_ptr + 1;
          read_ptr <= (read_ptr == SIZE-1) ? 0 : read_ptr + 1;
        end
      endcase
    end
  end
endmodule
