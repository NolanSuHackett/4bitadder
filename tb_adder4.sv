`timescale 1ns/1ps

module tb_adder4 ();

  // DUT interface signals
  logic        clk;
  logic [3:0]  a, b;
  logic [4:0]  sum;

  // Instantiate DUT (ensure your DUT module is really named 'adder4')
  adder4 uut (
    .clk(clk),
    .a  (a),
    .b  (b),
    .sum(sum)
  );

  // 10 ns Clock Period
  initial clk = 0;
  always  #5 clk = ~clk;

  // Wave dump
  initial begin
    $dumpfile("tb_adder4.vcd");
    $dumpvars(0, tb_adder4);
  end

  // Counters (use 'integer' for broad tool compatibility)
  integer test_cnt = 0;
  integer pass_cnt = 0;
  integer fail_cnt = 0;

  // Drive before edge; check on posedge (registered DUT)
  // NOTE: avoid 'logic' in task ports for Icarus compatibility
  task automatic do_check(input [3:0] aa, input [3:0] bb);
    logic [4:0] exp;           // no 'automatic' on local var — not needed
    @(negedge clk);            // drive on safe phase
    a = aa;
    b = bb;
    exp = aa + bb;

    @(posedge clk);            // sample on registered output edge
    test_cnt = test_cnt + 1;
    if (sum === exp) begin
      pass_cnt = pass_cnt + 1;
      $display("RESULT,PASS,%0d,%0d,%0d,%0d", a, b, sum, exp);
    end
    else begin
      fail_cnt = fail_cnt + 1;
      $display("RESULT,FAIL,%0d,%0d,%0d,%0d", a, b, sum, exp);
    end
  endtask

  // === Test Sequence ===
  initial begin
    a = '0;
    b = '0;

    // Directed vectors
    do_check(4'd0,  4'd0);
    do_check(4'd3,  4'd5);
    do_check(4'd15, 4'd1);
    do_check(4'd8,  4'd7);

    // Randomized smoke (use modulo for wide compatibility)
    repeat (20) do_check($urandom % 16, $urandom % 16);

    // Summary for CI/Jenkins
    $display("SUMMARY,TESTS,%0d,PASS,%0d,FAIL,%0d", test_cnt, pass_cnt, fail_cnt);

    if (fail_cnt != 0) $fatal(1, "Testbench reported %0d failures", fail_cnt);

    $finish;
  end

endmodule
