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

    wire spike;
    wire [7:0] state;

    // All output pins must be assigned. Assign unused uio_out bits to 0.
    assign uio_out[6:0] = 0;
    assign uio_oe = 8'hFF;  // Set all bits to 1 for output enable
    
    // List all unused inputs to prevent warnings
    wire _unused = &{ena, uio_in, 1'b0};

    // Instantiate the lif neuron module and connect outputs
    lif lif1 (
        .current(ui_in),
        .weight(8'd128),      // Use a fixed weight
        .clk(clk),
        .reset_n(rst_n),
        .spike(spike),
        .state(state)         // Connect state to the output in lif
    );

    // Assign the state to `uo_out` and spike to `uio_out[7]`
    assign uo_out = state;
    assign uio_out[7] = spike;

endmodule
