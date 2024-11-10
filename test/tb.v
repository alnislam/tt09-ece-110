`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Clock and reset signals
  reg clk;
  reg rst_n;

  // Inputs and outputs for the top module
  reg [7:0] ui_in;         // Dedicated inputs
  reg [7:0] uio_in;        // IOs: Input path
  wire [7:0] uo_out;       // Dedicated outputs
  wire [7:0] uio_out;      // IOs: Output path

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

  // Instantiate tt_um_anislam module
  tt_um_anislam uut (
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .clk(clk),
    .rst_n(rst_n)
  );

endmodule
