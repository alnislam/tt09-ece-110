# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_perceptron(dut):
    # Set up a 100 MHz clock (10 ns period)
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Log test start
    dut._log.info("Starting perceptron test")

    # Reset the DUT
    dut.rst_n.value = 0
    await Timer(20, units="ns")
    dut.rst_n.value = 1
    await Timer(20, units="ns")  # Add more time for the reset to take effect

    # Test cases
    test_cases = [
        {"ui_in": 50, "weights": 2, "bias": 200},
        {"ui_in": 80, "weights": 3, "bias": 150},
        {"ui_in": 100, "weights": 1, "bias": 50},
        {"ui_in": 120, "weights": 4, "bias": 100},
    ]

    for idx, case in enumerate(test_cases):
        # Apply inputs
        dut.ui_in.value = case["ui_in"]
        dut.weights.value = case["weights"]
        dut.bias.value = case["bias"]

        # Wait for multiple clock cycles to allow inputs to propagate
        for _ in range(5):
            await RisingEdge(dut.clk)

        # Check for unresolved bits before logging
        uo_out_val = dut.uo_out.value
        if "z" not in str(uo_out_val) and "x" not in str(uo_out_val):
            # Log the outputs
            spike_val = dut.spike_out.value
            dut._log.info(
                f"Test case {idx + 1}: "
                f"ui_in={case['ui_in']}, weights={case['weights']}, bias={case['bias']} -> "
                f"uo_out={uo_out_val}, spike={spike_val}"
            )
        else:
            dut._log.warning(f"Test case {idx + 1}: uo_out has unresolved bits, skipping output.")

    # Final log for test completion
    dut._log.info("Completed perceptron test cases")
