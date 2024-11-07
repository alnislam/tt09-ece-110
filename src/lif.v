`default_nettype none

module lif (
    input wire [7:0]    current,   // Input current
    input wire [7:0]    weight,    // Weight input
   // input wire [7:0]    bias,      // Bias input
    input wire          clk,
    input wire          reset_n,
   // output reg [7:0]    state,     // State of neuron
    output wire         spike      // Spike output
);

    wire [7:0] weighted_input;
    wire [7:0] next_state;
    reg [7:0] state; 
    reg [7:0] threshold = 8'd200;  // Threshold for spiking
    reg [7:0] bias = 8'd200; //fixed bias value

    // Weighted input calculation
    assign weighted_input = current * weight;

    // Next state calculation with bias and "leaky" integration
    assign next_state = weighted_input + bias + (state >> 1);

    // State and spike update on clock edge
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= 0;
        end else begin
            state <= next_state;
        end
    end

    // Spike output when state exceeds threshold
    assign spike = (state >= threshold);

endmodule