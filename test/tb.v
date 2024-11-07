`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Clock and reset signals
  reg clk;
  reg rst_n;

  // Inputs to the top module
  reg [7:0] ui_in;    // Current input
  reg [7:0] weights;  // Weights input
  reg [7:0] bias;     // Bias input
  wire [7:0] uo_out;  // Combined state and spike output
  
  // Initialize clock and reset
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100 MHz clock
  end

  initial begin
    // Reset sequence
    rst_n = 0;
    #20;           // Hold reset low for 20 ns
    rst_n = 1;     // Release reset
  end

  // Dump the signals to a VCD file for viewing in GTKWave
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  // Instantiate tt_um_example
  tt_um_example uut (
    .ui_in (ui_in),
    .weights (weights),
    .bias (bias),
    .uo_out (uo_out),
    .clk (clk),
    .rst_n (rst_n)
  );

endmodule
