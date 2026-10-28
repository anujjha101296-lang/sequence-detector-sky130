`timescale 1ns/1ps
module tb;
  reg clk=0, rst_n=0, din=0; wire detect;
  `ifdef GATE
  seq_det_gate dut(.clk(clk),.rst_n(rst_n),.din(din),.detect(detect));
  `else
  seq_det dut(.clk(clk),.rst_n(rst_n),.din(din),.detect(detect));
  `endif
  always #5 clk = ~clk;
  // reference model: shift history + valid count
  reg [3:0] hist; integer cnt; reg exp_det;
  always @(posedge clk) begin
    if (!rst_n) begin hist<=0; cnt<=0; end
    else begin hist <= {hist[2:0], din}; cnt <= (cnt<4)? cnt+1 : cnt; end
  end
  always @* exp_det = (cnt>=4) && (hist==4'b1011);
  integer errors=0, checks=0, dets=0, i, k;
  always @(negedge clk) begin
    checks = checks + 1;
    if (detect !== exp_det) begin errors = errors + 1;
      if (errors < 5) $display("MISMATCH t=%0t din=%b detect=%b exp=%b", $time, din, detect, exp_det); end
    if (detect === 1'b1) dets = dets + 1;
  end
  task send(input [31:0] bits, input integer n); integer j; begin
    for (j=n-1;j>=0;j=j-1) begin din = bits[j]; @(posedge clk); #1; end end endtask
  initial begin
    repeat(3) @(posedge clk); #1 rst_n = 1;
    // directed: single, overlapping, near-miss, back-to-back
    send(32'b1011, 4); send(32'b1011011, 7); send(32'b101011, 6); send(32'b1010, 4); send(32'b10111011, 8);
    // reset in the middle of a pattern must clear progress
    send(32'b101, 3); rst_n = 0; @(posedge clk); #1 rst_n = 1; send(32'b1, 1); send(32'b0000, 4);
    // exhaustive: all 12-bit streams after a reset (4096 streams)
    for (k=0;k<4096;k=k+1) begin rst_n=0; @(posedge clk); #1 rst_n=1; send(k,12); end
    // random: 200k cycles with random resets (~1/64)
    for (i=0;i<200000;i=i+1) begin
      rst_n = ($urandom%64)!=0; din = $urandom; @(posedge clk); #1; end
    rst_n = 1; repeat(5) @(posedge clk);
    $display("RESULT checks=%0d detections=%0d errors=%0d %s", checks, dets, errors, errors==0 ? "PASS":"FAIL");
    $finish;
  end
endmodule
