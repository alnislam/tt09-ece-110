/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_anislam (
    input  wire [7:0] ui_in,    // Dedicated inputs (current)
    input  wire [7:0] weights,  // Weight input
    input  wire [7:0] bias,     // Bias input
    output wire [7:0] uo_out,   // Dedicated outputs (state and spike)
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire spike;
    wire [7:0] state;

    // Instantiate the lif module and connect outputs
    lif lif1 (
        .current(ui_in),
        .weight(weights),
        .clk(clk),
        .reset_n(rst_n),
        .spike(spike)           // Spike output
    );

    // Assign the spike to uo_out[0] and optionally state to other bits
    assign uo_out = {state[7:1], spike};  // Place spike in the lowest bit, state in higher bits

endmodule
