/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_anislam (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire spike1, spike2;
    reg [7:0] state1, state2;

    // All output pins must be assigned. Assign unused uio_out bits to 0.
    assign uio_out[7:0] = 0;
    assign uio_oe = 8'h00;  // Set all bits to 0 for input enable
    
    // List all unused inputs to prevent warnings
    //wire _unused = &{ena, uio_out, 1'b0};
    wire _unused = &{ena, 1'b0};

    // Instantiate the first lif neuron module
    lif lif1 (
        .current(ui_in),          // Use ui_in as input current for the first neuron
        .weight(uio_in),          // Use uio_in as input weight for the first neuron
        .clk(clk),
        .reset_n(rst_n),
        .spike(spike1),
        .state(state1)
    );

    // Instantiate the second lif neuron module, driven by spike from lif1
    lif lif2 (
        .current({spike1, state1[7:1]}), // Use spike1 and state1 (how close to spiking) to drive current input of lif2
        .weight(8'd128),          // Use a fixed weight in the middle of the range 0-255, no other inputs available to drive this in the chip
        .clk(clk),
        .reset_n(rst_n),
        .spike(spike2),
        .state(state2)
    );

    // Assign the state of the last neuron to `uo_out` and spike to `uio_out[7]`
    assign uo_out = {spike2, spike1 , state2[7:2]}; //concatinating the most recent spike with the previous spike and how close the second neuron is to spiking
    //assign uio_out[7:0] = 8'b0;

endmodule
