module M_2
(
  output reg [16-1:0] Q,
  input wire [8-1:0] A,
  input wire cen,
  input wire clk,
  input wire reset

);

  always@(posedge clk) begin
    if(reset) begin
      Q <= 0;
    end
    else if(cen) begin
      case(A)
        //32'd0: Q <= 1;
        8'd0: Q <= 16'h6656;
8'd1: Q <= 16'hc1d2;
8'd2: Q <= 16'h60f4;
8'd3: Q <= 16'ha9c0;
8'd4: Q <= 16'ha7d0;
8'd5: Q <= 16'h962e;
8'd6: Q <= 16'ha3e4;
8'd7: Q <= 16'ha03e;
8'd8: Q <= 16'hdef0;
8'd9: Q <= 16'h8eb8;
8'd10: Q <= 16'hd4f4;
8'd11: Q <= 16'hcc92;
8'd12: Q <= 16'hc0b8;
8'd13: Q <= 16'hd408;
8'd14: Q <= 16'hfffe;
8'd15: Q <= 16'hc140;
8'd16: Q <= 16'hfa14;
8'd17: Q <= 16'hf134;
8'd18: Q <= 16'hf42c;
8'd19: Q <= 16'hf70b;
        default: Q <= 0;
      endcase
    end
  end

endmodule

