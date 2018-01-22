// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module boot_code
(
    input  logic        CLK,
    input  logic        RSTN,

    input  logic        CSN,
    input  logic [9:0]  A,
    output logic [31:0] Q
  );

  const logic [0:14] [31:0] mem = {
    32'h00000013, //b1
    32'h00000013,
    32'hff9ff06f,
    32'h00000013,
    32'h00000013,
    32'h00000013,
    32'h00000013,
    32'h00000013,
    32'h00000013,
    32'h00000013,
    32'h00000013,
    32'h00000013,
    32'h00000013,
    32'h00000013,
    32'h00000013// j b1
  };

  logic [9:0] A_Q;

  always_ff @(posedge CLK, negedge RSTN)
  begin
    if (~RSTN)
      A_Q <= '0;
    else
      if (~CSN)
        A_Q <= A;
  end

  assign Q = mem[A_Q];

endmodule
