`timescale 1ns/1ps

module tb_seq1011_directed;

  // DUT I/F
  logic clk;
  logic rst;
  logic din;
  logic det;

  // Instantiate DUT
  seq1011_mealy_overlap dut (
    .clk(clk),
    .rst(rst),
    .din(din),
    .det(det)
  );

  // Clock: 10 ns
  initial clk = 0;
  always #5 clk = ~clk;

  // Waveform dump (VCD; works in Questa too)
  initial begin
    $dumpfile("tb_seq1011_directed.vcd");
    $dumpvars(0, tb_seq1011_directed);
  end

  // Shift register of last 4 inputs to compute expected detection
  logic [3:0] sh4;   // window of last 4 bits
  logic       exp_det;

  // drive utility
  task automatic drive_bit(input bit b);
    din = b;
    @(posedge clk);
  endtask

  // Self-check each cycle
  always_ff @(posedge clk) begin
    if (rst) begin
      sh4     <= 4'b0;
      exp_det <= 1'b0;
    end else begin
      // next window with current din
      sh4     <= {sh4[2:0], din};
      exp_det <= ({sh4[2:0], din} == 4'b1011); // Mealy: detect same cycle
    end
  end

  // Assertions
  // 1) Correctness: det must equal expected pattern detect
  property p_det_correct;
    @(posedge clk) disable iff (rst)
      det == exp_det;
  endproperty
  assert property (p_det_correct)
    else $error("DET mismatch: det=%0b exp=%0b window=%b @%0t", det, exp_det, {sh4[2:0], din}, $time);

  // 2) No stretching: pulse must be 1 cycle max
  property p_pulse_one_cycle;
    @(posedge clk) disable iff (rst)
      det |=> !det;
  endproperty
  assert property (p_pulse_one_cycle)
    else $error("DET pulse stretched (>1 cycle) @%0t", $time);

  // Reset + directed sequences, including overlaps and edge cases
  initial begin
    rst = 1; din = 0;
    repeat (2) @(posedge clk);
    rst = 0;

    // 1) Simple hit: 1 0 1 1  -> detect once
    drive_bit(1); drive_bit(0); drive_bit(1); drive_bit(1);

    // 2) Overlap: 1 0 1 1 0 1 1 -> detect at positions 4 and 7
    drive_bit(0); drive_bit(1); drive_bit(1); // continuing from previous, first 4 already drove
    drive_bit(0); drive_bit(1); drive_bit(1);

    // 3) Leading ones: 1 1 0 1 1 -> single detect
    drive_bit(1); drive_bit(1); drive_bit(0); drive_bit(1); drive_bit(1);

    // 4) Noise zeros: 0 0 1 0 1 1 -> single detect
    drive_bit(0); drive_bit(0); drive_bit(1); drive_bit(0); drive_bit(1); drive_bit(1);

    // 5) Back-to-back sequences with minimal gap: 1 0 1 1 1 0 1 1 -> two detects
    drive_bit(1); drive_bit(0); drive_bit(1); drive_bit(1);
    drive_bit(1); drive_bit(0); drive_bit(1); drive_bit(1);

    // 6) Negative test: no detect
    drive_bit(0); drive_bit(0); drive_bit(1); drive_bit(0); drive_bit(0);

    // Drain a couple cycles
    repeat (3) @(posedge clk);

    $display("[TB] Directed tests completed @%0t", $time);
    $finish;
  end

endmodule
