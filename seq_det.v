// Overlapping "1011" sequence detector, Moore FSM, synchronous active-low reset.
module seq_det (input clk, input rst_n, input din, output detect);
  localparam S0=3'd0, S1=3'd1, S10=3'd2, S101=3'd3, S1011=3'd4;
  reg [2:0] st, ns;
  always @* begin
    case (st)
      S0:    ns = din ? S1    : S0;
      S1:    ns = din ? S1    : S10;
      S10:   ns = din ? S101  : S0;
      S101:  ns = din ? S1011 : S10;
      S1011: ns = din ? S1    : S10;   // overlap: ...1011 then 1 -> "1", then 0 -> "10"
      default: ns = S0;
    endcase
  end
  always @(posedge clk) if (!rst_n) st <= S0; else st <= ns;
  assign detect = (st == S1011);
endmodule
