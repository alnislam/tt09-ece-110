`default_nettype none

module lif (
    input wire [7:0] current,       // Input current
    input wire [7:0] weight,        // Weight input
    input wire [7:0] state_in,      // Current state input (from external storage for each neuron)
    input wire       clk,
    input wire       reset_n,
    output wire      spike,         // Spike output
    output wire [7:0] state_out     // Updated state output (to external storage)
);

    wire [7:0] weighted_input;
    wire [7:0] next_state;
    reg [7:0] threshold = 8'd200;   // Threshold for spiking
    reg [7:0] bias = 8'd200;        // Fixed bias value

    // Weighted input calculation
    assign weighted_input = current * weight;

    // Next state calculation with bias and "leaky" integration
    assign next_state = weighted_input + bias + (state_in >> 1);

    // Spike output when state exceeds threshold
    assign spike = (state_in >= threshold);

    // Output the updated state, resetting if it exceeds threshold
    assign state_out = (state_in >= threshold) ? 8'b0 : next_state;

endmodule
